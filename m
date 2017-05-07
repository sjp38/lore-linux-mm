Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA336B0315
	for <linux-mm@kvack.org>; Sun,  7 May 2017 00:22:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b17so37620256pfd.1
        for <linux-mm@kvack.org>; Sat, 06 May 2017 21:22:53 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b10si6178537pgf.419.2017.05.06.21.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 May 2017 21:22:52 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v10 3/6] virtio-balloon: VIRTIO_BALLOON_F_PAGE_CHUNKS
Date: Sun, 7 May 2017 04:22:46 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7391FFBE8@shsmsx102.ccr.corp.intel.com>
References: <1493887815-6070-1-git-send-email-wei.w.wang@intel.com>
 <1493887815-6070-4-git-send-email-wei.w.wang@intel.com>
 <20170506012146-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170506012146-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>

On 05/06/2017 06:29 AM, Michael S. Tsirkin wrote:
> On Thu, May 04, 2017 at 04:50:12PM +0800, Wei Wang wrote:
> > Add a new feature, VIRTIO_BALLOON_F_PAGE_CHUNKS, which enables the
> > transfer of the ballooned (i.e. inflated/deflated) pages in chunks to
> > the host.
> >
> > The implementation of the previous virtio-balloon is not very
> > efficient, because the ballooned pages are transferred to the host one
> > by one. Here is the breakdown of the time in percentage spent on each
> > step of the balloon inflating process (inflating 7GB of an 8GB idle
> > guest).
> >
> > 1) allocating pages (6.5%)
> > 2) sending PFNs to host (68.3%)
> > 3) address translation (6.1%)
> > 4) madvise (19%)
> >
> > It takes about 4126ms for the inflating process to complete.
> > The above profiling shows that the bottlenecks are stage 2) and stage
> > 4).
> >
> > This patch optimizes step 2) by transferring pages to the host in
> > chunks. A chunk consists of guest physically continuous pages.
> > When the pages are packed into a chunk, they are converted into
> > balloon page size (4KB) pages. A chunk is offered to the host via a
> > base PFN (i.e. the start PFN of those physically continuous
> > pages) and the size (i.e. the total number of the 4KB balloon size
> > pages). A chunk is formatted as below:
> > --------------------------------------------------------
> > |                 Base (52 bit)        | Rsvd (12 bit) |
> > --------------------------------------------------------
> > --------------------------------------------------------
> > |                 Size (52 bit)        | Rsvd (12 bit) |
> > --------------------------------------------------------
> >
> > By doing so, step 4) can also be optimized by doing address
> > translation and madvise() in chunks rather than page by page.
> >
> > With this new feature, the above ballooning process takes ~590ms
> > resulting in an improvement of ~85%.
> >
> > TODO: optimize stage 1) by allocating/freeing a chunk of pages instead
> > of a single page each time.
> >
> > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > Signed-off-by: Liang Li <liang.z.li@intel.com>
> > Suggested-by: Michael S. Tsirkin <mst@redhat.com>
>=20
>=20
> This is much cleaner, thanks. It might be even better to have wrappers th=
at put
> array and its size in a struct and manage that struct, but I won't requir=
e this for
> submission.

OK, thanks. Would this be your suggestion:

struct virtio_balloon_page_struct {=20
	unsigned int page_bmap_num;
	unsigned long *page_bmap[VIRTIO_BALLOON_PAGE_BMAP_MAX_NUM];
}

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
