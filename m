Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 395C128092A
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 10:58:44 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id f191so162776394qka.7
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 07:58:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 127si8368250qkd.115.2017.03.10.07.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 07:58:43 -0800 (PST)
Date: Fri, 10 Mar 2017 17:58:28 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 kernel 3/5] virtio-balloon: implementation of
 VIRTIO_BALLOON_F_CHUNK_TRANSFER
Message-ID: <20170310175349-mutt-send-email-mst@kernel.org>
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
 <1488519630-89058-4-git-send-email-wei.w.wang@intel.com>
 <20170309141411.GZ16328@bombadil.infradead.org>
 <58C28FF8.5040403@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58C28FF8.5040403@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, Liang Li <liang.z.li@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

On Fri, Mar 10, 2017 at 07:37:28PM +0800, Wei Wang wrote:
> On 03/09/2017 10:14 PM, Matthew Wilcox wrote:
> > On Fri, Mar 03, 2017 at 01:40:28PM +0800, Wei Wang wrote:
> > > From: Liang Li <liang.z.li@intel.com>
> > > 1) allocating pages (6.5%)
> > > 2) sending PFNs to host (68.3%)
> > > 3) address translation (6.1%)
> > > 4) madvise (19%)
> > > 
> > > This patch optimizes step 2) by transfering pages to the host in
> > > chunks. A chunk consists of guest physically continuous pages, and
> > > it is offered to the host via a base PFN (i.e. the start PFN of
> > > those physically continuous pages) and the size (i.e. the total
> > > number of the pages). A normal chunk is formated as below:
> > > -----------------------------------------------
> > > |  Base (52 bit)               | Size (12 bit)|
> > > -----------------------------------------------
> > > For large size chunks, an extended chunk format is used:
> > > -----------------------------------------------
> > > |                 Base (64 bit)               |
> > > -----------------------------------------------
> > > -----------------------------------------------
> > > |                 Size (64 bit)               |
> > > -----------------------------------------------
> > What's the advantage to extended chunks?  IOW, why is the added complexity
> > of having two chunk formats worth it?  You already reduced the overhead by
> > a factor of 4096 with normal chunks ... how often are extended chunks used
> > and how much more efficient are they than having several normal chunks?
> > 
> 
> Right, chunk_ext may be rarely used, thanks. I will remove chunk_ext if
> there is no objection from others.
> 
> Best,
> Wei

I don't think we can drop this, this isn't an optimization.


One of the issues of current balloon is the 4k page size
assumption. For example if you free a huge page you
have to split it up and pass 4k chunks to host.
Quite often host can't free these 4k chunks at all (e.g.
when it's using huge tlb fs).
It's even sillier for architectures with base page size >4k.

So as long as we are changing things, let's not hard-code
the 12 shift thing everywhere.


Two things to consider:
- host should pass its base page size to guest
  this can be a separate patch and for now we can fall back on 12 bit if not there

- guest should pass full huge pages to host
  this should be done correctly to avoid breaking up huge pages
  I would say yes let's use a single format but drop the "normal chunk"
  and always use the extended one.
  Also, size is in units of 4k, right? Please document that low 12 bit
  are reserved, they will be handy as e.g. flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
