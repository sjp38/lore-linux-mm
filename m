Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2536B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 10:10:17 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i186so13665qka.15
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 07:10:17 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l23si81261qtc.185.2017.10.13.07.10.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 07:10:15 -0700 (PDT)
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v9DEAElF019883
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 14:10:14 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v9DEAB6I000828
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 14:10:11 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v9DEAB6N018047
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 14:10:11 GMT
Received: by mail-oi0-f41.google.com with SMTP id g125so14464639oib.12
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 07:10:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOAebxtrSthSP4NAa0obBbsCK1KZxO+x0w5xNrpY6m2y9UZFvQ@mail.gmail.com>
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
 <20171009221931.1481-8-pasha.tatashin@oracle.com> <20171010155619.GA2517@arm.com>
 <CAOAebxv21+KtXPAk-xWz=+2fqWQDgp9SAFZz-N=XsuBxev=zcg@mail.gmail.com>
 <20171010171047.GC2517@arm.com> <CAOAebxtrSthSP4NAa0obBbsCK1KZxO+x0w5xNrpY6m2y9UZFvQ@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 13 Oct 2017 10:10:09 -0400
Message-ID: <CAOAebxu5WL-FQLgfCxNcWy36V6zsTO1v3LLqXv5rM1Pp9R-=YA@mail.gmail.com>
Subject: Re: [PATCH v11 7/9] arm64/kasan: add and use kasan_map_populate()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, Michal Hocko <mhocko@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Will,

I have a couple concerns about your patch:

One of the reasons (and actually, the main reason) why I preferred to
keep vmemmap_populate() instead of implementing kasan's own variant,
which btw can be done in common code similarly to
vmemmap_populate_basepages() is that vmemmap_populate() uses large
pages when available. I think it is a considerable downgrade to go
back to base pages, when we already have large page support available
to us.

The kasan shadow tree is large, it is up-to 1/8th of system memory, so
even on moderate size servers, shadow tree is going to be multiple
gigabytes.

The second concern is that there is an existing bug associated with
your patch that I am not sure how to solve:

Try building your patch with CONFIG_DEBUG_VM. This config makes
memblock_virt_alloc_try_nid_raw() to do memset(0xff) on all allocated
memory.

I am getting the following panic during boot:

[    0.012637] pid_max: default: 32768 minimum: 301
[    0.016037] Security Framework initialized
[    0.018389] Dentry cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.019559] Inode-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.020409] Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
[    0.020721] Mountpoint-cache hash table entries: 512 (order: 0, 4096 bytes)
[    0.055337] Unable to handle kernel paging request at virtual
address ffff0400010065af
[    0.055422] Mem abort info:
[    0.055518]   Exception class = DABT (current EL), IL = 32 bits
[    0.055579]   SET = 0, FnV = 0
[    0.055640]   EA = 0, S1PTW = 0
[    0.055699] Data abort info:
[    0.055762]   ISV = 0, ISS = 0x00000007
[    0.055822]   CM = 0, WnR = 0
[    0.055966] swapper pgtable: 4k pages, 48-bit VAs, pgd = ffff20000a8f4000
[    0.056047] [ffff0400010065af] *pgd=0000000046fe7003,
*pud=0000000046fe6003, *pmd=0000000046fe5003, *pte=0000000000000000
[    0.056436] Internal error: Oops: 96000007 [#1] PREEMPT SMP
[    0.056701] Modules linked in:
[    0.056939] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
4.14.0-rc4_pt_memset12-00096-gfca5985f860e-dirty #16
[    0.057001] Hardware name: linux,dummy-virt (DT)
[    0.057084] task: ffff2000099d9000 task.stack: ffff2000099c0000
[    0.057275] PC is at __asan_load8+0x34/0xb0
[    0.057375] LR is at __d_rehash+0xf0/0x240
[    0.057460] pc : [<ffff200008317d7c>] lr : [<ffff20000837e168>]
pstate: 60000045
[    0.057522] sp : ffff2000099c6a60
[    0.057590] x29: ffff2000099c6a60 x28: ffff2000099d9010
[    0.057733] x27: 0000000000000004 x26: ffff200008031000
[    0.057846] x25: ffff2000099d9000 x24: ffff800003c06410
---Type <return> to continue, or q <return> to quit---
[    0.057954] x23: 00000000000003af x22: ffff800003c06400
[    0.058065] x21: 1fffe40001338d5a x20: ffff200008032d78
[    0.058175] x19: ffff800003c06408 x18: 0000000000000000
[    0.058311] x17: 0000000000000009 x16: 0000000000007fff
[    0.058417] x15: 000000000000002a x14: ffff2000080ef374
[    0.058528] x13: ffff200008126648 x12: ffff200008411a7c
[    0.058638] x11: ffff200008392358 x10: ffff200008392184
[    0.058770] x9 : ffff20000835aad8 x8 : ffff200009850e90
[    0.058883] x7 : ffff20000904b23c x6 : 00000000f2f2f200
[    0.058990] x5 : 0000000000000000 x4 : ffff200008032d78
[    0.059097] x3 : 0000000000000000 x2 : dfff200000000000
[    0.059206] x1 : 0000000000000007 x0 : 1fffe400010065af
[    0.059372] Process swapper/0 (pid: 0, stack limit = 0xffff2000099c0000)
[    0.059442] Call trace:
[    0.059603] Exception stack(0xffff2000099c6920 to 0xffff2000099c6a60)
[    0.059771] 6920: 1fffe400010065af 0000000000000007
dfff200000000000 0000000000000000
[    0.059877] 6940: ffff200008032d78 0000000000000000
00000000f2f2f200 ffff20000904b23c
[    0.059973] 6960: ffff200009850e90 ffff20000835aad8
ffff200008392184 ffff200008392358
[    0.060066] 6980: ffff200008411a7c ffff200008126648
ffff2000080ef374 000000000000002a
[    0.060154] 69a0: 0000000000007fff 0000000000000009
0000000000000000 ffff800003c06408
[    0.060246] 69c0: ffff200008032d78 1fffe40001338d5a
ffff800003c06400 00000000000003af
[    0.060338] 69e0: ffff800003c06410 ffff2000099d9000
ffff200008031000 0000000000000004
[    0.060432] 6a00: ffff2000099d9010 ffff2000099c6a60
ffff20000837e168 ffff2000099c6a60
[    0.060525] 6a20: ffff200008317d7c 0000000060000045
ffff200008392358 ffff200008411a7c
[    0.060620] 6a40: ffffffffffffffff ffff2000080ef374
ffff2000099c6a60 ffff200008317d7c
[    0.060762] [<ffff200008317d7c>] __asan_load8+0x34/0xb0
[    0.060856] [<ffff20000837e168>] __d_rehash+0xf0/0x240
[    0.060944] [<ffff20000837fb80>] d_add+0x288/0x3f0
[    0.061041] [<ffff200008420db8>] proc_setup_self+0x110/0x198
[    0.061139] [<ffff200008411594>] proc_fill_super+0x13c/0x198
[    0.061234] [<ffff200008359648>] mount_ns+0x98/0x148
[    0.061328] [<ffff2000084116ac>] proc_mount+0x5c/0x70
[    0.061422] [<ffff20000835aad8>] mount_fs+0x50/0x1a8
[    0.061515] [<ffff200008392184>] vfs_kern_mount.part.7+0x9c/0x218
[    0.061602] [<ffff200008392358>] kern_mount_data+0x38/0x70
[    0.061699] [<ffff200008411a7c>] pid_ns_prepare_proc+0x24/0x50
[    0.061796] [<ffff200008126648>] alloc_pid+0x6e8/0x730
[    0.061891] [<ffff2000080ef374>] copy_process.isra.6.part.7+0x11cc/0x2cb8
[    0.061978] [<ffff2000080f1104>] _do_fork+0x14c/0x4c0
[    0.062065] [<ffff2000080f14c0>] kernel_thread+0x30/0x38
[    0.062156] [<ffff20000904b23c>] rest_init+0x34/0x108
[    0.062260] [<ffff200009850e90>] start_kernel+0x45c/0x48c
[    0.062458] Code: 540001e1 d343fc00 d2c40002 f2fbffe2 (38e26800)
[    0.063559] ---[ end trace 390c5d4fc6641888 ]---
[    0.064164] Kernel panic - not syncing: Attempted to kill the idle task!
[    0.064438] ---[ end Kernel panic - not syncing: Attempted to kill
the idle task!


So, I've been trying to root cause it, and here is what I've got:

First, I went back to my version of kasan_map_populate() and replaced
vmemmap_populate() with vmemmap_populate_basepages(), which
behavior-vise made it very similar to your patch. After doing this I
got the same panic. So, I figured there must be something to do with
the differences that regular vmemmap allocated with granularity of
SWAPPER_BLOCK_SIZE while kasan with granularity of PAGE_SIZE.

So, I made the following modification to your patch:

static void __init kasan_map_populate(unsigned long start, unsigned long end,
                                      int node)
{
+        start = round_down(start, SWAPPER_BLOCK_SIZE);
+       end = round_up(end, SWAPPER_BLOCK_SIZE);
        kasan_pgd_populate(start & PAGE_MASK, PAGE_ALIGN(end), node, false);
}

This is basically makes shadow tree ranges to be SWAPPER_BLOCK_SIZE
aligned. After, this modification everything is working.  However, I
am not sure if this is a proper fix.

I feel, this patch requires more work, and I am troubled with using
base pages instead of large pages.

Thank you,
Pavel

On Tue, Oct 10, 2017 at 1:41 PM, Pavel Tatashin
<pasha.tatashin@oracle.com> wrote:
> Hi Will,
>
> Ok, I will add your patch at the end of my series.
>
> Thank you,
> Pavel
>
>>
>> I was thinking that you could just add my patch to the end of your series
>> and have the whole lot go up like that. If you want to merge it with your
>> patch, I'm fine with that too.
>>
>> Will
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
