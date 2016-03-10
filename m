Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id B6FF66B0253
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 06:18:53 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id w104so67124330qge.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 03:18:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n14si3193691qkl.12.2016.03.10.03.18.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 03:18:52 -0800 (PST)
Date: Thu, 10 Mar 2016 11:18:45 +0000
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [RFC qemu 0/4] A PV solution for live migration optimization
Message-ID: <20160310111844.GB2276@work-vm>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160308111343.GM15443@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A7E3@shsmsx102.ccr.corp.intel.com>
 <20160310075728.GB4678@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A860@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E0414A860@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: Amit Shah <amit.shah@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, mohan_parthasarathy@hpe.com, jitendra.kolhe@hpe.com, simhan@hpe.com

Hi,
  I'm just catching back up on this thread; so without reference to any
particular previous mail in the thread.

  1) How many of the free pages do we tell the host about?
     Your main change is telling the host about all the
     free pages.
     If we tell the host about all the free pages, then we might
     end up needing to allocate more pages and update the host
     with pages we now want to use; that would have to wait for the
     host to acknowledge that use of these pages, since if we don't
     wait for it then it might have skipped migrating a page we
     just started using (I don't understand how your series solves that).
     So the guest probably needs to keep some free pages - how many?

  2) Clearing out caches
     Does it make sense to clean caches?  They're apparently useful data
     so if we clean them it's likely to slow the guest down; I guess
     they're also likely to be fairly static data - so at least fairly
     easy to migrate.
     The answer here partially depends on what you want from your migration;
     if you're after the fastest possible migration time it might make
     sense to clean the caches and avoid migrating them; but that might
     be at the cost of more disruption to the guest - there's a trade off
     somewhere and it's not clear to me how you set that depending on your
     guest/network/reqirements.

  3) Why is ballooning slow?
     You've got a figure of 5s to balloon on an 8GB VM - but an 
     8GB VM isn't huge; so I worry about how long it would take
     on a big VM.   We need to understand why it's slow 
       * is it due to the guest shuffling pages around? 
       * is it due to the virtio-balloon protocol sending one page
         at a time?
         + Do balloon pages normally clump in physical memory
            - i.e. would a 'large balloon' message help
            - or do we need a bitmap because it tends not to clump?

       * is it due to the madvise on the host?
         If we were using the normal balloon messages, then we
         could, during migration, just route those to the migration
         code rather than bothering with the madvise.
         If they're clumping together we could just turn that into
         one big madvise; if they're not then would we benefit from
         a call that lets us madvise lots of areas?

  4) Speeding up the migration of those free pages
    You're using the bitmap to avoid migrating those free pages; HPe's
    patchset is reconstructing a bitmap from the balloon data;  OK, so
    this all makes sense to avoid migrating them - I'd also been thinking
    of using pagemap to spot zero pages that would help find other zero'd
    pages, but perhaps ballooned is enough?

  5) Second-migrate
    Given a VM where you've done all those tricks on, what happens when
    you migrate it a second time?   I guess you're aiming for the guest
    to update it's bitmap;  HPe's solution is to migrate it's balloon
    bitmap along with the migration data.
     
Dave

--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
