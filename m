Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A6A7E5F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 02:31:40 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n3A6W342001945
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 07:32:04 +0100
Received: from wf-out-1314.google.com (wfc25.prod.google.com [10.142.3.25])
	by zps37.corp.google.com with ESMTP id n3A6VxqO017618
	for <linux-mm@kvack.org>; Thu, 9 Apr 2009 23:32:02 -0700
Received: by wf-out-1314.google.com with SMTP id 25so1165852wfc.22
        for <linux-mm@kvack.org>; Thu, 09 Apr 2009 23:32:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090409230205.310c68a7.akpm@linux-foundation.org>
References: <604427e00904081302m7b29c538u7781cd8f4dd576f2@mail.gmail.com>
	 <20090409230205.310c68a7.akpm@linux-foundation.org>
Date: Thu, 9 Apr 2009 23:32:01 -0700
Message-ID: <604427e00904092332w7e7a3004ne983abc373dd186b@mail.gmail.com>
Subject: Re: [PATCH][1/2]page_fault retry with NOPAGE_RETRY
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, torvalds@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

2009/4/9 Andrew Morton <akpm@linux-foundation.org>:
>
>> Subject: [PATCH][1/2]page_fault retry with NOPAGE_RETRY
>
> Please give each patch in the series a unique and meaningful title.
>
> On Wed, 8 Apr 2009 13:02:35 -0700 Ying Han <yinghan@google.com> wrote:
>
>> support for FAULT_FLAG_RETRY with no user change:
>
> yup, we'd prefer a complete changelog here please.
>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0Mike Waychison <mikew@google.com>
>
> This form:
>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: Mike Waychison <mikew@google.com>

Thanks Andrew,  and i need to add Fengguang to Signed-off-by.

>
> is conventional.
>
>> index 4a853ef..29c2c39 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -793,7 +793,7 @@ struct file_ra_state {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0there are only # of pages ahead */
>>
>> =A0 =A0 =A0 unsigned int ra_pages; =A0 =A0 =A0 =A0 =A0/* Maximum readahe=
ad window */
>> - =A0 =A0 int mmap_miss; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Cache mis=
s stat for mmap accesses */
>> + =A0 =A0 unsigned int mmap_miss; =A0 =A0 =A0 =A0 /* Cache miss stat for=
 mmap accesses */
>
> This change makes sense, but we're not told the reasons for making it?
> Did it fix a bug, or is it an unrelated fixlet, or...?

Fengguang: Could you help making comments on this part? and i will
make changes elsewhere
as Andrew pointed. Thanks

>
>> =A0 =A0 =A0 loff_t prev_pos; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Cache las=
t read() position */
>> =A0};
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index ffee2f7..5a134a9 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -144,6 +144,7 @@ extern pgprot_t protection_map[16];
>>
>> =A0#define FAULT_FLAG_WRITE =A0 =A0 0x01 =A0 =A0/* Fault was a write acc=
ess */
>> =A0#define FAULT_FLAG_NONLINEAR 0x02 =A0 =A0/* Fault was via a nonlinear=
 mapping */
>> +#define FAULT_FLAG_RETRY =A0 =A0 0x04 =A0 =A0/* Retry major fault */
>>
>>
>> =A0/*
>> @@ -690,6 +691,7 @@ static inline int page_mapped(struct page *page)
>>
>> =A0#define VM_FAULT_MINOR =A0 =A0 =A0 0 /* For backwards compat. Remove =
me quickly. */
>>
>> +#define VM_FAULT_RETRY =A0 =A0 =A0 0x0010
>> =A0#define VM_FAULT_OOM 0x0001
>> =A0#define VM_FAULT_SIGBUS =A0 =A0 =A00x0002
>> =A0#define VM_FAULT_MAJOR =A0 =A0 =A0 0x0004
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index f3e5f89..6eb7c36 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -714,6 +714,58 @@ repeat:
>> =A0EXPORT_SYMBOL(find_lock_page);
>>
>> =A0/**
>> + * find_lock_page_retry - locate, pin and lock a pagecache page
>> + * @mapping: the address_space to search
>> + * @offset: the page index
>> + * @vma: vma in which the fault was taken
>> + * @ppage: zero if page not present, otherwise point to the page in pag=
ecache
>> + * @retry: 1 indicate caller tolerate a retry.
>> + *
>> + * If retry flag is on, and page is already locked by someone else, ret=
urn
>> + * a hint of retry and leave *ppage untouched.
>> + *
>> + * Return *ppage=3D=3DNULL if page is not in pagecache. Otherwise retur=
n *ppage
>> + * points to the page in the pagecache with ret=3DVM_FAULT_RETRY indica=
te a
>> + * hint to caller for retry, or ret=3D0 which means page is succefully
>> + * locked.
>> + */
>
> How about this:
>
> =A0If the page was not found in pagecache, find_lock_page_retry()
> =A0returns 0 and sets *@ppage to NULL.
>
> =A0If the page was found in pagecache but is locked and @retry is
> =A0true, find_lock_page_retry() returns VM_FAULT_RETRY and does not
> =A0write to *@ppage.
>
> =A0If the page was found in pagecache and @retry is false,
> =A0find_lock_page_retry() locks the page, writes its address to *@ppage
> =A0and returns 0.
>
>> +unsigned find_lock_page_retry(struct address_space *mapping, pgoff_t of=
fset,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vm_area=
_struct *vma, struct page **ppage,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int retry)
>> +{
>> + =A0 =A0 unsigned int ret =3D 0;
>> + =A0 =A0 struct page *page;
>> +
>> +repeat:
>> + =A0 =A0 page =3D find_get_page(mapping, offset);
>> + =A0 =A0 if (page) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!retry)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_page(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!trylock_page(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mm_stru=
ct *mm =3D vma->vm_mm;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 up_read(&mm->m=
map_sem);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait_on_page_l=
ocked(page);
>
> It looks strange that we wait for the page lock and then don't
> just lock the page and return it.
>
> Adding a comment explaining _why_ we do this would be nice.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 down_read(&mm-=
>mmap_sem);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_rel=
ease(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return VM_FAUL=
T_RETRY;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(page->mapping !=3D mapping)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto repeat;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(page->index !=3D offset);
>> + =A0 =A0 }
>> + =A0 =A0 *ppage =3D page;
>> + =A0 =A0 return ret;
>> +}
>> +EXPORT_SYMBOL(find_lock_page_retry);
>> +
>> +/**
>> =A0 * find_or_create_page - locate or add a pagecache page
>> =A0 * @mapping: the page's address_space
>> =A0 * @index: the page's index into the mapping
>> @@ -1444,6 +1496,8 @@ int filemap_fault(struct vm_area_struct *vma, stru=
ct vm_
>> =A0 =A0 =A0 pgoff_t size;
>> =A0 =A0 =A0 int did_readaround =3D 0;
>> =A0 =A0 =A0 int ret =3D 0;
>> + =A0 =A0 int retry_flag =3D vmf->flags & FAULT_FLAG_RETRY;
>> + =A0 =A0 int retry_ret;
>>
>> =A0 =A0 =A0 size =3D (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_=
CACHE_SHIFT;
>> =A0 =A0 =A0 if (vmf->pgoff >=3D size)
>> @@ -1458,6 +1512,7 @@ int filemap_fault(struct vm_area_struct *vma, stru=
ct vm_
>> =A0 =A0 =A0 =A0*/
>> =A0retry_find:
>> =A0 =A0 =A0 page =3D find_lock_page(mapping, vmf->pgoff);
>> +
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* For sequential accesses, we use the generic readahead l=
ogic.
>> =A0 =A0 =A0 =A0*/
>> @@ -1465,7 +1520,13 @@ retry_find:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!page) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_sync_readahead(ma=
pping, ra, file,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vmf->pgoff, 1);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D find_lock_page(mappin=
g, vmf->pgoff);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retry_ret =3D find_lock_page_r=
etry(mapping, vmf->pgoff,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 vma, &page, retry_flag);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retry_ret =3D=3D VM_FAULT_=
RETRY) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* counteract =
the followed retry hit */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ra->mmap_miss+=
+;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retry_r=
et;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_cach=
ed_page;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> @@ -1504,7 +1565,14 @@ retry_find:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D vm=
f->pgoff - ra_pages / 2;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_page_cache_readahead(mapp=
ing, file, start, ra_pages);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 page =3D find_lock_page(mapping, vmf->pgoff);
>> +retry_find_retry:
>> + =A0 =A0 =A0 =A0 =A0 =A0 retry_ret =3D find_lock_page_retry(mapping, vm=
f->pgoff,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma, &page, re=
try_flag);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (retry_ret =3D=3D VM_FAULT_RETRY) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* counteract the followed ret=
ry hit */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ra->mmap_miss++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retry_ret;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_cached_page;
>> =A0 =A0 =A0 }
>> @@ -1548,7 +1616,7 @@ no_cached_page:
>> =A0 =A0 =A0 =A0* meantime, we'll just come back here and read it again.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 if (error >=3D 0)
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto retry_find;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto retry_find_retry;
>>
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* An error return from page_cache_read can result if the
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 164951c..5e215c9 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2467,6 +2467,13 @@ static int __do_fault(struct mm_struct *mm, struc=
t vm_a
>> =A0 =A0 =A0 vmf.page =3D NULL;
>>
>> =A0 =A0 =A0 ret =3D vma->vm_ops->fault(vma, &vmf);
>> +
>> + =A0 =A0 /* page may be available, but we have to restart the process
>> + =A0 =A0 =A0* because mmap_sem was dropped during the ->fault
>> + =A0 =A0 =A0*/
>
> The preferred comment layout is:
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * The page may be available, but we have to restart the p=
rocess
> =A0 =A0 =A0 =A0 * because mmap_sem was dropped during the ->fault
> =A0 =A0 =A0 =A0 */
>
>> + =A0 =A0 if (ret & VM_FAULT_RETRY)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>
> Again, I worry that in some places we treat VM_FAULT_RETRY as an
> enumerated type:
>
> =A0 =A0 =A0 =A0if (foo =3D=3D VM_FAULT_RETRY)
>
> but in other places we treat it as a bitfield
>
> =A0 =A0 =A0 =A0if (foo & VM_FAULT_RETRY)
>
> it may not be buggy, but it _looks_ buggy. =A0And confusing and
> inconsistent and dangerous.
>
> Can it be improved?
>
>> =A0 =A0 =A0 if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>>
>> @@ -2611,8 +2618,10 @@ static int do_linear_fault(struct mm_struct *mm, =
struct
>> =A0{
>> =A0 =A0 =A0 pgoff_t pgoff =3D (((address & PAGE_MASK)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 - vma->vm_start) >> PAGE_SHI=
FT) + vma->vm_pgoff;
>> - =A0 =A0 unsigned int flags =3D (write_access ? FAULT_FLAG_WRITE : 0);
>> + =A0 =A0 int write =3D write_access & ~FAULT_FLAG_RETRY;
>> + =A0 =A0 unsigned int flags =3D (write ? FAULT_FLAG_WRITE : 0);
>>
>> + =A0 =A0 flags |=3D (write_access & FAULT_FLAG_RETRY);
>
> gee, I'm lost.
>
> Can we please redo this as:
>
>
> =A0 =A0 =A0 =A0int write;
> =A0 =A0 =A0 =A0unsigned int flags;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Big fat comment explaining the next three lines goes he=
re
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0write =3D write_access & ~FAULT_FLAG_RETRY;
> =A0 =A0 =A0 =A0unsigned int flags =3D (write ? FAULT_FLAG_WRITE : 0);
> =A0 =A0 =A0 =A0flags |=3D (write_access & FAULT_FLAG_RETRY);
>
> ?
>
>> =A0 =A0 =A0 pte_unmap(page_table);
>> =A0 =A0 =A0 return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_=
pte);
>> =A0}
>> @@ -2726,26 +2735,32 @@ int handle_mm_fault(struct mm_struct *mm, struct=
 vm_ar
>> =A0 =A0 =A0 pud_t *pud;
>> =A0 =A0 =A0 pmd_t *pmd;
>> =A0 =A0 =A0 pte_t *pte;
>> + =A0 =A0 int ret;
>>
>> =A0 =A0 =A0 __set_current_state(TASK_RUNNING);
>>
>> - =A0 =A0 count_vm_event(PGFAULT);
>> -
>> - =A0 =A0 if (unlikely(is_vm_hugetlb_page(vma)))
>> - =A0 =A0 =A0 =A0 =A0 =A0 return hugetlb_fault(mm, vma, address, write_a=
ccess);
>> + =A0 =A0 if (unlikely(is_vm_hugetlb_page(vma))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D hugetlb_fault(mm, vma, address, write_=
access);
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 }
>>
>> + =A0 =A0 ret =3D VM_FAULT_OOM;
>> =A0 =A0 =A0 pgd =3D pgd_offset(mm, address);
>> =A0 =A0 =A0 pud =3D pud_alloc(mm, pgd, address);
>> =A0 =A0 =A0 if (!pud)
>> - =A0 =A0 =A0 =A0 =A0 =A0 return VM_FAULT_OOM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 pmd =3D pmd_alloc(mm, pud, address);
>> =A0 =A0 =A0 if (!pmd)
>> - =A0 =A0 =A0 =A0 =A0 =A0 return VM_FAULT_OOM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 pte =3D pte_alloc_map(mm, pmd, address);
>> =A0 =A0 =A0 if (!pte)
>> - =A0 =A0 =A0 =A0 =A0 =A0 return VM_FAULT_OOM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> - =A0 =A0 return handle_pte_fault(mm, vma, address, pte, pmd, write_acce=
ss);
>> + =A0 =A0 ret =3D handle_pte_fault(mm, vma, address, pte, pmd, write_acc=
ess);
>> +out:
>> + =A0 =A0 if (!(ret & VM_FAULT_RETRY))
>> + =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(PGFAULT);
>> + =A0 =A0 return ret;
>> =A0}
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
