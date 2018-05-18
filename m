Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B69FA6B064F
	for <linux-mm@kvack.org>; Fri, 18 May 2018 13:36:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b64-v6so5126345pfl.13
        for <linux-mm@kvack.org>; Fri, 18 May 2018 10:36:39 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o70-v6sor3865515pfo.38.2018.05.18.10.36.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 10:36:38 -0700 (PDT)
Date: Fri, 18 May 2018 11:36:37 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [LSFMM] RDMA data corruption potential during FS writeback
Message-ID: <20180518173637.GF15611@ziepe.ca>
References: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com>
 <20180518154945.GC15611@ziepe.ca>
 <0100016374267882-16b274b1-d6f6-4c13-94bb-8e78a51e9091-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016374267882-16b274b1-d6f6-4c13-94bb-8e78a51e9091-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On Fri, May 18, 2018 at 04:47:48PM +0000, Christopher Lameter wrote:
> On Fri, 18 May 2018, Jason Gunthorpe wrote:
> 
> > > The solution that was proposed at the meeting was that mmu notifiers can
> > > remedy that situation by allowing callbacks to the RDMA device to ensure
> > > that the RDMA device and the filesystem do not do concurrent writeback.
> >
> > This keeps coming up, and I understand why it seems appealing from the
> > MM side, but the reality is that very little RDMA hardware supports
> > this, and it carries with it a fairly big performance penalty so many
> > users don't like using it.
> 
> Ok so we have a latent data corruption issue that is not being addressed.
> 
> > > But could we do more to prevent issues here? I think what may be useful is
> > > to not allow the memory registrations of file back writable mappings
> > > unless the device driver provides mmu callbacks or something like that.
> >
> > Why does every proposed solution to this involve crippling RDMA? Are
> > there really no ideas no ideas to allow the FS side to accommodate
> > this use case??
> 
> The newcomer here is RDMA. The FS side is the mainstream use case and has
> been there since Unix learned to do paging.

Well, it has been this way for 12 years, so it isn't that new.

Honestly it sounds like get_user_pages is just a broken Linux
API??

Nothing can use it to write to pages because the FS could explode -
RDMA makes it particularly easy to trigger this due to the longer time
windows, but presumably any get_user_pages could generate a race and
hit this? Is that right?

I am left with the impression that solving it in the FS is too
performance costly so FS doesn't want that overheard? Was that also
the conclusion?

Could we take another crack at this during Linux Plumbers? Will the MM
parties be there too? I'm sorry I wasn't able to attend LSFMM this
year!

> > > There may even be more issues if DAX is being used but the FS writeback
> > > has the potential of biting anyone at this point it seems.
> >
> > I think Dan already 'solved' this via get_user_pages_longterm which
> > just fails for DAX backed pages.
> 
> That is indeed crippling and would be killing the ideas that we had around
> here for using DAX. There needs to be an ability to shove large amounts of
> data into memory via RDMA and from there onto a disk without too much of a
> fuss and without copying. In the case of DAX this trivially should avoid
> the copying to disk since its already in memory. If this does not work
> then the whole thing is really not that high performant anymore since it
> requires a copy operation.

AFIAK, if you enable ODP on your MR then DAX will work as you want,
but you take lower network performance to get it. You might be the
first person to test this though ;)

Jason
