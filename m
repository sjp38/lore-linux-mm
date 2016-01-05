Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5326B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 05:05:31 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id f206so16693449wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 02:05:31 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id u131si4225753wmb.69.2016.01.05.02.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 02:05:29 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id f206so16692908wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 02:05:29 -0800 (PST)
Date: Tue, 5 Jan 2016 11:05:27 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Intel-gfx] [PATCH v2 1/2] mm: Export nr_swap_pages
Message-ID: <20160105100527.GO8076@phenom.ffwll.local>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <20151204160952.GA24927@cmpxchg.org>
 <20151210093242.GH20822@phenom.ffwll.local>
 <20151223220427.GA11412@cmpxchg.org>
 <20151223142611.63907890.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151223142611.63907890.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Daniel Vetter <daniel@ffwll.ch>, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>

On Wed, Dec 23, 2015 at 02:26:11PM -0800, Andrew Morton wrote:
> On Wed, 23 Dec 2015 17:04:27 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Thu, Dec 10, 2015 at 10:32:42AM +0100, Daniel Vetter wrote:
> > > On Fri, Dec 04, 2015 at 11:09:52AM -0500, Johannes Weiner wrote:
> > > > On Fri, Dec 04, 2015 at 03:58:53PM +0000, Chris Wilson wrote:
> > > > > Some modules, like i915.ko, use swappable objects and may try to swap
> > > > > them out under memory pressure (via the shrinker). Before doing so, they
> > > > > want to check using get_nr_swap_pages() to see if any swap space is
> > > > > available as otherwise they will waste time purging the object from the
> > > > > device without recovering any memory for the system. This requires the
> > > > > nr_swap_pages counter to be exported to the modules.
> > > > > 
> > > > > Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> > > > > Cc: "Goel, Akash" <akash.goel@intel.com>
> > > > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > > > Cc: linux-mm@kvack.org
> > > > 
> > > > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > > 
> > > Ack for merging this through drm-intel trees for 4.5? I'm a bit unclear
> > > who's ack I need for that for linux-mm topics ...
> > 
> > Andrew would be the -mm maintainer. CC'd.
> 
> yup, please go ahead and merge that via the DRM tree.
> 
> nr_swap_pages is a crappy name.  That means "number of pages in swap",
> which isn't the case.  Something like "swap_pages_available" would be
> better.
> 
> And your swap_available() isn't good either ;) It can mean "is any swap
> online" or "what is the amount of free swap space (in unknown units!)".
> I'd call it "swap_is_full()" and put a ! in the caller.  But it's
> hardly important for a wee little static helper.

Yeah it's not super-pretty, but then the entire core mm/shrinker
abstraction is more than just a bit leaky (at least i915 has plenty of
code to make sure we don't bite our own tail). In case of doubt I prefer
the simplest export and avoid the mistake of fake abstraction in the form
of an inline helper with a pretty name.

Merged to drm-intel.git as-is, but missed the 4.5 train so will only land
in 4.6.

Thanks, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
