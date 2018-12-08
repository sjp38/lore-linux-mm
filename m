Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id A921C8E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 13:09:38 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id w80so3718633oiw.19
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 10:09:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21sor3658363oti.126.2018.12.08.10.09.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 08 Dec 2018 10:09:37 -0800 (PST)
MIME-Version: 1.0
References: <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
 <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com> <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com> <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com> <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com> <CAPcyv4hwtMA+4qc6500ucn5vf6fRrNdfyMHru_Jhzx86=1Wwww@mail.gmail.com>
 <20181208163353.GA2952@redhat.com> <20181208164825.GA26154@infradead.org>
In-Reply-To: <20181208164825.GA26154@infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 8 Dec 2018 10:09:26 -0800
Message-ID: <CAPcyv4hP1XrheKTrapANmrg10xz6dpG7cj=qEG8La9L34bCKDQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Sat, Dec 8, 2018 at 8:48 AM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Sat, Dec 08, 2018 at 11:33:53AM -0500, Jerome Glisse wrote:
> > Patchset to use HMM inside nouveau have already been posted, some
> > of the bits have already made upstream and more are line up for
> > next merge window.
>
> Even with that it is a relative fringe feature compared to making
> something like get_user_pages() that is literally used every to actually
> work properly.
>
> So I think we need to kick out HMM here and just find another place for
> it to store data.
>
> And just to make clear that I'm not picking just on this - the same is
> true to a just a little smaller extent for the pgmap..

Fair enough, I cringed as I took a full pointer for that use case, I'm
happy to look at ways of consolidating or dropping that usage.

Another fix that may put pressure 'struct page' is resolving the
untenable situation of dax being incompatible with reflink, i.e.
reflink currently requires page-cache pages. Dave has talked about
silently establishing page-cache entries when a dax-page is cow'd for
reflink, but I wonder if we could go the other way and introduce the
mechanism of a page belonging to multiple mappings simultaneously and
managed by the filesystem.

Both HMM and ZONE_DEVICE in general are guilty of side-stepping the mm
and I'm in favor of undoing that as much as possible,
