Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC69C6B0038
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 22:57:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 30so20057384qtw.19
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 19:57:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c138si613077qke.203.2017.04.13.19.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 19:57:45 -0700 (PDT)
Date: Fri, 14 Apr 2017 05:57:37 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v9 0/5] Extend virtio-balloon for fast (de)inflating &
 fast live migration
Message-ID: <20170414055106-mutt-send-email-mst@kernel.org>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
 <20170413204411.GJ784@bombadil.infradead.org>
 <20170414044515-mutt-send-email-mst@kernel.org>
 <58F033D0.7080101@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58F033D0.7080101@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Fri, Apr 14, 2017 at 10:28:32AM +0800, Wei Wang wrote:
> On 04/14/2017 09:50 AM, Michael S. Tsirkin wrote:
> > On Thu, Apr 13, 2017 at 01:44:11PM -0700, Matthew Wilcox wrote:
> > > On Thu, Apr 13, 2017 at 05:35:03PM +0800, Wei Wang wrote:
> > > > 2) transfer the guest unused pages to the host so that they
> > > > can be skipped to migrate in live migration.
> > > I don't understand this second bit.  You leave the pages on the free list,
> > > and tell the host they're free.  What's preventing somebody else from
> > > allocating them and using them for something?  Is the guest semi-frozen
> > > at this point with just enough of it running to ask the balloon driver
> > > to do things?
> > There's missing documentation here.
> > 
> > The way things actually work is host sends to guest
> > a request for unused pages and then write-protects all memory.
> > 
> > So guest isn't frozen but any changes will be detected by host.
> > 
> 
> Probably it's better to say " transfer the info about the guest unused pages
> to the host so that the host gets a chance to skip the transfer of the
> unused
> pages during live migration".
> 
> Best,
> Wei

IMHO this would not be helpful.
Most people don't know how does migration work, even if they did
this isn't tied to migration in any way.
It just makes people go "oh it's some virtualization mumbo jumbo".
We want people to be able to review and for that
interfaces need to be separate from the implementation.

IOW we must document what the interface promises not how it's used.


The promise is that pages have been unused at some time between when
host sent command and when guest completed it.  Host uses that by
tracking memory changes and then discarding changes made to pages
it gets from guest before it sent the command.

Say that and drop all mention of transfer, migration etc.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
