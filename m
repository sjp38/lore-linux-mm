Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41B3D6B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 01:52:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f81-v6so4484731pfd.7
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 22:52:57 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d4-v6si13281886pgq.411.2018.07.01.22.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 22:52:55 -0700 (PDT)
Date: Mon, 2 Jul 2018 08:52:51 +0300
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180702055251.GV3014@mtr-leonro.mtl.com>
References: <20180626134757.GY28965@dhcp22.suse.cz>
 <20180626164825.fz4m2lv6hydbdrds@quack2.suse.cz>
 <20180627113221.GO32348@dhcp22.suse.cz>
 <20180627115349.cu2k3ainqqdrrepz@quack2.suse.cz>
 <20180627115927.GQ32348@dhcp22.suse.cz>
 <20180627124255.np2a6rxy6rb6v7mm@quack2.suse.cz>
 <20180627145718.GB20171@ziepe.ca>
 <20180627170246.qfvucs72seqabaef@quack2.suse.cz>
 <1f6e79c5-5801-16d2-18a6-66bd0712b5b8@nvidia.com>
 <20180628091743.khhta7nafuwstd3m@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="l06SQqiZYCi8rTKz"
Content-Disposition: inline
In-Reply-To: <20180628091743.khhta7nafuwstd3m@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>


--l06SQqiZYCi8rTKz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 28, 2018 at 11:17:43AM +0200, Jan Kara wrote:
> On Wed 27-06-18 19:42:01, John Hubbard wrote:
> > On 06/27/2018 10:02 AM, Jan Kara wrote:
> > > On Wed 27-06-18 08:57:18, Jason Gunthorpe wrote:
> > >> On Wed, Jun 27, 2018 at 02:42:55PM +0200, Jan Kara wrote:
> > >>> On Wed 27-06-18 13:59:27, Michal Hocko wrote:
> > >>>> On Wed 27-06-18 13:53:49, Jan Kara wrote:
> > >>>>> On Wed 27-06-18 13:32:21, Michal Hocko wrote:
> > >>>> [...]
> > >>>>>> Appart from that, do we really care about 32b here? Big DIO, IB users
> > >>>>>> seem to be 64b only AFAIU.
> > >>>>>
> > >>>>> IMO it is a bad habit to leave unpriviledged-user-triggerable oops in the
> > >>>>> kernel even for uncommon platforms...
> > >>>>
> > >>>> Absolutely agreed! I didn't mean to keep the blow up for 32b. I just
> > >>>> wanted to say that we can stay with a simple solution for 32b. I thought
> > >>>> the g-u-p-longterm has plugged the most obvious breakage already. But
> > >>>> maybe I just misunderstood.
> > >>>
> > >>> Most yes, but if you try hard enough, you can still trigger the oops e.g.
> > >>> with appropriately set up direct IO when racing with writeback / reclaim.
> > >>
> > >> gup longterm is only different from normal gup if you have DAX and few
> > >> people do, which really means it doesn't help at all.. AFAIK??
> > >
> > > Right, what I wrote works only for DAX. For non-DAX situation g-u-p
> > > longterm does not currently help at all. Sorry for confusion.
> > >
> >
> > OK, I've got an early version of this up and running, reusing the page->lru
> > fields. I'll clean it up and do some heavier testing, and post as a PATCH v2.
>
> Cool.
>
> > One question though: I'm still vague on the best actions to take in the
> > following functions:
> >
> >     page_mkclean_one
> >     try_to_unmap_one
> >
> > At the moment, they are both just doing an evil little early-out:
> >
> > 	if (PageDmaPinned(page))
> > 		return false;
> >
> > ...but we talked about maybe waiting for the condition to clear, instead?
> > Thoughts?
>
> What needs to happen in page_mkclean() depends on the caller. Most of the
> callers really need to be sure the page is write-protected once
> page_mkclean() returns. Those are:
>
>   pagecache_isize_extended()
>   fb_deferred_io_work()
>   clear_page_dirty_for_io() if called for data-integrity writeback - which
>     is currently known only in its caller (e.g. write_cache_pages()) where
>     it can be determined as wbc->sync_mode == WB_SYNC_ALL. Getting this
>     information into page_mkclean() will require some plumbing and
>     clear_page_dirty_for_io() has some 50 callers but it's doable.
>
> clear_page_dirty_for_io() for cleaning writeback (wbc->sync_mode !=
> WB_SYNC_ALL) can just skip pinned pages and we probably need to do that as
> otherwise memory cleaning would get stuck on pinned pages until RDMA
> drivers release its pins.

Sorry for naive question, but won't it create too much dirty pages
so writeback will be called "non-stop" to rebalance watermarks without
ability to progress?

Thanks

--l06SQqiZYCi8rTKz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJbOb2zAAoJEORje4g2clin2UEP/2gsXQfoqD/g3+O6NCSU6W8/
zWhbpfKO5Sdk1SxTUcgiIA8q8NsYfdkS3MrELWp2HnnsopBzwfDvCyJWgyPyXUn5
eDFdSzVmZJal1i1SaUr1cAvCwZRYKw8ht5yq6delwJHSVsfy6Aqp4WOQrCtybV4A
BODxFNtd1xjn7U6fdlAD07L/dSCyWVmV0ePqy2Fk6lPOuHimOV0Zy8XfLp++fopq
sQkYpe9ZV712fsiIOZGMFtL0ictgjn917JnJKN4g89s3fNUwZHvivWu1KbEqyVeT
sdC6rdW/tN24aIXd1mmn+DVBI/6g/oD+WDfjYOQcbbVvwWc4PLfWhITE63oMjwRh
GUWwHE12O8o5TU6MyXkKcleQmdXhIFoZvRzxJmxxmW+4aPj8agPf2GIRjINYdwAL
3tkqUL/tEGtCIu3+5poOIqgMp/AwXAchDPaSIJuyOrjamFUj8f1X1ZvElPjaBjQn
RLvtteMqSIP+q0iU2pTR0/2/DEHIBZPBGKaxHo6FToDMNJRi4RB6/BBR9qc/7fWp
7xhf8jw+Sk+cFPSOBh6Ju2Eajq3lGrU4VNz+aT3el7jOeTY4LJizLdzVRVOmVXv7
G+CAVzaNK/G77Qc0F0TY2s7S9ihh+hcyiYyUSG/l/v2zxl1qRaMlu077n9EPmxi3
RyDg7USdthTqO8uo/Ybw
=GG7j
-----END PGP SIGNATURE-----

--l06SQqiZYCi8rTKz--
