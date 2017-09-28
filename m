Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0416B025F
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 10:37:53 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f51so2493941wrf.3
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 07:37:53 -0700 (PDT)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id w18si1571986wra.552.2017.09.28.07.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 07:37:51 -0700 (PDT)
Message-ID: <59CD093A.6030201@iogearbox.net>
Date: Thu, 28 Sep 2017 16:37:46 +0200
From: Daniel Borkmann <daniel@iogearbox.net>
MIME-Version: 1.0
Subject: Re: EBPF-triggered WARNING at mm/percpu.c:1361 in v4-14-rc2
References: <20170928112727.GA11310@leverpostej>
In-Reply-To: <20170928112727.GA11310@leverpostej>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, syzkaller@googlegroups.com
Cc: "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>

On 09/28/2017 01:27 PM, Mark Rutland wrote:
> Hi,
>
> While fuzzing v4.14-rc2 with Syzkaller, I found it was possible to trigger the
> warning at mm/percpu.c:1361, on both arm64 and x86_64. This appears to require
> increasing RLIMIT_MEMLOCK, so to the best of my knowledge this cannot be
> triggered by an unprivileged user.
>
> I've included example splats for both x86_64 and arm64, along with a C
> reproducer, inline below.
>
> It looks like dev_map_alloc() requests a percpu alloction of 32776 bytes, which
> is larger than the maximum supported allocation size of 32768 bytes.
>
> I wonder if it would make more sense to pr_warn() for sizes that are too
> large, so that callers don't have to roll their own checks against
> PCPU_MIN_UNIT_SIZE?

Perhaps the pr_warn() should be ratelimited; or could there be an
option where we only return NULL, not triggering a warn at all (which
would likely be what callers might do anyway when checking against
PCPU_MIN_UNIT_SIZE and then bailing out)?

> e.g. something like:
>
> ----
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 59d44d6..f731c45 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -1355,8 +1355,13 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
>          bits = size >> PCPU_MIN_ALLOC_SHIFT;
>          bit_align = align >> PCPU_MIN_ALLOC_SHIFT;
>
> -       if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE ||
> -                    !is_power_of_2(align))) {
> +       if (unlikely(size > PCPU_MIN_UNIT_SIZE)) {
> +               pr_warn("cannot allocate pcpu chunk of size %zu (max %zu)\n",
> +                       size, PCPU_MIN_UNIT_SIZE);
> +               return NULL;
> +       }
> +
> +       if (unlikely(!size || align > PAGE_SIZE || !is_power_of_2(align))) {
>                  WARN(true, "illegal size (%zu) or align (%zu) for percpu allocation\n",
>                       size, align);
>                  return NULL;
> ----
>
> Thanks,
> Mark.
>
>
>
> Example splat(x86_64)
> ----
> [  138.144185] illegal size (32776) or align (8) for percpu allocation
> [  138.150452] ------------[ cut here ]------------
> [  138.155074] WARNING: CPU: 1 PID: 2223 at mm/percpu.c:1361 pcpu_alloc+0x7c/0x5f0
> [  138.162369] Modules linked in:
> [  138.165423] CPU: 1 PID: 2223 Comm: repro Not tainted 4.14.0-rc2 #3
> [  138.171593] Hardware name: LENOVO 7484A3G/LENOVO, BIOS 5CKT54AUS 09/07/2009
> [  138.178543] task: ffff881b73069980 task.stack: ffffa36f40f90000
> [  138.184455] RIP: 0010:pcpu_alloc+0x7c/0x5f0
> [  138.188633] RSP: 0018:ffffa36f40f93e00 EFLAGS: 00010286
> [  138.193853] RAX: 0000000000000037 RBX: 0000000000000000 RCX: 0000000000000000
> [  138.200974] RDX: ffff881b7ec94a40 RSI: ffff881b7ec8cbb8 RDI: ffff881b7ec8cbb8
> [  138.208097] RBP: ffffa36f40f93e68 R08: 0000000000000001 R09: 00000000000002c4
> [  138.215219] R10: 0000562a577047f0 R11: ffffffffa10ad7cd R12: ffff881b73216cc0
> [  138.222343] R13: 0000000000000014 R14: 00007ffebeed0900 R15: ffffffffffffffea
> [  138.229463] FS:  00007fef84a15700(0000) GS:ffff881b7ec80000(0000) knlGS:0000000000000000
> [  138.237538] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  138.243274] CR2: 00007fef84497ba0 CR3: 00000001b3235000 CR4: 00000000000406e0
> [  138.250397] Call Trace:
> [  138.252844]  __alloc_percpu+0x10/0x20
> [  138.256508]  dev_map_alloc+0x122/0x1b0
> [  138.260255]  SyS_bpf+0x8f9/0x10b0
> [  138.263570]  ? security_task_setrlimit+0x3e/0x60
> [  138.268184]  ? do_prlimit+0xa6/0x1f0
> [  138.271760]  entry_SYSCALL_64_fastpath+0x13/0x94
> [  138.276372] RIP: 0033:0x7fef84546259
> [  138.279946] RSP: 002b:00007ffebeed09b8 EFLAGS: 00000206 ORIG_RAX: 0000000000000141
> [  138.287503] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007fef84546259
> [  138.294627] RDX: 0000000000000014 RSI: 00007ffebeed09d0 RDI: 0000000000000000
> [  138.301749] RBP: 0000562a57704780 R08: 00007fef84810cb0 R09: 00007ffebeed0ae8
> [  138.308874] R10: 0000562a577047f0 R11: 0000000000000206 R12: 0000562a577045d0
> [  138.315997] R13: 00007ffebeed0ae0 R14: 0000000000000000 R15: 0000000000000000
> [  138.323122] Code: fe 00 10 00 00 77 10 48 8b 4d b8 48 89 c8 48 83 e8 01 48 85 c1 74 1e 48 8b 55 b8 48 8b 75 c0 48 c7 c7 90 5e be a0 e8 40 88 f3 ff <0f> ff 45 31 ed e9 5e 02 00 00 4c 8b 6d c0 49 89 cc 49 c1 ec 02
> [  138.341953] ---[ end trace b6e380365bfb8a36 ]---
> ----
>
>
>
> Example splat (arm64)
> ----
> [   17.287365] illegal size (32776) or align (8) for percpu allocation
> [   17.295347] ------------[ cut here ]------------
> [   17.297191] WARNING: CPU: 1 PID: 1440 at mm/percpu.c:1361 pcpu_alloc+0x120/0x9f0
> [   17.307723] Kernel panic - not syncing: panic_on_warn set ...
> [   17.307723]
> [   17.311755] CPU: 1 PID: 1440 Comm: repro Not tainted 4.14.0-rc2-00001-gd7ad33d #115
> [   17.320675] Hardware name: linux,dummy-virt (DT)
> [   17.323858] Call trace:
> [   17.325246] [<ffff200008094e98>] dump_backtrace+0x0/0x558
> [   17.332538] [<ffff200008095410>] show_stack+0x20/0x30
> [   17.340391] [<ffff20000a312628>] dump_stack+0x128/0x1a0
> [   17.342081] [<ffff20000815e330>] panic+0x250/0x518
> [   17.344096] [<ffff20000815e074>] __warn+0x2a4/0x310
> [   17.345654] [<ffff20000a310984>] report_bug+0x1d4/0x290
> [   17.348652] [<ffff2000080957c8>] bug_handler.part.1+0x40/0xf8
> [   17.356873] [<ffff2000080958cc>] bug_handler+0x4c/0x88
> [   17.360543] [<ffff20000808640c>] brk_handler+0x1c4/0x360
> [   17.365076] [<ffff200008081b68>] do_debug_exception+0x118/0x398
> [   17.368297] Exception stack(0xffff80001c82b930 to 0xffff80001c82ba70)
> [   17.372981] b920:                                   0000000000000037 0000000000000000
> [   17.380137] b940: bec1e481d6136f00 dfff200000000000 1fffe40001cbd30c dfff200000000000
> [   17.384902] b960: dfff200000000000 0000000000000000 ffff80001ce6c050 1ffff000039cd809
> [   17.392527] b980: ffff80001ce6c048 ffff80001ce6c068 1ffff000039cd80c 1ffff000039cd80e
> [   17.396935] b9a0: 1ffff000039cd80d ffff20000e1485a0 0000000000000000 0000000000000000
> [   17.404665] b9c0: ffff20000da58140 0000000000000000 00000000014000c0 0000000000000008
> [   17.407064] b9e0: 0000000000000004 000000000000800b 1ffff000039057b9 ffff80001c82bdcc
> [   17.415067] ba00: 0000000000000000 1ffff000039c0b14 1ffff000039c0b12 ffff80001c82ba70
> [   17.419137] ba20: ffff20000850c880 ffff80001c82ba70 ffff20000850c880 0000000080000145
> [   17.426052] ba40: 0000000000000008 ffff20000ae60b88 0001000000000000 00000000f4f4f404
> [   17.437346] ba60: ffff80001c82ba70 ffff20000850c880
> [   17.445759] [<ffff200008083ef0>] el1_dbg+0x18/0x74
> [   17.448272] [<ffff20000850c880>] pcpu_alloc+0x120/0x9f0
> [   17.456523] [<ffff20000850d1c8>] __alloc_percpu+0x30/0x40
> [   17.458412] [<ffff200008425d2c>] dev_map_alloc+0x58c/0x8d8
> [   17.462917] [<ffff2000083f0634>] SyS_bpf+0x86c/0x2d58
> [   17.468126] Exception stack(0xffff80001c82bec0 to 0xffff80001c82c000)
> [   17.470108] bec0: 0000000000000000 0000ffffe78f4898 0000000000000014 0000000000000000
> [   17.474655] bee0: 0000000000000000 0000ffffe78f49f0 0000001000000000 0000001000000000
> [   17.482196] bf00: 0000000000000118 0003ffffffffffff 0101010101010101 0000001000000000
> [   17.486928] bf20: 0000ffffb6468030 0000000000000000 0000ffffb6468028 000000000000071c
> [   17.498389] bf40: 0000ffffb63b8a00 0000aaaaba991028 0000000000000000 0000aaaaba9808f0
> [   17.502871] bf60: 0000000000000000 0000aaaaba980730 0000000000000000 0000000000000000
> [   17.505879] bf80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [   17.514090] bfa0: 0000000000000000 0000ffffe78f4870 0000aaaaba9808e0 0000ffffe78f4870
> [   17.520813] bfc0: 0000ffffb63b8a24 0000000080000000 0000000000000000 0000000000000118
> [   17.523888] bfe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [   17.532537] [<ffff2000080846f0>] el0_svc_naked+0x24/0x28
> [   17.540427] SMP: stopping secondary CPUs
> [   17.566662] Kernel Offset: disabled
> [   17.567498] CPU features: 0x002082
> [   17.568238] Memory Limit: none
> [   17.568958] Rebooting in 86400 seconds..
> ----
>
>
>
> C reproducer
> ----
> #include <stdint.h>
> #include <sys/resource.h>
> #include <sys/syscall.h>
> #include <unistd.h>
>
> #include <linux/bpf.h>
>
> /*
>   * Debian Stretch's headers are too old to contain a number of interesting
>   * values, so manually define them to keep things legible...
>   */
> struct LOCALDEF_bpf_attr {
> 	uint32_t	map_type;
> 	uint32_t	key_size;
> 	uint32_t	value_size;
> 	uint32_t	max_entries;
> 	uint32_t	map_flags;
> };
>
> #define LOCALDEF_BPF_MAP_TYPE_DEVMAP 0xe
>
> int main(int argc, char *argv[])
> {
> 	struct rlimit rlimit = {
> 		.rlim_cur = 8 << 20,
> 		.rlim_max = 8 << 20,
> 	};
> 	
> 	setrlimit(RLIMIT_MEMLOCK, &rlimit);
>
> 	struct LOCALDEF_bpf_attr attr = {
> 		.map_type = LOCALDEF_BPF_MAP_TYPE_DEVMAP,
> 		.key_size = 4,
> 		.value_size = 4,
> 		.max_entries = 0x40001,
> 		.map_flags = 0,
> 	};
>
> 	syscall(__NR_bpf, BPF_MAP_CREATE, &attr, sizeof(attr));
>
> 	return 0;
> }
> ----
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
