Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 224B46B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:08:41 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id v4-v6so5825240plz.21
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:08:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2-v6si1912670pfn.13.2018.10.03.09.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 09:08:39 -0700 (PDT)
Date: Wed, 3 Oct 2018 18:08:36 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/4] get_user_pages*() and RDMA: first steps
Message-ID: <20181003160836.GF24030@quack2.suse.cz>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928152958.GA3321@redhat.com>
 <4c884529-e2ff-3808-9763-eb0e71f5a616@nvidia.com>
 <20180928214934.GA3265@redhat.com>
 <dfa6aaef-b97e-ebd4-6cc8-c907a7b3f9bb@nvidia.com>
 <20180929084608.GA3188@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180929084608.GA3188@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Christian Benvenuti <benve@cisco.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>

On Sat 29-09-18 04:46:09, Jerome Glisse wrote:
> On Fri, Sep 28, 2018 at 07:28:16PM -0700, John Hubbard wrote:
> > Actually, the latest direction on that discussion was toward periodically
> > writing back, even while under RDMA, via bounce buffers:
> > 
> >   https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
> > 
> > I still think that's viable. Of course, there are other things besides 
> > writeback (see below) that might also lead to waiting.
> 
> Write back under bounce buffer is fine, when looking back at links you
> provided the solution that was discuss was blocking in page_mkclean()
> which is horrible in my point of view.

Yeah, after looking into it for some time, we figured that waiting for page
pins in page_mkclean() isn't really going to fly due to deadlocks. So we
came up with the bounce buffers idea which should solve that nicely.

> > > With the solution put forward here you can potentialy wait _forever_ for
> > > the driver that holds a pin to drop it. This was the point i was trying to
> > > get accross during LSF/MM. 
> > 
> > I agree that just blocking indefinitely is generally unacceptable for kernel
> > code, but we can probably avoid it for many cases (bounce buffers), and
> > if we think it is really appropriate (file system unmounting, maybe?) then
> > maybe tolerate it in some rare cases.  
> > 
> > >You can not fix broken hardware that decided to
> > > use GUP to do a feature they can't reliably do because their hardware is
> > > not capable to behave.
> > > 
> > > Because code is easier here is what i was meaning:
> > > 
> > > https://cgit.freedesktop.org/~glisse/linux/commit/?h=gup&id=a5dbc0fe7e71d347067579f13579df372ec48389
> > > https://cgit.freedesktop.org/~glisse/linux/commit/?h=gup&id=01677bc039c791a16d5f82b3ef84917d62fac826
> > > 
> > 
> > While that may work sometimes, I don't think it is reliable enough to trust for
> > identifying pages that have been gup-pinned. There's just too much overloading of
> > other mechanisms going on there, and if we pile on top with this constraint of "if you
> > have +3 refcounts, and this particular combination of page counts and mapcounts, then
> > you're definitely a long-term pinned page", I think users will find a lot of corner
> > cases for us that break that assumption. 
> 
> So the mapcount == refcount (modulo extra reference for mapping and
> private) should holds, here are the case when it does not:
>     - page being migrated
>     - page being isolated from LRU
>     - mempolicy changes against the page
>     - page cache lookup
>     - some file system activities
>     - i likely miss couples here i am doing that from memory
> 
> What matter is that all of the above are transitory, the extra reference
> only last for as long as it takes for the action to finish (migration,
> mempolicy change, ...).
> 
> So skipping those false positive page while reclaiming likely make sense,
> the blocking free buffer maybe not.

Well, as John wrote, these page refcount are fragile (and actually
filesystem dependent as some filesystems hold page reference from their
page->private data and some don't). So I think we really need a new
reliable mechanism for tracking page references from GUP. And John works
towards that.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
