Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C367E6B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 17:58:23 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so188454418pdb.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 14:58:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gm2si16468344pbc.22.2015.03.30.14.58.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 14:58:22 -0700 (PDT)
Date: Mon, 30 Mar 2015 14:58:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/mmap.c: use while instead of if+goto
Message-Id: <20150330145821.ca638ac21a02564cb5c04a36@linux-foundation.org>
In-Reply-To: <20150330205413.GA4458@node.dhcp.inet.fi>
References: <1427744435-6304-1-git-send-email-linux@rasmusvillemoes.dk>
	<20150330205413.GA4458@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Roman Gushchin <klamm@yandex-team.ru>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 30 Mar 2015 23:54:13 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Mar 30, 2015 at 09:40:35PM +0200, Rasmus Villemoes wrote:
> > The creators of the C language gave us the while keyword. Let's use
> > that instead of synthesizing it from if+goto.
> > 
> > Made possible by 6597d783397a ("mm/mmap.c: replace find_vma_prepare()
> > with clearer find_vma_links()").
> > 
> > Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> 
> 
> Looks good, except both your plus-lines are over 80-characters long for no
> reason.

--- a/mm/mmap.c~mm-mmapc-use-while-instead-of-ifgoto-fix
+++ a/mm/mmap.c
@@ -1551,7 +1551,8 @@ unsigned long mmap_region(struct file *f
 
 	/* Clear old maps */
 	error = -ENOMEM;
-	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
+	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,
+			      &rb_parent)) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
 	}
@@ -1569,7 +1570,8 @@ unsigned long mmap_region(struct file *f
 	/*
 	 * Can we just expand an old mapping?
 	 */
-	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff, NULL);
+	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff,
+	                NULL);
 	if (vma)
 		goto out;
 
@@ -2737,7 +2739,8 @@ static unsigned long do_brk(unsigned lon
 	/*
 	 * Clear old maps.  this also does some error checking for us
 	 */
-	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
+	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,
+			      &rb_parent)) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
 	}

I'm not sure it improves things a lot, but mmap.c has been pretty
careful about the 80-col thing...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
