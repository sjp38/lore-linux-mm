Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EC1C96B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 16:10:15 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id e127so53224200pfe.3
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:10:15 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id n62si22196473pfa.183.2016.02.12.13.10.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 13:10:15 -0800 (PST)
Received: by mail-pa0-x235.google.com with SMTP id fy10so12867527pac.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:10:15 -0800 (PST)
Date: Fri, 12 Feb 2016 13:10:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Bug 112301] New: [bisected] NULL pointer dereference when
 starting a kvm based VM
In-Reply-To: <20160211133026.96452d486f8029084c4129b7@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1602121247530.9500@eggly.anvils>
References: <bug-112301-27@https.bugzilla.kernel.org/> <20160211133026.96452d486f8029084c4129b7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: harn-solo@gmx.de, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, ebru.akagunduz@gmail.com, Hugh Dickins <hughd@google.com>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On Thu, 11 Feb 2016, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 11 Feb 2016 07:09:04 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=112301
> > 
> >             Bug ID: 112301
> >            Summary: [bisected] NULL pointer dereference when starting a
> >                     kvm based VM
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 4.5-rcX
> >           Hardware: All
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: harn-solo@gmx.de
> >         Regression: No
> > 
> > Created attachment 203451
> >   --> https://bugzilla.kernel.org/attachment.cgi?id=203451&action=edit
> > Call Trace of a NULL pointer dereference at gup_pte_range
> > 
> > Starting a qemu-kvm based VM configured to use hughpages I'm getting the
> > following NULL pointer dereference, see attached dmesg section.
> > 
> > The issue was introduced with commit 7d2eba0557c18f7522b98befed98799990dd4fdb
> > Author: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> > Date:   Thu Jan 14 15:22:19 2016 -0800
> >     mm: add tracepoint for scanning pages
> 
> Thanks for the detailed report.  Can you please verify that your tree
> has 629d9d1cafbd49cb374 ("mm: avoid uninitialized variable in
> tracepoint")?
> 
> vfio_pin_pages() doesn't seem to be doing anything crazy.  Hugh, Ebru:
> could you please take a look?

I very much doubt that the uninitialized variable in collapse_huge_page()
had anything to do with the crash in gup_pte_range().  Far more likely
is that the bisection hit a point in between the introduction of that
uninitialized variable and its subsequent fix, the test crashed, and
the bisector didn't notice that it was crashing for a different reason.

Comparing the "Code:" of the gup_pte_range() crash with disassembly of
gup_pte_range() here, it looks as if it's crashing in pte_page().  And,
yes, that pte_page() looks broken in 4.5-rc: please try this patch.

[PATCH] mm, x86: fix pte_page() crash in gup_pte_range()

Commit 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
has moved up the pte_page(pte) in x86's fast gup_pte_range(), for no
discernible reason: put it back where it belongs, after the pte_flags
check and the pfn_valid cross-check.

That may be the cause of the NULL pointer dereference in gup_pte_range(),
seen when vfio called vaddr_get_pfn() when starting a qemu-kvm based VM.

Reported-by: Michael Long <Harn-Solo@gmx.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 arch/x86/mm/gup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 4.5-rc3/arch/x86/mm/gup.c	2016-01-24 14:54:51.359500642 -0800
+++ linux/arch/x86/mm/gup.c	2016-02-12 12:15:36.460501324 -0800
@@ -102,7 +102,6 @@ static noinline int gup_pte_range(pmd_t
 			return 0;
 		}
 
-		page = pte_page(pte);
 		if (pte_devmap(pte)) {
 			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
 			if (unlikely(!pgmap)) {
@@ -115,6 +114,7 @@ static noinline int gup_pte_range(pmd_t
 			return 0;
 		}
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+		page = pte_page(pte);
 		get_page(page);
 		put_dev_pagemap(pgmap);
 		SetPageReferenced(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
