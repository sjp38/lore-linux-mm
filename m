Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44E306B069B
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 07:48:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x64so1863261wmg.11
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 04:48:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t44si1428087wrc.248.2017.08.03.04.48.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 04:48:46 -0700 (PDT)
Date: Thu, 3 Aug 2017 13:48:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] Tagging of vmalloc pages for supporting the pmalloc
 allocator
Message-ID: <20170803114844.GO12521@dhcp22.suse.cz>
References: <07063abd-2f5d-20d9-a182-8ae9ead26c3c@huawei.com>
 <20170802170848.GA3240@redhat.com>
 <8e82639c-40db-02ce-096a-d114b0436d3c@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8e82639c-40db-02ce-096a-d114b0436d3c@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Kees Cook <keescook@google.com>

On Thu 03-08-17 13:11:45, Igor Stoppa wrote:
> On 02/08/17 20:08, Jerome Glisse wrote:
> > On Wed, Aug 02, 2017 at 06:14:28PM +0300, Igor Stoppa wrote:
[...]
> >> A way to ensure that the address really belongs to pmalloc would be to
> >> pre-screen it, against either the signature or some magic number and,
> >> if such test is passed, then compare the address against those really
> >> available in the pmalloc pools.
> >>
> >> This would be slower, but it would be limited only to those cases where
> >> the signature/magic number matches and the answer is likely to be true.
> >>
> >> 2) However, both the current (incorrect) implementation and the one I am
> >> considering, are abusing something that should be used otherwise (see
> >> the following snippet):
> >>
> >> from include/linux/mm_types.h:
> >>
> >> struct page {
> >> ...
> >>   union {
> >>     unsigned long private;		/* Mapping-private opaque data:
> >> 				 	 * usually used for buffer_heads
> >> 					 * if PagePrivate set; used for
> >> 					 * swp_entry_t if PageSwapCache;
> >> 					 * indicates order in the buddy
> >> 					 * system if PG_buddy is set.
> >> 					 */
> >> #if USE_SPLIT_PTE_PTLOCKS
> >> #if ALLOC_SPLIT_PTLOCKS
> >> 		spinlock_t *ptl;
> >> #else
> >> 		spinlock_t ptl;
> >> #endif
> >> #endif
> >> 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
> >> 	};
> >> ...
> >> }
> >>
> >>
> >> The "private" field is meant for mapping-private opaque data, which is
> >> not how I am using it.
> > 
> > As you can see this is an union and thus the meaning of that field depends
> > on how the page is use. The private comment you see is only meaningfull for
> > page that are in the page cache and are coming from a file system ie when
> > a process does an mmap of a file. When page is use by sl[au]b the slab_cache
> > field is how it is interpreted ... Context in which a page is use do matter.
> 
> I am not native English speaker, but the comment seems to imply that, no
> matter what, it's Mapping-private.
> 
> If the "Mapping-private" was dropped or somehow connected exclusively to
> the cases listed in the comment, then I think it would be more clear
> that the comment needs to be intended as related to mapping in certain
> cases only.
> But it is otherwise ok to use the "private" field for whatever purpose
> it might be suitable, as long as it is not already in use.

I would recommend adding a new field into the enum...
[...]
> But, to reply more specifically to your advice, yes, I think I could add
> a flag to vm_struct and then retrieve its value, for the address being
> processed, by passing through find_vm_area().

... and you can store vm_struct pointer to the struct page there and you
won't need to do the slow find_vm_area. I haven't checked very closely
but this should be possible in principle. I guess other callers might
benefit from this as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
