Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 6FB938D0003
	for <linux-mm@kvack.org>; Fri, 11 May 2012 15:59:23 -0400 (EDT)
Date: Fri, 11 May 2012 12:59:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 43227] New: BUG: Bad page state in process wcg_gfam_6.11_i
Message-Id: <20120511125921.a888e12c.akpm@linux-foundation.org>
In-Reply-To: <bug-43227-27@https.bugzilla.kernel.org/>
References: <bug-43227-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, sliedes@cc.hut.fi


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 10 May 2012 23:29:46 +0000 (UTC)
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=43227
> 
>            Summary: BUG: Bad page state in process wcg_gfam_6.11_i
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.3.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: sliedes@cc.hut.fi
>         Regression: No
> 
> 
> Created an attachment (id=73246)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=73246)
> Entire dmesg
> 
> Hi,
> 
> I noticed that a number of bad page state bugs have apparently been fixed in
> recent stable kernels. Unfortunately it seems there's still some such bug left
> in 3.3.5.
> 
> I just saw this bug for the first time after upgrading from (mainline) 3.3.2 to
> 3.3.5 (having read the other bug reports I suspect this is the significant
> change) and changing my root filesystem from ext4 to xfs, hence causing heavier
> exercise of the xfs code than before (but I've had a backup partition on xfs
> before with no issues).
> 
> This is the bug I'm seeing:
> 
> [67031.755786] BUG: Bad page state in process wcg_gfam_6.11_i  pfn:02519
> [67031.755790] page:ffffea0000094640 count:0 mapcount:0 mapping:         
> (null) index:0x7f1eb293b
> [67031.755792] page flags: 0x4000000000000014(referenced|dirty)

AFAICT we got this warning because the page allocator found a free page
with PG_referenced and PG_dirty set.

It would be a heck of a lot more useful if we'd been told about this
when the page was freed, not when it was reused!  Can anyone think of a
reason why PAGE_FLAGS_CHECK_AT_FREE doesn't include these flags (at
least)?

> ...
>
> [67031.755872] Pid: 5229, comm: wcg_gfam_6.11_i Tainted: G           O 3.3.5 #2
> [67031.755874] Call Trace:
> [67031.755880]  [<ffffffff813f6a33>] bad_page+0xcb/0xe0
> [67031.755884]  [<ffffffff810dfc4e>] get_page_from_freelist+0x54e/0x5f0
> [67031.755888]  [<ffffffff811e0b4e>] ? string.isra.4+0x3e/0xd0
> [67031.755891]  [<ffffffff810dfe05>] __alloc_pages_nodemask+0x115/0x810
> [67031.755895]  [<ffffffff81143a06>] ? seq_printf+0x56/0x90
> [67031.755898]  [<ffffffff8118570a>] ? do_task_stat+0x6ba/0xbf0
> [67031.755901]  [<ffffffff8110561b>] ? anon_vma_prepare+0xfb/0x170
> [67031.755904]  [<ffffffff810fb0c6>] handle_pte_fault+0x736/0x970
> [67031.755906]  [<ffffffff810fb668>] handle_mm_fault+0x1c8/0x2f0
> [67031.755909]  [<ffffffff81400cbe>] do_page_fault+0x16e/0x4f0
> [67031.755913]  [<ffffffff813fdbc5>] page_fault+0x25/0x30
> [67031.755916]  [<ffffffff811e2bfd>] ? copy_user_generic_string+0x2d/0x40
> [67031.755919]  [<ffffffff81143e08>] ? seq_read+0x2c8/0x390
> [67031.755922]  [<ffffffff811240b4>] vfs_read+0xa4/0x180
> [67031.755924]  [<ffffffff811241d5>] sys_read+0x45/0x90
> [67031.755927]  [<ffffffff81406a09>] ia32_do_call+0x13/0x13
> [67031.755929] Disabling lock debugging due to kernel taint
> 
> Before that there's a warning about "irq 17: nobody cared" (see the attached
> entire dmesg if you are interested); this is apparently an unrelated, known
> issue with Asus motherboards which has persisted for a long time without
> causing  bad page state bugs.
> 
> FWIW, I noticed that a number of the patches that may have something to do with
> this and that have gone in since v3.3.2 are KVM related. I have run a large
> number of KVM guests on this computer between the boot and this bug occuring,
> so this might (or might not) be KVM related.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
