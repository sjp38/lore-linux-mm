Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA16688
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 13:45:27 -0500
Date: Mon, 30 Nov 1998 13:52:08 GMT
Message-Id: <199811301352.NAA03313@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Update shared mappings
In-Reply-To: <87btm3dmxy.fsf@atlas.CARNet.hr>
References: <87btm3dmxy.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>, Zlatko.Calusic@CARNet.hr
Cc: Linux-MM List <linux-mm@kvack.org>, Andi Kleen <andi@zero.aec.at>
List-ID: <linux-mm.kvack.org>

Hi,

On 20 Nov 1998 05:10:01 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> Should this patch be applied to kernel? [Andrea's
> update_shared_mappings patch]

No.

> Index: 129.2/mm/filemap.c
> --- 129.2/mm/filemap.c Thu, 19 Nov 1998 18:20:34 +0100 zcalusic (linux-2.1/y/b/29_filemap.c 1.2.4.1.1.1.1.1 644)
> +++ 129.3/mm/filemap.c Fri, 20 Nov 1998 05:07:24 +0100 zcalusic (linux-2.1/y/b/29_filemap.c 1.2.4.1.1.1.1.2 644)
> @@ -5,6 +5,10 @@
>   */
 
> +static void update_one_shared_mapping(struct vm_area_struct *shared,
> +				      unsigned long address, pte_t orig_pte)
> +{
> +	pgd_t *pgd;
> +	pmd_t *pmd;
> +	pte_t *pte;
> +	struct semaphore * mmap_sem = &shared->vm_mm->mmap_sem;
> +
> +	down(mmap_sem);

The mmap_semaphore is already taken out _much_ earlier on in msync(), or
the vm_area_struct can be destroyed by another thread.  Is this patch
tested?  Won't we deadlock immediately on doing this extra down()
operation? 

The only reason that this patch works in its current state is that
exit_mmap() skips the down(&mm->mmap_sem).  It can safely do so only
because if we are exiting the mmap, we know we are the last thread and
so no other thread can be playing games with us.  So, exit_mmap()
doesn't deadlock, but a sys_msync() on the region looks as if it will.

Other than that, it looks fine.  One other thing occurs to me, though:
it would be easy enough to add a condition (atomic_read(&page->count) >
2) on this to disable the update-mappings call entirely if the page is
only mapped by one vma (which will be a very common case).  We already
access the count field, so we are avoiding the cost of any extra cache
misses if we make this check.

Comments?

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
