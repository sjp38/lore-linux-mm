Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18C1F6B02C3
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 14:26:24 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a199so31862064qkb.9
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 11:26:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i20si755795qtf.145.2017.06.20.11.26.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 11:26:23 -0700 (PDT)
Date: Tue, 20 Jun 2017 21:26:15 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
Message-ID: <20170620212107-mutt-send-email-mst@kernel.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
 <1497977049.20270.100.camel@redhat.com>
 <7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com>
 <1497979740.20270.102.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497979740.20270.102.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, Nitesh Narayan Lal <nilal@redhat.com>

On Tue, Jun 20, 2017 at 01:29:00PM -0400, Rik van Riel wrote:
> On Tue, 2017-06-20 at 18:49 +0200, David Hildenbrand wrote:
> > On 20.06.2017 18:44, Rik van Riel wrote:
> 
> > > Nitesh Lal (on the CC list) is working on a way
> > > to efficiently batch recently freed pages for
> > > free page hinting to the hypervisor.
> > > 
> > > If that is done efficiently enough (eg. with
> > > MADV_FREE on the hypervisor side for lazy freeing,
> > > and lazy later re-use of the pages), do we still
> > > need the harder to use batch interface from this
> > > patch?
> > > 
> > 
> > David's opinion incoming:
> > 
> > No, I think proper free page hinting would be the optimum solution,
> > if
> > done right. This would avoid the batch interface and even turn
> > virtio-balloon in some sense useless.
> 
> I agree with that.  Let me go into some more detail of
> what Nitesh is implementing:
> 
> 1) In arch_free_page, the being-freed page is added
>    to a per-cpu set of freed pages.
> 2) Once that set is full, arch_free_pages goes into a
>    slow path, which:
>    2a) Iterates over the set of freed pages, and
>    2b) Checks whether they are still free, and
>    2c) Adds the still free pages to a list that is
>        to be passed to the hypervisor, to be MADV_FREEd.
>    2d) Makes that hypercall.
> 
> Meanwhile all arch_alloc_pages has to do is make sure it
> does not allocate a page while it is currently being
> MADV_FREEd on the hypervisor side.
> 
> The code Wei is working on looks like it could be 
> suitable for steps (2c) and (2d) above. Nitesh already
> has code for steps 1 through 2b.
> 
> -- 
> All rights reversed


So my question is this: Wei posted these numbers for balloon
inflation times:
inflating 7GB of an 8GB idle guest:

	1) allocating pages (6.5%)
	2) sending PFNs to host (68.3%)
	3) address translation (6.1%)
	4) madvise (19%)

	It takes about 4126ms for the inflating process to complete.

It seems that this is an excessive amount of time to stay
under a lock. What are your estimates for Nitesh's work?

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
