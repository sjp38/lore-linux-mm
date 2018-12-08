Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 144D38E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 11:34:01 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q3so7097119qtq.15
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 08:34:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t27si1466086qvt.161.2018.12.08.08.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Dec 2018 08:33:59 -0800 (PST)
Date: Sat, 8 Dec 2018 11:33:53 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181208163353.GA2952@redhat.com>
References: <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
 <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
 <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com>
 <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <CAPcyv4hwtMA+4qc6500ucn5vf6fRrNdfyMHru_Jhzx86=1Wwww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4hwtMA+4qc6500ucn5vf6fRrNdfyMHru_Jhzx86=1Wwww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Dec 07, 2018 at 11:16:32PM -0800, Dan Williams wrote:
> On Fri, Dec 7, 2018 at 4:53 PM John Hubbard <jhubbard@nvidia.com> wrote:
> >
> > On 12/7/18 11:16 AM, Jerome Glisse wrote:
> > > On Thu, Dec 06, 2018 at 06:45:49PM -0800, John Hubbard wrote:
> [..]
> > I see. OK, HMM has done an efficient job of mopping up unused fields, and now we are
> > completely out of space. At this point, after thinking about it carefully, it seems clear
> > that it's time for a single, new field:
> >
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 5ed8f6292a53..1c789e324da8 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -182,6 +182,9 @@ struct page {
> >         /* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */
> >         atomic_t _refcount;
> >
> > +       /* DMA usage count. See get_user_pages*(), put_user_page*(). */
> > +       atomic_t _dma_pinned_count;
> > +
> >  #ifdef CONFIG_MEMCG
> >         struct mem_cgroup *mem_cgroup;
> >  #endif
> >
> >
> > ...because after all, the reason this is so difficult is that this fix has to work
> > in pretty much every configuration. get_user_pages() use is widespread, it's a very
> > general facility, and...it needs fixing.  And we're out of space.
> 
> HMM seems entirely too greedy in this regard. Especially with zero
> upstream users. When can we start to delete the pieces of HMM that
> have no upstream consumers? I would think that would be 4.21 / 5.0 as
> there needs to be some forcing function. We can always re-add pieces
> of HMM with it's users when / if they arrive.

Patchset to use HMM inside nouveau have already been posted, some
of the bits have already made upstream and more are line up for
next merge window.

Cheers,
J�r�me
