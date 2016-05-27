Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 478AA6B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 16:20:37 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id di3so55437102pab.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 13:20:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sk6si30479838pab.145.2016.05.27.13.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 13:20:36 -0700 (PDT)
Date: Fri, 27 May 2016 13:20:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix overflow in vm_map_ram
Message-Id: <20160527132035.0239af56b4887e89e7c3b962@linux-foundation.org>
In-Reply-To: <08d280dc9c9fe037805e3ff74d7dad02@naudit.es>
References: <etPan.57175fb3.7a271c6b.2bd@naudit.es>
	<20160526142837.662100b01ff094be9a28f01b@linux-foundation.org>
	<08d280dc9c9fe037805e3ff74d7dad02@naudit.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guillermo.julian@naudit.es
Cc: linux-mm@kvack.org

On Fri, 27 May 2016 10:25:59 +0200 "guillermo.julian" <guillermo.julian@naudit.es> wrote:

> El 2016-05-26 23:28, Andrew Morton escribi__:
> > On Wed, 20 Apr 2016 12:53:33 +0200 Guillermo Juli__n Moreno
> > <guillermo.julian@naudit.es> wrote:
> > 
> >> 
> >> When remapping pages accounting for 4G or more memory space, the
> >> operation 'count << PAGE_SHIFT' overflows as it is performed on an
> >> integer. Solution: cast before doing the bitshift.
> > 
> > Yup.
> > 
> > We need to work out which kernel versions to fix.  What are the runtime
> > effects of this?  Are there real drivers in the tree which actually map
> > more than 4G?
> 
> Looking at the references of vm_map_ram, it is only used in three 
> drivers (XFS, v4l2-core and android/ion). However, in the vmap() code, 
> the same bug is likely to occur (vmalloc.c:1557), and that function is 
> more frequently used. But if it has gone unnoticed until now, most 
> probably it isn't a critical issue (4G memory allocations are usually 
> not needed. In fact this bug surfaced during a performance test in a 
> modified driver, not in a regular configuration.

Yup.  I'll add this as well:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-fix-overflow-in-vm_map_ram-fix

fix vmap() as well, per Guillermo

Cc: Guillermo Juli_n Moreno <guillermo.julian@naudit.es>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmalloc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff -puN mm/vmalloc.c~mm-fix-overflow-in-vm_map_ram-fix mm/vmalloc.c
--- a/mm/vmalloc.c~mm-fix-overflow-in-vm_map_ram-fix
+++ a/mm/vmalloc.c
@@ -1574,14 +1574,15 @@ void *vmap(struct page **pages, unsigned
 		unsigned long flags, pgprot_t prot)
 {
 	struct vm_struct *area;
+	unsigned long size;		/* In bytes */
 
 	might_sleep();
 
 	if (count > totalram_pages)
 		return NULL;
 
-	area = get_vm_area_caller((count << PAGE_SHIFT), flags,
-					__builtin_return_address(0));
+	size = (unsigned long)count << PAGE_SHIFT;
+	area = get_vm_area_caller(size, flags, __builtin_return_address(0));
 	if (!area)
 		return NULL;
 
_


I checked all other instances of "<< PAGE" in vmalloc.c and we're good.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
