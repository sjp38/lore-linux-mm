Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7FA36B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 09:15:39 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o135so38655415qke.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:15:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j14si3868569qtj.57.2017.03.16.06.15.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 06:15:38 -0700 (PDT)
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <c3b12452-9533-87c8-4543-8f12f5c90fe3@redhat.com>
Date: Thu, 16 Mar 2017 14:15:19 +0100
MIME-Version: 1.0
In-Reply-To: <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
Content-Type: multipart/mixed;
 boundary="------------7AC6D09ABF2C56474372EF15"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, Borislav Petkov <bp@suse.de>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net

This is a multi-part message in MIME format.
--------------7AC6D09ABF2C56474372EF15
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit



On 10/03/2017 23:41, Brijesh Singh wrote:
>> Maybe there's a reason this fires:
>>
>> WARNING: modpost: Found 2 section mismatch(es).
>> To see full details build your kernel with:
>> 'make CONFIG_DEBUG_SECTION_MISMATCH=y'
>>
>> WARNING: vmlinux.o(.text+0x48edc): Section mismatch in reference from
>> the function __change_page_attr() to the function
>> .init.text:memblock_alloc()
>> The function __change_page_attr() references
>> the function __init memblock_alloc().
>> This is often because __change_page_attr lacks a __init
>> annotation or the annotation of memblock_alloc is wrong.
>>
>> WARNING: vmlinux.o(.text+0x491d1): Section mismatch in reference from
>> the function __change_page_attr() to the function
>> .meminit.text:memblock_free()
>> The function __change_page_attr() references
>> the function __meminit memblock_free().
>> This is often because __change_page_attr lacks a __meminit
>> annotation or the annotation of memblock_free is wrong.
>> 
>> But maybe Paolo might have an even better idea...
> 
> I am sure he will have better idea :)

Not sure if it's better or worse, but an alternative idea is to turn
__change_page_attr and __change_page_attr_set_clr inside out, so that:
1) the alloc_pages/__free_page happens in __change_page_attr_set_clr;
2) __change_page_attr_set_clr overall does not beocome more complex.

Then you can introduce __early_change_page_attr_set_clr and/or
early_kernel_map_pages_in_pgd, for use in your next patches.  They use
the memblock allocator instead of alloc/free_page

The attached patch is compile-tested only and almost certainly has some
thinko in it.  But it even skims a few lines from the code so the idea
might have some merit.

Paolo

--------------7AC6D09ABF2C56474372EF15
Content-Type: text/x-patch;
 name="alloc-in-cpa-set-clr.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="alloc-in-cpa-set-clr.patch"

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 28d42130243c..953c8e697562 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -490,11 +490,12 @@ static void __set_pmd_pte(pte_t *kpte, unsigned lon=
g address, pte_t pte)
 }
=20
 static int
-try_preserve_large_page(pte_t *kpte, unsigned long address,
+try_preserve_large_page(pte_t **p_kpte, unsigned long address,
 			struct cpa_data *cpa)
 {
 	unsigned long nextpage_addr, numpages, pmask, psize, addr, pfn, old_pfn=
;
-	pte_t new_pte, old_pte, *tmp;
+	pte_t *kpte =3D *p_kpte;
+	pte_t new_pte, old_pte;
 	pgprot_t old_prot, new_prot, req_prot;
 	int i, do_split =3D 1;
 	enum pg_level level;
@@ -507,8 +508,8 @@ try_preserve_large_page(pte_t *kpte, unsigned long ad=
dress,
 	 * Check for races, another CPU might have split this page
 	 * up already:
 	 */
-	tmp =3D _lookup_address_cpa(cpa, address, &level);
-	if (tmp !=3D kpte)
+	*p_kpte =3D _lookup_address_cpa(cpa, address, &level);
+	if (*p_kpte !=3D kpte)
 		goto out_unlock;
=20
 	switch (level) {
@@ -634,17 +635,18 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpt=
e, unsigned long address,
 	unsigned int i, level;
 	pte_t *tmp;
 	pgprot_t ref_prot;
+	int retry =3D 1;
=20
+	if (!debug_pagealloc_enabled())
+		spin_lock(&cpa_lock);
 	spin_lock(&pgd_lock);
 	/*
 	 * Check for races, another CPU might have split this page
 	 * up for us already:
 	 */
 	tmp =3D _lookup_address_cpa(cpa, address, &level);
-	if (tmp !=3D kpte) {
-		spin_unlock(&pgd_lock);
-		return 1;
-	}
+	if (tmp !=3D kpte)
+		goto out;
=20
 	paravirt_alloc_pte(&init_mm, page_to_pfn(base));
=20
@@ -671,10 +673,11 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpt=
e, unsigned long address,
 		break;
=20
 	default:
-		spin_unlock(&pgd_lock);
-		return 1;
+		goto out;
 	}
=20
+	retry =3D 0;
+
 	/*
 	 * Set the GLOBAL flags only if the PRESENT flag is set
 	 * otherwise pmd/pte_present will return true even on a non
@@ -718,28 +721,34 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpt=
e, unsigned long address,
 	 * going on.
 	 */
 	__flush_tlb_all();
-	spin_unlock(&pgd_lock);
=20
-	return 0;
-}
-
-static int split_large_page(struct cpa_data *cpa, pte_t *kpte,
-			    unsigned long address)
-{
-	struct page *base;
+out:
+	spin_unlock(&pgd_lock);
=20
+	/*
+	 * Do a global flush tlb after splitting the large page
+ 	 * and before we do the actual change page attribute in the PTE.
+ 	 *
+ 	 * With out this, we violate the TLB application note, that says
+ 	 * "The TLBs may contain both ordinary and large-page
+	 *  translations for a 4-KByte range of linear addresses. This
+	 *  may occur if software modifies the paging structures so that
+	 *  the page size used for the address range changes. If the two
+	 *  translations differ with respect to page frame or attributes
+	 *  (e.g., permissions), processor behavior is undefined and may
+	 *  be implementation-specific."
+ 	 *
+ 	 * We do this global tlb flush inside the cpa_lock, so that we
+	 * don't allow any other cpu, with stale tlb entries change the
+	 * page attribute in parallel, that also falls into the
+	 * just split large page entry.
+ 	 */
+	if (!retry)
+		flush_tlb_all();
 	if (!debug_pagealloc_enabled())
 		spin_unlock(&cpa_lock);
-	base =3D alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
-	if (!debug_pagealloc_enabled())
-		spin_lock(&cpa_lock);
-	if (!base)
-		return -ENOMEM;
-
-	if (__split_large_page(cpa, kpte, address, base))
-		__free_page(base);
=20
-	return 0;
+	return retry;
 }
=20
 static bool try_to_free_pte_page(pte_t *pte)
@@ -1166,30 +1175,26 @@ static int __cpa_process_fault(struct cpa_data *c=
pa, unsigned long vaddr,
 	}
 }
=20
-static int __change_page_attr(struct cpa_data *cpa, int primary)
+static int __change_page_attr(struct cpa_data *cpa, pte_t **p_kpte, unsi=
gned long address,
+			      int primary)
 {
-	unsigned long address;
-	int do_split, err;
 	unsigned int level;
 	pte_t *kpte, old_pte;
+	int err =3D 0;
=20
-	if (cpa->flags & CPA_PAGES_ARRAY) {
-		struct page *page =3D cpa->pages[cpa->curpage];
-		if (unlikely(PageHighMem(page)))
-			return 0;
-		address =3D (unsigned long)page_address(page);
-	} else if (cpa->flags & CPA_ARRAY)
-		address =3D cpa->vaddr[cpa->curpage];
-	else
-		address =3D *cpa->vaddr;
-repeat:
-	kpte =3D _lookup_address_cpa(cpa, address, &level);
-	if (!kpte)
-		return __cpa_process_fault(cpa, address, primary);
+	if (!debug_pagealloc_enabled())
+		spin_lock(&cpa_lock);
+	*p_kpte =3D kpte =3D _lookup_address_cpa(cpa, address, &level);
+	if (!kpte) {
+		err =3D __cpa_process_fault(cpa, address, primary);
+		goto out;
+	}
=20
 	old_pte =3D *kpte;
-	if (pte_none(old_pte))
-		return __cpa_process_fault(cpa, address, primary);
+	if (pte_none(old_pte)) {
+		err =3D __cpa_process_fault(cpa, address, primary);
+		goto out;
+	}
=20
 	if (level =3D=3D PG_LEVEL_4K) {
 		pte_t new_pte;
@@ -1228,59 +1233,27 @@ static int __change_page_attr(struct cpa_data *cp=
a, int primary)
 			cpa->flags |=3D CPA_FLUSHTLB;
 		}
 		cpa->numpages =3D 1;
-		return 0;
+		goto out;
 	}
=20
 	/*
 	 * Check, whether we can keep the large page intact
 	 * and just change the pte:
 	 */
-	do_split =3D try_preserve_large_page(kpte, address, cpa);
-	/*
-	 * When the range fits into the existing large page,
-	 * return. cp->numpages and cpa->tlbflush have been updated in
-	 * try_large_page:
-	 */
-	if (do_split <=3D 0)
-		return do_split;
-
-	/*
-	 * We have to split the large page:
-	 */
-	err =3D split_large_page(cpa, kpte, address);
-	if (!err) {
-		/*
-	 	 * Do a global flush tlb after splitting the large page
-	 	 * and before we do the actual change page attribute in the PTE.
-	 	 *
-	 	 * With out this, we violate the TLB application note, that says
-	 	 * "The TLBs may contain both ordinary and large-page
-		 *  translations for a 4-KByte range of linear addresses. This
-		 *  may occur if software modifies the paging structures so that
-		 *  the page size used for the address range changes. If the two
-		 *  translations differ with respect to page frame or attributes
-		 *  (e.g., permissions), processor behavior is undefined and may
-		 *  be implementation-specific."
-	 	 *
-	 	 * We do this global tlb flush inside the cpa_lock, so that we
-		 * don't allow any other cpu, with stale tlb entries change the
-		 * page attribute in parallel, that also falls into the
-		 * just split large page entry.
-	 	 */
-		flush_tlb_all();
-		goto repeat;
-	}
+	err =3D try_preserve_large_page(p_kpte, address, cpa);
=20
+out:
+	if (!debug_pagealloc_enabled())
+		spin_unlock(&cpa_lock);
 	return err;
 }
=20
 static int __change_page_attr_set_clr(struct cpa_data *cpa, int checkali=
as);
=20
-static int cpa_process_alias(struct cpa_data *cpa)
+static int cpa_process_alias(struct cpa_data *cpa, unsigned long vaddr)
 {
 	struct cpa_data alias_cpa;
 	unsigned long laddr =3D (unsigned long)__va(cpa->pfn << PAGE_SHIFT);
-	unsigned long vaddr;
 	int ret;
=20
 	if (!pfn_range_is_mapped(cpa->pfn, cpa->pfn + 1))
@@ -1290,16 +1263,6 @@ static int cpa_process_alias(struct cpa_data *cpa)=

 	 * No need to redo, when the primary call touched the direct
 	 * mapping already:
 	 */
-	if (cpa->flags & CPA_PAGES_ARRAY) {
-		struct page *page =3D cpa->pages[cpa->curpage];
-		if (unlikely(PageHighMem(page)))
-			return 0;
-		vaddr =3D (unsigned long)page_address(page);
-	} else if (cpa->flags & CPA_ARRAY)
-		vaddr =3D cpa->vaddr[cpa->curpage];
-	else
-		vaddr =3D *cpa->vaddr;
-
 	if (!(within(vaddr, PAGE_OFFSET,
 		    PAGE_OFFSET + (max_pfn_mapped << PAGE_SHIFT)))) {
=20
@@ -1338,33 +1301,64 @@ static int cpa_process_alias(struct cpa_data *cpa=
)
 	return 0;
 }
=20
+static unsigned long cpa_address(struct cpa_data *cpa, unsigned long num=
pages)
+{
+	/*
+	 * Store the remaining nr of pages for the large page
+	 * preservation check.
+	 */
+	/* for array changes, we can't use large page */
+	cpa->numpages =3D 1;
+	if (cpa->flags & CPA_PAGES_ARRAY) {
+		struct page *page =3D cpa->pages[cpa->curpage];
+		if (unlikely(PageHighMem(page)))
+			return -EINVAL;
+		return (unsigned long)page_address(page);
+	} else if (cpa->flags & CPA_ARRAY) {
+		return cpa->vaddr[cpa->curpage];
+	} else {
+		cpa->numpages =3D numpages;
+		return *cpa->vaddr;
+	}
+}
+
+static void cpa_advance(struct cpa_data *cpa)
+{
+	if (cpa->flags & (CPA_PAGES_ARRAY | CPA_ARRAY))
+		cpa->curpage++;
+	else
+		*cpa->vaddr +=3D cpa->numpages * PAGE_SIZE;
+}
+
 static int __change_page_attr_set_clr(struct cpa_data *cpa, int checkali=
as)
 {
 	unsigned long numpages =3D cpa->numpages;
+	unsigned long vaddr;
+	struct page *base;
+	pte_t *kpte;
 	int ret;
=20
 	while (numpages) {
-		/*
-		 * Store the remaining nr of pages for the large page
-		 * preservation check.
-		 */
-		cpa->numpages =3D numpages;
-		/* for array changes, we can't use large page */
-		if (cpa->flags & (CPA_ARRAY | CPA_PAGES_ARRAY))
-			cpa->numpages =3D 1;
-
-		if (!debug_pagealloc_enabled())
-			spin_lock(&cpa_lock);
-		ret =3D __change_page_attr(cpa, checkalias);
-		if (!debug_pagealloc_enabled())
-			spin_unlock(&cpa_lock);
-		if (ret)
-			return ret;
-
-		if (checkalias) {
-			ret =3D cpa_process_alias(cpa);
-			if (ret)
+		vaddr =3D cpa_address(cpa, numpages);
+		if (!IS_ERR_VALUE(vaddr)) {
+repeat:
+			ret =3D __change_page_attr(cpa, &kpte, vaddr, checkalias);
+			if (ret < 0)
 				return ret;
+			if (ret) {
+				base =3D alloc_page(GFP_KERNEL|__GFP_NOTRACK);
+				if (!base)
+					return -ENOMEM;
+				if (__split_large_page(cpa, kpte, vaddr, base))
+					__free_page(base);
+				goto repeat;
+			}
+
+			if (checkalias) {
+				ret =3D cpa_process_alias(cpa, vaddr);
+				if (ret < 0)
+					return ret;
+			}
 		}
=20
 		/*
@@ -1374,11 +1368,7 @@ static int __change_page_attr_set_clr(struct cpa_d=
ata *cpa, int checkalias)
 		 */
 		BUG_ON(cpa->numpages > numpages || !cpa->numpages);
 		numpages -=3D cpa->numpages;
-		if (cpa->flags & (CPA_PAGES_ARRAY | CPA_ARRAY))
-			cpa->curpage++;
-		else
-			*cpa->vaddr +=3D cpa->numpages * PAGE_SIZE;
-
+		cpa_advance(cpa);
 	}
 	return 0;
 }

--------------7AC6D09ABF2C56474372EF15--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
