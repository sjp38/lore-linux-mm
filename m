Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 617316B0028
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 14:11:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 3so1575333wrb.5
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 11:11:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l1si3326643edc.306.2018.03.28.11.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 11:11:42 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2SIAunJ077462
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 14:11:41 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h0efp4h70-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 14:11:41 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 28 Mar 2018 19:11:38 +0100
Subject: Re: [PATCH v9 09/24] mm: protect mremap() against SPF hanlder
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-10-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803271500540.43106@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 28 Mar 2018 20:11:28 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803271500540.43106@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <1fe7529a-947c-fdb2-12d2-b38bdd41bb04@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org



On 28/03/2018 00:12, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 88042d843668..ef6ef0627090 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2189,16 +2189,24 @@ void anon_vma_interval_tree_verify(struct anon_vma_chain *node);
>>  extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
>>  extern int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>  	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
>> -	struct vm_area_struct *expand);
>> +	struct vm_area_struct *expand, bool keep_locked);
>>  static inline int vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>  	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
>>  {
>> -	return __vma_adjust(vma, start, end, pgoff, insert, NULL);
>> +	return __vma_adjust(vma, start, end, pgoff, insert, NULL, false);
>>  }
>> -extern struct vm_area_struct *vma_merge(struct mm_struct *,
>> +extern struct vm_area_struct *__vma_merge(struct mm_struct *,
>>  	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
>>  	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
>> -	struct mempolicy *, struct vm_userfaultfd_ctx);
>> +	struct mempolicy *, struct vm_userfaultfd_ctx, bool keep_locked);
>> +static inline struct vm_area_struct *vma_merge(struct mm_struct *vma,
>> +	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
>> +	unsigned long vm_flags, struct anon_vma *anon, struct file *file,
>> +	pgoff_t off, struct mempolicy *pol, struct vm_userfaultfd_ctx uff)
>> +{
>> +	return __vma_merge(vma, prev, addr, end, vm_flags, anon, file, off,
>> +			   pol, uff, false);
>> +}
> 
> The first formal to vma_merge() is an mm, not a vma.

Oops !

> This area could use an uncluttering.
> 
>>  extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
>>  extern int __split_vma(struct mm_struct *, struct vm_area_struct *,
>>  	unsigned long addr, int new_below);
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index d6533cb85213..ac32b577a0c9 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -684,7 +684,7 @@ static inline void __vma_unlink_prev(struct mm_struct *mm,
>>   */
>>  int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>  	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
>> -	struct vm_area_struct *expand)
>> +	struct vm_area_struct *expand, bool keep_locked)
>>  {
>>  	struct mm_struct *mm = vma->vm_mm;
>>  	struct vm_area_struct *next = vma->vm_next, *orig_vma = vma;
>> @@ -996,7 +996,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>  
>>  	if (next && next != vma)
>>  		vm_raw_write_end(next);
>> -	vm_raw_write_end(vma);
>> +	if (!keep_locked)
>> +		vm_raw_write_end(vma);
>>  
>>  	validate_mm(mm);
>>  
> 
> This will require a fixup for the following patch where a retval from 
> anon_vma_close() can also return without vma locked even though 
> keep_locked == true.

Yes I saw your previous email about that.

> 
> How does vma_merge() handle that error wrt vm_raw_write_begin(vma)?

The not written assumption is that in the case __vma_adjust() is returning an
error, the vma is no more sequence locked. That's need to be clarify a huge
comment near the __vma_adjust() definition.

This being said, in that case of __vma_merge() is returning NULL which means
that it didn't do the job (the caller don't know if this is due to an error or
because the VMA cannot be merged). In that case again the assumption is that
the VMA are no locked in that case since the merge operation was not done. But
again this is not documented at all and I've to fix that.
In addition the caller copy_vma() which is the only one calling __vma_merge()
with keep_locked=true, is assuming that in that case, the VMA is not locked and
it will allocate a new VMA which will be locked before it is inserted in the RB
tree.

So it should work, but I've to make a huge effort to document that in the code.
Thanks a lot for raising this !

> 
>> @@ -1132,12 +1133,13 @@ can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
>>   * parameter) may establish ptes with the wrong permissions of NNNN
>>   * instead of the right permissions of XXXX.
>>   */
>> -struct vm_area_struct *vma_merge(struct mm_struct *mm,
>> +struct vm_area_struct *__vma_merge(struct mm_struct *mm,
>>  			struct vm_area_struct *prev, unsigned long addr,
>>  			unsigned long end, unsigned long vm_flags,
>>  			struct anon_vma *anon_vma, struct file *file,
>>  			pgoff_t pgoff, struct mempolicy *policy,
>> -			struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
>> +			struct vm_userfaultfd_ctx vm_userfaultfd_ctx,
>> +			bool keep_locked)
>>  {
>>  	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
>>  	struct vm_area_struct *area, *next;
>> @@ -1185,10 +1187,11 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
>>  							/* cases 1, 6 */
>>  			err = __vma_adjust(prev, prev->vm_start,
>>  					 next->vm_end, prev->vm_pgoff, NULL,
>> -					 prev);
>> +					 prev, keep_locked);
>>  		} else					/* cases 2, 5, 7 */
>>  			err = __vma_adjust(prev, prev->vm_start,
>> -					 end, prev->vm_pgoff, NULL, prev);
>> +					   end, prev->vm_pgoff, NULL, prev,
>> +					   keep_locked);
>>  		if (err)
>>  			return NULL;
>>  		khugepaged_enter_vma_merge(prev, vm_flags);
>> @@ -1205,10 +1208,12 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
>>  					     vm_userfaultfd_ctx)) {
>>  		if (prev && addr < prev->vm_end)	/* case 4 */
>>  			err = __vma_adjust(prev, prev->vm_start,
>> -					 addr, prev->vm_pgoff, NULL, next);
>> +					 addr, prev->vm_pgoff, NULL, next,
>> +					 keep_locked);
>>  		else {					/* cases 3, 8 */
>>  			err = __vma_adjust(area, addr, next->vm_end,
>> -					 next->vm_pgoff - pglen, NULL, next);
>> +					 next->vm_pgoff - pglen, NULL, next,
>> +					 keep_locked);
>>  			/*
>>  			 * In case 3 area is already equal to next and
>>  			 * this is a noop, but in case 8 "area" has
>> @@ -3163,9 +3168,20 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>>  
>>  	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
>>  		return NULL;	/* should never get here */
>> -	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
>> -			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
>> -			    vma->vm_userfaultfd_ctx);
>> +
>> +	/* There is 3 cases to manage here in
>> +	 *     AAAA            AAAA              AAAA              AAAA
>> +	 * PPPP....      PPPP......NNNN      PPPP....NNNN      PP........NN
>> +	 * PPPPPPPP(A)   PPPP..NNNNNNNN(B)   PPPPPPPPPPPP(1)       NULL
>> +	 *                                   PPPPPPPPNNNN(2)
>> +	 *				     PPPPNNNNNNNN(3)
>> +	 *
>> +	 * new_vma == prev in case A,1,2
>> +	 * new_vma == next in case B,3
>> +	 */
> 
> Interleaved tabs and whitespace.

Fair enough, I will try to fix that.

>> +	new_vma = __vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
>> +			      vma->anon_vma, vma->vm_file, pgoff,
>> +			      vma_policy(vma), vma->vm_userfaultfd_ctx, true);
>>  	if (new_vma) {
>>  		/*
>>  		 * Source vma may have been merged into new_vma
>> @@ -3205,6 +3221,15 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>>  			get_file(new_vma->vm_file);
>>  		if (new_vma->vm_ops && new_vma->vm_ops->open)
>>  			new_vma->vm_ops->open(new_vma);
>> +		/*
>> +		 * As the VMA is linked right now, it may be hit by the
>> +		 * speculative page fault handler. But we don't want it to
>> +		 * to start mapping page in this area until the caller has
>> +		 * potentially move the pte from the moved VMA. To prevent
>> +		 * that we protect it right now, and let the caller unprotect
>> +		 * it once the move is done.
>> +		 */
>> +		vm_raw_write_begin(new_vma);
>>  		vma_link(mm, new_vma, prev, rb_link, rb_parent);
>>  		*need_rmap_locks = false;
>>  	}
>> diff --git a/mm/mremap.c b/mm/mremap.c
>> index 049470aa1e3e..8ed1a1d6eaed 100644
>> --- a/mm/mremap.c
>> +++ b/mm/mremap.c
>> @@ -302,6 +302,14 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>>  	if (!new_vma)
>>  		return -ENOMEM;
>>  
>> +	/* new_vma is returned protected by copy_vma, to prevent speculative
>> +	 * page fault to be done in the destination area before we move the pte.
>> +	 * Now, we must also protect the source VMA since we don't want pages
>> +	 * to be mapped in our back while we are copying the PTEs.
>> +	 */
>> +	if (vma != new_vma)
>> +		vm_raw_write_begin(vma);
>> +
>>  	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len,
>>  				     need_rmap_locks);
>>  	if (moved_len < old_len) {
>> @@ -318,6 +326,8 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>>  		 */
>>  		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len,
>>  				 true);
>> +		if (vma != new_vma)
>> +			vm_raw_write_end(vma);
>>  		vma = new_vma;
>>  		old_len = new_len;
>>  		old_addr = new_addr;
>> @@ -326,7 +336,10 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>>  		mremap_userfaultfd_prep(new_vma, uf);
>>  		arch_remap(mm, old_addr, old_addr + old_len,
>>  			   new_addr, new_addr + new_len);
>> +		if (vma != new_vma)
>> +			vm_raw_write_end(vma);
>>  	}
>> +	vm_raw_write_end(new_vma);
> 
> Just do
> 
> vm_raw_write_end(vma);
> vm_raw_write_end(new_vma);
> 
> here.

Are you sure ? we can have vma = new_vma done if (unlikely(err))

Cheers,
Laurent.
