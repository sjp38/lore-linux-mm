Date: Thu, 19 Jun 2008 11:32:58 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
	pte and _count=2?
Message-ID: <20080619163258.GD10062@sgi.com>
References: <20080618164158.GC10062@sgi.com> <200806190329.30622.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806181944080.4968@blonde.site> <20080618203300.GA10123@sgi.com> <Pine.LNX.4.64.0806182209320.16252@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806182209320.16252@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 18, 2008 at 10:46:09PM +0100, Hugh Dickins wrote:
> On Wed, 18 Jun 2008, Robin Holt wrote:
> > On Wed, Jun 18, 2008 at 08:01:48PM +0100, Hugh Dickins wrote:
> --- 2.6.26-rc6/mm/memory.c	2008-05-26 20:00:39.000000000 +0100
> +++ linux/mm/memory.c	2008-06-18 22:06:46.000000000 +0100
> @@ -1152,9 +1152,15 @@ int get_user_pages(struct task_struct *t
>  				 * do_wp_page has broken COW when necessary,
>  				 * even if maybe_mkwrite decided not to set
>  				 * pte_write. We can thus safely do subsequent
> -				 * page lookups as if they were reads.
> +				 * page lookups as if they were reads. But only
> +				 * do so when looping for pte_write is futile:
> +				 * in some cases userspace may also be wanting
> +				 * to write to the gotten user page, which a
> +				 * read fault here might prevent (a readonly
> +				 * page would get reCOWed by userspace write).
>  				 */
> -				if (ret & VM_FAULT_WRITE)
> +				if ((ret & VM_FAULT_WRITE) &&
> +				    !(vma->vm_flags & VM_WRITE))
>  					foll_flags &= ~FOLL_WRITE;
>  
>  				cond_resched();

I applied the equivalent of this to the sles10 kernel and still saw the
problem.  I also changed the driver to use force=0 and gave more memory
to the test.  That passed in the same way as force=1.  I then restricted
memory and got the same failure.

I am not convinced yet that we can use force=0 yet since I do not recall
the reason for force=1 being used.  I will look into that seperately
from this.

I am working on putting in a trap to detect the problem closer to the
time of failure.

Thanks,
Robin Holt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
