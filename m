Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DB79E6B0088
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 19:08:41 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so10635939pab.27
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 16:08:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id vn9si52302pbc.2.2014.04.01.16.08.40
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 16:08:40 -0700 (PDT)
Date: Tue, 1 Apr 2014 16:08:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] A long explanation for a short patch
Message-Id: <20140401160839.8b561fbaae6568439fbc5a1d@linux-foundation.org>
In-Reply-To: <20140314165332.GH16145@hansolo.jdub.homelinux.org>
References: <1394764246-19936-1-git-send-email-jhubbard@nvidia.com>
	<5322875D.1040702@oracle.com>
	<532289F6.5010404@nvidia.com>
	<20140314134222.GG16145@hansolo.jdub.homelinux.org>
	<53231BB3.20205@oracle.com>
	<20140314165332.GH16145@hansolo.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Boyer <jwboyer@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, John Hubbard <jhubbard@nvidia.com>, "john.hubbard@gmail.com" <john.hubbard@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 14 Mar 2014 12:53:32 -0400 Josh Boyer <jwboyer@redhat.com> wrote:

> I suppose the
> thing that gave me pause here is that the highlighted example was an
> issue with a proprietary module whereas this one is permissively
> licensed (more permissively than GPL even).

Doesn't really matter much.

a) things used to work, but 309381feaee564 broke it, unintentionally.

b) modules which work OK with CONFIG_DEBUG_VM=n will break with
   CONFIG_DEBUG_VM=y, which makes no sense.


I queued the patch for 3.15-rc1 with a tweaked changelog:


From: John Hubbard <jhubbard@nvidia.com>
Subject: mm/page_alloc.c: change mm debug routines back to EXPORT_SYMBOL

A new dump_page() routine was recently added, and marked
EXPORT_SYMBOL_GPL.  dump_page() was also added to the VM_BUG_ON_PAGE()
macro, and so the end result is that non-GPL code can no longer call
get_page() and a few other routines.

This only happens if the kernel was compiled with CONFIG_DEBUG_VM.

Change dump_page() to be EXPORT_SYMBOL.

Longer explanation:

Prior to 309381feaee564 ("mm: dump page when hitting a VM_BUG_ON using
VM_BUG_ON_PAGE") , it was possible to build MIT-licensed (non-GPL) drivers
on Fedora.  Fedora is semi-unique, in that it sets CONFIG_VM_DEBUG.

Because Fedora sets CONFIG_VM_DEBUG, they end up pulling in dump_page(),
via VM_BUG_ON_PAGE, via get_page().  As one of the authors of NVIDIA's
new, open source, "UVM-Lite" kernel module, I originally choose to use the
kernel's get_page() routine from within nvidia_uvm_page_cache.c, because
get_page() has always seemed to be very clearly intended for use by
non-GPL, driver code.

So I'm hoping that making get_page() widely accessible again will not be
too controversial.  We did check with Fedora first, and they responded
(https://bugzilla.redhat.com/show_bug.cgi?id=1074710#c3) that we should
try to get upstream changed, before asking Fedora to change.  Their
reasoning seems beneficial to Linux: leaving CONFIG_DEBUG_VM set allows
Fedora to help catch mm bugs.

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Josh Boyer <jwboyer@redhat.com>

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/page_alloc.c~mm-page_allocc-change-mm-debug-routines-back-to-export_symbol mm/page_alloc.c
--- a/mm/page_alloc.c~mm-page_allocc-change-mm-debug-routines-back-to-export_symbol
+++ a/mm/page_alloc.c
@@ -6566,4 +6566,4 @@ void dump_page(struct page *page, const
 {
 	dump_page_badflags(page, reason, 0);
 }
-EXPORT_SYMBOL_GPL(dump_page);
+EXPORT_SYMBOL(dump_page);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
