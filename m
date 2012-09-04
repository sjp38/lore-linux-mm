Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 3DF846B0062
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 10:27:52 -0400 (EDT)
Date: Tue, 4 Sep 2012 16:27:45 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/7] mm: fix potential anon_vma locking issue in
 mprotect()
Message-ID: <20120904142745.GE3334@redhat.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
 <1346750457-12385-3-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346750457-12385-3-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

Hi Michel,

On Tue, Sep 04, 2012 at 02:20:52AM -0700, Michel Lespinasse wrote:
> This change fixes an anon_vma locking issue in the following situation:
> - vma has no anon_vma
> - next has an anon_vma
> - vma is being shrunk / next is being expanded, due to an mprotect call
> 
> We need to take next's anon_vma lock to avoid races with rmap users
> (such as page migration) while next is being expanded.
> 
> This change also removes an optimization which avoided taking anon_vma
> lock during brk adjustments. We could probably make that optimization
> work again, but the following anon rmap change would break it,
> so I kept things as simple as possible here.

Agreed, definitely a bug not to take the lock whenever any
vm_start/vm_pgoff are moved, regardless if they're the next or current
vma. Only vm_end can be moved without taking the lock.

I'd prefer to fix it like this though:

-	if (vma->anon_vma && (importer || start != vma->vm_start)) {
+	if ((vma->anon_vma && (importer || start != vma->vm_start) ||
+           (adjust_next && next->anon_vma)) {

The strict fix is just to check also if we're moving next->vm_start or
not, and the lock is only needed if next->anon_vma is set (otherwise
there's no page yet set in the vma and we hold the mmap_sem in write
mode clearly that prevents new pages to be instantiated under us).

Plus we know if adjust_next is set, next is not null, so the above
should work. The already existing (optimized) check for the "vma"
should have been ok, so no need to de-optimize it.

Then it's still fine to retain the VM_BUG_ON in the branch where
anon_vma was not null.

Thanks!
Andrea

> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> ---
>  mm/mmap.c |   14 ++++++--------
>  1 files changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index cebc346ba0db..5e64c7dfc090 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -570,14 +570,12 @@ again:			remove_next = 1 + (end > next->vm_end);
>  
>  	vma_adjust_trans_huge(vma, start, end, adjust_next);
>  
> -	/*
> -	 * When changing only vma->vm_end, we don't really need anon_vma
> -	 * lock. This is a fairly rare case by itself, but the anon_vma
> -	 * lock may be shared between many sibling processes.  Skipping
> -	 * the lock for brk adjustments makes a difference sometimes.
> -	 */
> -	if (vma->anon_vma && (importer || start != vma->vm_start)) {
> -		anon_vma = vma->anon_vma;
> +	anon_vma = vma->anon_vma;
> +	if (!anon_vma && adjust_next)
> +		anon_vma = next->anon_vma;
> +	if (anon_vma) {
> +		VM_BUG_ON(adjust_next && next->anon_vma &&
> +			  anon_vma != next->anon_vma);
>  		anon_vma_lock(anon_vma);
>  	}
>  
> -- 
> 1.7.7.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
