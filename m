Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 564B86B000A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 20:41:02 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 17-v6so3292445pgs.18
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 17:41:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d186-v6si3305988pfg.23.2018.10.03.17.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Oct 2018 17:41:00 -0700 (PDT)
Date: Wed, 3 Oct 2018 17:39:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: Introduce new function vm_insert_kmem_page
Message-ID: <20181004003956.GA31522@bombadil.infradead.org>
References: <20181003185854.GA1174@jordon-HP-15-Notebook-PC>
 <20181003200003.GA9965@bombadil.infradead.org>
 <20181003221444.GZ30658@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181003221444.GZ30658@n2100.armlinux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, miguel.ojeda.sandonis@gmail.com, robin@protonic.nl, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, m.szyprowski@samsung.com, keescook@chromium.org, treding@nvidia.com, mhocko@suse.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, mark.rutland@arm.com, aryabinin@virtuozzo.com, dvyukov@google.com, kstewart@linuxfoundation.org, tchibo@google.com, riel@redhat.com, minchan@kernel.org, peterz@infradead.org, ying.huang@intel.com, ak@linux.intel.com, rppt@linux.vnet.ibm.com, linux@dominikbrodowski.net, arnd@arndb.de, cpandya@codeaurora.org, hannes@cmpxchg.org, joe@perches.com, mcgrof@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, linux-mm@kvack.org

On Wed, Oct 03, 2018 at 11:14:45PM +0100, Russell King - ARM Linux wrote:
> On Wed, Oct 03, 2018 at 01:00:03PM -0700, Matthew Wilcox wrote:
> > On Thu, Oct 04, 2018 at 12:28:54AM +0530, Souptick Joarder wrote:
> > > These are the approaches which could have been taken to handle
> > > this scenario -
> > > 
> > > *  Replace vm_insert_page with vmf_insert_page and then write few
> > >    extra lines of code to convert VM_FAULT_CODE to errno which
> > >    makes driver users more complex ( also the reverse mapping errno to
> > >    VM_FAULT_CODE have been cleaned up as part of vm_fault_t migration ,
> > >    not preferred to introduce anything similar again)
> > > 
> > > *  Maintain both vm_insert_page and vmf_insert_page and use it in
> > >    respective places. But it won't gurantee that vm_insert_page will
> > >    never be used in #PF context.
> > > 
> > > *  Introduce a similar API like vm_insert_page, convert all non #PF
> > >    consumer to use it and finally remove vm_insert_page by converting
> > >    it to vmf_insert_page.
> > > 
> > > And the 3rd approach was taken by introducing vm_insert_kmem_page().
> > > 
> > > In short, vmf_insert_page will be used in page fault handlers
> > > context and vm_insert_kmem_page will be used to map kernel
> > > memory to user vma outside page fault handlers context.
> > 
> > As far as I can tell, vm_insert_kmem_page() is line-for-line identical
> > with vm_insert_page().  Seriously, here's a diff I just did:
[...]
> > What on earth are you trying to do?
> 
> Reading the commit log, it seems that the intention is to split out
> vm_insert_page() used outside of page-fault handling with the use
> within page-fault handling, so that different return codes can be
> used.

Right, but we already did that.  We now have vmf_insert_page() which
returns a VM_FAULT_* code and vm_insert_page() which returns an errno.
