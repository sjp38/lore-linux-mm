Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBEA6B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 21:57:43 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id r26-v6so962585otk.17
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 18:57:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o7-v6sor412237oig.29.2018.06.19.18.57.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 18:57:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <ecb54f89-52dc-a37a-5592-d2c40f216047@nvidia.com>
References: <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
 <311eba48-60f1-b6cc-d001-5cc3ed4d76a9@nvidia.com> <20180618081258.GB16991@lst.de>
 <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com> <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
 <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com> <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <0e6053b3-b78c-c8be-4fab-e8555810c732@nvidia.com> <20180619082949.wzoe42wpxsahuitu@quack2.suse.cz>
 <20180619090255.GA25522@bombadil.infradead.org> <20180619104142.lpilc6esz7w3a54i@quack2.suse.cz>
 <70001987-3938-d33e-11e0-de5b19ca3bdf@nvidia.com> <CAPcyv4iGKYRpbv-KK3KUrm8Ab485DwX05y4uGH2ZZ8GNYh8Q_g@mail.gmail.com>
 <ecb54f89-52dc-a37a-5592-d2c40f216047@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Jun 2018 18:57:41 -0700
Message-ID: <CAPcyv4iZU3Cin589Tg2g=NN5XoTosbsosf27frxBCWznB+X8ng@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <john.hubbard@gmail.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Tue, Jun 19, 2018 at 6:34 PM, John Hubbard <jhubbard@nvidia.com> wrote:
> On 06/19/2018 06:24 PM, Dan Williams wrote:
>> On Tue, Jun 19, 2018 at 11:11 AM, John Hubbard <jhubbard@nvidia.com> wrote:
>>> On 06/19/2018 03:41 AM, Jan Kara wrote:
>>>> On Tue 19-06-18 02:02:55, Matthew Wilcox wrote:
>>>>> On Tue, Jun 19, 2018 at 10:29:49AM +0200, Jan Kara wrote:
>> [..]
>>>> And then there's the aspect that both these approaches are a bit too
>>>> heavyweight for some get_user_pages_fast() users (e.g. direct IO) - Al Viro
>>>> had an idea to use page lock for that path but e.g. fs/direct-io.c would have
>>>> problems due to lock ordering constraints (filesystem ->get_block would
>>>> suddently get called with the page lock held). But we can probably leave
>>>> performance optimizations for phase two.
>>>
>>>
>>> So I assume that phase one would be to apply this approach only to
>>> get_user_pages_longterm. (Please let me know if that's wrong.)
>>
>> I think that's wrong, because get_user_pages_longterm() is only a
>> filesystem-dax avoidance mechanism, it's not trying to address all the
>> problems that Jan is talking about. I don't see any viable half-step
>> solutions.
>>
>
> OK, but in that case, I'm slightly confused by Jan's comment above, about leaving
> performance optimizations until phase two. Because that *is* a half-step approach:
> phase one, phase two.

No, sorry, I might be confusing things. The half step is leaving
truncate broken, or my strawman that only addressed unmap.

> Are you disagreeing with Jan, or are you suggesting "fix get_user_pages first, and
> leave get_user_pages_fast alone for now?"

I'm agreeing with Jan, we need to fix page_mkclean() and
try_to_unmap() without regressing truncate behavior.
