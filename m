Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7774B6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 17:33:27 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id my13so96650bkb.12
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 14:33:26 -0800 (PST)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id kt1si8163857bkb.328.2014.01.22.14.33.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 14:33:26 -0800 (PST)
Received: by mail-lb0-f181.google.com with SMTP id z5so856181lbh.12
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 14:33:25 -0800 (PST)
Date: Thu, 23 Jan 2014 02:33:25 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [Bug 67651] Bisected: Lots of fragmented mmaps cause gimp to
 fail in 3.12 after exceeding vm_max_map_count
Message-ID: <20140122223325.GA30637@moon>
References: <20140122190816.GB4963@suse.de>
 <20140122191928.GQ1574@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140122191928.GQ1574@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, gnome@rvzt.net, drawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Wed, Jan 22, 2014 at 11:19:28PM +0400, Cyrill Gorcunov wrote:
> > commit. Test case was simple -- try and open the large file described in
> > the bug. I did not investigate the patch itself as I'm just reporting
> > the results of the bisection. If I had to guess, I'd say that VMA
> > merging has been affected.
> 
> Thanks a lot for report, Mel! I'm investigating...

Mel, here is a quick fix for bring merging back (just in case if you
have a minute to test it and confirm the merging were affected). It
seems I've lost setting up vma-softdirty bit somewhere and procedure
which tests vma flags mathcing fails, will continue investigating/testing
tomorrow.
---
 mm/mmap.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: linux-2.6.git/mm/mmap.c
===================================================================
--- linux-2.6.git.orig/mm/mmap.c
+++ linux-2.6.git/mm/mmap.c
@@ -893,8 +893,18 @@ again:			remove_next = 1 + (end > next->
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
 			struct file *file, unsigned long vm_flags)
 {
+	/*
+	 * VM_SOFTDIRTY should not prevent from VMA merging, if we
+	 * match the flags but dirty bit -- just mark merged one as
+	 * a dirty then.
+	 */
+#ifdef CONFIG_MEM_SOFT_DIRTY
+	if ((vma->vm_flags ^ vm_flags) & ~VM_SOFTDIRTY)
+		return 0;
+#else
 	if (vma->vm_flags ^ vm_flags)
 		return 0;
+#endif
 	if (vma->vm_file != file)
 		return 0;
 	if (vma->vm_ops && vma->vm_ops->close)
@@ -1082,7 +1092,11 @@ static int anon_vma_compatible(struct vm
 	return a->vm_end == b->vm_start &&
 		mpol_equal(vma_policy(a), vma_policy(b)) &&
 		a->vm_file == b->vm_file &&
+#ifdef CONFIG_MEM_SOFT_DIRTY
+		!((a->vm_flags ^ b->vm_flags) & ~(VM_READ|VM_WRITE|VM_EXEC|VM_SOFTDIRTY)) &&
+#else
 		!((a->vm_flags ^ b->vm_flags) & ~(VM_READ|VM_WRITE|VM_EXEC)) &&
+#endif
 		b->vm_pgoff == a->vm_pgoff + ((b->vm_start - a->vm_start) >> PAGE_SHIFT);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
