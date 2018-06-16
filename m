Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4566B0007
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 21:09:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y26-v6so5451865pfn.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 18:09:51 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u21-v6si8803912pfd.78.2018.06.15.18.09.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 18:09:49 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v33 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Date: Sat, 16 Jun 2018 01:09:44 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7396A5CB0@shsmsx102.ccr.corp.intel.com>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <1529037793-35521-3-git-send-email-wei.w.wang@intel.com>
 <20180615144000-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7396A3D04@shsmsx102.ccr.corp.intel.com>
 <20180615171635-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180615171635-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Michael S. Tsirkin'" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On Friday, June 15, 2018 10:29 PM, Michael S. Tsirkin wrote:
> On Fri, Jun 15, 2018 at 02:11:23PM +0000, Wang, Wei W wrote:
> > On Friday, June 15, 2018 7:42 PM, Michael S. Tsirkin wrote:
> > > On Fri, Jun 15, 2018 at 12:43:11PM +0800, Wei Wang wrote:
> > > > Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_HINT feature
> > > > indicates the support of reporting hints of guest free pages to hos=
t via
> virtio-balloon.
> > > >
> > > > Host requests the guest to report free page hints by sending a
> > > > command to the guest via setting the
> > > VIRTIO_BALLOON_HOST_CMD_FREE_PAGE_HINT
> > > > bit of the host_cmd config register.
> > > >
> > > > As the first step here, virtio-balloon only reports free page
> > > > hints from the max order (10) free page list to host. This has
> > > > generated similar good results as reporting all free page hints dur=
ing
> our tests.
> > > >
> > > > TODO:
> > > > - support reporting free page hints from smaller order free page li=
sts
> > > >   when there is a need/request from users.
> > > >
> > > > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > > > Signed-off-by: Liang Li <liang.z.li@intel.com>
> > > > Cc: Michael S. Tsirkin <mst@redhat.com>
> > > > Cc: Michal Hocko <mhocko@kernel.org>
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > ---
> > > >  drivers/virtio/virtio_balloon.c     | 187
> +++++++++++++++++++++++++++++--
> > > -----
> > > >  include/uapi/linux/virtio_balloon.h |  13 +++
> > > >  2 files changed, 163 insertions(+), 37 deletions(-)
> > > >
> > > > diff --git a/drivers/virtio/virtio_balloon.c
> > > > b/drivers/virtio/virtio_balloon.c index 6b237e3..582a03b 100644
> > > > --- a/drivers/virtio/virtio_balloon.c
> > > > +++ b/drivers/virtio/virtio_balloon.c
> > > > @@ -43,6 +43,9 @@
> > > >  #define OOM_VBALLOON_DEFAULT_PAGES 256  #define
> > > > VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
> > > >
> > > > +/* The size of memory in bytes allocated for reporting free page
> > > > +hints */ #define FREE_PAGE_HINT_MEM_SIZE (PAGE_SIZE * 16)
> > > > +
> > > >  static int oom_pages =3D OOM_VBALLOON_DEFAULT_PAGES;
> > > > module_param(oom_pages, int, S_IRUSR | S_IWUSR);
> > > > MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
> > >
> > > Doesn't this limit memory size of the guest we can report?
> > > Apparently to several gigabytes ...
> > > OTOH huge guests with lots of free memory is exactly where we would
> > > gain the most ...
> >
> > Yes, the 16-page array can report up to 32GB (each page can hold 512
> addresses of 4MB free page blocks, i.e. 2GB free memory per page) free
> memory to host. It is not flexible.
> >
> > How about allocating the buffer according to the guest memory size
> > (proportional)? That is,
> >
> > /* Calculates the maximum number of 4MB (equals to 1024 pages) free
> > pages blocks that the system can have */ 4m_page_blocks =3D
> > totalram_pages / 1024;
> >
> > /* Allocating one page can hold 512 free page blocks, so calculates
> > the number of pages that can hold those 4MB blocks. And this
> > allocation should not exceed 1024 pages */ pages_to_allocate =3D
> > min(4m_page_blocks / 512, 1024);
> >
> > For a 2TB guests, which has 2^19 page blocks (4MB each), we will alloca=
te
> 1024 pages as the buffer.
> >
> > When the guest has large memory, it should be easier to succeed in
> allocation of large buffer. If that allocation fails, that implies that n=
othing
> would be got from the 4MB free page list.
> >
> > I think the proportional allocation is simpler compared to other
> > approaches like
> > - scattered buffer, which will complicate the get_from_free_page_list
> > implementation;
> > - one buffer to call get_from_free_page_list multiple times, which need=
s
> get_from_free_page_list to maintain states.. also too complicated.
> >
> > Best,
> > Wei
> >
>=20
> That's more reasonable, but question remains what to do if that value
> exceeds MAX_ORDER. I'd say maybe tell host we can't report it.

Not necessarily, I think. We have min(4m_page_blocks / 512, 1024) above, so=
 the maximum memory that can be reported is 2TB. For larger guests, e.g. 4T=
B, the optimization can still offer 2TB free memory (better than no optimiz=
ation).

On the other hand, large guests being large mostly because the guests need =
to use large memory. In that case, they usually won't have that much free m=
emory to report.

>=20
> Also allocating it with GFP_KERNEL is out. You only want to take it off t=
he free
> list. So I guess __GFP_NOMEMALLOC and __GFP_ATOMIC.

Sounds good, thanks.

> Also you can't allocate this on device start. First totalram_pages can ch=
ange.
> Second that's too much memory to tie up forever.

Yes, makes sense.

Best,
Wei
