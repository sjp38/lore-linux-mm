Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E094C6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 04:23:47 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so898505pad.38
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 01:23:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id yy4si3143436pbc.69.2014.01.15.01.23.45
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 01:23:46 -0800 (PST)
Date: Wed, 15 Jan 2014 01:25:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] mm: vmscan: shrink all slab objects if tight on
 memory
Message-Id: <20140115012541.ad302526.akpm@linux-foundation.org>
In-Reply-To: <52D64B27.30604@parallels.com>
References: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com>
	<20140113150502.4505f661589a4a2d30e6f11d@linux-foundation.org>
	<52D4E5F2.5080205@parallels.com>
	<20140114141453.374bd18e5290876177140085@linux-foundation.org>
	<52D64B27.30604@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

On Wed, 15 Jan 2014 12:47:35 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:

> On 01/15/2014 02:14 AM, Andrew Morton wrote:
> > On Tue, 14 Jan 2014 11:23:30 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
> >
> >> On 01/14/2014 03:05 AM, Andrew Morton wrote:
> >>> That being said, I think I'll schedule this patch as-is for 3.14.  Can
> >>> you please take a look at implementing the simpler approach, send me
> >>> something for 3.15-rc1?
> >> IMHO the simpler approach (Glauber's patch) is not suitable as is,
> >> because it, in fact, neglects the notion of batch_size when doing low
> >> prio scans, because it calls ->scan() for < batch_size objects even if
> >> the slab has >= batch_size objects while AFAIU it should accumulate a
> >> sufficient number of objects to scan in nr_deferred instead.
> > Well.  If you mean that when nr-objects=large and batch_size=32 and
> > total_scan=33, the patched code will scan 32 objects and then 1 object
> > then yes, that should be fixed.
> 
> I mean if nr_objects=large and batch_size=32 and shrink_slab() is called
> 8 times with total_scan=4, we can either call ->scan() 8 times with
> nr_to_scan=4 (Glauber's patch) or call it only once with nr_to_scan=32
> (that's how it works now). Frankly, after a bit of thinking I am
> starting to doubt that this can affect performance at all provided the
> shrinker is implemented in a sane way, because as you've mentioned
> shrink_slab() is already a slow path. It seems I misunderstood the
> purpose of batch_size initially: I though we need it to limit the number
> of calls to ->scan(), but now I guess the only purpose of it is limiting
> the number of objects scanned in one pass to avoid latency issues.

Actually, the intent of batching is to limit the number of calls to
->scan().  At least, that was the intent when I wrote it!  This is a
good principle and we should keep doing it.  If we're going to send the
CPU away to tread on a pile of cold cachelines, we should make sure
that it does a good amount of work while it's there.

> But
> then another question arises - why do you think the behavior you
> described above (scanning 32 and then 1 object if total_scan=33,
> batch_size=32) is bad?

Yes, it's a bit inefficient but it won't be too bad.  What would be bad
would be to scan a very small number of objects and then to advance to
the next shrinker.

> In other words why can't we make the scan loop
> look like this:
> 
>     while (total_scan > 0) {
>         unsigned long ret;
>         unsigned long nr_to_scan = min(total_scan, batch_size);
> 
>         shrinkctl->nr_to_scan = nr_to_scan;
>         ret = shrinker->scan_objects(shrinker, shrinkctl);
>         if (ret == SHRINK_STOP)
>             break;
>         freed += ret;
> 
>         count_vm_events(SLABS_SCANNED, nr_to_scan);
>         total_scan -= nr_to_scan;
> 
>         cond_resched();
>     }


Well, if we come in here with total_scan=1 then we defeat the original
intent of the batching, don't we?  We end up doing a lot of work just
to scan one object.  So perhaps add something like

	if (total_scan < batch_size && max_pass > batch_size)
		skip the while loop

If we do this, total_scan will be accumulated into nr_deferred, up to
the point where the threshold is exceeded, yes?

All the arithmetic in there hurts my brain and I don't know what values
total_scan typically ends up with.

btw. all that trickery with delta and lru_pages desperately needs
documenting.  What the heck is it intended to do??



We could avoid the "scan 32 then scan just 1" issue with something like

	if (total_scan > batch_size)
		total_scan %= batch_size;

before the loop.  But I expect the effects of that will be unmeasurable
- on average the number of objects which are scanned in the final pass
of the loop will be batch_size/2, yes?  That's still a decent amount.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
