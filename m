From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sun, 14 Jan 2007 21:06:20 +1100 (EST)
Subject: Re: [PATCH 0/29] Page Table Interface Explanation
In-Reply-To: <1168716541.5975.23.camel@lappy>
Message-ID: <Pine.LNX.4.64.0701142049380.3687@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
 <1168716541.5975.23.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Paul Davies <pauld@gelato.unsw.edu.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peter

> weird naming, functions are not iterators, if named after what they do
> it should be *_iteration.

Sorry.  I had genuine "iterators" in a previous attempted PTI and never
changed my naming convention.

> But still, I would have expected an iterator based interface; something
> along the lines of:
>
> typedef struct pti_struct {
>  struct mm_struct *mm;
>  pgd_t *pgd;
>  pud_t *pud;
>  pmd_t *pmd;
>  pte_t *pte;
>  spinlock_t *ptl;
>  unsigned long address;
> } pti_t
>
> with accessors like:
>
> #define pti_address(pti) (pti).address
> #define pti_pte(pti) (pti).pte
>
> and methods like:
>
> bool pti_valid(pti_t *pti);
> pti_t pti_lookup(struct mm_struct *mm, unsigned long address);
> pti_t pti_acquire(struct mm_struct *mm, unsigned long address);
> void pti_release(pti_t *pti);
>
> bool pti_next(pti_t *pti);
>
> so that you could write the typical loops like:
>
>  int ret = 0;
>
>  pti_t *pri = pti_lookup(mm, start);
>  do_for_each_pti_range(pti, end) {
>    if (per_pte_op(pti_pte(pti))) {
>      ret = -EFOO;
>      break;
>    }
>  } while_for_each_pti_range(pti, end);
>  pti_release(pti);
>
>  return ret;
>
> where do_for_each_pti_range() and while_for_each_pti_range() look
> something like:
>
> #define do_for_each_pti_range(pti, end) \
>  if (pti_valid(pti) && pti_address(pti) < end) do
>
> #define while_for_each_pti_range(pti, end) \
>  while (pti_next(pti) && pti_valid(pti) && pti_address(pti) < end)
Excellent.

After LCA, I will take what you have given me, and do a version based
around what you would have expected to see.  I hope that you will be 
able to find the time to have a quick look at it :)

Cheers

Paul Davies

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
