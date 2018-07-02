Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6156B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 02:34:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z9-v6so8075498pfe.23
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 23:34:09 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s64-v6si14044811pgs.499.2018.07.01.23.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 23:34:07 -0700 (PDT)
Date: Mon, 2 Jul 2018 09:34:03 +0300
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180702063403.GX3014@mtr-leonro.mtl.com>
References: <20180627113221.GO32348@dhcp22.suse.cz>
 <20180627115349.cu2k3ainqqdrrepz@quack2.suse.cz>
 <20180627115927.GQ32348@dhcp22.suse.cz>
 <20180627124255.np2a6rxy6rb6v7mm@quack2.suse.cz>
 <20180627145718.GB20171@ziepe.ca>
 <20180627170246.qfvucs72seqabaef@quack2.suse.cz>
 <1f6e79c5-5801-16d2-18a6-66bd0712b5b8@nvidia.com>
 <20180628091743.khhta7nafuwstd3m@quack2.suse.cz>
 <20180702055251.GV3014@mtr-leonro.mtl.com>
 <235a23e3-6e02-234c-3e20-b2dddc93e568@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vs0rQTeTompTJjtd"
Content-Disposition: inline
In-Reply-To: <235a23e3-6e02-234c-3e20-b2dddc93e568@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>


--vs0rQTeTompTJjtd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Jul 01, 2018 at 11:10:04PM -0700, John Hubbard wrote:
> On 07/01/2018 10:52 PM, Leon Romanovsky wrote:
> > On Thu, Jun 28, 2018 at 11:17:43AM +0200, Jan Kara wrote:
> >> On Wed 27-06-18 19:42:01, John Hubbard wrote:
> >>> On 06/27/2018 10:02 AM, Jan Kara wrote:
> >>>> On Wed 27-06-18 08:57:18, Jason Gunthorpe wrote:
> >>>>> On Wed, Jun 27, 2018 at 02:42:55PM +0200, Jan Kara wrote:
> >>>>>> On Wed 27-06-18 13:59:27, Michal Hocko wrote:
> >>>>>>> On Wed 27-06-18 13:53:49, Jan Kara wrote:
> >>>>>>>> On Wed 27-06-18 13:32:21, Michal Hocko wrote:
> >>>>>>> [...]
> >>> One question though: I'm still vague on the best actions to take in the
> >>> following functions:
> >>>
> >>>     page_mkclean_one
> >>>     try_to_unmap_one
> >>>
> >>> At the moment, they are both just doing an evil little early-out:
> >>>
> >>> 	if (PageDmaPinned(page))
> >>> 		return false;
> >>>
> >>> ...but we talked about maybe waiting for the condition to clear, instead?
> >>> Thoughts?
> >>
> >> What needs to happen in page_mkclean() depends on the caller. Most of the
> >> callers really need to be sure the page is write-protected once
> >> page_mkclean() returns. Those are:
> >>
> >>   pagecache_isize_extended()
> >>   fb_deferred_io_work()
> >>   clear_page_dirty_for_io() if called for data-integrity writeback - which
> >>     is currently known only in its caller (e.g. write_cache_pages()) where
> >>     it can be determined as wbc->sync_mode == WB_SYNC_ALL. Getting this
> >>     information into page_mkclean() will require some plumbing and
> >>     clear_page_dirty_for_io() has some 50 callers but it's doable.
> >>
> >> clear_page_dirty_for_io() for cleaning writeback (wbc->sync_mode !=
> >> WB_SYNC_ALL) can just skip pinned pages and we probably need to do that as
> >> otherwise memory cleaning would get stuck on pinned pages until RDMA
> >> drivers release its pins.
> >
> > Sorry for naive question, but won't it create too much dirty pages
> > so writeback will be called "non-stop" to rebalance watermarks without
> > ability to progress?
> >
>
> That is an interesting point.
>
> Holding off page writeback of this region does seem like it could cause
> problems under memory pressure. Maybe adjusting the watermarks so that we
> tell the writeback  system, "all is well, just ignore this region until
> we're done with it" might help? Any ideas here are welcome...

AFAIR, it is per-zone, so the solution to count dirty-but-untouchable
number of pages to take them into account for accounting can work, but
it seems like an overkill. Can we create special ZONE for such gup
pages, or this is impossible too?

>
> Longer term, maybe some additional work could allow the kernel to be able
> to writeback the gup-pinned pages (while DMA is happening--snapshots), but
> that seems like a pretty big overhaul.
>
> thanks,
> --
> John Hubbard
> NVIDIA

--vs0rQTeTompTJjtd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJbOcdbAAoJEORje4g2clincF8P/3tH3MM9BAk1vtFcIlSgwgpV
CQo1zGcl889+0KwSERr8y3BKYaPE778TN2m6kUqZPiKJRBQ4AlmUCPR9KPAkvB2G
5JlGMcqBzFd13lfu7i6sG2mAA4inEvvf4Pe0DF2FH8bma3grt3JDLSIhbrk9bu1a
XEV8+ThFcjonsZis2Qr89aXiyvixorRblKWFmtKhlCZkeWYol08I0jk3UTkucod4
PCahPfSXuOJsha2KVLmLlbOH9cIaGHUzNkUtq/R61Fx64HQ/WbGJnIMXJFnDZtVz
o5JI1MtYBTib1j4e/8MaWb1b8CIgv9KoUtX3h8m/ySayRkkyTkdL8jtfuayOCb2P
zf6HcixfstiYaLxzl3QxyRNsnBTBTSxEmnZlK3BQ2/bDD3gP2D5FPpBEim2odSWI
Fh2djmRICd/rnWJVF9b5OUCQ2a6tzquRMVv2is5ogvD2B1pUPf2D4kSEoYA4IKd1
biYv0TL5VJn2DEUK7ldomhimbtji5dXaYocXwVkKzeuXRdkcfXhw9AbbsLLRacyL
78OtTp4++rQdVwh91pcyNibBYrTD/wVPe8KbIPSjXF1I87uzN76uzEVrP7UEute8
LYVHkPMItOpbzqDOBpmDq00d4r0abip3B5Aa4aCrutGsdW0OtaZ4z17Td96CcM1b
39VS5RZudMv3B1dY0Gng
=j7ao
-----END PGP SIGNATURE-----

--vs0rQTeTompTJjtd--
