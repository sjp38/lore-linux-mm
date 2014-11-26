Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id B552B6B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 12:35:21 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id hi2so5758861wib.17
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 09:35:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cj1si8982848wib.103.2014.11.26.09.35.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Nov 2014 09:35:20 -0800 (PST)
Date: Wed, 26 Nov 2014 18:35:17 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
Message-ID: <20141126173517.GA8180@dhcp22.suse.cz>
References: <546CC0CD.40906@suse.cz>
 <CALYGNiO9_bAVVZ2GdFq=PO2yV3LPs2utsbcb2pFby7MypptLCw@mail.gmail.com>
 <CANN689G+y77m2_paF0vBpHG8EsJ2-pEnJvLJSGs-zHf+SqTEjQ@mail.gmail.com>
 <CALYGNiOC4dEzzVzSQXGC4oxLbgp=8TC=A+duJs67jT97TWQ++g@mail.gmail.com>
 <546DFFA1.4030700@redhat.com>
 <CALYGNiP_zqAucmN=Gn75Mm2wK1iE6fPNxTsaTRgnUbFbFE7C-g@mail.gmail.com>
 <CALYGNiO9NSpCFcRezArgfqzLQcTx2DnFYWYgpyK2HFyCnuGLOA@mail.gmail.com>
 <20141125105953.GC4607@dhcp22.suse.cz>
 <CALYGNiPZmf4Y1_vX_FaiALKp-BPvct7fAiaPEjnDGnVx9paS9w@mail.gmail.com>
 <20141125150006.GB4415@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141125150006.GB4415@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>

On Tue 25-11-14 16:00:06, Michal Hocko wrote:
> On Tue 25-11-14 16:13:16, Konstantin Khlebnikov wrote:
> > On Tue, Nov 25, 2014 at 1:59 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > > On Mon 24-11-14 11:09:40, Konstantin Khlebnikov wrote:
> > >> On Thu, Nov 20, 2014 at 6:03 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> > >> > On Thu, Nov 20, 2014 at 5:50 PM, Rik van Riel <riel@redhat.com> wrote:
> > >> >> -----BEGIN PGP SIGNED MESSAGE-----
> > >> >> Hash: SHA1
> > >> >>
> > >> >> On 11/20/2014 09:42 AM, Konstantin Khlebnikov wrote:
> > >> >>
> > >> >>> I'm thinking about limitation for reusing anon_vmas which might
> > >> >>> increase performance without breaking asymptotic estimation of
> > >> >>> count anon_vma in the worst case. For example this heuristic: allow
> > >> >>> to reuse only anon_vma with single direct descendant. It seems
> > >> >>> there will be arount up to two times more anon_vmas but
> > >> >>> false-aliasing must be much lower.
> > >>
> > >> Done. RFC patch in attachment.

Ok, finally managed to untagnle myself from vma chains and your patch
makes sense to me, it is quite clever actually. Here is it including the
fixup.
---
> From 1d4b0b38198c69ecfeb37670cb1dda767a802c9a Mon Sep 17 00:00:00 2001
> From: Konstantin Khlebnikov <koct9i@gmail.com>
> Date: Tue, 25 Nov 2014 10:54:44 +0100
> Subject: [PATCH] mm: prevent endless growth of anon_vma hierarchy
> 
> Constantly forking task causes unlimited grow of anon_vma chain.
> Each next child allocate new level of anon_vmas and links vmas to all
> previous levels because it inherits pages from them. None of anon_vmas
> cannot be freed because there might be pages which points to them.
> 
> This patch adds heuristic which decides to reuse existing anon_vma instead
> of forking new one. It counts vmas and direct descendants for each anon_vma.
> Anon_vma with degree lower than two will be reused at next fork.
> As a result each anon_vma has either alive vma or at least two descendants,
> endless chains are no longer possible and count of anon_vmas is no more than
> two times more than count of vmas.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Link: http://lkml.kernel.org/r/20120816024610.GA5350@evergreen.ssec.wisc.edu

Tested-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Michal Hocko <mhocko@suse.cz>

and I guess
Reported-by: Daniel Forrest <dan.forrest@ssec.wisc.edu>

who somehow vanished from CC list (added back) would be appropriate as
well.

plus

Fixes: 5beb49305251 (mm: change anon_vma linking to fix multi-process server scalability issue)
and mark it for stable

Thanks!

> ---
>  include/linux/rmap.h | 16 ++++++++++++++++
>  mm/rmap.c            | 29 ++++++++++++++++++++++++++++-
>  2 files changed, 44 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index c0c2bce6b0b7..b1d140c20b37 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -45,6 +45,22 @@ struct anon_vma {
>  	 * mm_take_all_locks() (mm_all_locks_mutex).
>  	 */
>  	struct rb_root rb_root;	/* Interval tree of private "related" vmas */
> +
> +	/*
> +	 * Count of child anon_vmas and VMAs which points to this anon_vma.
> +	 *
> +	 * This counter is used for making decision about reusing old anon_vma
> +	 * instead of forking new one. It allows to detect anon_vmas which have
> +	 * just one direct descendant and no vmas. Reusing such anon_vma not
> +	 * leads to significant preformance regression but prevents degradation
> +	 * of anon_vma hierarchy to endless linear chain.
> +	 *
> +	 * Root anon_vma is never reused because it is its own parent and it has
> +	 * at leat one vma or child, thus at fork it's degree is at least 2.
> +	 */
> +	unsigned degree;
> +
> +	struct anon_vma *parent;	/* Parent of this anon_vma */
>  };
>  
>  /*
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 19886fb2f13a..40ae8184a1e1 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -72,6 +72,8 @@ static inline struct anon_vma *anon_vma_alloc(void)
>  	anon_vma = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
>  	if (anon_vma) {
>  		atomic_set(&anon_vma->refcount, 1);
> +		anon_vma->degree = 1;	/* Reference for first vma */
> +		anon_vma->parent = anon_vma;
>  		/*
>  		 * Initialise the anon_vma root to point to itself. If called
>  		 * from fork, the root will be reset to the parents anon_vma.
> @@ -188,6 +190,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
>  		if (likely(!vma->anon_vma)) {
>  			vma->anon_vma = anon_vma;
>  			anon_vma_chain_link(vma, avc, anon_vma);
> +			anon_vma->degree++;
>  			allocated = NULL;
>  			avc = NULL;
>  		}
> @@ -256,7 +259,17 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
>  		anon_vma = pavc->anon_vma;
>  		root = lock_anon_vma_root(root, anon_vma);
>  		anon_vma_chain_link(dst, avc, anon_vma);
> +
> +		/*
> +		 * Reuse existing anon_vma if its degree lower than two,
> +		 * that means it has no vma and just one anon_vma child.
> +		 */
> +		if (!dst->anon_vma && anon_vma != src->anon_vma &&
> +				anon_vma->degree < 2)
> +			dst->anon_vma = anon_vma;
>  	}
> +	if (dst->anon_vma)
> +		dst->anon_vma->degree++;
>  	unlock_anon_vma_root(root);
>  	return 0;
>  
> @@ -279,6 +292,9 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
>  	if (!pvma->anon_vma)
>  		return 0;
>  
> +	/* Drop inherited anon_vma, we'll reuse old one or allocate new. */
> +	vma->anon_vma = NULL;
> +
>  	/*
>  	 * First, attach the new VMA to the parent VMA's anon_vmas,
>  	 * so rmap can find non-COWed pages in child processes.
> @@ -286,6 +302,10 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
>  	if (anon_vma_clone(vma, pvma))
>  		return -ENOMEM;
>  
> +	/* An old anon_vma has been reused. */
> +	if (vma->anon_vma)
> +		return 0;
> +
>  	/* Then add our own anon_vma. */
>  	anon_vma = anon_vma_alloc();
>  	if (!anon_vma)
> @@ -299,6 +319,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
>  	 * lock any of the anon_vmas in this anon_vma tree.
>  	 */
>  	anon_vma->root = pvma->anon_vma->root;
> +	anon_vma->parent = pvma->anon_vma;
>  	/*
>  	 * With refcounts, an anon_vma can stay around longer than the
>  	 * process it belongs to. The root anon_vma needs to be pinned until
> @@ -309,6 +330,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
>  	vma->anon_vma = anon_vma;
>  	anon_vma_lock_write(anon_vma);
>  	anon_vma_chain_link(vma, avc, anon_vma);
> +	anon_vma->parent->degree++;
>  	anon_vma_unlock_write(anon_vma);
>  
>  	return 0;
> @@ -339,12 +361,16 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
>  		 * Leave empty anon_vmas on the list - we'll need
>  		 * to free them outside the lock.
>  		 */
> -		if (RB_EMPTY_ROOT(&anon_vma->rb_root))
> +		if (RB_EMPTY_ROOT(&anon_vma->rb_root)) {
> +			anon_vma->parent->degree--;
>  			continue;
> +		}
>  
>  		list_del(&avc->same_vma);
>  		anon_vma_chain_free(avc);
>  	}
> +	if (vma->anon_vma)
> +		vma->anon_vma->degree--;
>  	unlock_anon_vma_root(root);
>  
>  	/*
> @@ -355,6 +381,7 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
>  	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
>  		struct anon_vma *anon_vma = avc->anon_vma;
>  
> +		BUG_ON(anon_vma->degree);
>  		put_anon_vma(anon_vma);
>  
>  		list_del(&avc->same_vma);
> -- 
> 2.1.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
