Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DE8D66B0055
	for <linux-mm@kvack.org>; Sat, 20 Jun 2009 11:43:38 -0400 (EDT)
Received: by bwz21 with SMTP id 21so2934556bwz.38
        for <linux-mm@kvack.org>; Sat, 20 Jun 2009 08:44:59 -0700 (PDT)
Subject: Re: BUG: Bad page state [was: Strange oopses in 2.6.30]
From: Maxim Levitsky <maximlevitsky@gmail.com>
In-Reply-To: <4A3CFFEC.1000805@gmail.com>
References: <1245448091.5475.19.camel@localhost>
	 <1245506908.6327.36.camel@localhost>  <4A3CFFEC.1000805@gmail.com>
Content-Type: text/plain
Date: Sat, 20 Jun 2009 18:44:56 +0300
Message-Id: <1245512696.15474.11.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2009-06-20 at 17:27 +0200, Jiri Slaby wrote:
> On 06/20/2009 04:08 PM, Maxim Levitsky wrote:
> > On Sat, 2009-06-20 at 00:48 +0300, Maxim Levitsky wrote:
> >> I see lots of following oopses in 2.6.30 and latest -git 
> >>
> >> Many different applications shows up, not just reiserfsck
> >> Something in MM I guess, it makes me worry. But system seems to work.
> >>
> >> Is this known?
> >>
> >> dmesg attached.
> >>
> >>
> >> [   34.544040] BUG: Bad page state in process reiserfsck  pfn:37d86
> >> [   34.544044] page:c2a34f38 flags:3650000c count:0 mapcount:0
> >> mapping:(null) index:bffeb
> >> [   34.544048] Pid: 2654, comm: reiserfsck Tainted: G    B
> >> 2.6.30-git #4
> >> [   34.544051] Call Trace:
> >> [   34.544055]  [<c04cd26a>] ? printk+0x18/0x1e
> >> [   34.544059]  [<c018f065>] bad_page+0xd5/0x140
> >> [   34.544064]  [<c0190097>] free_hot_cold_page+0x1e7/0x280
> >> [   34.544069]  [<c0193682>] ? release_pages+0x92/0x1b0
> >> [   34.544074]  [<c0190155>] __pagevec_free+0x25/0x30
> >> [   34.544078]  [<c0193758>] release_pages+0x168/0x1b0
> >> [   34.544084]  [<c0193cf3>] ? lru_add_drain+0x53/0xd0
> >> [   34.544088]  [<c01ab7d4>] free_pages_and_swap_cache+0x84/0xa0
> >> [   34.544093]  [<c019ff5d>] unmap_vmas+0x73d/0x760
> >> [   34.544099]  [<c016480e>] ? lock_release_non_nested+0x15e/0x270
> >> [   34.544104]  [<c01a43b5>] exit_mmap+0xb5/0x1b0
> >> [   34.544109]  [<c0138666>] mmput+0x36/0xc0
> >> [   34.544113]  [<c013c874>] exit_mm+0xe4/0x120
> >> [   34.544117]  [<c0175539>] ? acct_collect+0x139/0x180
> >> [   34.544122]  [<c013e889>] do_exit+0x6b9/0x720
> >> [   34.544142]  [<c01bcac2>] ? vfs_write+0x122/0x180
> >> [   34.544146]  [<c01bbda0>] ? do_sync_write+0x0/0x110
> >> [   34.544151]  [<c013e920>] do_group_exit+0x30/0x90
> >> [   34.544156]  [<c013e993>] sys_exit_group+0x13/0x20
> >> [   34.544161]  [<c01039e8>] sysenter_do_call+0x12/0x3c
> >> [   34.544180] BUG: Bad page state in process reiserfsck  pfn:37d91
> >> [   34.544184] page:c2a35174 flags:3650000c count:0 mapcount:0
> >> mapping:(null) index:bfff6
> >> [   34.544188] Pid: 2654, comm: reiserfsck Tainted: G    B
> >> 2.6.30-git #4
> 
> I got similar on 64-bit mmotm 2009-06-12-12-20. You seem not to use
> 2.6.30, but some git post 2.6.30.
Yes, yesterday git 
I tried 2.6.30 too, but it gives same warnings.



> 
> Flags are:
> 0000000000400000 -- __PG_MLOCKED
> 800000000050000c -- my page flags
>         3650000c -- Maxim's page flags
> 0000000000693ce1 -- my PAGE_FLAGS_CHECK_AT_FREE
> 
> In my .config, there is
> CONFIG_PAGEFLAGS_EXTENDED=y
> CONFIG_HAVE_MLOCKED_PAGE_BIT=y
> 
> The traces:
> BUG: Bad page state in process gpg-agent  pfn:1c83c9
> page:ffffea00063cd3f8 flags:800000000050000c count:0 mapcount:0
> mapping:(null) i
> ndex:7feda9eae
> Pid: 3859, comm: gpg-agent Not tainted 2.6.30-mm1_64 #641
> Call Trace:
>  [<ffffffff8108fab2>] bad_page+0xd2/0x130
>  [<ffffffff81091a57>] free_hot_cold_page+0x47/0x200
>  [<ffffffff81091c48>] __pagevec_free+0x38/0x50
>  [<ffffffff81094eac>] release_pages+0x20c/0x240
>  [<ffffffff810afc6f>] free_pages_and_swap_cache+0xaf/0xd0
>  [<ffffffff8115d53a>] ? cpumask_any_but+0x2a/0x40
>  [<ffffffff810a8520>] unmap_region+0x150/0x170
>  [<ffffffff810a87b4>] do_munmap+0x274/0x370
>  [<ffffffff810a88fc>] sys_munmap+0x4c/0x70
>  [<ffffffff8100beab>] system_call_fastpath+0x16/0x1b
> Disabling lock debugging due to kernel taint
> BUG: Bad page state in process gpg-agent  pfn:1c83c8
> page:ffffea00063cd3c0 flags:800000000050000c count:0 mapcount:0
> mapping:(null) i
> ndex:7feda9ead
> Pid: 3859, comm: gpg-agent Tainted: G    B      2.6.30-mm1_64 #641
> Call Trace:
>  [<ffffffff8108fab2>] bad_page+0xd2/0x130
>  [<ffffffff81091a57>] free_hot_cold_page+0x47/0x200
>  [<ffffffff81091c48>] __pagevec_free+0x38/0x50
>  [<ffffffff81094eac>] release_pages+0x20c/0x240
>  [<ffffffff810afc6f>] free_pages_and_swap_cache+0xaf/0xd0
>  [<ffffffff8115d53a>] ? cpumask_any_but+0x2a/0x40
>  [<ffffffff810a8520>] unmap_region+0x150/0x170
>  [<ffffffff810a87b4>] do_munmap+0x274/0x370
>  [<ffffffff810a88fc>] sys_munmap+0x4c/0x70
>  [<ffffffff8100beab>] system_call_fastpath+0x16/0x1b
> BUG: Bad page state in process gpg-agent  pfn:1c800f
> page:ffffea00063c0348 flags:800000000050000c count:0 mapcount:0
> mapping:(null) i
> ndex:7feda9eac
> Pid: 3859, comm: gpg-agent Tainted: G    B      2.6.30-mm1_64 #641
> Call Trace:
>  [<ffffffff8108fab2>] bad_page+0xd2/0x130
>  [<ffffffff81091a57>] free_hot_cold_page+0x47/0x200
>  [<ffffffff81091c48>] __pagevec_free+0x38/0x50
>  [<ffffffff81094eac>] release_pages+0x20c/0x240
>  [<ffffffff810afc6f>] free_pages_and_swap_cache+0xaf/0xd0
>  [<ffffffff8115d53a>] ? cpumask_any_but+0x2a/0x40
>  [<ffffffff810a8520>] unmap_region+0x150/0x170
>  [<ffffffff810a87b4>] do_munmap+0x274/0x370
>  [<ffffffff810a88fc>] sys_munmap+0x4c/0x70
>  [<ffffffff8100beab>] system_call_fastpath+0x16/0x1b


Regards,
	Maxim Levitsky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
