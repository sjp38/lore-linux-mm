Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id EAD176B0256
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 17:26:23 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id e65so6007821pfe.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 14:26:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bm5si12737045pad.107.2015.12.23.14.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 14:26:23 -0800 (PST)
Date: Wed, 23 Dec 2015 14:26:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Intel-gfx] [PATCH v2 1/2] mm: Export nr_swap_pages
Message-Id: <20151223142611.63907890.akpm@linux-foundation.org>
In-Reply-To: <20151223220427.GA11412@cmpxchg.org>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
	<20151204160952.GA24927@cmpxchg.org>
	<20151210093242.GH20822@phenom.ffwll.local>
	<20151223220427.GA11412@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Daniel Vetter <daniel@ffwll.ch>, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>

On Wed, 23 Dec 2015 17:04:27 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Dec 10, 2015 at 10:32:42AM +0100, Daniel Vetter wrote:
> > On Fri, Dec 04, 2015 at 11:09:52AM -0500, Johannes Weiner wrote:
> > > On Fri, Dec 04, 2015 at 03:58:53PM +0000, Chris Wilson wrote:
> > > > Some modules, like i915.ko, use swappable objects and may try to swap
> > > > them out under memory pressure (via the shrinker). Before doing so, they
> > > > want to check using get_nr_swap_pages() to see if any swap space is
> > > > available as otherwise they will waste time purging the object from the
> > > > device without recovering any memory for the system. This requires the
> > > > nr_swap_pages counter to be exported to the modules.
> > > > 
> > > > Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> > > > Cc: "Goel, Akash" <akash.goel@intel.com>
> > > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > > Cc: linux-mm@kvack.org
> > > 
> > > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > Ack for merging this through drm-intel trees for 4.5? I'm a bit unclear
> > who's ack I need for that for linux-mm topics ...
> 
> Andrew would be the -mm maintainer. CC'd.

yup, please go ahead and merge that via the DRM tree.

nr_swap_pages is a crappy name.  That means "number of pages in swap",
which isn't the case.  Something like "swap_pages_available" would be
better.

And your swap_available() isn't good either ;) It can mean "is any swap
online" or "what is the amount of free swap space (in unknown units!)".
I'd call it "swap_is_full()" and put a ! in the caller.  But it's
hardly important for a wee little static helper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
