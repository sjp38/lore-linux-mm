Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id C7CB16B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 09:49:40 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id w104so152236279qge.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 06:49:40 -0700 (PDT)
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com. [129.33.205.207])
        by mx.google.com with ESMTPS id f125si11216385qkb.95.2016.03.21.06.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 06:49:39 -0700 (PDT)
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 21 Mar 2016 09:49:39 -0400
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6E7CB6E8040
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 09:36:26 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2LDnapH25034884
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 13:49:36 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2LDnYMI005928
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 09:49:35 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 21/29] HMM: mm add helper to update page table when migrating memory back v2.
In-Reply-To: <20160321120251.GA4518@gmail.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com> <1457469802-11850-22-git-send-email-jglisse@redhat.com> <877fgwul3v.fsf@linux.vnet.ibm.com> <20160321120251.GA4518@gmail.com>
Date: Mon, 21 Mar 2016 19:18:41 +0530
Message-ID: <871t74uekm.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

Jerome Glisse <j.glisse@gmail.com> writes:

> [ text/plain ]
> On Mon, Mar 21, 2016 at 04:57:32PM +0530, Aneesh Kumar K.V wrote:
>> J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> writes:
>
> [...]
>
>> > +
>> > +#ifdef CONFIG_HMM
>> > +/* mm_hmm_migrate_back() - lock HMM CPU page table entry and allocate=
 new page.
>> > + *
>> > + * @mm: The mm struct.
>> > + * @vma: The vm area struct the range is in.
>> > + * @new_pte: Array of new CPU page table entry value.
>> > + * @start: Start address of the range (inclusive).
>> > + * @end: End address of the range (exclusive).
>> > + *
>> > + * This function will lock HMM page table entry and allocate new page=
 for entry
>> > + * it successfully locked.
>> > + */
>>=20
>>=20
>> Can you add more comments around this ?
>
> I should describe the process a bit more i guess. It is multi-step, first=
 we update
> CPU page table with special HMM "lock" entry, this is to exclude concurre=
nt migration
> happening on same page. Once we have "locked" the CPU page table entry we=
 allocate
> the proper number of pages. Then we schedule the dma from the GPU to this=
 pages and
> once it is done we update the CPU page table to point to this pages. This=
 is why we
> are going over the page table so many times. This should answer most of y=
our questions
> below but i still provide answer for each of them.
>
>>=20
>> > +int mm_hmm_migrate_back(struct mm_struct *mm,
>> > +			struct vm_area_struct *vma,
>> > +			pte_t *new_pte,
>> > +			unsigned long start,
>> > +			unsigned long end)
>> > +{
>> > +	pte_t hmm_entry =3D swp_entry_to_pte(make_hmm_entry_locked());
>> > +	unsigned long addr, i;
>> > +	int ret =3D 0;
>> > +
>> > +	VM_BUG_ON(vma->vm_ops || (vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
>> > +
>> > +	if (unlikely(anon_vma_prepare(vma)))
>> > +		return -ENOMEM;
>> > +
>> > +	start &=3D PAGE_MASK;
>> > +	end =3D PAGE_ALIGN(end);
>> > +	memset(new_pte, 0, sizeof(pte_t) * ((end - start) >> PAGE_SHIFT));
>> > +
>> > +	for (addr =3D start; addr < end;) {
>> > +		unsigned long cstart, next;
>> > +		spinlock_t *ptl;
>> > +		pgd_t *pgdp;
>> > +		pud_t *pudp;
>> > +		pmd_t *pmdp;
>> > +		pte_t *ptep;
>> > +
>> > +		pgdp =3D pgd_offset(mm, addr);
>> > +		pudp =3D pud_offset(pgdp, addr);
>> > +		/*
>> > +		 * Some other thread might already have migrated back the entry
>> > +		 * and freed the page table. Unlikely thought.
>> > +		 */
>> > +		if (unlikely(!pudp)) {
>> > +			addr =3D min((addr + PUD_SIZE) & PUD_MASK, end);
>> > +			continue;
>> > +		}
>> > +		pmdp =3D pmd_offset(pudp, addr);
>> > +		if (unlikely(!pmdp || pmd_bad(*pmdp) || pmd_none(*pmdp) ||
>> > +			     pmd_trans_huge(*pmdp))) {
>> > +			addr =3D min((addr + PMD_SIZE) & PMD_MASK, end);
>> > +			continue;
>> > +		}
>> > +		ptep =3D pte_offset_map_lock(mm, pmdp, addr, &ptl);
>> > +		for (cstart =3D addr, i =3D (addr - start) >> PAGE_SHIFT,
>> > +		     next =3D min((addr + PMD_SIZE) & PMD_MASK, end);
>> > +		     addr < next; addr +=3D PAGE_SIZE, ptep++, i++) {
>> > +			swp_entry_t entry;
>> > +
>> > +			entry =3D pte_to_swp_entry(*ptep);
>> > +			if (pte_none(*ptep) || pte_present(*ptep) ||
>> > +			    !is_hmm_entry(entry) ||
>> > +			    is_hmm_entry_locked(entry))
>> > +				continue;
>> > +
>> > +			set_pte_at(mm, addr, ptep, hmm_entry);
>> > +			new_pte[i] =3D pte_mkspecial(pfn_pte(my_zero_pfn(addr),
>> > +						   vma->vm_page_prot));
>> > +		}
>> > +		pte_unmap_unlock(ptep - 1, ptl);
>>=20
>>=20
>> I guess this is fixing all the ptes in the cpu page table mapping a pmd
>> entry. But then what is below ?
>
> Because we are dealing with special swap entry we know we can not have hu=
ge pages.
> So we only care about HMM special swap entry. We record entry we want to =
migrate
> in the new_pte array. The loop above is under pmd spin lock, the loop bel=
ow does
> memory allocation and we do not want to hold any spin lock while doing al=
location.
>

Can this go as code comment ?

>>=20
>> > +
>> > +		for (addr =3D cstart, i =3D (addr - start) >> PAGE_SHIFT;
>> > +		     addr < next; addr +=3D PAGE_SIZE, i++) {
>>=20
>> Your use of vairable addr with multiple loops updating then is also
>> making it complex. We should definitely add more comments here. I guess
>> we are going through the same range we iterated above here.
>
> Correct we are going over the exact same range, i am keeping the addr only
> for alloc_zeroed_user_highpage_movable() purpose.
>

Can we use a different variable name there ?

>>=20
>> > +			struct mem_cgroup *memcg;
>> > +			struct page *page;
>> > +
>> > +			if (!pte_present(new_pte[i]))
>> > +				continue;
>>=20
>> What is that checking for ?. We set that using pte_mkspecial above ?
>
> Not all entry in the range might match the criteria (ie special unlocked =
HMM swap
> entry). We want to allocate pages only for entry that match the criteria.
>

Since we did in the beginning,=20
	memset(new_pte, 0, sizeof(pte_t) * ((end - start) >> PAGE_SHIFT));

we should not find present bit set ? using present there is confusing,
may be pte_none(). Also with comments around explaining the details ?

>>=20
>> > +
>> > +			page =3D alloc_zeroed_user_highpage_movable(vma, addr);
>> > +			if (!page) {
>> > +				ret =3D -ENOMEM;
>> > +				break;
>> > +			}
>> > +			__SetPageUptodate(page);
>> > +			if (mem_cgroup_try_charge(page, mm, GFP_KERNEL,
>> > +						  &memcg)) {
>> > +				page_cache_release(page);
>> > +				ret =3D -ENOMEM;
>> > +				break;
>> > +			}
>> > +			/*
>> > +			 * We can safely reuse the s_mem/mapping field of page
>> > +			 * struct to store the memcg as the page is only seen
>> > +			 * by HMM at this point and we can clear it before it
>> > +			 * is public see mm_hmm_migrate_back_cleanup().
>> > +			 */
>> > +			page->s_mem =3D memcg;
>> > +			new_pte[i] =3D mk_pte(page, vma->vm_page_prot);
>> > +			if (vma->vm_flags & VM_WRITE) {
>> > +				new_pte[i] =3D pte_mkdirty(new_pte[i]);
>> > +				new_pte[i] =3D pte_mkwrite(new_pte[i]);
>> > +			}
>>=20
>> Why mark it dirty if vm_flags is VM_WRITE ?
>
> It is a left over of some debuging i was doing, i missed it.
>
>>=20
>> > +		}
>> > +
>> > +		if (!ret)
>> > +			continue;
>> > +
>> > +		hmm_entry =3D swp_entry_to_pte(make_hmm_entry());
>> > +		ptep =3D pte_offset_map_lock(mm, pmdp, addr, &ptl);
>>=20
>>=20
>> Again we loop through the same range ?
>
> Yes but this is the out of memory code path here, ie we have to split the=
 migration
> into several pass. So what happen here is we clear the new_pte array for =
entry we
> failed to allocate a page for.
>
>>=20
>> > +		for (addr =3D cstart, i =3D (addr - start) >> PAGE_SHIFT;
>> > +		     addr < next; addr +=3D PAGE_SIZE, ptep++, i++) {
>> > +			unsigned long pfn =3D pte_pfn(new_pte[i]);
>> > +
>> > +			if (!pte_present(new_pte[i]) || !is_zero_pfn(pfn))
>> > +				continue;
>>=20



So here we are using the fact that we had set new pte using zero pfn in
the firs loop and hence if we find a present new_pte with zero pfn, it impl=
ies we
failed to allocate a page for that ?

>>=20
>> What is that checking for ?
>
> If new_pte entry is not present then it is not something we want to migra=
te. If it
> is present but does not point to zero pfn then it is an entry for which w=
e allocated
> a page so we want to keep it.
>
>> > +
>> > +			set_pte_at(mm, addr, ptep, hmm_entry);
>> > +			pte_clear(mm, addr, &new_pte[i]);
>>=20
>> what is that pte_clear for ?. Handling of new_pte needs more code commen=
ts.
>>=20
>
> Entry for which we failed to allocate memory we clear the special HMM swa=
p entry
> as well as the new_pte entry so that migration code knows it does not hav=
e to do
> anything here.
>

So that pte_clear is not expecting to do any sort of tlb flushes etc ? The
idea is to put new_pte =3D 0 ?.=20=20

Can we do all those conditionals without using pte bits ? A check like
pte_present, is_zero_pfn etc confuse the reader. Instead can
we do

if (pte_state[i] =3D=3D SKIP_LOOP_FIRST)

if (pte_state[i] =3D=3D SKIP_LOOP_SECOND)

I understand that we want to return new_pte array with valid pages, so
may be the above will make code complex, but atleast code should have
more comments explaining each step

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
