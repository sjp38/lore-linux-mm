Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 164D96B05F6
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:47:50 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 65-v6so5091294qkl.11
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:47:50 -0700 (PDT)
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id c80-v6si8080512qkj.231.2018.05.18.09.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 May 2018 09:47:48 -0700 (PDT)
Date: Fri, 18 May 2018 16:47:48 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [LSFMM] RDMA data corruption potential during FS writeback
In-Reply-To: <20180518154945.GC15611@ziepe.ca>
Message-ID: <0100016374267882-16b274b1-d6f6-4c13-94bb-8e78a51e9091-000000@email.amazonses.com>
References: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com> <20180518154945.GC15611@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On Fri, 18 May 2018, Jason Gunthorpe wrote:

> > The solution that was proposed at the meeting was that mmu notifiers can
> > remedy that situation by allowing callbacks to the RDMA device to ensure
> > that the RDMA device and the filesystem do not do concurrent writeback.
>
> This keeps coming up, and I understand why it seems appealing from the
> MM side, but the reality is that very little RDMA hardware supports
> this, and it carries with it a fairly big performance penalty so many
> users don't like using it.

Ok so we have a latent data corruption issue that is not being addressed.

> > But could we do more to prevent issues here? I think what may be useful is
> > to not allow the memory registrations of file back writable mappings
> > unless the device driver provides mmu callbacks or something like that.
>
> Why does every proposed solution to this involve crippling RDMA? Are
> there really no ideas no ideas to allow the FS side to accommodate
> this use case??

The newcomer here is RDMA. The FS side is the mainstream use case and has
been there since Unix learned to do paging.

> > There may even be more issues if DAX is being used but the FS writeback
> > has the potential of biting anyone at this point it seems.
>
> I think Dan already 'solved' this via get_user_pages_longterm which
> just fails for DAX backed pages.

That is indeed crippling and would be killing the ideas that we had around
here for using DAX. There needs to be an ability to shove large amounts of
data into memory via RDMA and from there onto a disk without too much of a
fuss and without copying. In the case of DAX this trivially should avoid
the copying to disk since its already in memory. If this does not work
then the whole thing is really not that high performant anymore since it
requires a copy operation.
