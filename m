Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7516B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 13:03:42 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id u110so159117257qge.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 10:03:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b19si22317030qge.77.2016.03.14.10.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 10:03:41 -0700 (PDT)
Date: Mon, 14 Mar 2016 17:03:34 +0000
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [RFC qemu 0/4] A PV solution for live migration optimization
Message-ID: <20160314170334.GK2234@work-vm>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160308111343.GM15443@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A7E3@shsmsx102.ccr.corp.intel.com>
 <20160310075728.GB4678@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A860@shsmsx102.ccr.corp.intel.com>
 <20160310111844.GB2276@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0414B118@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E0414B118@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: Amit Shah <amit.shah@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mohan_parthasarathy@hpe.com" <mohan_parthasarathy@hpe.com>, "jitendra.kolhe@hpe.com" <jitendra.kolhe@hpe.com>, "simhan@hpe.com" <simhan@hpe.com>

* Li, Liang Z (liang.z.li@intel.com) wrote:
> > 
> > Hi,
> >   I'm just catching back up on this thread; so without reference to any
> > particular previous mail in the thread.
> > 
> >   1) How many of the free pages do we tell the host about?
> >      Your main change is telling the host about all the
> >      free pages.
> 
> Yes, all the guest's free pages.
> 
> >      If we tell the host about all the free pages, then we might
> >      end up needing to allocate more pages and update the host
> >      with pages we now want to use; that would have to wait for the
> >      host to acknowledge that use of these pages, since if we don't
> >      wait for it then it might have skipped migrating a page we
> >      just started using (I don't understand how your series solves that).
> >      So the guest probably needs to keep some free pages - how many?
> 
> Actually, there is no need to care about whether the free pages will be used by the host.
> We only care about some of the free pages we get reused by the guest, right?
> 
> The dirty page logging can be used to solve this, starting the dirty page logging before getting
> the free pages informant from guest. Even some of the free pages are modified by the guest
> during the process of getting the free pages information, these modified pages will be traced
> by the dirty page logging mechanism. So in the following migration_bitmap_sync() function.
> The pages in the free pages bitmap, but latter was modified, will be reset to dirty. We won't
> omit any dirtied pages.
> 
> So, guest doesn't need to keep any free pages.

OK, yes, that works; so we do:
  * enable dirty logging
  * ask guest for free pages
  * initialise the migration bitmap as everything-free
  * then later we do the normal sync-dirty bitmap stuff and it all just works.

That's nice and simple.

> >   2) Clearing out caches
> >      Does it make sense to clean caches?  They're apparently useful data
> >      so if we clean them it's likely to slow the guest down; I guess
> >      they're also likely to be fairly static data - so at least fairly
> >      easy to migrate.
> >      The answer here partially depends on what you want from your migration;
> >      if you're after the fastest possible migration time it might make
> >      sense to clean the caches and avoid migrating them; but that might
> >      be at the cost of more disruption to the guest - there's a trade off
> >      somewhere and it's not clear to me how you set that depending on your
> >      guest/network/reqirements.
> > 
> 
> Yes, clean the caches is an option.  Let the users decide using it or not.
> 
> >   3) Why is ballooning slow?
> >      You've got a figure of 5s to balloon on an 8GB VM - but an
> >      8GB VM isn't huge; so I worry about how long it would take
> >      on a big VM.   We need to understand why it's slow
> >        * is it due to the guest shuffling pages around?
> >        * is it due to the virtio-balloon protocol sending one page
> >          at a time?
> >          + Do balloon pages normally clump in physical memory
> >             - i.e. would a 'large balloon' message help
> >             - or do we need a bitmap because it tends not to clump?
> > 
> 
> I didn't do a comprehensive test. But I found most of the time spending
> on allocating the pages and sending the PFNs to guest, I don't know that's
> the most time consuming operation, allocating the pages or sending the PFNs.

It might be a good idea to analyse it a bit more to convince people where
the problem is.

> >        * is it due to the madvise on the host?
> >          If we were using the normal balloon messages, then we
> >          could, during migration, just route those to the migration
> >          code rather than bothering with the madvise.
> >          If they're clumping together we could just turn that into
> >          one big madvise; if they're not then would we benefit from
> >          a call that lets us madvise lots of areas?
> > 
> 
> My test showed madvise() is not the main reason for the long time, only taken
> 10% of the total  inflating balloon operation time.
> Big madvise can more or less improve the performance.

OK; 10% of the total is still pretty big even for your 8GB VM.

> >   4) Speeding up the migration of those free pages
> >     You're using the bitmap to avoid migrating those free pages; HPe's
> >     patchset is reconstructing a bitmap from the balloon data;  OK, so
> >     this all makes sense to avoid migrating them - I'd also been thinking
> >     of using pagemap to spot zero pages that would help find other zero'd
> >     pages, but perhaps ballooned is enough?
> > 
> Could you describe your ideal with more details?

At the moment the migration code spends a fair amount of time checking if a page
is zero; I was thinking perhaps the qemu could just open /proc/self/pagemap
and check if the page was mapped; that would seem cheap if we're checking big
ranges; and that would find all the balloon pages.

> >   5) Second-migrate
> >     Given a VM where you've done all those tricks on, what happens when
> >     you migrate it a second time?   I guess you're aiming for the guest
> >     to update it's bitmap;  HPe's solution is to migrate it's balloon
> >     bitmap along with the migration data.
> 
> Nothing is special in the second migration, QEMU will request the guest for free pages
> Information, and the guest will traverse it's current free page list to construct a
> new free page bitmap and send it to QEMU. Just like in the first migration.

Right.

Dave

> Liang
> > 
> > Dave
> > 
> > --
> > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
