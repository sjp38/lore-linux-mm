Date: Thu, 26 Jun 2008 03:05:10 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 5/5] Convert anon_vma spinlock to rw semaphore
Message-ID: <20080626010510.GC6938@duo.random>
References: <20080626003632.049547282@sgi.com> <20080626003833.966166360@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080626003833.966166360@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, apw@shadowen.org, Hugh Dickins <hugh@veritas.com>, holt@sgi.com, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 25, 2008 at 05:36:37PM -0700, Christoph Lameter wrote:
> However:
> - Atomic overhead increases in situations where a new reference
>   to the anon_vma has to be established or removed. Overhead also increases
>   when a speculative reference is used (try_to_unmap,
>   page_mkclean, page migration).
> - There is the potential for more frequent processor change due to up_xxx
>   letting waiting tasks run first.

You dropped the benchmark numbers from the comment, that was useful
data. You may want to re-run the benchmark on different hardware just
to be sure it was valid though (just to be sure it's a significant
regression for AIM).

>  void __anon_vma_link(struct vm_area_struct *vma)
>  {
>  	struct anon_vma *anon_vma = vma->anon_vma;
>  
> -	if (anon_vma)
> +	if (anon_vma) {
> +		get_anon_vma(anon_vma);
>  		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
> +	}
>  }

Last time I checked this code the above get_anon_vma was superfluous.

Below a quote of the email where I already pointed this out once in
the middle of the mmu notifier email flooding, so it's fair enough
that it got lost in the noise ;).

I recommend to optimize this and re-run the benchmark and see if my
optimization makes the -10% slowdown go away in AIM. If it does then
it's surely more reasonable to merge those unconditionally. Unless we
can prove no slowdown in small-smp, I doubt it's ok to merge this one
unconditionally (and I also doubt my optimization will fix AIM as it
only removes a atomic op for each vma in fork, and similar during vma
teardown).

Thanks!

------------
Secondly we don't need to increase the refcount in fork() when we
queue the vma-copy in the anon_vma. You should init the refcount to 1
when the anon_vma is allocated, remove the atomic_inc from all code
(except when down_read_trylock fails) and then change anon_vma_unlink
to:

        up_write(&anon_vma->sem);
        if (empty)
                put_anon_vma(anon_vma);

While the down_read_trylock surely won't help in AIM, the second
change will reduce a bit the overhead in the VM core fast paths by
avoiding all refcounting changes by checking the list_empty the same
way the current code does. I really like how I designed the garbage 
collection through list_empty and that's efficient and I'd like to
keep it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
