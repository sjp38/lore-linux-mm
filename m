Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C346C6B03D3
	for <linux-mm@kvack.org>; Mon,  8 May 2017 13:40:41 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c75so33838243qka.7
        for <linux-mm@kvack.org>; Mon, 08 May 2017 10:40:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 13si12902970qkf.88.2017.05.08.10.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 May 2017 10:40:40 -0700 (PDT)
Date: Mon, 8 May 2017 20:40:33 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [virtio-dev] Re: [PATCH v9 2/5] virtio-balloon:
 VIRTIO_BALLOON_F_BALLOON_CHUNKS
Message-ID: <20170508203533-mutt-send-email-mst@kernel.org>
References: <1492076108-117229-3-git-send-email-wei.w.wang@intel.com>
 <20170413184040-mutt-send-email-mst@kernel.org>
 <58F08A60.2020407@intel.com>
 <20170415000934-mutt-send-email-mst@kernel.org>
 <58F43801.7060004@intel.com>
 <286AC319A985734F985F78AFA26841F7391F6DCD@shsmsx102.ccr.corp.intel.com>
 <20170426192753-mutt-send-email-mst@kernel.org>
 <59019055.3040708@intel.com>
 <20170506012322-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7391FFBB0@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F7391FFBB0@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>

On Sun, May 07, 2017 at 04:19:28AM +0000, Wang, Wei W wrote:
> On 05/06/2017 06:26 AM, Michael S. Tsirkin wrote:
> > On Thu, Apr 27, 2017 at 02:31:49PM +0800, Wei Wang wrote:
> > > On 04/27/2017 07:20 AM, Michael S. Tsirkin wrote:
> > > > On Wed, Apr 26, 2017 at 11:03:34AM +0000, Wang, Wei W wrote:
> > > > > Hi Michael, could you please give some feedback?
> > > > I'm sorry, I'm not sure feedback on what you are requesting.
> > > Oh, just some trivial things (e.g. use a field in the header,
> > > hdr->chunks to indicate the number of chunks in the payload) that
> > > wasn't confirmed.
> > >
> > > I will prepare the new version with fixing the agreed issues, and we
> > > can continue to discuss those parts if you still find them improper.
> > >
> > >
> > > >
> > > > The interface looks reasonable now, even though there's a way to
> > > > make it even simpler if we can limit chunk size to 2G (in fact 4G -
> > > > 1). Do you think we can live with this limitation?
> > > Yes, I think we can. So, is it good to change to use the previous
> > > 64-bit chunk format (52-bit base + 12-bit size)?
> > 
> > This isn't what I meant. virtio ring has descriptors with a 64 bit address and 32 bit
> > size.
> > 
> > If size < 4g is not a significant limitation, why not just use that to pass
> > address/size in a standard s/g list, possibly using INDIRECT?
> 
> OK, I see your point, thanks. Post the two options here for an analysis:
> Option1 (what we have now):
> struct virtio_balloon_page_chunk {
>         __le64 chunk_num;
>         struct virtio_balloon_page_chunk_entry entry[];
> };
> Option2:
> struct virtio_balloon_page_chunk {
>         __le64 chunk_num;
>         struct scatterlist entry[];
> };

This isn't what I meant really :) I meant vring_desc.

> I don't have an issue to change it to Option2, but I would prefer Option1,
> because I think there is no be obvious difference between the two options,
> while Option1 appears to have little advantages here:
> 1) "struct virtio_balloon_page_chunk_entry" has smaller size than
> "struct scatterlist", so the same size of allocated page chunk buffer
> can hold more entry[] using Option1;
> 2) INDIRECT needs on demand kmalloc();

Within alloc_indirect?  We can fix that with a separate patch.


> 3) no 4G size limit;

Do you see lots of >=4g chunks in practice?

> What do you think?
> 
> Best,
> Wei
> 
>

OTOH using existing vring APIs handles things like DMA transparently.


-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
