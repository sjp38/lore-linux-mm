Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 588936B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 18:36:22 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id rr13so2416674pbb.8
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 15:36:22 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id et3si3481060pbc.463.2014.04.24.15.36.15
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 15:36:21 -0700 (PDT)
Message-ID: <535991C3.9080808@intel.com>
Date: Thu, 24 Apr 2014 15:35:47 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Throttle shrinkers harder
References: <1397113506-9177-1-git-send-email-chris@chris-wilson.co.uk> <20140418121416.c022eca055da1b6d81b2cf1b@linux-foundation.org> <20140422193041.GD10722@phenom.ffwll.local> <53582D3C.1010509@intel.com> <20140424055836.GB31221@nuc-i3427.alporthouse.com> <53592C16.8000906@intel.com> <20140424153920.GM31221@nuc-i3427.alporthouse.com>
In-Reply-To: <20140424153920.GM31221@nuc-i3427.alporthouse.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On 04/24/2014 08:39 AM, Chris Wilson wrote:
> On Thu, Apr 24, 2014 at 08:21:58AM -0700, Dave Hansen wrote:
>> Is it possible that there's still a get_page() reference that's holding
>> those pages in place from the graphics code?
> 
> Not from i915.ko. The last resort of our shrinker is to drop all page
> refs held by the GPU, which is invoked if we are asked to free memory
> and we have no inactive objects left.

How sure are we that this was performed before the OOM?

Also, forgive me for being an idiot wrt the way graphics work, but are
there any good candidates that you can think of that could be holding a
reference?  I've honestly never seen an OOM like this.

Somewhat rhetorical question for the mm folks on cc: should we be
sticking the pages on which you're holding a reference on our
unreclaimable list?

> If we could get a callback for the oom report, I could dump some details
> about what the GPU is holding onto. That seems like a useful extension to
> add to the shrinkers.

There's a register_oom_notifier().  Is that sufficient for your use, or
is there something additional that would help?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
