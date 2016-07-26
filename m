Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57B386B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 06:55:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so6434213wmp.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 03:55:01 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id d143si96154lfd.188.2016.07.26.03.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 03:54:59 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id 33so174104lfw.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 03:54:59 -0700 (PDT)
Date: Tue, 26 Jul 2016 13:54:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: correctly handle errors during VMA merging
Message-ID: <20160726105456.GB7370@node.shutemov.name>
References: <1469514843-23778-1-git-send-email-vegard.nossum@oracle.com>
 <20160726085344.GA7370@node.shutemov.name>
 <57972C45.5050803@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57972C45.5050803@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Leon Yu <chianglungyu@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>

On Tue, Jul 26, 2016 at 11:24:21AM +0200, Vegard Nossum wrote:
> On 07/26/2016 10:53 AM, Kirill A. Shutemov wrote:
> >On Tue, Jul 26, 2016 at 08:34:03AM +0200, Vegard Nossum wrote:
> >>Using trinity + fault injection I've been running into this bug a lot:
> >>
> >>     ==================================================================
> >>     BUG: KASAN: out-of-bounds in mprotect_fixup+0x523/0x5a0 at addr ffff8800b9e7d740
> >>     Read of size 8 by task trinity-c3/6338
> [...]
> >>I can give the reproducer a spin.
> >
> >Could you post your reproducer? I guess it requires kernel instrumentation
> >to make allocation failure more likely.
> 
> I'm sorry but company policy prevents me from posting straight-up
> reproducers.

That's very weird policy. I don't think this kind of reproducer can be
considered exploit.

> But as I said I'm happy to rerun it if you have an alternative patch.
> 
> It should be enough to enable fault injection (echo 1 >
> /proc/self/make-it-fail) for the process doing the mprotect().

That's what I came up with:

	#define _GNU_SOURCE
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <unistd.h>
	#include <sys/mman.h>

	#define PAGE_SIZE 4096
	#define SIZE (3 * PAGE_SIZE)
	#define BASE ((void *)0x400000000000)

	int main(int argc, char **argv)
	{
		char *p;

		p = mmap(BASE, SIZE, PROT_READ | PROT_WRITE,
				MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);

		mprotect(p + PAGE_SIZE, PAGE_SIZE, PROT_READ | PROT_WRITE | PROT_EXEC);
		memset(p + 2 * PAGE_SIZE, 1, PAGE_SIZE);
		mprotect(p + PAGE_SIZE, PAGE_SIZE, PROT_READ | PROT_WRITE);

		return 0;
	}

Plus kernel modification to make the allocation fail:


index a384c10c7657..35f004676233 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -629,6 +629,7 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
        bool start_changed = false, end_changed = false;
        long adjust_next = 0;
        int remove_next = 0;
+       bool second_iteration = false;
 
        if (next && !insert) {
                struct vm_area_struct *exporter = NULL;
@@ -670,6 +671,8 @@ again:                      remove_next = 1 + (end > next->vm_end);
                        int error;
 
                        importer->anon_vma = exporter->anon_vma;
+                       if (second_iteration)
+                               return -ENOMEM;
                        error = anon_vma_clone(importer, exporter);
                        if (error)
                                return error;
@@ -796,6 +799,7 @@ again:                      remove_next = 1 + (end > next->vm_end);
                 * up the code too much to do both in one go.
                 */
                next = vma->vm_next;
+               second_iteration = true;
                if (remove_next == 2)
                        goto again;
                else if (next)
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
