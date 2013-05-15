Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 9508A6B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 11:26:40 -0400 (EDT)
Message-ID: <5193A95E.70205@parallels.com>
Date: Wed, 15 May 2013 19:27:26 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 12/31] fs: convert inode and dentry shrinking to be
 node aware
References: <1368382432-25462-1-git-send-email-glommer@openvz.org> <1368382432-25462-13-git-send-email-glommer@openvz.org> <20130514095200.GI29466@dastard>
In-Reply-To: <20130514095200.GI29466@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On 05/14/2013 01:52 PM, Dave Chinner wrote:
> kswapd0-632 1210443.469309: mm_shrink_slab_start: cache items 600456 delta 1363 total_scan 300228
> kswapd3-635 1210443.510311: mm_shrink_slab_start: cache items 514885 delta 1250 total_scan 101025
> kswapd1-633 1210443.517440: mm_shrink_slab_start: cache items 613824 delta 1357 total_scan 97727
> kswapd2-634 1210443.527026: mm_shrink_slab_start: cache items 568610 delta 1331 total_scan 259185
> kswapd3-635 1210443.573165: mm_shrink_slab_start: cache items 486408 delta 1277 total_scan 243204
> kswapd1-633 1210443.697012: mm_shrink_slab_start: cache items 550827 delta 1224 total_scan 82231
> 
> in the space of 230ms, I can see why the caches are getting
> completely emptied. kswapds are making multiple, large scale scan
> passes on the caches. Looks like our problem is an impedence
> mismatch: global windup counter, per-node cache scan calculations.
> 
> So, that's the mess we really need to cleaning up before going much
> further with this patchset. We need stable behaviour from the
> shrinkers - I'll look into this a bit deeper tomorrow.

That doesn't totally make sense to me.

Both our scan and count functions will be per-node now. This means we
will always try to keep ourselves within reasonable maximums on a
per-node basis as well.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
