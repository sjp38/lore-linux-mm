Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id AE5DD6B0266
	for <linux-mm@kvack.org>; Sat,  9 Nov 2013 11:55:20 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id rr4so3425699pbb.25
        for <linux-mm@kvack.org>; Sat, 09 Nov 2013 08:55:20 -0800 (PST)
Received: from psmtp.com ([74.125.245.201])
        by mx.google.com with SMTP id fn9si3367839pab.14.2013.11.09.08.55.15
        for <linux-mm@kvack.org>;
        Sat, 09 Nov 2013 08:55:19 -0800 (PST)
In-Reply-To: <1383954120-24368-15-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com> <1383954120-24368-15-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [PATCH 14/24] mm/lib/swiotlb: Use memblock apis for early memory allocations
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Sat, 09 Nov 2013 11:55:03 -0500
Message-ID: <6314f039-a40e-4250-9d62-6bb6ac7c6bec@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>, tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Santosh Shilimkar <santosh=2Eshilimkar@ti=2Ecom> wrote:
>Switch to memblock=
 interfaces for early memory allocator instead of
>bootmem allocator=2E No =
functional change in beahvior than what it is
>in current code from bootmem=
 users points of view=2E
>
>Archs already converted to NO_BOOTMEM now direc=
tly use memblock
>interfaces instead of bootmem wrappers build on top of me=
mblock=2E And
>the
>archs which still uses bootmem, these new apis just fal=
lback to exiting
>bootmem APIs=2E
>
>Cc: Yinghai Lu <yinghai@kernel=2Eorg>
=
>Cc: Tejun Heo <tj@kernel=2Eorg>
>Cc: Andrew Morton <akpm@linux-foundation=
=2Eorg>
>Cc: Konrad Rzeszutek Wilk <konrad=2Ewilk@oracle=2Ecom>
>
>Signed-o=
ff-by: Santosh Shilimkar <santosh=2Eshilimkar@ti=2Ecom>
>---
> lib/swiotlb=
=2Ec |   36 +++++++++++++++++++++---------------
> 1 file changed, 21 inser=
tions(+), 15 deletions(-)
>
>diff --git a/lib/swiotlb=2Ec b/lib/swiotlb=2Ec=

>index 4e8686c=2E=2E78ac01a 100644
>--- a/lib/swiotlb=2Ec
>+++ b/lib/swiot=
lb=2Ec
>@@ -169,8 +169,9 @@ int __init swiotlb_init_with_tbl(char *tlb,
>un=
signed long nslabs, int verbose)
> 	/*
> 	 * Get the overflow emergency buf=
fer
> 	 */
>-	v_overflow_buffer =3D alloc_bootmem_low_pages_nopanic(
>-				=
		PAGE_ALIGN(io_tlb_overflow));
>+	v_overflow_buffer =3D memblock_virt_allo=
c_align_nopanic(
>+						PAGE_ALIGN(io_tlb_overflow),
>+						PAGE_SIZE);

=
Does this guarantee that the pages will be allocated below 4GB?

> 	if (!v_=
overflow_buffer)
> 		return -ENOMEM;
> 
>@@ -181,11 +182,15 @@ int __init s=
wiotlb_init_with_tbl(char *tlb,
>unsigned long nslabs, int verbose)
>	 * to=
 find contiguous free memory regions of size up to IO_TLB_SEGSIZE
> 	 * bet=
ween io_tlb_start and io_tlb_end=2E
> 	 */
>-	io_tlb_list =3D alloc_bootmem=
_pages(PAGE_ALIGN(io_tlb_nslabs *
>sizeof(int)));
>+	io_tlb_list =3D memblo=
ck_virt_alloc_align(
>+				PAGE_ALIGN(io_tlb_nslabs * sizeof(int)),
>+				P=
AGE_SIZE);
> 	for (i =3D 0; i < io_tlb_nslabs; i++)
>  		io_tlb_list[i] =3D=
 IO_TLB_SEGSIZE - OFFSET(i, IO_TLB_SEGSIZE);
> 	io_tlb_index =3D 0;
>-	io_t=
lb_orig_addr =3D alloc_bootmem_pages(PAGE_ALIGN(io_tlb_nslabs *
>sizeof(phy=
s_addr_t)));
>+	io_tlb_orig_addr =3D memblock_virt_alloc_align(
>+				PAGE_=
ALIGN(io_tlb_nslabs * sizeof(phys_addr_t)),
>+				PAGE_SIZE);
> 
> 	if (ver=
bose)
> 		swiotlb_print_info();
>@@ -212,13 +217,14 @@ swiotlb_init(int ver=
bose)
> 	bytes =3D io_tlb_nslabs << IO_TLB_SHIFT;
> 
> 	/* Get IO TLB memor=
y from the low pages */
>-	vstart =3D alloc_bootmem_low_pages_nopanic(PAGE_=
ALIGN(bytes));
>+	vstart =3D memblock_virt_alloc_align_nopanic(PAGE_ALIGN(b=
ytes),
>+						   PAGE_SIZE);

Ditto?
> 	if (vstart && !swiotlb_init_with_t=
bl(vstart, io_tlb_nslabs, verbose))
> 		return;
> 
> 	if (io_tlb_start)
>-	=
	free_bootmem(io_tlb_start,
>-				 PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT=
));
>+		memblock_free_early(io_tlb_start,
>+				    PAGE_ALIGN(io_tlb_nslab=
s << IO_TLB_SHIFT));
> 	pr_warn("Cannot allocate SWIOTLB buffer");
> 	no_io=
tlb_memory =3D true;
> }
>@@ -354,14 +360,14 @@ void __init swiotlb_free(vo=
id)
> 		free_pages((unsigned long)phys_to_virt(io_tlb_start),
> 			   get_o=
rder(io_tlb_nslabs << IO_TLB_SHIFT));
> 	} else {
>-		free_bootmem_late(io_=
tlb_overflow_buffer,
>-				  PAGE_ALIGN(io_tlb_overflow));
>-		free_bootmem=
_late(__pa(io_tlb_orig_addr),
>-				  PAGE_ALIGN(io_tlb_nslabs * sizeof(phy=
s_addr_t)));
>-		free_bootmem_late(__pa(io_tlb_list),
>-				  PAGE_ALIGN(io=
_tlb_nslabs * sizeof(int)));
>-		free_bootmem_late(io_tlb_start,
>-				  PA=
GE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT));
>+		memblock_free_late(io_tlb_ove=
rflow_buffer,
>+				   PAGE_ALIGN(io_tlb_overflow));
>+		memblock_free_late=
(__pa(io_tlb_orig_addr),
>+				   PAGE_ALIGN(io_tlb_nslabs * sizeof(phys_ad=
dr_t)));
>+		memblock_free_late(__pa(io_tlb_list),
>+				   PAGE_ALIGN(io_t=
lb_nslabs * sizeof(int)));
>+		memblock_free_late(io_tlb_start,
>+				   PA=
GE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT));
> 	}
> 	io_tlb_nslabs =3D 0;
> }
=


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
