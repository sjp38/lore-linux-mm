Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 250898E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 02:16:46 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id t184so2961470oih.22
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 23:16:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n20sor3058163otq.97.2018.12.07.23.16.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 23:16:44 -0800 (PST)
MIME-Version: 1.0
References: <20181204001720.26138-1-jhubbard@nvidia.com> <20181204001720.26138-2-jhubbard@nvidia.com>
 <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
 <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com> <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
 <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com> <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com> <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com> <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
In-Reply-To: <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 7 Dec 2018 23:16:32 -0800
Message-ID: <CAPcyv4hwtMA+4qc6500ucn5vf6fRrNdfyMHru_Jhzx86=1Wwww@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Dec 7, 2018 at 4:53 PM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 12/7/18 11:16 AM, Jerome Glisse wrote:
> > On Thu, Dec 06, 2018 at 06:45:49PM -0800, John Hubbard wrote:
[..]
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

HMM seems entirely too greedy in this regard. Especially with zero
upstream users. When can we start to delete the pieces of HMM that
have no upstream consumers? I would think that would be 4.21 / 5.0 as
there needs to be some forcing function. We can always re-add pieces
of HMM with it's users when / if they arrive.
