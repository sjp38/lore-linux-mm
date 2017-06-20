Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA876B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 14:17:38 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m57so84374409qta.9
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 11:17:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 138si240560qkh.173.2017.06.20.11.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 11:17:37 -0700 (PDT)
Date: Tue, 20 Jun 2017 21:17:26 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
Message-ID: <20170620211445-mutt-send-email-mst@kernel.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
 <1497977049.20270.100.camel@redhat.com>
 <7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, Nitesh Narayan Lal <nilal@redhat.com>

On Tue, Jun 20, 2017 at 06:49:33PM +0200, David Hildenbrand wrote:
> On 20.06.2017 18:44, Rik van Riel wrote:
> > On Mon, 2017-06-12 at 07:10 -0700, Dave Hansen wrote:
> > 
> >> The hypervisor is going to throw away the contents of these pages,
> >> right?  As soon as the spinlock is released, someone can allocate a
> >> page, and put good data in it.  What keeps the hypervisor from
> >> throwing
> >> away good data?
> > 
> > That looks like it may be the wrong API, then?
> > 
> > We already have hooks called arch_free_page and
> > arch_alloc_page in the VM, which are called when
> > pages are freed, and allocated, respectively.
> > 
> > Nitesh Lal (on the CC list) is working on a way
> > to efficiently batch recently freed pages for
> > free page hinting to the hypervisor.
> > 
> > If that is done efficiently enough (eg. with
> > MADV_FREE on the hypervisor side for lazy freeing,
> > and lazy later re-use of the pages), do we still
> > need the harder to use batch interface from this
> > patch?
> > 
> David's opinion incoming:
> 
> No, I think proper free page hinting would be the optimum solution, if
> done right. This would avoid the batch interface and even turn
> virtio-balloon in some sense useless.

I agree generally. But we have to balance that against the fact that
this was discussed since at least 2011 and no one built this solution
yet.

> -- 
> 
> Thanks,
> 
> David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
