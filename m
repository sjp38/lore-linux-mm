Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C7CB28E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 21:24:53 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c84so5097846qkb.13
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 18:24:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 42si3273399qvd.29.2018.12.07.18.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 18:24:52 -0800 (PST)
Date: Fri, 7 Dec 2018 21:24:46 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181208022445.GA7024@redhat.com>
References: <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
 <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
 <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
 <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com>
 <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Dec 07, 2018 at 04:52:42PM -0800, John Hubbard wrote:
> On 12/7/18 11:16 AM, Jerome Glisse wrote:
> > On Thu, Dec 06, 2018 at 06:45:49PM -0800, John Hubbard wrote:
> >> On 12/4/18 5:57 PM, John Hubbard wrote:
> >>> On 12/4/18 5:44 PM, Jerome Glisse wrote:
> >>>> On Tue, Dec 04, 2018 at 05:15:19PM -0800, Matthew Wilcox wrote:
> >>>>> On Tue, Dec 04, 2018 at 04:58:01PM -0800, John Hubbard wrote:
> >>>>>> On 12/4/18 3:03 PM, Dan Williams wrote:
> >>>>>>> Except the LRU fields are already in use for ZONE_DEVICE pages... how
> >>>>>>> does this proposal interact with those?
> >>>>>>
> >>>>>> Very badly: page->pgmap and page->hmm_data both get corrupted. Is there an entire
> >>>>>> use case I'm missing: calling get_user_pages() on ZONE_DEVICE pages? Said another
> >>>>>> way: is it reasonable to disallow calling get_user_pages() on ZONE_DEVICE pages?
> >>>>>>
> >>>>>> If we have to support get_user_pages() on ZONE_DEVICE pages, then the whole 
> >>>>>> LRU field approach is unusable.
> >>>>>
> >>>>> We just need to rearrange ZONE_DEVICE pages.  Please excuse the whitespace
> >>>>> damage:
> >>>>>
> >>>>> +++ b/include/linux/mm_types.h
> >>>>> @@ -151,10 +151,12 @@ struct page {
> >>>>>  #endif
> >>>>>                 };
> >>>>>                 struct {        /* ZONE_DEVICE pages */
> >>>>> +                       unsigned long _zd_pad_2;        /* LRU */
> >>>>> +                       unsigned long _zd_pad_3;        /* LRU */
> >>>>> +                       unsigned long _zd_pad_1;        /* uses mapping */
> >>>>>                         /** @pgmap: Points to the hosting device page map. */
> >>>>>                         struct dev_pagemap *pgmap;
> >>>>>                         unsigned long hmm_data;
> >>>>> -                       unsigned long _zd_pad_1;        /* uses mapping */
> >>>>>                 };
> >>>>>  
> >>>>>                 /** @rcu_head: You can use this to free a page by RCU. */
> >>>>>
> >>>>> You don't use page->private or page->index, do you Dan?
> >>>>
> >>>> page->private and page->index are use by HMM DEVICE page.
> >>>>
> >>>
> >>> OK, so for the ZONE_DEVICE + HMM case, that leaves just one field remaining for 
> >>> dma-pinned information. Which might work. To recap, we need:
> >>>
> >>> -- 1 bit for PageDmaPinned
> >>> -- 1 bit, if using LRU field(s), for PageDmaPinnedWasLru.
> >>> -- N bits for a reference count
> >>>
> >>> Those *could* be packed into a single 64-bit field, if really necessary.
> >>>
> >>
> >> ...actually, this needs to work on 32-bit systems, as well. And HMM is using a lot.
> >> However, it is still possible for this to work.
> >>
> >> Matthew, can I have that bit now please? I'm about out of options, and now it will actually
> >> solve the problem here.
> >>
> >> Given:
> >>
> >> 1) It's cheap to know if a page is ZONE_DEVICE, and ZONE_DEVICE means not on the LRU.
> >> That, in turn, means only 1 bit instead of 2 bits (in addition to a counter) is required, 
> >> for that case. 
> >>
> >> 2) There is an independent bit available (according to Matthew). 
> >>
> >> 3) HMM uses 4 of the 5 struct page fields, so only one field is available for a counter 
> >>    in that case.
> > 
> > To expend on this, HMM private page are use for anonymous page
> > so the index and mapping fields have the value you expect for
> > such pages. Down the road i want also to support file backed
> > page with HMM private (mapping, private, index).
> > 
> > For HMM public both anonymous and file back page are supported
> > today (HMM public is only useful on platform with something like
> > OpenCAPI, CCIX or NVlink ... so PowerPC for now).
> > 
> >> 4) get_user_pages() must work on ZONE_DEVICE and HMM pages.
> > 
> > get_user_pages() only need to work with HMM public page not the
> > private one as we can not allow _anyone_ to pin HMM private page.
> > So on get_user_pages() on HMM private we get a page fault and
> > it is migrated back to regular memory.
> > 
> > 
> >> 5) For a proper atomic counter for both 32- and 64-bit, we really do need a complete
> >> unsigned long field.
> >>
> >> So that leads to the following approach:
> >>
> >> -- Use a single unsigned long field for an atomic reference count for the DMA pinned count.
> >> For normal pages, this will be the *second* field of the LRU (in order to avoid PageTail bit).
> >>
> >> For ZONE_DEVICE pages, we can also line up the fields so that the second LRU field is 
> >> available and reserved for this DMA pinned count. Basically _zd_pad_1 gets move up and
> >> optionally renamed:
> >>
> >> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> >> index 017ab82e36ca..b5dcd9398cae 100644
> >> --- a/include/linux/mm_types.h
> >> +++ b/include/linux/mm_types.h
> >> @@ -90,8 +90,8 @@ struct page {
> >>                                  * are in use.
> >>                                  */
> >>                                 struct {
> >> -                                       unsigned long dma_pinned_flags;
> >> -                                       atomic_t      dma_pinned_count;
> >> +                                       unsigned long dma_pinned_flags; /* LRU.next */
> >> +                                       atomic_t      dma_pinned_count; /* LRU.prev */
> >>                                 };
> >>                         };
> >>                         /* See page-flags.h for PAGE_MAPPING_FLAGS */
> >> @@ -161,9 +161,9 @@ struct page {
> >>                 };
> >>                 struct {        /* ZONE_DEVICE pages */
> >>                         /** @pgmap: Points to the hosting device page map. */
> >> -                       struct dev_pagemap *pgmap;
> >> -                       unsigned long hmm_data;
> >> -                       unsigned long _zd_pad_1;        /* uses mapping */
> >> +                       struct dev_pagemap *pgmap;      /* LRU.next */
> >> +                       unsigned long _zd_pad_1;        /* LRU.prev or dma_pinned_count */
> >> +                       unsigned long hmm_data;         /* uses mapping */
> > 
> > This breaks HMM today as hmm_data would alias with mapping field.
> > hmm_data can only be in LRU.prev
> > 
> 
> I see. OK, HMM has done an efficient job of mopping up unused fields, and now we are
> completely out of space. At this point, after thinking about it carefully, it seems clear
> that it's time for a single, new field:
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 5ed8f6292a53..1c789e324da8 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -182,6 +182,9 @@ struct page {
>         /* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */
>         atomic_t _refcount;
>  
> +       /* DMA usage count. See get_user_pages*(), put_user_page*(). */
> +       atomic_t _dma_pinned_count;
> +
>  #ifdef CONFIG_MEMCG
>         struct mem_cgroup *mem_cgroup;
>  #endif
> 
> 
> ...because after all, the reason this is so difficult is that this fix has to work
> in pretty much every configuration. get_user_pages() use is widespread, it's a very
> general facility, and...it needs fixing.  And we're out of space. 
> 
> I'm going to send out an updated RFC that shows the latest, and I think it's going
> to include the above.

Another crazy idea, why not treating GUP as another mapping of the page
and caller of GUP would have to provide either a fake anon_vma struct or
a fake vma struct (or both for PRIVATE mapping of a file where you can
have a mix of both private and file page thus only if it is a read only
GUP) that would get added to the list of existing mapping.

So the flow would be:
    somefunction_thatuse_gup()
    {
        ...
        GUP(_fast)(vma, ..., fake_anon, fake_vma);
        ...
    }

    GUP(vma, ..., fake_anon, fake_vma)
    {
        if (vma->flags == ANON) {
            // Add the fake anon vma to the anon vma chain as a child
            // of current vma
        } else {
            // Add the fake vma to the mapping tree
        }

        // The existing GUP except that now it inc mapcount and not
        // refcount
        GUP_old(..., &nanonymous, &nfiles);

        atomic_add(&fake_anon->refcount, nanonymous);
        atomic_add(&fake_vma->refcount, nfiles);

        return nanonymous + nfiles;
    }

I believe all call place of GUP could be updated they fall into 2
categories:
    - fake_anon/fake_vma on stack (direct I/O and few other who
      just do GUP inside their work function and drop reference
      their too)
    - fake_anon/fake_vma as part of the object they have ie GUP
      user that have some kind of struct where they keep the result
      of the GUP around (most user in driver directory fall under
      that)


Few nice bonus:
    [B1] GUP_pin <= (mapcount - refcount) ie it gives a boundary for
         number of GUP on the page (some other part of the kernel might
         still temporarily inc the refcount without a mapcount increase)
    [B2] can add a revoke call back as part of the fake anon_vma/
         vma structure (if the existing GUP user can do that or maybe
         something like an emergency revoke when the memory is poisonous)
    [B3] extra cost is once per GUP call not per page so the impact
         on performance should definitly be better
    [B4] no need to modify LRU or complexify the inner of GUP code
         only the pre-ambule.

Few issues with that proposal:
    [I1] need to check mapcount in page free code path to avoid
         freeing the page if refcount reach 0 before all the GUP
         user unmap the page, page is no in some zombie state ie
         refcount = 0 and mapcount > 0
    [I2] KVM seems to use GUP for weird reasons, it might be better
         to convert KVM to use something else than GUP that have the
         same end result from KVM point of view (i believe it uses it
         to force page fault on the host page). Maybe we can work
         with KVM folks and see if we can provide them with the API
         that actualy do what they want instead of them using GUP
         for its side effect
    [I3] ANON page will need special handling as this will confuse
         mm code path that deal with COW pages ... the page is not
         COW but still has mapcount > 1
    [I4] GUP must be per vma (not an issue everywhere) we can provide
         helpers to iterate over virtual address by vma
    [I5] to ascertain that a page is under GUP might be costly code
         would look like:
            bool page_is_guped(struct page *page)
            {
                if (page_mapcount(page) > page_refcount(page)) {
                    return true;
                }
                // Unknown have to walk the reverse mapping to see
                // if they are any fake anon or fake vma and even
                // if there is we could not say for sure if they
                // apply to the page under consideration we would
                // have to assume so unless:
                //
                // GUP user keep around the array they used to store
                // the GUP results then we can check if the page is
                // in there.
            }

Probably other issues i can not think of right now ...


Maybe even better would be to add a pointer to struct address_space
and re-arrange struct anon_vma to move unsigned degree at the top and
define some flag in it (i don't think we want to grow anon_vam struct)
so that we can differentiate fake anon_vma from others by looking at
first word.

Patchset would probably looks like:
    [1-N] Convert all put_page to put_user_page() with an extra void
          pointer as first step (to allow converting using one at a
          time)
    [N-M] convet every GUP user to provide the fake struct (from
          stack or as part of their object that track GUP result)
    [M-O] patches to add all the helpers and changes inside mm to
          handle fake vma and fake anon vma and the implication of
          having mapcount > refcount (not all time)
    [P] convert GUP to add the fake to anon_vma/mapping and convert
        GUP to inc mapcount and not refcount

Note that the GUP user do not necessarily need to keep the fake
anon or vma struct as part of their own struct. It can use a key
system ie:
    put_user_page_with_key(page, key);
    versus
    put_user_page(page, fake_anon/fake_vma);

Then put_user_page would walk the list of mapping of the page
until it finds the fake anon or fake vma that have the matching
key and dec the refcount of that fake struct and free it once
it reaches zero ...

Anyway they are few thing we can do to alievate the pain for the
GUP users.


Maybe this is crazy but this is what i have without needing to add
a field to struct page.

Cheers,
J�r�me
