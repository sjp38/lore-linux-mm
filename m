Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0936B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 15:55:24 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id w104so24544342qge.1
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 12:55:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w127si355181qhw.1.2016.03.15.12.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 12:55:23 -0700 (PDT)
Date: Tue, 15 Mar 2016 19:55:16 +0000
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [RFC qemu 0/4] A PV solution for live migration optimization
Message-ID: <20160315195515.GL11728@work-vm>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160308111343.GM15443@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A7E3@shsmsx102.ccr.corp.intel.com>
 <20160310075728.GB4678@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A860@shsmsx102.ccr.corp.intel.com>
 <20160310111844.GB2276@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0414B118@shsmsx102.ccr.corp.intel.com>
 <20160314170334.GK2234@work-vm>
 <20160315121613-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E0414E385@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E0414E385@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Amit Shah <amit.shah@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mohan_parthasarathy@hpe.com" <mohan_parthasarathy@hpe.com>, "jitendra.kolhe@hpe.com" <jitendra.kolhe@hpe.com>, "simhan@hpe.com" <simhan@hpe.com>

* Li, Liang Z (liang.z.li@intel.com) wrote:
> > On Mon, Mar 14, 2016 at 05:03:34PM +0000, Dr. David Alan Gilbert wrote:
> > > * Li, Liang Z (liang.z.li@intel.com) wrote:
> > > > >
> > > > > Hi,
> > > > >   I'm just catching back up on this thread; so without reference
> > > > > to any particular previous mail in the thread.
> > > > >
> > > > >   1) How many of the free pages do we tell the host about?
> > > > >      Your main change is telling the host about all the
> > > > >      free pages.
> > > >
> > > > Yes, all the guest's free pages.
> > > >
> > > > >      If we tell the host about all the free pages, then we might
> > > > >      end up needing to allocate more pages and update the host
> > > > >      with pages we now want to use; that would have to wait for the
> > > > >      host to acknowledge that use of these pages, since if we don't
> > > > >      wait for it then it might have skipped migrating a page we
> > > > >      just started using (I don't understand how your series solves that).
> > > > >      So the guest probably needs to keep some free pages - how many?
> > > >
> > > > Actually, there is no need to care about whether the free pages will be
> > used by the host.
> > > > We only care about some of the free pages we get reused by the guest,
> > right?
> > > >
> > > > The dirty page logging can be used to solve this, starting the dirty
> > > > page logging before getting the free pages informant from guest.
> > > > Even some of the free pages are modified by the guest during the
> > > > process of getting the free pages information, these modified pages will
> > be traced by the dirty page logging mechanism. So in the following
> > migration_bitmap_sync() function.
> > > > The pages in the free pages bitmap, but latter was modified, will be
> > > > reset to dirty. We won't omit any dirtied pages.
> > > >
> > > > So, guest doesn't need to keep any free pages.
> > >
> > > OK, yes, that works; so we do:
> > >   * enable dirty logging
> > >   * ask guest for free pages
> > >   * initialise the migration bitmap as everything-free
> > >   * then later we do the normal sync-dirty bitmap stuff and it all just works.
> > >
> > > That's nice and simple.
> > 
> > This works once, sure. But there's an issue is that you have to defer migration
> > until you get the free page list, and this only works once. So you end up with
> > heuristics about how long to wait.
> > 
> > Instead I propose:
> > 
> > - mark all pages dirty as we do now.
> > 
> > - at start of migration, start tracking dirty
> >   pages in kvm, and tell guest to start tracking free pages
> > 
> > we can now introduce any kind of delay, for example wait for ack from guest,
> > or do whatever else, or even just start migrating pages
> > 
> > - repeatedly:
> > 	- get list of free pages from guest
> > 	- clear them in migration bitmap
> > 	- get dirty list from kvm
> > 
> > - at end of migration, stop tracking writes in kvm,
> >   and tell guest to stop tracking free pages
> 
> I had thought of filtering out the free pages in each migration bitmap synchronization. 
> The advantage is we can skip process as many free pages as possible. Not just once.
> The disadvantage is that we should change the current memory management code to track the free pages,
> instead of traversing the free page list to construct the free pages bitmap, to reduce the overhead to get the free pages bitmap.
> I am not sure the if the Kernel people would like it.
> 
> If keeping the traversing mechanism, because of the overhead, maybe it's not worth to filter out the free pages repeatedly.

Well, Michael's idea of not waiting for the dirty
bitmap to be filled does make that idea of constnatly
using the free-bitmap better.

In that case, is it easier if something (guest/host?)
allocates some memory in the guests physical RAM space
and just points the host to it, rather than having an 
explicit 'send'.

Dave

> Liang
> 
> 
> 
> 
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
