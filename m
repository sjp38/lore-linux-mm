Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA7F16B02F3
	for <linux-mm@kvack.org>; Sun,  7 May 2017 00:19:34 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i63so41356585pgd.15
        for <linux-mm@kvack.org>; Sat, 06 May 2017 21:19:34 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u79si6051889pgb.192.2017.05.06.21.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 May 2017 21:19:33 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [virtio-dev] Re: [PATCH v9 2/5] virtio-balloon:
 VIRTIO_BALLOON_F_BALLOON_CHUNKS
Date: Sun, 7 May 2017 04:19:28 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7391FFBB0@shsmsx102.ccr.corp.intel.com>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
 <1492076108-117229-3-git-send-email-wei.w.wang@intel.com>
 <20170413184040-mutt-send-email-mst@kernel.org> <58F08A60.2020407@intel.com>
 <20170415000934-mutt-send-email-mst@kernel.org> <58F43801.7060004@intel.com>
 <286AC319A985734F985F78AFA26841F7391F6DCD@shsmsx102.ccr.corp.intel.com>
 <20170426192753-mutt-send-email-mst@kernel.org> <59019055.3040708@intel.com>
 <20170506012322-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170506012322-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>

On 05/06/2017 06:26 AM, Michael S. Tsirkin wrote:
> On Thu, Apr 27, 2017 at 02:31:49PM +0800, Wei Wang wrote:
> > On 04/27/2017 07:20 AM, Michael S. Tsirkin wrote:
> > > On Wed, Apr 26, 2017 at 11:03:34AM +0000, Wang, Wei W wrote:
> > > > Hi Michael, could you please give some feedback?
> > > I'm sorry, I'm not sure feedback on what you are requesting.
> > Oh, just some trivial things (e.g. use a field in the header,
> > hdr->chunks to indicate the number of chunks in the payload) that
> > wasn't confirmed.
> >
> > I will prepare the new version with fixing the agreed issues, and we
> > can continue to discuss those parts if you still find them improper.
> >
> >
> > >
> > > The interface looks reasonable now, even though there's a way to
> > > make it even simpler if we can limit chunk size to 2G (in fact 4G -
> > > 1). Do you think we can live with this limitation?
> > Yes, I think we can. So, is it good to change to use the previous
> > 64-bit chunk format (52-bit base + 12-bit size)?
>=20
> This isn't what I meant. virtio ring has descriptors with a 64 bit addres=
s and 32 bit
> size.
>=20
> If size < 4g is not a significant limitation, why not just use that to pa=
ss
> address/size in a standard s/g list, possibly using INDIRECT?

OK, I see your point, thanks. Post the two options here for an analysis:
Option1 (what we have now):
struct virtio_balloon_page_chunk {
        __le64 chunk_num;
        struct virtio_balloon_page_chunk_entry entry[];
};
Option2:
struct virtio_balloon_page_chunk {
        __le64 chunk_num;
        struct scatterlist entry[];
};

I don't have an issue to change it to Option2, but I would prefer Option1,
because I think there is no be obvious difference between the two options,
while Option1 appears to have little advantages here:
1) "struct virtio_balloon_page_chunk_entry" has smaller size than
"struct scatterlist", so the same size of allocated page chunk buffer
can hold more entry[] using Option1;
2) INDIRECT needs on demand kmalloc();
3) no 4G size limit;

What do you think?

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
