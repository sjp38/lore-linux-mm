Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 369346B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 05:19:57 -0400 (EDT)
Date: Wed, 10 Apr 2013 19:19:51 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Message-ID: <20130410091951.GA10459@dastard>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
 <1364548450-28254-3-git-send-email-glommer@parallels.com>
 <515936B5.8070501@jp.fujitsu.com>
 <515940E4.8050704@parallels.com>
 <5164F416.8040903@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5164F416.8040903@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Apr 10, 2013 at 01:09:42PM +0800, Ric Mason wrote:
> Hi Glauber,
> On 04/01/2013 04:10 PM, Glauber Costa wrote:
> > Hi Kame,
> >
> >> Doesn't this break
> >>
> >> ==
> >>                 /*
> >>                  * copy the current shrinker scan count into a local variable
> >>                  * and zero it so that other concurrent shrinker invocations
> >>                  * don't also do this scanning work.
> >>                  */
> >>                 nr = atomic_long_xchg(&shrinker->nr_in_batch, 0);
> >> ==
> >>
> >> This xchg magic ?
> >>
> >> Thnks,
> >> -Kame
> > This is done before the actual reclaim attempt, and all it does is to
> > indicate to other concurrent shrinkers that "I've got it", and others
> > should not attempt to shrink.
> >
> > Even before I touch this, this quantity represents the number of
> > entities we will try to shrink. Not necessarily we will succeed. What my
> > patch does, is to try at least once if the number is too small.
> >
> > Before it, we will try to shrink 512 objects and succeed at 0 (because
> > batch is 1024). After this, we will try to free 512 objects and succeed
> > at an undefined quantity between 0 and 512.
> 
> Where you get the magic number 512 and 1024? The value of SHRINK_BATCH
> is 128.

The default is SHRINK_BATCH, but batch size has been customisable
for some time now...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
