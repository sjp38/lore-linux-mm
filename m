Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1B60C6B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 12:32:14 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id k14so7618426wgh.15
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 09:32:13 -0700 (PDT)
Received: from mail.8bytes.org (8bytes.org. [2a01:238:4242:f000:64f:6c43:3523:e535])
        by mx.google.com with ESMTP id p6si8734221wic.67.2014.07.09.09.32.12
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 09:32:13 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id BFB3E12B20A
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 18:32:11 +0200 (CEST)
Date: Wed, 9 Jul 2014 18:32:08 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 3/8] mmu_notifier: add event information to address
 invalidation v3
Message-ID: <20140709163208.GP1958@8bytes.org>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
 <1404856801-11702-4-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1404856801-11702-4-git-send-email-j.glisse@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com
Cc: akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 08, 2014 at 06:00:00PM -0400, j.glisse@gmail.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> The event information will be usefull for new user of mmu_notifier API.
> The event argument differentiate between a vma disappearing, a page
> being write protected or simply a page being unmaped. This allow new
> user to take different path for different event for instance on unmap
> the resource used to track a vma are still valid and should stay around.
> While if the event is saying that a vma is being destroy it means that any
> resources used to track this vma can be free.
> 
> Changed since v1:
>   - renamed action into event (updated commit message too).
>   - simplified the event names and clarified their intented usage
>     also documenting what exceptation the listener can have in
>     respect to each event.
> 
> Changed since v2:
>   - Avoid crazy name.
>   - Do not move code that do not need to move.

Okay, I can actually see use-cases for something like this. Given the
number of invalidate_range_start/end call-sites and the semantics of
these call-backs it would allow certain optimizations to know details of
whats going on between these calls.

But why do you need this event information for all the other
mmu_notifier call-backs? In change_pte for example you already get the
address and the new pte value, isn't that enough to find out whats going
on?


	Joerg


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
