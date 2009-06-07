Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 49BDF6B004D
	for <linux-mm@kvack.org>; Sun,  7 Jun 2009 13:15:32 -0400 (EDT)
Date: Sun, 7 Jun 2009 18:55:15 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [patch][v2] swap: virtual swap readahead
In-Reply-To: <20090602223738.GA15475@cmpxchg.org>
Message-ID: <Pine.LNX.4.64.0906071747440.20105@sister.anvils>
References: <20090602223738.GA15475@cmpxchg.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1000707623-1244397315=:20105"
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1000707623-1244397315=:20105
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Wed, 3 Jun 2009, Johannes Weiner wrote:
> Hi Andrew,
> 
> I redid the qsbench runs with a bigger page cluster (2^4).  It shows
> improvement on both versions, the patched one still performing better.
> Rik hinted me that we can make the default even bigger when we are
> better at avoiding reading unrelated pages.  I am currently testing
> this.  Here are the timings for 2^4 (i.e. twice the) ra pages:
> 
> vanilla:
> 1 x 2048M [20 runs]  user 101.41/101.06 [1.42] system 11.02/10.83 [0.92] real 368.44/361.31 [48.47]
> 2 x 1024M [20 runs]  user 101.42/101.23 [0.66] system 12.98/13.01 [0.56] real 338.45/338.56 [2.94]
> 4 x 540M [20 runs]  user 101.75/101.62 [1.03] system 10.05/9.52 [1.53] real 371.97/351.88 [77.69]
> 8 x 280M [20 runs]  user 103.35/103.33 [0.63] system 9.80/9.59 [1.72] real 453.48/473.21 [115.61]
> 16 x 128M [20 runs]  user 91.04/91.00 [0.86] system 8.95/9.41 [2.06] real 312.16/342.29 [100.53]
> 
> vswapra:
> 1 x 2048M [20 runs]  user 98.47/98.32 [1.33] system 9.85/9.90 [0.92] real 373.95/382.64 [26.77]
> 2 x 1024M [20 runs]  user 96.89/97.00 [0.44] system 9.52/9.48 [1.49] real 288.43/281.55 [53.12]
> 4 x 540M [20 runs]  user 98.74/98.70 [0.92] system 7.62/7.83 [1.25] real 291.15/296.94 [54.85]
> 8 x 280M [20 runs]  user 100.68/100.59 [0.53] system 7.59/7.62 [0.41] real 305.12/311.29 [26.09]
> 16 x 128M [20 runs]  user 88.67/88.50 [1.02] system 6.06/6.22 [0.72] real 205.29/221.65 [42.06]
> 
> Furthermore I changed the patch to leave shmem alone for now and added
> documentation for the new approach.  And I adjusted the changelog a
> bit.
> 
> Andi, I think the NUMA policy is already taken care of.  Can you have
> another look at it?  Other than that you gave positive feedback - can
> I add your acked-by?
> 
> 	Hannes
> 
> ---
> The current swap readahead implementation reads a physically
> contiguous group of swap slots around the faulting page to take
> advantage of the disk head's position and in the hope that the
> surrounding pages will be needed soon as well.
> 
> This works as long as the physical swap slot order approximates the
> LRU order decently, otherwise it wastes memory and IO bandwidth to
> read in pages that are unlikely to be needed soon.
> 
> However, the physical swap slot layout diverges from the LRU order
> with increasing swap activity, i.e. high memory pressure situations,
> and this is exactly the situation where swapin should not waste any
> memory or IO bandwidth as both are the most contended resources at
> this point.
> 
> Another approximation for LRU-relation is the VMA order as groups of
> VMA-related pages are usually used together.
> 
> This patch combines both the physical and the virtual hint to get a
> good approximation of pages that are sensible to read ahead.
> 
> When both diverge, we either read unrelated data, seek heavily for
> related data, or, what this patch does, just decrease the readahead
> efforts.
> 
> To achieve this, we have essentially two readahead windows of the same
> size: one spans the virtual, the other one the physical neighborhood
> of the faulting page.  We only read where both areas overlap.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Andi Kleen <andi@firstfloor.org>

I think this a great idea, a very promising approach.  I like it
so much better than Andrew's and others' proposals to dedicate
areas of swap space to distinct virtual objects: which, as you
rightly pointed out, condemn us to unnecessary seeking when
writing swap (and is even more of an issue if we're writing
to SSD rather than HDD).

It would be nice to get results from a wider set of benchmarks
than just qsbench; but I don't think qsbench is biased in your
favour, and I don't think you need go to too much trouble on
that - let's just aim to get your work into mmotm, then we can
all play around with it for a while.  I suppose what I'd most
like is to try it with shmem, which you've understandably left
out for now.

You'll be hating me for the way I made shmem_truncate_range() etc.
nigh incomprehensible when enabling highmem index pages there.
Christoph Rohland's original was much nicer.  Again and again and
again I've wanted to throw all that out, and keep swap entries in
the standard radix tree which keeps the struct page pointers; but
again and again and again, I've been unable to justify losing the
highmem index ability - for a while it seemed as if x86_64 was
going to make highmem a thing of the past, and it's certainly helped
us to ignore 32GB 32-bit; but I think 4GB 32-bit is here a long while.

Though I like the way you localized it all into swapin_readahead(),
I'd prefer to keep ptes out of swap_state.c, and think several issues
will fall away if you turn your patch around.  You'll avoid the pte code
in swap_state.c, you'll satisfy Andi's concerns about locking/kmapping
overhead, and you'll find shmem much much easier, if instead of peering
back at where you've come from in swapin_readahead(), you make the outer
levels (do_swap_page and shmem_getpage) pass a vector of swap entries to
swapin_readahead()?  That vector on stack, and copied from the one page
table or index page (don't bother to cross page table or index page
boundaries) while it was mapped.

It's probably irrelevant to you, but I've attached an untested patch
of mine which stomps somewhat on this area: I was shocked to notice
shmem_getpage() in a list of deep stack offenders a few months back,
realized it was those unpleasant NUMA mempolicy pseudo-vmas, and made
a patch to get rid of them.  I've rebased it to 2.6.30-rc8 and checked
that the resulting kernel runs, but not really tested it; and I think
I didn't even try to get the mpol reference counting right (tends to
be an issue precisely in swapin_readahead, where one mpol ends up used
repeatedly) - mpol refcounting is an arcane art only Lee understands!
I've attached the patch because you may want to glance at it and
decide, either that it's something which is helpful to the direction
you're going in and you'd like to base upon it, or that it's a
distraction and you'd prefer me to keep it to myself until your
changes are in.

But your patch below is incomplete, isn't it?  The old swapin_readahead()
is now called swapin_readahead_phys(), and you want shmem_getpage() to be
using that for now: but no prototype for it and no change to mm/shmem.c.

Hugh

> ---
>  mm/swap_state.c |  115 ++++++++++++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 99 insertions(+), 16 deletions(-)
> 
> version 2:
>   o fall back to physical ra window for shmem
>   o add documentation to the new ra algorithm
> 
> qsbench, 20 runs, 1.7GB RAM, 2GB swap, "mean (standard deviation) median":
> 
> 		vanilla				vswapra
> 
> 1  x 2048M	391.25 ( 71.76) 384.56		445.55 (83.19) 415.41
> 2  x 1024M	384.25 ( 75.00) 423.08		290.26 (31.38) 299.51
> 4  x  540M	553.91 (100.02) 554.57		336.58 (52.49) 331.52
> 8  x  280M	561.08 ( 82.36) 583.12		319.13 (43.17) 307.69
> 16 x  128M	285.51 (113.20) 236.62		214.24 (62.37) 214.15
> 
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -325,27 +325,14 @@ struct page *read_swap_cache_async(swp_e
>  	return found_page;
>  }
>  
> -/**
> - * swapin_readahead - swap in pages in hope we need them soon
> - * @entry: swap entry of this memory
> - * @gfp_mask: memory allocation flags
> - * @vma: user vma this address belongs to
> - * @addr: target address for mempolicy
> - *
> - * Returns the struct page for entry and addr, after queueing swapin.
> - *
> +/*
>   * Primitive swap readahead code. We simply read an aligned block of
>   * (1 << page_cluster) entries in the swap area. This method is chosen
>   * because it doesn't cost us any seek time.  We also make sure to queue
>   * the 'original' request together with the readahead ones...
> - *
> - * This has been extended to use the NUMA policies from the mm triggering
> - * the readahead.
> - *
> - * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
>   */
> -struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> -			struct vm_area_struct *vma, unsigned long addr)
> +static struct page *swapin_readahead_phys(swp_entry_t entry, gfp_t gfp_mask,
> +				struct vm_area_struct *vma, unsigned long addr)
>  {
>  	int nr_pages;
>  	struct page *page;
> @@ -371,3 +358,99 @@ struct page *swapin_readahead(swp_entry_
>  	lru_add_drain();	/* Push any new pages onto the LRU now */
>  	return read_swap_cache_async(entry, gfp_mask, vma, addr);
>  }
> +
> +/**
> + * swapin_readahead - swap in pages in hope we need them soon
> + * @entry: swap entry of this memory
> + * @gfp_mask: memory allocation flags
> + * @vma: user vma this address belongs to
> + * @addr: target address for mempolicy
> + *
> + * Returns the struct page for entry and addr, after queueing swapin.
> + *
> + * The readahead window is the virtual area around the faulting page,
> + * where the physical proximity of the swap slots is taken into
> + * account as well.
> + *
> + * While the swap allocation algorithm tries to keep LRU-related pages
> + * together on the swap backing, it is not reliable on heavy thrashing
> + * systems where concurrent reclaimers allocate swap slots and/or most
> + * anonymous memory pages are already in swap cache.
> + *
> + * On the virtual side, subgroups of VMA-related pages are usually
> + * used together, which gives another hint to LRU relationship.
> + *
> + * By taking both aspects into account, we get a good approximation of
> + * which pages are sensible to read together with the faulting one.
> + *
> + * This has been extended to use the NUMA policies from the mm
> + * triggering the readahead.
> + *
> + * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
> + */
> +struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> +			struct vm_area_struct *vma, unsigned long addr)
> +{
> +	unsigned long start, pos, end;
> +	unsigned long pmin, pmax;
> +	int cluster, window;
> +
> +	if (!vma || !vma->vm_mm)	/* XXX: shmem case */
> +		return swapin_readahead_phys(entry, gfp_mask, vma, addr);
> +
> +	cluster = 1 << page_cluster;
> +	window = cluster << PAGE_SHIFT;
> +
> +	/* Physical range to read from */
> +	pmin = swp_offset(entry) & ~(cluster - 1);
> +	pmax = pmin + cluster;
> +
> +	/* Virtual range to read from */
> +	start = addr & ~(window - 1);
> +	end = start + window;
> +
> +	for (pos = start; pos < end; pos += PAGE_SIZE) {
> +		struct page *page;
> +		swp_entry_t swp;
> +		spinlock_t *ptl;
> +		pgd_t *pgd;
> +		pud_t *pud;
> +		pmd_t *pmd;
> +		pte_t *pte;
> +
> +		pgd = pgd_offset(vma->vm_mm, pos);
> +		if (!pgd_present(*pgd))
> +			continue;
> +		pud = pud_offset(pgd, pos);
> +		if (!pud_present(*pud))
> +			continue;
> +		pmd = pmd_offset(pud, pos);
> +		if (!pmd_present(*pmd))
> +			continue;
> +		pte = pte_offset_map_lock(vma->vm_mm, pmd, pos, &ptl);
> +		if (!is_swap_pte(*pte)) {
> +			pte_unmap_unlock(pte, ptl);
> +			continue;
> +		}
> +		swp = pte_to_swp_entry(*pte);
> +		pte_unmap_unlock(pte, ptl);
> +
> +		if (swp_type(swp) != swp_type(entry))
> +			continue;
> +		/*
> +		 * Dont move the disk head too far away.  This also
> +		 * throttles readahead while thrashing, where virtual
> +		 * order diverges more and more from physical order.
> +		 */
> +		if (swp_offset(swp) > pmax)
> +			continue;
> +		if (swp_offset(swp) < pmin)
> +			continue;
> +		page = read_swap_cache_async(swp, gfp_mask, vma, pos);
> +		if (!page)
> +			continue;
> +		page_cache_release(page);
> +	}
> +	lru_add_drain();	/* Push any new pages onto the LRU now */
> +	return read_swap_cache_async(entry, gfp_mask, vma, addr);
> +}
--8323584-1000707623-1244397315=:20105
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=PATCH
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.64.0906071855150.20105@sister.anvils>
Content-Description: alloc_page_mpol patch
Content-Disposition: attachment; filename=PATCH

W1BBVENIXSBtbTogYWxsb2NfcGFnZV9tcG9sDQoNCkludHJvZHVjZSBhbGxv
Y19wYWdlX21wb2woKSwgdG8gZ2V0IHJpZCBvZiB0aG9zZSBtcG9sIHBzZXVk
by12bWFzIGZyb20NCnNobWVtLmMsIHdoaWNoIGNhdXNlZCBzaG1lbV9nZXRw
YWdlKCkgdG8gc2hvdyB1cCBpbiBkZWVwIHN0YWNrIHJlcG9ydHMuDQoNCk5v
dC15ZXQtU2lnbmVkLW9mZi1ieTogSHVnaCBEaWNraW5zIDxodWdoLmRpY2tp
bnNAdGlzY2FsaS5jby51az4NCi0tLQ0KDQogaW5jbHVkZS9saW51eC9nZnAu
aCAgICAgICB8ICAgIDYgKysrDQogaW5jbHVkZS9saW51eC9tZW1wb2xpY3ku
aCB8ICAgMTAgKysrKysrDQogaW5jbHVkZS9saW51eC9zd2FwLmggICAgICB8
ICAgIDkgKystLS0NCiBtbS9tZW1vcnkuYyAgICAgICAgICAgICAgIHwgICAg
NSArLS0NCiBtbS9tZW1wb2xpY3kuYyAgICAgICAgICAgIHwgICA3NSArKysr
KysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0tLS0tLS0tDQog
bW0vc2htZW0uYyAgICAgICAgICAgICAgICB8ICAgNjYgKysrKy0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KIG1tL3N3YXBfc3RhdGUu
YyAgICAgICAgICAgfCAgIDEwICsrKy0tLQ0KIG1tL3N3YXBmaWxlLmMgICAg
ICAgICAgICAgfCAgICA0ICstDQogOCBmaWxlcyBjaGFuZ2VkLCA4MCBpbnNl
cnRpb25zKCspLCAxMDUgZGVsZXRpb25zKC0pDQoNCi0tLSAyLjYuMzAtcmM4
L2luY2x1ZGUvbGludXgvZ2ZwLmgJMjAwOS0wNC0wOCAxODoyNjoxNC4wMDAw
MDAwMDAgKzAxMDANCisrKyBsaW51eC9pbmNsdWRlL2xpbnV4L2dmcC5oCTIw
MDktMDYtMDcgMTM6NTY6NTguMDAwMDAwMDAwICswMTAwDQpAQCAtNyw2ICs3
LDcgQEANCiAjaW5jbHVkZSA8bGludXgvdG9wb2xvZ3kuaD4NCiANCiBzdHJ1
Y3Qgdm1fYXJlYV9zdHJ1Y3Q7DQorc3RydWN0IG1lbXBvbGljeTsNCiANCiAv
Kg0KICAqIEdGUCBiaXRtYXNrcy4uDQpAQCAtMjEzLDEwICsyMTQsMTMgQEAg
YWxsb2NfcGFnZXMoZ2ZwX3QgZ2ZwX21hc2ssIHVuc2lnbmVkIGludA0KIH0N
CiBleHRlcm4gc3RydWN0IHBhZ2UgKmFsbG9jX3BhZ2Vfdm1hKGdmcF90IGdm
cF9tYXNrLA0KIAkJCXN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNp
Z25lZCBsb25nIGFkZHIpOw0KK2V4dGVybiBzdHJ1Y3QgcGFnZSAqYWxsb2Nf
cGFnZV9tcG9sKGdmcF90IGdmcF9tYXNrLA0KKwkJCXN0cnVjdCBtZW1wb2xp
Y3kgKm1wb2wsIHBnb2ZmX3QgcGdvZmYpOw0KICNlbHNlDQogI2RlZmluZSBh
bGxvY19wYWdlcyhnZnBfbWFzaywgb3JkZXIpIFwNCiAJCWFsbG9jX3BhZ2Vz
X25vZGUobnVtYV9ub2RlX2lkKCksIGdmcF9tYXNrLCBvcmRlcikNCi0jZGVm
aW5lIGFsbG9jX3BhZ2Vfdm1hKGdmcF9tYXNrLCB2bWEsIGFkZHIpIGFsbG9j
X3BhZ2VzKGdmcF9tYXNrLCAwKQ0KKyNkZWZpbmUgYWxsb2NfcGFnZV92bWEo
Z2ZwX21hc2ssIHZtYSwgYWRkcikJYWxsb2NfcGFnZXMoZ2ZwX21hc2ssIDAp
DQorI2RlZmluZSBhbGxvY19wYWdlX21wb2woZ2ZwX21hc2ssIG1wb2wsIHBn
b2ZmKQlhbGxvY19wYWdlcyhnZnBfbWFzaywgMCkNCiAjZW5kaWYNCiAjZGVm
aW5lIGFsbG9jX3BhZ2UoZ2ZwX21hc2spIGFsbG9jX3BhZ2VzKGdmcF9tYXNr
LCAwKQ0KIA0KLS0tIDIuNi4zMC1yYzgvaW5jbHVkZS9saW51eC9tZW1wb2xp
Y3kuaAkyMDA4LTEwLTA5IDIzOjEzOjUzLjAwMDAwMDAwMCArMDEwMA0KKysr
IGxpbnV4L2luY2x1ZGUvbGludXgvbWVtcG9saWN5LmgJMjAwOS0wNi0wNyAx
Mzo1Njo1OC4wMDAwMDAwMDAgKzAxMDANCkBAIC02Miw2ICs2Miw3IEBAIGVu
dW0gew0KICNpbmNsdWRlIDxsaW51eC9wYWdlbWFwLmg+DQogDQogc3RydWN0
IG1tX3N0cnVjdDsNCitzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3Q7DQogDQogI2lm
ZGVmIENPTkZJR19OVU1BDQogDQpAQCAtMTQ3LDYgKzE0OCw5IEBAIHN0YXRp
YyBpbmxpbmUgc3RydWN0IG1lbXBvbGljeSAqbXBvbF9kdXANCiAJcmV0dXJu
IHBvbDsNCiB9DQogDQorZXh0ZXJuIHN0cnVjdCBtZW1wb2xpY3kgKmdldF92
bWFfcG9saWN5KHN0cnVjdCB0YXNrX3N0cnVjdCAqdGFzaywNCisJCQlzdHJ1
Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwgdW5zaWduZWQgbG9uZyBhZGRyKTsN
CisNCiAjZGVmaW5lIHZtYV9wb2xpY3kodm1hKSAoKHZtYSktPnZtX3BvbGlj
eSkNCiAjZGVmaW5lIHZtYV9zZXRfcG9saWN5KHZtYSwgcG9sKSAoKHZtYSkt
PnZtX3BvbGljeSA9IChwb2wpKQ0KIA0KQEAgLTI5NCw2ICsyOTgsMTIgQEAg
bXBvbF9zaGFyZWRfcG9saWN5X2xvb2t1cChzdHJ1Y3Qgc2hhcmVkXw0KIHsN
CiAJcmV0dXJuIE5VTEw7DQogfQ0KKw0KK3N0YXRpYyBpbmxpbmUgc3RydWN0
IG1lbXBvbGljeSAqZ2V0X3ZtYV9wb2xpY3koc3RydWN0IHRhc2tfc3RydWN0
ICp0YXNrLA0KKwkJCXN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNp
Z25lZCBsb25nIGFkZHIpDQorew0KKwlyZXR1cm4gTlVMTDsNCit9DQogDQog
I2RlZmluZSB2bWFfcG9saWN5KHZtYSkgTlVMTA0KICNkZWZpbmUgdm1hX3Nl
dF9wb2xpY3kodm1hLCBwb2wpIGRvIHt9IHdoaWxlKDApDQotLS0gMi42LjMw
LXJjOC9pbmNsdWRlL2xpbnV4L3N3YXAuaAkyMDA5LTA2LTAzIDEwOjEzOjI3
LjAwMDAwMDAwMCArMDEwMA0KKysrIGxpbnV4L2luY2x1ZGUvbGludXgvc3dh
cC5oCTIwMDktMDYtMDcgMTM6NTY6NTguMDAwMDAwMDAwICswMTAwDQpAQCAt
MTIsOSArMTIsOCBAQA0KICNpbmNsdWRlIDxhc20vYXRvbWljLmg+DQogI2lu
Y2x1ZGUgPGFzbS9wYWdlLmg+DQogDQotc3RydWN0IG5vdGlmaWVyX2Jsb2Nr
Ow0KLQ0KIHN0cnVjdCBiaW87DQorc3RydWN0IG1lbXBvbGljeTsNCiANCiAj
ZGVmaW5lIFNXQVBfRkxBR19QUkVGRVIJMHg4MDAwCS8qIHNldCBpZiBzd2Fw
IHByaW9yaXR5IHNwZWNpZmllZCAqLw0KICNkZWZpbmUgU1dBUF9GTEFHX1BS
SU9fTUFTSwkweDdmZmYNCkBAIC0yOTAsOSArMjg5LDkgQEAgZXh0ZXJuIHZv
aWQgZnJlZV9wYWdlX2FuZF9zd2FwX2NhY2hlKHN0cg0KIGV4dGVybiB2b2lk
IGZyZWVfcGFnZXNfYW5kX3N3YXBfY2FjaGUoc3RydWN0IHBhZ2UgKiosIGlu
dCk7DQogZXh0ZXJuIHN0cnVjdCBwYWdlICpsb29rdXBfc3dhcF9jYWNoZShz
d3BfZW50cnlfdCk7DQogZXh0ZXJuIHN0cnVjdCBwYWdlICpyZWFkX3N3YXBf
Y2FjaGVfYXN5bmMoc3dwX2VudHJ5X3QsIGdmcF90LA0KLQkJCXN0cnVjdCB2
bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNpZ25lZCBsb25nIGFkZHIpOw0KKwkJ
CXN0cnVjdCBtZW1wb2xpY3kgKm1wb2wsIHBnb2ZmX3QgcGdvZmYpOw0KIGV4
dGVybiBzdHJ1Y3QgcGFnZSAqc3dhcGluX3JlYWRhaGVhZChzd3BfZW50cnlf
dCwgZ2ZwX3QsDQotCQkJc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHVu
c2lnbmVkIGxvbmcgYWRkcik7DQorCQkJc3RydWN0IG1lbXBvbGljeSAqbXBv
bCwgcGdvZmZfdCBwZ29mZik7DQogDQogLyogbGludXgvbW0vc3dhcGZpbGUu
YyAqLw0KIGV4dGVybiBsb25nIG5yX3N3YXBfcGFnZXM7DQpAQCAtMzc3LDcg
KzM3Niw3IEBAIHN0YXRpYyBpbmxpbmUgdm9pZCBzd2FwX2ZyZWUoc3dwX2Vu
dHJ5X3QNCiB9DQogDQogc3RhdGljIGlubGluZSBzdHJ1Y3QgcGFnZSAqc3dh
cGluX3JlYWRhaGVhZChzd3BfZW50cnlfdCBzd3AsIGdmcF90IGdmcF9tYXNr
LA0KLQkJCXN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNpZ25lZCBs
b25nIGFkZHIpDQorCQkJCQlzdHJ1Y3QgbWVtcG9saWN5ICptcG9sLCBwZ29m
Zl90IHBnb2ZmKQ0KIHsNCiAJcmV0dXJuIE5VTEw7DQogfQ0KLS0tIDIuNi4z
MC1yYzgvbW0vbWVtb3J5LmMJMjAwOS0wNS0wOSAwOTowNjo0NC4wMDAwMDAw
MDAgKzAxMDANCisrKyBsaW51eC9tbS9tZW1vcnkuYwkyMDA5LTA2LTA3IDEz
OjU2OjU4LjAwMDAwMDAwMCArMDEwMA0KQEAgLTI0NjcsOCArMjQ2Nyw5IEBA
IHN0YXRpYyBpbnQgZG9fc3dhcF9wYWdlKHN0cnVjdCBtbV9zdHJ1Y3QNCiAJ
cGFnZSA9IGxvb2t1cF9zd2FwX2NhY2hlKGVudHJ5KTsNCiAJaWYgKCFwYWdl
KSB7DQogCQlncmFiX3N3YXBfdG9rZW4oKTsgLyogQ29udGVuZCBmb3IgdG9r
ZW4gX2JlZm9yZV8gcmVhZC1pbiAqLw0KLQkJcGFnZSA9IHN3YXBpbl9yZWFk
YWhlYWQoZW50cnksDQotCQkJCQlHRlBfSElHSFVTRVJfTU9WQUJMRSwgdm1h
LCBhZGRyZXNzKTsNCisJCXBhZ2UgPSBzd2FwaW5fcmVhZGFoZWFkKGVudHJ5
LCBHRlBfSElHSFVTRVJfTU9WQUJMRSwNCisJCQkJCWdldF92bWFfcG9saWN5
KGN1cnJlbnQsIHZtYSwgYWRkcmVzcyksDQorCQkJCQlsaW5lYXJfcGFnZV9p
bmRleCh2bWEsIGFkZHJlc3MpKTsNCiAJCWlmICghcGFnZSkgew0KIAkJCS8q
DQogCQkJICogQmFjayBvdXQgaWYgc29tZWJvZHkgZWxzZSBmYXVsdGVkIGlu
IHRoaXMgcHRlDQotLS0gMi42LjMwLXJjOC9tbS9tZW1wb2xpY3kuYwkyMDA5
LTAzLTIzIDIzOjEyOjE0LjAwMDAwMDAwMCArMDAwMA0KKysrIGxpbnV4L21t
L21lbXBvbGljeS5jCTIwMDktMDYtMDcgMTM6NTY6NTguMDAwMDAwMDAwICsw
MTAwDQpAQCAtMTMwNCw3ICsxMzA0LDcgQEAgYXNtbGlua2FnZSBsb25nIGNv
bXBhdF9zeXNfbWJpbmQoY29tcGF0Xw0KICAqIGZyZWVpbmcgYnkgYW5vdGhl
ciB0YXNrLiAgSXQgaXMgdGhlIGNhbGxlcidzIHJlc3BvbnNpYmlsaXR5IHRv
IGZyZWUgdGhlDQogICogZXh0cmEgcmVmZXJlbmNlIGZvciBzaGFyZWQgcG9s
aWNpZXMuDQogICovDQotc3RhdGljIHN0cnVjdCBtZW1wb2xpY3kgKmdldF92
bWFfcG9saWN5KHN0cnVjdCB0YXNrX3N0cnVjdCAqdGFzaywNCitzdHJ1Y3Qg
bWVtcG9saWN5ICpnZXRfdm1hX3BvbGljeShzdHJ1Y3QgdGFza19zdHJ1Y3Qg
KnRhc2ssDQogCQlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwgdW5zaWdu
ZWQgbG9uZyBhZGRyKQ0KIHsNCiAJc3RydWN0IG1lbXBvbGljeSAqcG9sID0g
dGFzay0+bWVtcG9saWN5Ow0KQEAgLTE0MjUsOSArMTQyNSw4IEBAIHVuc2ln
bmVkIHNsYWJfbm9kZShzdHJ1Y3QgbWVtcG9saWN5ICpwb2wNCiAJfQ0KIH0N
CiANCi0vKiBEbyBzdGF0aWMgaW50ZXJsZWF2aW5nIGZvciBhIFZNQSB3aXRo
IGtub3duIG9mZnNldC4gKi8NCi1zdGF0aWMgdW5zaWduZWQgb2Zmc2V0X2ls
X25vZGUoc3RydWN0IG1lbXBvbGljeSAqcG9sLA0KLQkJc3RydWN0IHZtX2Fy
ZWFfc3RydWN0ICp2bWEsIHVuc2lnbmVkIGxvbmcgb2ZmKQ0KKy8qIERldGVy
bWluZSBhIG5vZGUgbnVtYmVyIGZvciBpbnRlcmxlYXZlICovDQorc3RhdGlj
IHVuc2lnbmVkIGludCBpbnRlcmxlYXZlX25pZChzdHJ1Y3QgbWVtcG9saWN5
ICpwb2wsIHBnb2ZmX3QgcGdvZmYpDQogew0KIAl1bnNpZ25lZCBubm9kZXMg
PSBub2Rlc193ZWlnaHQocG9sLT52Lm5vZGVzKTsNCiAJdW5zaWduZWQgdGFy
Z2V0Ow0KQEAgLTE0MzYsNyArMTQzNSw3IEBAIHN0YXRpYyB1bnNpZ25lZCBv
ZmZzZXRfaWxfbm9kZShzdHJ1Y3QgbWUNCiANCiAJaWYgKCFubm9kZXMpDQog
CQlyZXR1cm4gbnVtYV9ub2RlX2lkKCk7DQotCXRhcmdldCA9ICh1bnNpZ25l
ZCBpbnQpb2ZmICUgbm5vZGVzOw0KKwl0YXJnZXQgPSAodW5zaWduZWQgaW50
KXBnb2ZmICUgbm5vZGVzOw0KIAljID0gMDsNCiAJZG8gew0KIAkJbmlkID0g
bmV4dF9ub2RlKG5pZCwgcG9sLT52Lm5vZGVzKTsNCkBAIC0xNDQ1LDI4ICsx
NDQ0LDYgQEAgc3RhdGljIHVuc2lnbmVkIG9mZnNldF9pbF9ub2RlKHN0cnVj
dCBtZQ0KIAlyZXR1cm4gbmlkOw0KIH0NCiANCi0vKiBEZXRlcm1pbmUgYSBu
b2RlIG51bWJlciBmb3IgaW50ZXJsZWF2ZSAqLw0KLXN0YXRpYyBpbmxpbmUg
dW5zaWduZWQgaW50ZXJsZWF2ZV9uaWQoc3RydWN0IG1lbXBvbGljeSAqcG9s
LA0KLQkJIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNpZ25lZCBs
b25nIGFkZHIsIGludCBzaGlmdCkNCi17DQotCWlmICh2bWEpIHsNCi0JCXVu
c2lnbmVkIGxvbmcgb2ZmOw0KLQ0KLQkJLyoNCi0JCSAqIGZvciBzbWFsbCBw
YWdlcywgdGhlcmUgaXMgbm8gZGlmZmVyZW5jZSBiZXR3ZWVuDQotCQkgKiBz
aGlmdCBhbmQgUEFHRV9TSElGVCwgc28gdGhlIGJpdC1zaGlmdCBpcyBzYWZl
Lg0KLQkJICogZm9yIGh1Z2UgcGFnZXMsIHNpbmNlIHZtX3Bnb2ZmIGlzIGlu
IHVuaXRzIG9mIHNtYWxsDQotCQkgKiBwYWdlcywgd2UgbmVlZCB0byBzaGlm
dCBvZmYgdGhlIGFsd2F5cyAwIGJpdHMgdG8gZ2V0DQotCQkgKiBhIHVzZWZ1
bCBvZmZzZXQuDQotCQkgKi8NCi0JCUJVR19PTihzaGlmdCA8IFBBR0VfU0hJ
RlQpOw0KLQkJb2ZmID0gdm1hLT52bV9wZ29mZiA+PiAoc2hpZnQgLSBQQUdF
X1NISUZUKTsNCi0JCW9mZiArPSAoYWRkciAtIHZtYS0+dm1fc3RhcnQpID4+
IHNoaWZ0Ow0KLQkJcmV0dXJuIG9mZnNldF9pbF9ub2RlKHBvbCwgdm1hLCBv
ZmYpOw0KLQl9IGVsc2UNCi0JCXJldHVybiBpbnRlcmxlYXZlX25vZGVzKHBv
bCk7DQotfQ0KLQ0KICNpZmRlZiBDT05GSUdfSFVHRVRMQkZTDQogLyoNCiAg
KiBodWdlX3pvbmVsaXN0KEB2bWEsIEBhZGRyLCBAZ2ZwX2ZsYWdzLCBAbXBv
bCkNCkBAIC0xNDkxLDggKzE0NjgsOSBAQCBzdHJ1Y3Qgem9uZWxpc3QgKmh1
Z2Vfem9uZWxpc3Qoc3RydWN0IHZtDQogCSpub2RlbWFzayA9IE5VTEw7CS8q
IGFzc3VtZSAhTVBPTF9CSU5EICovDQogDQogCWlmICh1bmxpa2VseSgoKm1w
b2wpLT5tb2RlID09IE1QT0xfSU5URVJMRUFWRSkpIHsNCi0JCXpsID0gbm9k
ZV96b25lbGlzdChpbnRlcmxlYXZlX25pZCgqbXBvbCwgdm1hLCBhZGRyLA0K
LQkJCQlodWdlX3BhZ2Vfc2hpZnQoaHN0YXRlX3ZtYSh2bWEpKSksIGdmcF9m
bGFncyk7DQorCQlwZ29mZl90IHBnb2ZmID0gbGluZWFyX3BhZ2VfaW5kZXgo
dm1hLCBhZGRyKTsNCisJCXBnb2ZmID4+PSBodWdlX3BhZ2Vfc2hpZnQoaHN0
YXRlX3ZtYSh2bWEpKTsNCisJCXpsID0gbm9kZV96b25lbGlzdChpbnRlcmxl
YXZlX25pZCgqbXBvbCwgcGdvZmYpLCBnZnBfZmxhZ3MpOw0KIAl9IGVsc2Ug
ew0KIAkJemwgPSBwb2xpY3lfem9uZWxpc3QoZ2ZwX2ZsYWdzLCAqbXBvbCk7
DQogCQlpZiAoKCptcG9sKS0+bW9kZSA9PSBNUE9MX0JJTkQpDQpAQCAtMTU1
MCw3ICsxNTI4LDQwIEBAIGFsbG9jX3BhZ2Vfdm1hKGdmcF90IGdmcCwgc3Ry
dWN0IHZtX2FyZWENCiAJaWYgKHVubGlrZWx5KHBvbC0+bW9kZSA9PSBNUE9M
X0lOVEVSTEVBVkUpKSB7DQogCQl1bnNpZ25lZCBuaWQ7DQogDQotCQluaWQg
PSBpbnRlcmxlYXZlX25pZChwb2wsIHZtYSwgYWRkciwgUEFHRV9TSElGVCk7
DQorCQlpZiAodm1hKQ0KKwkJCW5pZCA9IGludGVybGVhdmVfbmlkKHBvbCwg
bGluZWFyX3BhZ2VfaW5kZXgodm1hLCBhZGRyKSk7DQorCQllbHNlDQorCQkJ
bmlkID0gaW50ZXJsZWF2ZV9ub2Rlcyhwb2wpOw0KKwkJbXBvbF9jb25kX3B1
dChwb2wpOw0KKwkJcmV0dXJuIGFsbG9jX3BhZ2VfaW50ZXJsZWF2ZShnZnAs
IDAsIG5pZCk7DQorCX0NCisJemwgPSBwb2xpY3lfem9uZWxpc3QoZ2ZwLCBw
b2wpOw0KKwlpZiAodW5saWtlbHkobXBvbF9uZWVkc19jb25kX3JlZihwb2wp
KSkgew0KKwkJLyoNCisJCSAqIHNsb3cgcGF0aDogcmVmIGNvdW50ZWQgc2hh
cmVkIHBvbGljeQ0KKwkJICovDQorCQlzdHJ1Y3QgcGFnZSAqcGFnZSA9ICBf
X2FsbG9jX3BhZ2VzX25vZGVtYXNrKGdmcCwgMCwNCisJCQkJCQl6bCwgcG9s
aWN5X25vZGVtYXNrKGdmcCwgcG9sKSk7DQorCQlfX21wb2xfcHV0KHBvbCk7
DQorCQlyZXR1cm4gcGFnZTsNCisJfQ0KKwkvKg0KKwkgKiBmYXN0IHBhdGg6
ICBkZWZhdWx0IG9yIHRhc2sgcG9saWN5DQorCSAqLw0KKwlyZXR1cm4gX19h
bGxvY19wYWdlc19ub2RlbWFzayhnZnAsIDAsIHpsLCBwb2xpY3lfbm9kZW1h
c2soZ2ZwLCBwb2wpKTsNCit9DQorDQorc3RydWN0IHBhZ2UgKg0KK2FsbG9j
X3BhZ2VfbXBvbChnZnBfdCBnZnAsIHN0cnVjdCBtZW1wb2xpY3kgKnBvbCwg
cGdvZmZfdCBwZ29mZikNCit7DQorCXN0cnVjdCB6b25lbGlzdCAqemw7DQor
DQorCWNwdXNldF91cGRhdGVfdGFza19tZW1vcnlfc3RhdGUoKTsNCisNCisJ
aWYgKHVubGlrZWx5KHBvbC0+bW9kZSA9PSBNUE9MX0lOVEVSTEVBVkUpKSB7
DQorCQl1bnNpZ25lZCBpbnQgbmlkOw0KKw0KKwkJbmlkID0gaW50ZXJsZWF2
ZV9uaWQocG9sLCBwZ29mZik7DQogCQltcG9sX2NvbmRfcHV0KHBvbCk7DQog
CQlyZXR1cm4gYWxsb2NfcGFnZV9pbnRlcmxlYXZlKGdmcCwgMCwgbmlkKTsN
CiAJfQ0KQEAgLTE3NTcsMTEgKzE3NjgsMTEgQEAgc3RhdGljIHZvaWQgc3Bf
aW5zZXJ0KHN0cnVjdCBzaGFyZWRfcG9saQ0KIHN0cnVjdCBtZW1wb2xpY3kg
Kg0KIG1wb2xfc2hhcmVkX3BvbGljeV9sb29rdXAoc3RydWN0IHNoYXJlZF9w
b2xpY3kgKnNwLCB1bnNpZ25lZCBsb25nIGlkeCkNCiB7DQotCXN0cnVjdCBt
ZW1wb2xpY3kgKnBvbCA9IE5VTEw7DQorCXN0cnVjdCBtZW1wb2xpY3kgKnBv
bCA9ICZkZWZhdWx0X3BvbGljeTsNCiAJc3RydWN0IHNwX25vZGUgKnNuOw0K
IA0KIAlpZiAoIXNwLT5yb290LnJiX25vZGUpDQotCQlyZXR1cm4gTlVMTDsN
CisJCXJldHVybiBwb2w7DQogCXNwaW5fbG9jaygmc3AtPmxvY2spOw0KIAlz
biA9IHNwX2xvb2t1cChzcCwgaWR4LCBpZHgrMSk7DQogCWlmIChzbikgew0K
LS0tIDIuNi4zMC1yYzgvbW0vc2htZW0uYwkyMDA5LTA1LTA5IDA5OjA2OjQ0
LjAwMDAwMDAwMCArMDEwMA0KKysrIGxpbnV4L21tL3NobWVtLmMJMjAwOS0w
Ni0wNyAxMzo1Njo1OC4wMDAwMDAwMDAgKzAxMDANCkBAIC0xMTA2LDggKzEx
MDYsNyBAQCByZWRpcnR5Og0KIAlyZXR1cm4gMDsNCiB9DQogDQotI2lmZGVm
IENPTkZJR19OVU1BDQotI2lmZGVmIENPTkZJR19UTVBGUw0KKyNpZiBkZWZp
bmVkKENPTkZJR19OVU1BKSAmJiBkZWZpbmVkKENPTkZJR19UTVBGUykNCiBz
dGF0aWMgdm9pZCBzaG1lbV9zaG93X21wb2woc3RydWN0IHNlcV9maWxlICpz
ZXEsIHN0cnVjdCBtZW1wb2xpY3kgKm1wb2wpDQogew0KIAljaGFyIGJ1ZmZl
cls2NF07DQpAQCAtMTEzMSw2NCArMTEzMCwxMSBAQCBzdGF0aWMgc3RydWN0
IG1lbXBvbGljeSAqc2htZW1fZ2V0X3NibXBvDQogCX0NCiAJcmV0dXJuIG1w
b2w7DQogfQ0KLSNlbmRpZiAvKiBDT05GSUdfVE1QRlMgKi8NCi0NCi1zdGF0
aWMgc3RydWN0IHBhZ2UgKnNobWVtX3N3YXBpbihzd3BfZW50cnlfdCBlbnRy
eSwgZ2ZwX3QgZ2ZwLA0KLQkJCXN0cnVjdCBzaG1lbV9pbm9kZV9pbmZvICpp
bmZvLCB1bnNpZ25lZCBsb25nIGlkeCkNCi17DQotCXN0cnVjdCBtZW1wb2xp
Y3kgbXBvbCwgKnNwb2w7DQotCXN0cnVjdCB2bV9hcmVhX3N0cnVjdCBwdm1h
Ow0KLQlzdHJ1Y3QgcGFnZSAqcGFnZTsNCi0NCi0Jc3BvbCA9IG1wb2xfY29u
ZF9jb3B5KCZtcG9sLA0KLQkJCQltcG9sX3NoYXJlZF9wb2xpY3lfbG9va3Vw
KCZpbmZvLT5wb2xpY3ksIGlkeCkpOw0KLQ0KLQkvKiBDcmVhdGUgYSBwc2V1
ZG8gdm1hIHRoYXQganVzdCBjb250YWlucyB0aGUgcG9saWN5ICovDQotCXB2
bWEudm1fc3RhcnQgPSAwOw0KLQlwdm1hLnZtX3Bnb2ZmID0gaWR4Ow0KLQlw
dm1hLnZtX29wcyA9IE5VTEw7DQotCXB2bWEudm1fcG9saWN5ID0gc3BvbDsN
Ci0JcGFnZSA9IHN3YXBpbl9yZWFkYWhlYWQoZW50cnksIGdmcCwgJnB2bWEs
IDApOw0KLQlyZXR1cm4gcGFnZTsNCi19DQotDQotc3RhdGljIHN0cnVjdCBw
YWdlICpzaG1lbV9hbGxvY19wYWdlKGdmcF90IGdmcCwNCi0JCQlzdHJ1Y3Qg
c2htZW1faW5vZGVfaW5mbyAqaW5mbywgdW5zaWduZWQgbG9uZyBpZHgpDQot
ew0KLQlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgcHZtYTsNCi0NCi0JLyogQ3Jl
YXRlIGEgcHNldWRvIHZtYSB0aGF0IGp1c3QgY29udGFpbnMgdGhlIHBvbGlj
eSAqLw0KLQlwdm1hLnZtX3N0YXJ0ID0gMDsNCi0JcHZtYS52bV9wZ29mZiA9
IGlkeDsNCi0JcHZtYS52bV9vcHMgPSBOVUxMOw0KLQlwdm1hLnZtX3BvbGlj
eSA9IG1wb2xfc2hhcmVkX3BvbGljeV9sb29rdXAoJmluZm8tPnBvbGljeSwg
aWR4KTsNCi0NCi0JLyoNCi0JICogYWxsb2NfcGFnZV92bWEoKSB3aWxsIGRy
b3AgdGhlIHNoYXJlZCBwb2xpY3kgcmVmZXJlbmNlDQotCSAqLw0KLQlyZXR1
cm4gYWxsb2NfcGFnZV92bWEoZ2ZwLCAmcHZtYSwgMCk7DQotfQ0KLSNlbHNl
IC8qICFDT05GSUdfTlVNQSAqLw0KLSNpZmRlZiBDT05GSUdfVE1QRlMNCisj
ZWxzZQ0KIHN0YXRpYyBpbmxpbmUgdm9pZCBzaG1lbV9zaG93X21wb2woc3Ry
dWN0IHNlcV9maWxlICpzZXEsIHN0cnVjdCBtZW1wb2xpY3kgKnApDQogew0K
IH0NCi0jZW5kaWYgLyogQ09ORklHX1RNUEZTICovDQotDQotc3RhdGljIGlu
bGluZSBzdHJ1Y3QgcGFnZSAqc2htZW1fc3dhcGluKHN3cF9lbnRyeV90IGVu
dHJ5LCBnZnBfdCBnZnAsDQotCQkJc3RydWN0IHNobWVtX2lub2RlX2luZm8g
KmluZm8sIHVuc2lnbmVkIGxvbmcgaWR4KQ0KLXsNCi0JcmV0dXJuIHN3YXBp
bl9yZWFkYWhlYWQoZW50cnksIGdmcCwgTlVMTCwgMCk7DQotfQ0KLQ0KLXN0
YXRpYyBpbmxpbmUgc3RydWN0IHBhZ2UgKnNobWVtX2FsbG9jX3BhZ2UoZ2Zw
X3QgZ2ZwLA0KLQkJCXN0cnVjdCBzaG1lbV9pbm9kZV9pbmZvICppbmZvLCB1
bnNpZ25lZCBsb25nIGlkeCkNCi17DQotCXJldHVybiBhbGxvY19wYWdlKGdm
cCk7DQotfQ0KLSNlbmRpZiAvKiBDT05GSUdfTlVNQSAqLw0KIA0KLSNpZiAh
ZGVmaW5lZChDT05GSUdfTlVNQSkgfHwgIWRlZmluZWQoQ09ORklHX1RNUEZT
KQ0KIHN0YXRpYyBpbmxpbmUgc3RydWN0IG1lbXBvbGljeSAqc2htZW1fZ2V0
X3NibXBvbChzdHJ1Y3Qgc2htZW1fc2JfaW5mbyAqc2JpbmZvKQ0KIHsNCiAJ
cmV0dXJuIE5VTEw7DQpAQCAtMTI2OCw3ICsxMjE0LDkgQEAgcmVwZWF0Og0K
IAkJCQkqdHlwZSB8PSBWTV9GQVVMVF9NQUpPUjsNCiAJCQl9DQogCQkJc3Bp
bl91bmxvY2soJmluZm8tPmxvY2spOw0KLQkJCXN3YXBwYWdlID0gc2htZW1f
c3dhcGluKHN3YXAsIGdmcCwgaW5mbywgaWR4KTsNCisJCQlzd2FwcGFnZSA9
IHN3YXBpbl9yZWFkYWhlYWQoc3dhcCwgZ2ZwLA0KKwkJCQltcG9sX3NoYXJl
ZF9wb2xpY3lfbG9va3VwKCZpbmZvLT5wb2xpY3ksIGlkeCksDQorCQkJCQkJ
aWR4KTsNCiAJCQlpZiAoIXN3YXBwYWdlKSB7DQogCQkJCXNwaW5fbG9jaygm
aW5mby0+bG9jayk7DQogCQkJCWVudHJ5ID0gc2htZW1fc3dwX2FsbG9jKGlu
Zm8sIGlkeCwgc2dwKTsNCkBAIC0xMzk1LDcgKzEzNDMsOSBAQCByZXBlYXQ6
DQogCQkJaW50IHJldDsNCiANCiAJCQlzcGluX3VubG9jaygmaW5mby0+bG9j
ayk7DQotCQkJZmlsZXBhZ2UgPSBzaG1lbV9hbGxvY19wYWdlKGdmcCwgaW5m
bywgaWR4KTsNCisJCQlmaWxlcGFnZSA9IGFsbG9jX3BhZ2VfbXBvbChnZnAs
DQorCQkJCW1wb2xfc2hhcmVkX3BvbGljeV9sb29rdXAoJmluZm8tPnBvbGlj
eSwgaWR4KSwNCisJCQkJCQkJaWR4KTsNCiAJCQlpZiAoIWZpbGVwYWdlKSB7
DQogCQkJCXNobWVtX3VuYWNjdF9ibG9ja3MoaW5mby0+ZmxhZ3MsIDEpOw0K
IAkJCQlzaG1lbV9mcmVlX2Jsb2Nrcyhpbm9kZSwgMSk7DQotLS0gMi42LjMw
LXJjOC9tbS9zd2FwX3N0YXRlLmMJMjAwOS0wNi0wMyAxMDoxMzoyNy4wMDAw
MDAwMDAgKzAxMDANCisrKyBsaW51eC9tbS9zd2FwX3N0YXRlLmMJMjAwOS0w
Ni0wNyAxMzo1Njo1OC4wMDAwMDAwMDAgKzAxMDANCkBAIC0yNjYsNyArMjY2
LDcgQEAgc3RydWN0IHBhZ2UgKiBsb29rdXBfc3dhcF9jYWNoZShzd3BfZW50
cg0KICAqIHRoZSBzd2FwIGVudHJ5IGlzIG5vIGxvbmdlciBpbiB1c2UuDQog
ICovDQogc3RydWN0IHBhZ2UgKnJlYWRfc3dhcF9jYWNoZV9hc3luYyhzd3Bf
ZW50cnlfdCBlbnRyeSwgZ2ZwX3QgZ2ZwX21hc2ssDQotCQkJc3RydWN0IHZt
X2FyZWFfc3RydWN0ICp2bWEsIHVuc2lnbmVkIGxvbmcgYWRkcikNCisJCQlz
dHJ1Y3QgbWVtcG9saWN5ICptcG9sLCBwZ29mZl90IHBnb2ZmKQ0KIHsNCiAJ
c3RydWN0IHBhZ2UgKmZvdW5kX3BhZ2UsICpuZXdfcGFnZSA9IE5VTEw7DQog
CWludCBlcnI7DQpAQCAtMjg1LDcgKzI4NSw3IEBAIHN0cnVjdCBwYWdlICpy
ZWFkX3N3YXBfY2FjaGVfYXN5bmMoc3dwX2UNCiAJCSAqIEdldCBhIG5ldyBw
YWdlIHRvIHJlYWQgaW50byBmcm9tIHN3YXAuDQogCQkgKi8NCiAJCWlmICgh
bmV3X3BhZ2UpIHsNCi0JCQluZXdfcGFnZSA9IGFsbG9jX3BhZ2Vfdm1hKGdm
cF9tYXNrLCB2bWEsIGFkZHIpOw0KKwkJCW5ld19wYWdlID0gYWxsb2NfcGFn
ZV9tcG9sKGdmcF9tYXNrLCBtcG9sLCBwZ29mZik7DQogCQkJaWYgKCFuZXdf
cGFnZSkNCiAJCQkJYnJlYWs7CQkvKiBPdXQgb2YgbWVtb3J5ICovDQogCQl9
DQpAQCAtMzQ1LDcgKzM0NSw3IEBAIHN0cnVjdCBwYWdlICpyZWFkX3N3YXBf
Y2FjaGVfYXN5bmMoc3dwX2UNCiAgKiBDYWxsZXIgbXVzdCBob2xkIGRvd25f
cmVhZCBvbiB0aGUgdm1hLT52bV9tbSBpZiB2bWEgaXMgbm90IE5VTEwuDQog
ICovDQogc3RydWN0IHBhZ2UgKnN3YXBpbl9yZWFkYWhlYWQoc3dwX2VudHJ5
X3QgZW50cnksIGdmcF90IGdmcF9tYXNrLA0KLQkJCXN0cnVjdCB2bV9hcmVh
X3N0cnVjdCAqdm1hLCB1bnNpZ25lZCBsb25nIGFkZHIpDQorCQkJc3RydWN0
IG1lbXBvbGljeSAqbXBvbCwgcGdvZmZfdCBwZ29mZikNCiB7DQogCWludCBu
cl9wYWdlczsNCiAJc3RydWN0IHBhZ2UgKnBhZ2U7DQpAQCAtMzYzLDExICsz
NjMsMTEgQEAgc3RydWN0IHBhZ2UgKnN3YXBpbl9yZWFkYWhlYWQoc3dwX2Vu
dHJ5Xw0KIAlmb3IgKGVuZF9vZmZzZXQgPSBvZmZzZXQgKyBucl9wYWdlczsg
b2Zmc2V0IDwgZW5kX29mZnNldDsgb2Zmc2V0KyspIHsNCiAJCS8qIE9rLCBk
byB0aGUgYXN5bmMgcmVhZC1haGVhZCBub3cgKi8NCiAJCXBhZ2UgPSByZWFk
X3N3YXBfY2FjaGVfYXN5bmMoc3dwX2VudHJ5KHN3cF90eXBlKGVudHJ5KSwg
b2Zmc2V0KSwNCi0JCQkJCQlnZnBfbWFzaywgdm1hLCBhZGRyKTsNCisJCQkJ
CQlnZnBfbWFzaywgbXBvbCwgcGdvZmYpOw0KIAkJaWYgKCFwYWdlKQ0KIAkJ
CWJyZWFrOw0KIAkJcGFnZV9jYWNoZV9yZWxlYXNlKHBhZ2UpOw0KIAl9DQog
CWxydV9hZGRfZHJhaW4oKTsJLyogUHVzaCBhbnkgbmV3IHBhZ2VzIG9udG8g
dGhlIExSVSBub3cgKi8NCi0JcmV0dXJuIHJlYWRfc3dhcF9jYWNoZV9hc3lu
YyhlbnRyeSwgZ2ZwX21hc2ssIHZtYSwgYWRkcik7DQorCXJldHVybiByZWFk
X3N3YXBfY2FjaGVfYXN5bmMoZW50cnksIGdmcF9tYXNrLCBtcG9sLCBwZ29m
Zik7DQogfQ0KLS0tIDIuNi4zMC1yYzgvbW0vc3dhcGZpbGUuYwkyMDA5LTAz
LTIzIDIzOjEyOjE0LjAwMDAwMDAwMCArMDAwMA0KKysrIGxpbnV4L21tL3N3
YXBmaWxlLmMJMjAwOS0wNi0wNyAxMzo1Njo1OC4wMDAwMDAwMDAgKzAxMDAN
CkBAIC05NTEsOCArOTUxLDggQEAgc3RhdGljIGludCB0cnlfdG9fdW51c2Uo
dW5zaWduZWQgaW50IHR5cA0KIAkJICovDQogCQlzd2FwX21hcCA9ICZzaS0+
c3dhcF9tYXBbaV07DQogCQllbnRyeSA9IHN3cF9lbnRyeSh0eXBlLCBpKTsN
Ci0JCXBhZ2UgPSByZWFkX3N3YXBfY2FjaGVfYXN5bmMoZW50cnksDQotCQkJ
CQlHRlBfSElHSFVTRVJfTU9WQUJMRSwgTlVMTCwgMCk7DQorCQlwYWdlID0g
cmVhZF9zd2FwX2NhY2hlX2FzeW5jKGVudHJ5LCBHRlBfSElHSFVTRVJfTU9W
QUJMRSwNCisJCQkJCWdldF92bWFfcG9saWN5KGN1cnJlbnQsIE5VTEwsIDAp
LCAwKTsNCiAJCWlmICghcGFnZSkgew0KIAkJCS8qDQogCQkJICogRWl0aGVy
IHN3YXBfZHVwbGljYXRlKCkgZmFpbGVkIGJlY2F1c2UgZW50cnkNCg==

--8323584-1000707623-1244397315=:20105--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
