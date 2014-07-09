Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCBC6B0035
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 13:15:51 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id im17so7485982vcb.39
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 10:15:51 -0700 (PDT)
Received: from mail-vc0-x22d.google.com (mail-vc0-x22d.google.com [2607:f8b0:400c:c03::22d])
        by mx.google.com with ESMTPS id ne10si21872974veb.55.2014.07.09.10.15.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 10:15:50 -0700 (PDT)
Received: by mail-vc0-f173.google.com with SMTP id lf12so7565705vcb.32
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 10:15:49 -0700 (PDT)
Date: Wed, 9 Jul 2014 13:16:04 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 3/8] mmu_notifier: add event information to address
 invalidation v3
Message-ID: <20140709171603.GB4249@gmail.com>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
 <1404856801-11702-4-git-send-email-j.glisse@gmail.com>
 <20140709163208.GP1958@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140709163208.GP1958@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 09, 2014 at 06:32:08PM +0200, Joerg Roedel wrote:
> On Tue, Jul 08, 2014 at 06:00:00PM -0400, j.glisse@gmail.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > The event information will be usefull for new user of mmu_notifier API.
> > The event argument differentiate between a vma disappearing, a page
> > being write protected or simply a page being unmaped. This allow new
> > user to take different path for different event for instance on unmap
> > the resource used to track a vma are still valid and should stay around.
> > While if the event is saying that a vma is being destroy it means that any
> > resources used to track this vma can be free.
> > 
> > Changed since v1:
> >   - renamed action into event (updated commit message too).
> >   - simplified the event names and clarified their intented usage
> >     also documenting what exceptation the listener can have in
> >     respect to each event.
> > 
> > Changed since v2:
> >   - Avoid crazy name.
> >   - Do not move code that do not need to move.
> 
> Okay, I can actually see use-cases for something like this. Given the
> number of invalidate_range_start/end call-sites and the semantics of
> these call-backs it would allow certain optimizations to know details of
> whats going on between these calls.
> 
> But why do you need this event information for all the other
> mmu_notifier call-backs? In change_pte for example you already get the
> address and the new pte value, isn't that enough to find out whats going
> on?
> 

For hmm no, because hmm do not know the old pte value. Thus have no idea.
But right as i am not going to further use change_pte i do not mind much
about it so i can drop it for change_pte. But other user might still find
that useful as it avoids them to lookup the old pte and do a comparison.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
