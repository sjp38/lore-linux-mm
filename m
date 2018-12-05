Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 473B26B719F
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 20:00:30 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id j13so11330609oii.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 17:00:30 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x123sor8420206oix.94.2018.12.04.17.00.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 17:00:29 -0800 (PST)
MIME-Version: 1.0
References: <20181204001720.26138-1-jhubbard@nvidia.com> <20181204001720.26138-2-jhubbard@nvidia.com>
 <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
 <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com> <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
 <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com>
In-Reply-To: <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 4 Dec 2018 17:00:17 -0800
Message-ID: <CAPcyv4ii1F3iRv7TnnT2QAG+M4fst7Cu=8zggVauSizEmCtfTw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Dec 4, 2018 at 4:58 PM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 12/4/18 3:03 PM, Dan Williams wrote:
> > On Tue, Dec 4, 2018 at 1:56 PM John Hubbard <jhubbard@nvidia.com> wrote:
[..]
> > Ok, sorry, I mis-remembered. So, you're effectively trying to capture
> > the end of the page pin event separate from the final 'put' of the
> > page? Makes sense.
> >
>
> Yes, that's it exactly.
>
> >> I was not able to actually find any place where a single additional page
> >> bit would help our situation, which is why this still uses LRU fields for
> >> both the two bits required (the RFC [1] still applies), and the dma_pinned_count.
> >
> > Except the LRU fields are already in use for ZONE_DEVICE pages... how
> > does this proposal interact with those?
>
> Very badly: page->pgmap and page->hmm_data both get corrupted. Is there an entire
> use case I'm missing: calling get_user_pages() on ZONE_DEVICE pages? Said another
> way: is it reasonable to disallow calling get_user_pages() on ZONE_DEVICE pages?
>
> If we have to support get_user_pages() on ZONE_DEVICE pages, then the whole
> LRU field approach is unusable.

Unfortunately, the entire motivation for ZONE_DEVICE was to support
get_user_pages() for persistent memory.
