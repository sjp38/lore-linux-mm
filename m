Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 934888E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 00:18:15 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id g7so4226477plp.10
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 21:18:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i6si4511957plt.290.2018.12.07.21.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Dec 2018 21:18:14 -0800 (PST)
Date: Fri, 7 Dec 2018 21:18:10 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181208051810.GA24118@bombadil.infradead.org>
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
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Dec 07, 2018 at 04:52:42PM -0800, John Hubbard wrote:
> I see. OK, HMM has done an efficient job of mopping up unused fields, and now we are
> completely out of space. At this point, after thinking about it carefully, it seems clear
> that it's time for a single, new field:

Sorry for not replying earlier; I'm travelling and have had trouble
keeping on top of my mail.

Adding this field will grow struct page by 4-8 bytes, so it will no
longer be 64 bytes.  This isn't an acceptable answer.

We have a few options for bits.  One is that we have (iirc) two
bits available in page->flags on 32-bit.  That'll force a few more
configurations into using _last_cpupid and/or page_ext.  I'm not a huge
fan of this approach.

The second is to use page->lru.next bit 1.  This requires some care
because m68k allows misaligned pointers.  If the list_head that it's
joined to is misaligned, we'll be in trouble.  This can get tricky because
some pages are attached to list_heads which are on the stack ... and I
don't think gcc guarantees __aligned attributes work for stack variables.

The third is to use page->lru.prev bit 0.  We'd want to switch pgmap
and hmm_data around to make this work, and we'd want to record this
in mm_types.h so nobody tries to use a field which aliases with
page->lru.prev and has bit 0 set on a page which can be mapped to
userspace (which I currently believe to be true).

The fourth is to use a bit in page->flags for 64-bit and a bit in
page_ext->flags for 32-bit.  Or we could get rid of page_ext and grow
struct page with a ->flags2 on 32-bit.

Fifth, it isn't clear to me how many bits might be left in ->_last_cpupid
at this point, and perhaps there's scope for using a bit in there.

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
> 
> -- 
> thanks,
> John Hubbard
> NVIDIA
> 
