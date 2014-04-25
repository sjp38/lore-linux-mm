Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 04D086B0036
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 13:56:42 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kp14so3399017pab.5
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 10:56:42 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hu10si5326987pbc.272.2014.04.25.10.56.41
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 10:56:42 -0700 (PDT)
Message-ID: <535AA1D8.3030703@intel.com>
Date: Fri, 25 Apr 2014 10:56:40 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Throttle shrinkers harder
References: <1397113506-9177-1-git-send-email-chris@chris-wilson.co.uk> <20140418121416.c022eca055da1b6d81b2cf1b@linux-foundation.org> <20140422193041.GD10722@phenom.ffwll.local> <53582D3C.1010509@intel.com> <20140424055836.GB31221@nuc-i3427.alporthouse.com> <53592C16.8000906@intel.com> <20140424153920.GM31221@nuc-i3427.alporthouse.com> <535991C3.9080808@intel.com> <20140425072325.GO31221@nuc-i3427.alporthouse.com> <535A9901.6090607@intel.com>
In-Reply-To: <535A9901.6090607@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

Poking around with those tracepoints, I don't see the i915 shrinker
getting run, only i915_gem_inactive_count() being called.  It must be
returning 0 because we're never even _getting_ to the tracepoints
themselves after calling i915_gem_inactive_count().

This is on my laptop, and I haven't been able to coax i915 in to
reclaiming a single page in 10 or 15 minutes.  That seems fishy to me.
Surely *SOMETHING* has become reclaimable in that time.

Here's /sys/kernel/debug/dri/0/i915_gem_objects:

> 919 objects, 354914304 bytes
> 874 [333] objects, 291004416 [93614080] bytes in gtt
>   0 [0] active objects, 0 [0] bytes
>   874 [333] inactive objects, 291004416 [93614080] bytes
> 0 unbound objects, 0 bytes
> 199 purgeable objects, 92844032 bytes
> 30 pinned mappable objects, 18989056 bytes
> 139 fault mappable objects, 17371136 bytes
> 2145386496 [268435456] gtt total
> 
> Xorg: 632 objects, 235450368 bytes (0 active, 180899840 inactive, 21262336 unbound)
> gnome-control-c: 11 objects, 110592 bytes (0 active, 0 inactive, 49152 unbound)
> chromium-browse: 266 objects, 101367808 bytes (0 active, 101330944 inactive, 0 unbound)
> Xorg: 0 objects, 0 bytes (0 active, 0 inactive, 0 unbound)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
