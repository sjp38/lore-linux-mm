Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CBB186B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 19:04:28 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p0B04OaR020501
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 16:04:25 -0800
Received: from pxi16 (pxi16.prod.google.com [10.243.27.16])
	by kpbe18.cbf.corp.google.com with ESMTP id p0B04NKZ003218
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 16:04:23 -0800
Received: by pxi16 with SMTP id 16so3912880pxi.32
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 16:04:23 -0800 (PST)
Date: Mon, 10 Jan 2011 16:04:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: known oom issues on numa in -mm tree?
In-Reply-To: <1647057595.150391.1294300999587.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.DEB.2.00.1101101602520.16216@chino.kir.corp.google.com>
References: <1647057595.150391.1294300999587.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Jan 2011, CAI Qian wrote:

> Hi,
> 
> Did anyone notice the oom issues on numa systems in -mm tree? There are 
> several of oom tests using cpuset and memcg are either waiting for a 
> long time to trigger oom or hung completely. Here were some sysrq-t 
> output while those were happening.
> 

sysrq+m would be interesting to see the state of memory when you suspect 
we're oom.

> CAI Qian
> 
> 
> oom02           R  running task        0  2057   2053 0x00000088
>  0000000000000282 ffffffffffffff10 ffffffff81098272 0000000000000010
>  0000000000000202 ffff8802159d7a18 0000000000000018 ffffffff81098252
>  01ff8802159d7a28 0000000000000000 0000000000000000 ffffffff810ffd60
> Call Trace:
>  [<ffffffff81098272>] ? smp_call_function_many+0x1b2/0x210
>  [<ffffffff81098252>] ? smp_call_function_many+0x192/0x210
>  [<ffffffff810ffd60>] ? drain_local_pages+0x0/0x20
>  [<ffffffff810982f2>] ? smp_call_function+0x22/0x30
>  [<ffffffff81067df4>] ? on_each_cpu+0x24/0x50
>  [<ffffffff810fdbec>] ? drain_all_pages+0x1c/0x20

This suggests we're in the direct reclaim path and not currently 
considered to be in the hopeless situation of oom.

>  [<ffffffff811003eb>] ? __alloc_pages_nodemask+0x4fb/0x800
>  [<ffffffff81138b59>] ? alloc_page_vma+0x89/0x140
>  [<ffffffff8111c011>] ? handle_mm_fault+0x871/0xd80
>  [<ffffffff8149fd6b>] ? schedule+0x3eb/0x9b0
>  [<ffffffff811187a0>] ? follow_page+0x220/0x370
>  [<ffffffff8111c68b>] ? __get_user_pages+0x16b/0x4d0
>  [<ffffffff8111eaa0>] ? __mlock_vma_pages_range+0xe0/0x250
>  [<ffffffff8111eecb>] ? mlock_fixup+0x16b/0x200
>  [<ffffffff8111f219>] ? do_mlock+0xc9/0x100
>  [<ffffffff8111f398>] ? sys_mlock+0xb8/0x100
>  [<ffffffff8100bfc2>] ? system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
