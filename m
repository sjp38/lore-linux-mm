Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 343FA6B025E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 17:28:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c84so61615100pfc.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 14:28:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sr4si23150263pab.10.2016.05.26.14.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 14:28:38 -0700 (PDT)
Date: Thu, 26 May 2016 14:28:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix overflow in vm_map_ram
Message-Id: <20160526142837.662100b01ff094be9a28f01b@linux-foundation.org>
In-Reply-To: <etPan.57175fb3.7a271c6b.2bd@naudit.es>
References: <etPan.57175fb3.7a271c6b.2bd@naudit.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guillermo =?ISO-8859-1?Q?Juli=E1n?= Moreno <guillermo.julian@naudit.es>
Cc: linux-mm@kvack.org

On Wed, 20 Apr 2016 12:53:33 +0200 Guillermo Juli__n Moreno <guillermo.julian@naudit.es> wrote:

> 
> When remapping pages accounting for 4G or more memory space, the
> operation 'count << PAGE_SHIFT' overflows as it is performed on an
> integer. Solution: cast before doing the bitshift.

Yup.

We need to work out which kernel versions to fix.  What are the runtime
effects of this?  Are there real drivers in the tree which actually map
more than 4G?

I fixed vm_unmap_ram() as well, but I didn't test it.  I wonder why you
missed that...

> diff --git a/mm/vmalloc.c b/mm/vmalloc.c  
> index ae7d20b..97257e4 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1114,7 +1114,7 @@ EXPORT_SYMBOL(vm_unmap_ram);
> */
> void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
> {
> - unsigned long size = count << PAGE_SHIFT;
> + unsigned long size = ((unsigned long) count) << PAGE_SHIFT;
> unsigned long addr;
> void *mem;
> 

Your email client totally messes up the patches.  Please fix that for
next time.


From: Guillermo Juli_n Moreno <guillermo.julian@naudit.es>
Subject: mm: fix overflow in vm_map_ram()

When remapping pages accounting for 4G or more memory space, the
operation 'count << PAGE_SHIFT' overflows as it is performed on an
integer. Solution: cast before doing the bitshift.

[akpm@linux-foundation.org: fix vm_unmap_ram() also]
Link: http://lkml.kernel.org/r/etPan.57175fb3.7a271c6b.2bd@naudit.es
Signed-off-by: Guillermo Juli_n Moreno <guillermo.julian@naudit.es>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmalloc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN mm/vmalloc.c~mm-fix-overflow-in-vm_map_ram mm/vmalloc.c
--- a/mm/vmalloc.c~mm-fix-overflow-in-vm_map_ram
+++ a/mm/vmalloc.c
@@ -1105,7 +1105,7 @@ EXPORT_SYMBOL_GPL(vm_unmap_aliases);
  */
 void vm_unmap_ram(const void *mem, unsigned int count)
 {
-	unsigned long size = count << PAGE_SHIFT;
+	unsigned long size = (unsigned long)count << PAGE_SHIFT;
 	unsigned long addr = (unsigned long)mem;
 
 	BUG_ON(!addr);
@@ -1140,7 +1140,7 @@ EXPORT_SYMBOL(vm_unmap_ram);
  */
 void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
 {
-	unsigned long size = count << PAGE_SHIFT;
+	unsigned long size = (unsigned long)count << PAGE_SHIFT;
 	unsigned long addr;
 	void *mem;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
