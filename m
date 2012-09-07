Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 256CB6B005A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 18:44:00 -0400 (EDT)
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
From: Suresh Siddha <suresh.b.siddha@intel.com>
Reply-To: Suresh Siddha <suresh.b.siddha@intel.com>
Date: Fri, 07 Sep 2012 15:42:58 -0700
In-Reply-To: <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com>
References: <1340959739.2936.28.camel@lappy>
	 <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com>
	 <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On Fri, 2012-09-07 at 11:14 -0700, Linus Torvalds wrote:
> Guys, this looks like a MTD and/or io_remap_pfn_range() bug, and it's
> not getting any traction.
> 
> What the f*ck is mtd_mmap() doing, and why? The problem seems to be an
> overflow condition, because reserve_pfn_range() does
> 
>     reserve_memtype(paddr, paddr + size, want_flags, &flags);
> 
> and then the BUG_ON() in reserve_memtype is
> 
>     BUG_ON(start >= end);
> 
> so it very much looks like a paddr+size overflow. However, that makes
> little sense too, since we're working in "u64", so I suspect the
> overflow has happened somewhere earlier.
> 
> I really don't see where, though. Could somebody please take a look?
> The mtdchar_mmap() types seem insane (why "u32" for len, for example?
> And that whole
> 
>   off = vma->vm_pgoff << PAGE_SHIFT;
> 
> thing looks like it would overflow, since the whole point of pgoff is
> that if you shift it up by PAGE_SHIFT you need to also extend to
> 64-bit etc.
> 
> So I would *guess* that it's the mtdchar_mmap() stuff that overflows
> due to bad types, but maybe it does deeper than that?
> 

I started to look into this to see if this is a PAT issue but it does
indeed appear to be a mtd mmap issue.

Sasha, Does the appended fix the issue for you?

--8<--
From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: mtd: check the starting offset to be mmap'd

We need to check if both the starting offset aswell the total length
being mmap'd are with in the limits. With a large starting offset,
offset + (length-to-be-mapped) can wrap and appear smaller than the
limit. Need to check both start and end.

Also fix the types of the variables start, off, len.

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
---
 drivers/mtd/mtdchar.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/mtd/mtdchar.c b/drivers/mtd/mtdchar.c
index f2f482b..f79c0fa 100644
--- a/drivers/mtd/mtdchar.c
+++ b/drivers/mtd/mtdchar.c
@@ -1132,16 +1132,15 @@ static int mtdchar_mmap(struct file *file, struct vm_area_struct *vma)
 	struct mtd_file_info *mfi = file->private_data;
 	struct mtd_info *mtd = mfi->mtd;
 	struct map_info *map = mtd->priv;
-	unsigned long start;
-	unsigned long off;
-	u32 len;
+	resource_size_t start, off;
+	unsigned long len;
 
 	if (mtd->type == MTD_RAM || mtd->type == MTD_ROM) {
 		off = vma->vm_pgoff << PAGE_SHIFT;
 		start = map->phys;
 		len = PAGE_ALIGN((start & ~PAGE_MASK) + map->size);
 		start &= PAGE_MASK;
-		if ((vma->vm_end - vma->vm_start + off) > len)
+		if (off >= len || (vma->vm_end - vma->vm_start + off) > len)
 			return -EINVAL;
 
 		off += start;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
