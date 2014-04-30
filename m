Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f48.google.com (mail-oa0-f48.google.com [209.85.219.48])
	by kanga.kvack.org (Postfix) with ESMTP id A2D4B6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 06:02:40 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id i4so959251oah.21
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 03:02:40 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id ij7si18692567obc.198.2014.04.30.03.02.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 03:02:39 -0700 (PDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C5F963EE1C1
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 19:02:36 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B3EA645DF5A
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 19:02:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 958C745DF14
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 19:02:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 73BD91DB8045
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 19:02:36 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C48A01DB804C
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 19:02:34 +0900 (JST)
Message-ID: <5360C9E7.6010701@jp.fujitsu.com>
Date: Wed, 30 Apr 2014 19:01:11 +0900
From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,writeback: fix divide by zero in pos_ratio_polynom
References: <20140429151910.53f740ef@annuminas.surriel.com>
In-Reply-To: <20140429151910.53f740ef@annuminas.surriel.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, akpm@linux-foundation.org, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, mhocko@suse.cz, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

Hi Rik,

I applied your patch to linux-next kernel, then divide error happened
when I ran ltp stress test.
The divide error occurred on the following div_u64(), so the following
should be also fixed...

static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
                                         unsigned long thresh,
                                         unsigned long bg_thresh,
                                         unsigned long dirty,
                                         unsigned long bdi_thresh,
                                         unsigned long bdi_dirty)
{
...
         if (bdi_dirty < x_intercept - span / 4) {
                 pos_ratio = div_u64(pos_ratio * (x_intercept - bdi_dirty),
                                     x_intercept - bdi_setpoint + 1);

The result of disassemble is as follows.

0xffffffff8116f520 <bdi_position_ratio+0xf0>:	mov    %rsi,%rax
0xffffffff8116f523 <bdi_position_ratio+0xf3>:	sub    %ebx,%esi
0xffffffff8116f525 <bdi_position_ratio+0xf5>:	xor    %edx,%edx
0xffffffff8116f527 <bdi_position_ratio+0xf7>:	sub    %r13,%rax
0xffffffff8116f52a <bdi_position_ratio+0xfa>:	add    $0x1,%esi
0xffffffff8116f52d <bdi_position_ratio+0xfd>:	imul   %r11,%rax
0xffffffff8116f531 <bdi_position_ratio+0x101>:	div    %rsi <= divide error!

The panic log is as follows.
---
[ 4102.894894] divide error: 0000 [#1] SMP
[ 4102.899344] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle tun bridge stp llc ip6table_filter ip6_tables iptable_filter ip_tables ebtable_nat ebtables cfg80211 rfkill btrfs raid456 async_raid6_recov async_memcpy async_pq async_xor async_tx coretemp kvm_intel kvm dm_mod raid6_pq i7core_edac edac_core iTCO_wdt iTCO_vendor_support xor lpc_ich i2c_i801 mfd_core serio_raw pcspkr acpi_power_meter crc32c_intel shpchp ipmi_si tpm_infineon ipmi_msghandler acpi_cpufreq nfsd auth_rpcgss nfs_acl lockd sunrpc uinput xfs libcrc32c sd_mod crc_t10dif crct10dif_common sr_mod cdrom mgag200 syscopyarea sysfillrect sysimgblt i2c_algo_bit drm_kms_helper ttm drm e1000e ahci mptsas libahci scsi_transport_sas libata mptscsih ptp mptbase i2c_core pps_core
[ 4102.984462] CPU: 7 PID: 19758 Comm: mmap-corruption Not tainted 3.15.0-rc3-next-20140429+ #1
[ 4102.993984] Hardware name: FUJITSU                          PRIMERGY TX150 S7             /D2759, BIOS 6.00 Rev. 1.16.2759.A1           06/22/2010
[ 4103.008759] task: ffff88003680ed00 ti: ffff88000db62000 task.ti: ffff88000db62000
[ 4103.017179] RIP: 0010:[<ffffffff8116f531>]  [<ffffffff8116f531>] bdi_position_ratio.isra.12+0x101/0x1d0
[ 4103.027772] RSP: 0000:ffff88000db63be8  EFLAGS: 00010256
[ 4103.033775] RAX: 04790000004f17b7 RBX: 00000000000026f0 RCX: 00003fffffffffff
[ 4103.041807] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
[ 4103.049834] RBP: ffff88000db63c00 R08: 0000000000001623 R09: 000000000000063f
[ 4103.057897] R10: 000000000000065e R11: 0000000000000479 R12: 000000000000065f
[ 4103.065959] R13: 0000000000001540 R14: ffffea0000e4af30 R15: 0000000000000001
[ 4103.073992] FS:  00007f869a3e8740(0000) GS:ffff88003f5c0000(0000) knlGS:0000000000000000
[ 4103.083093] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 4103.089558] CR2: 00007f8694bc6000 CR3: 0000000037332000 CR4: 00000000000007e0
[ 4103.097595] Stack:
[ 4103.099859]  0000000000001540 0000000000000000 ffff8800347e3570 ffff88000db63d18
[ 4103.108240]  ffffffff8162f858 0000000000001540 ffffffff8120cbc1 ffff88000db63c48
[ 4103.116614]  ffffffff8120c318 ffffea00003b7dc0 0000000000001000 0000000000000000
[ 4103.124984] Call Trace:
[ 4103.127740]  [<ffffffff8162f858>] balance_dirty_pages.isra.21+0x278/0x5f1
[ 4103.135378]  [<ffffffff8120cbc1>] ? __block_commit_write.isra.21+0x81/0xb0
[ 4103.143115]  [<ffffffff8120c318>] ? __set_page_dirty_buffers+0x88/0xb0
[ 4103.150461]  [<ffffffff8120fa43>] ? block_page_mkwrite+0x63/0xb0
[ 4103.157222]  [<ffffffff81170c97>] balance_dirty_pages_ratelimited+0xe7/0x110
[ 4103.165154]  [<ffffffff8119149c>] do_shared_fault+0x15c/0x230
[ 4103.171619]  [<ffffffff81192406>] handle_mm_fault+0x2d6/0x1080
[ 4103.178184]  [<ffffffff810a0666>] ? ftrace_raw_event_sched_stat_runtime+0x86/0xc0
[ 4103.188806]  [<ffffffff8105dff6>] __do_page_fault+0x1b6/0x550
[ 4103.197479]  [<ffffffff81142b2a>] ? ftrace_event_buffer_commit+0x8a/0xc0
[ 4103.207216]  [<ffffffff810a0c63>] ? ftrace_raw_event_sched_switch+0xb3/0xf0
[ 4103.217240]  [<ffffffff81012625>] ? __switch_to+0x165/0x590
[ 4103.225710]  [<ffffffff8105e3c1>] do_page_fault+0x31/0x70
[ 4103.233948]  [<ffffffff8163dec8>] page_fault+0x28/0x30
[ 4103.241856] Code: 48 c1 e9 12 48 c1 eb 10 48 c1 ee 10 48 01 de 48 89 f2 48 29 ca 49 39 d5 73 14 48 89 f0 29 de 31 d2 4c 29 e8 83 c6 01 49 0f af c3 <48> f7 f6 4c 89 e2 48 d1 ea 49 39 d5 73 15 49 c1 ec 04 4d 39 e5
[ 4103.268205] RIP  [<ffffffff8116f531>] bdi_position_ratio.isra.12+0x101/0x1d0
[ 4103.278446]  RSP <ffff88000db63be8>
---

Thanks,
Masayoshi Mizuma

On Tue, 29 Apr 2014 15:19:10 -0400 Rik van Riel wrote:
> It is possible for "limit - setpoint + 1" to equal zero, leading to a
> divide by zero error. Blindly adding 1 to "limit - setpoint" is not
> working, so we need to actually test the divisor before calling div64.
>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Cc: stable@vger.kernel.org
> ---
>   mm/page-writeback.c | 7 ++++++-
>   1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index ef41349..2682516 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -597,11 +597,16 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
>   					  unsigned long dirty,
>   					  unsigned long limit)
>   {
> +	unsigned int divisor;
>   	long long pos_ratio;
>   	long x;
>
> +	divisor = limit - setpoint;
> +	if (!divisor)
> +		divisor = 1;
> +
>   	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
> -		    limit - setpoint + 1);
> +		    divisor);
>   	pos_ratio = x;
>   	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
>   	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
