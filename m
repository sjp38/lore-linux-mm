Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6F23F6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 19:23:18 -0400 (EDT)
Date: Mon, 23 May 2011 16:22:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 35662] New: softlockup with kernel 2.6.39
Message-Id: <20110523162225.6017b2df.akpm@linux-foundation.org>
In-Reply-To: <bug-35662-10286@https.bugzilla.kernel.org/>
References: <bug-35662-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Hussam Al-Tayeb <hussam@visp.net.lb>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 23 May 2011 08:13:30 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=35662
> 
>            Summary: softlockup with kernel 2.6.39
>            Product: IO/Storage
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: io_other@kernel-bugs.osdl.org
>         ReportedBy: ht990332@gmail.com
>         Regression: No

I'll mark this as a regression.

> 
> After upgrading to kernel 2.6.39, I started having soft lockups due to disk
> activity. anything more that low disk activity would cause a problem in an
> application A.
> dmesg would spit out something like [ 1920.307498] INFO: task java:25665
> blocked for more than 120 seconds.
> [ 1920.307499] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> message.
> [ 1920.307500] java D f036df98 0 25665 25393 0x00000000
> [ 1920.307503] f036dee0 00000086 c15899c8 f036df98 e1c09590 00000001 00cbde28
> 00000170
> [ 1920.307507] f036de98 00000064 f036de60 f036de60 f036de68 f036de68 e1c09590
> c14e1440
> [ 1920.307511] 081c6000 c14e1440 f5506440 e1c09590 e1c08450 00000000 ffffffff
> c15899c8
> [ 1920.307515] Call Trace:
> [ 1920.307518] [<c1073c8d>] ? get_futex_key+0x6d/0x1d0
> [ 1920.307520] [<c10742c5>] ? futex_wake+0xe5/0x100
> [ 1920.307522] [<c132fd65>] rwsem_down_failed_common+0x95/0xe0
> [ 1920.307525] [<c1027640>] ? vmalloc_sync_all+0x120/0x120
> [ 1920.307527] [<c132fde2>] rwsem_down_read_failed+0x12/0x14
> [ 1920.307529] [<c132fe1f>] call_rwsem_down_read_failed+0x7/0xc
> [ 1920.307531] [<c132f69d>] ? down_read+0xd/0x10
> [ 1920.307534] [<c1027787>] do_page_fault+0x147/0x420
> [ 1920.307536] [<c10760e4>] ? sys_futex+0xc4/0x130
> [ 1920.307538] [<c1027640>] ? vmalloc_sync_all+0x120/0x120
> [ 1920.307540] [<c1330c4b>] error_code+0x67/0x6c
> 
> Application A would then stop being able to read/write from disk. Other running
> applications would still be able to read/write fine to the disk.
> I could even copy the data application A to another folder or delete it.
> This isn't a hard lockup and I could still continue to use the computer but
> then it'll hang at shutdown.
> At first I thought the disk (which I bought 12 days ago) is bad so I ran
> badblocks -vs and didn't find a single bad block. I ran smartctl long test and
> the disk is fine. It started to feel like some ext4 regression.
> 
> I downgraded to kernel 2.6.38.6 and performed a disk intensive action which was
> recompiling libreoffice. This worked without a problem.
> I also tried the application A which was giving problems earlier but I couldn't
> see a problem again. So I compiled libreoffice again to check and didn't have
> lockups.
> 

It appears that we forgot to release mmap_sem.

Also,

> all paritions apart from swap and /boot and encrypted with LuKs.

This involves dm-crypt, correct?

I see quite a lot of dm-crypt related bug reports float past.  But
there have been very few changes in dm-crypt recently, and something
broke in 2.6.39...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
