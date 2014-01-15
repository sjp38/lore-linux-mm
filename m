Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1DDAD6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 10:55:33 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id u14so926270lbd.15
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 07:55:32 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ps5si2672686lbb.155.2014.01.15.07.55.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 07:55:29 -0800 (PST)
Message-ID: <52D6AF5F.2040102@parallels.com>
Date: Wed, 15 Jan 2014 19:55:11 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm: vmscan: shrink all slab objects if tight on memory
References: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com> <20140113150502.4505f661589a4a2d30e6f11d@linux-foundation.org> <52D4E5F2.5080205@parallels.com> <20140114141453.374bd18e5290876177140085@linux-foundation.org> <52D64B27.30604@parallels.com> <20140115012541.ad302526.akpm@linux-foundation.org>
In-Reply-To: <20140115012541.ad302526.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

On 01/15/2014 01:25 PM, Andrew Morton wrote:
> On Wed, 15 Jan 2014 12:47:35 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
>
>> On 01/15/2014 02:14 AM, Andrew Morton wrote:
>>> On Tue, 14 Jan 2014 11:23:30 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
>>>
>>>> On 01/14/2014 03:05 AM, Andrew Morton wrote:
>>>>> That being said, I think I'll schedule this patch as-is for 3.14.  Can
>>>>> you please take a look at implementing the simpler approach, send me
>>>>> something for 3.15-rc1?
>>>> IMHO the simpler approach (Glauber's patch) is not suitable as is,
>>>> because it, in fact, neglects the notion of batch_size when doing low
>>>> prio scans, because it calls ->scan() for < batch_size objects even if
>>>> the slab has >= batch_size objects while AFAIU it should accumulate a
>>>> sufficient number of objects to scan in nr_deferred instead.
>>> Well.  If you mean that when nr-objects=large and batch_size=32 and
>>> total_scan=33, the patched code will scan 32 objects and then 1 object
>>> then yes, that should be fixed.
>> I mean if nr_objects=large and batch_size=32 and shrink_slab() is called
>> 8 times with total_scan=4, we can either call ->scan() 8 times with
>> nr_to_scan=4 (Glauber's patch) or call it only once with nr_to_scan=32
>> (that's how it works now). Frankly, after a bit of thinking I am
>> starting to doubt that this can affect performance at all provided the
>> shrinker is implemented in a sane way, because as you've mentioned
>> shrink_slab() is already a slow path. It seems I misunderstood the
>> purpose of batch_size initially: I though we need it to limit the number
>> of calls to ->scan(), but now I guess the only purpose of it is limiting
>> the number of objects scanned in one pass to avoid latency issues.
> Actually, the intent of batching is to limit the number of calls to
> ->scan().  At least, that was the intent when I wrote it!  This is a
> good principle and we should keep doing it.  If we're going to send the
> CPU away to tread on a pile of cold cachelines, we should make sure
> that it does a good amount of work while it's there.
>
>> But
>> then another question arises - why do you think the behavior you
>> described above (scanning 32 and then 1 object if total_scan=33,
>> batch_size=32) is bad?
> Yes, it's a bit inefficient but it won't be too bad.  What would be bad
> would be to scan a very small number of objects and then to advance to
> the next shrinker.
>
>> In other words why can't we make the scan loop
>> look like this:
>>
>>     while (total_scan > 0) {
>>         unsigned long ret;
>>         unsigned long nr_to_scan = min(total_scan, batch_size);
>>
>>         shrinkctl->nr_to_scan = nr_to_scan;
>>         ret = shrinker->scan_objects(shrinker, shrinkctl);
>>         if (ret == SHRINK_STOP)
>>             break;
>>         freed += ret;
>>
>>         count_vm_events(SLABS_SCANNED, nr_to_scan);
>>         total_scan -= nr_to_scan;
>>
>>         cond_resched();
>>     }
>
> Well, if we come in here with total_scan=1 then we defeat the original
> intent of the batching, don't we?  We end up doing a lot of work just
> to scan one object.  So perhaps add something like
>
> 	if (total_scan < batch_size && max_pass > batch_size)
> 		skip the while loop
>
> If we do this, total_scan will be accumulated into nr_deferred, up to
> the point where the threshold is exceeded, yes?

Yes, but only if the shrinker has > batch_size objects to scan,
otherwise (max_pass < batch_size) we will proceed to the while loop and
call ->scan() even if total_scan = 1. I mean if batch_size = 32,
max_pass = 31 and total_scan = 1 (low memory pressure), we will call
->scan() 31 times scanning only 1 object during each pass, which is not
good.

> All the arithmetic in there hurts my brain and I don't know what values
> total_scan typically ends up with.
>
> btw. all that trickery with delta and lru_pages desperately needs
> documenting.  What the heck is it intended to do??
>
>
>
> We could avoid the "scan 32 then scan just 1" issue with something like
>
> 	if (total_scan > batch_size)
> 		total_scan %= batch_size;
>
> before the loop.  But I expect the effects of that will be unmeasurable
> - on average the number of objects which are scanned in the final pass
> of the loop will be batch_size/2, yes?  That's still a decent amount.

Let me try to summarize. We want to scan batch_size objects in one pass,
not more (to keep latency low) and not less (to avoid cpu cache
pollution due to too frequent calls); if the calculated value of
nr_to_scan is less than the batch_size we should accumulate it in
nr_deferred instead of calling ->scan() and add nr_deferred to
nr_to_scan on the next pass, i.e. in pseudo-code:

    /* calculate current nr_to_scan */
    max_pass = shrinker->count();
    delta = max_pass * nr_user_pages_scanned / nr_user_pages;

    /* add nr_deferred */
    total_scan = delta + nr_deferred;

    while (total_scan >= batch_size) {
        shrinker->scan(batch_size);
        total_scan -= batch_size;
    }

    /* save the remainder to nr_deferred  */
    nr_deferred = total_scan;

That would work, but if max_pass is < batch_size, it would not scan the
objects immediately even if prio is high (we want to scan all objects).
For example, dropping caches would not work on the first attempt - the
user would have to call it batch_size / max_pass times. This could be
fixed by making the code proceed to ->scan() not only if total_scan is
>= batch_size, but also if max_pass is < batch_size and total_scan is >=
max_pass, i.e.

    while (total_scan >= batch_size ||
            (max_pass < batch_size && total_scan >= max_pass)) ...

which is equivalent to

    while (total_scan >= batch_size ||
                total_scan >= max_pass) ...

The latter is the loop condition from the current patch, i.e. this patch
would make the trick if shrink_slab() followed the pseudo-code above. In
real life, it does not actually - we have to bias total_scan before the
while loop in order to avoid dropping fs meta caches on light memory
pressure due to a large number being built in nr_deferred:

    if (delta < max_pass / 4)
        total_scan = min(total_scan, max_pass / 2);

    while (total_scan >= batch_size) ...

With this biasing, it is impossible to achieve the ideal behavior I've
described above, because we will never accumulate max_pass objects in
nr_deferred if memory pressure is low. So, if applied to the real code,
this patch takes on a slightly different sense, which I tried to reflect
in the comment to the code: it will call ->scan() with nr_to_scan <
batch_size only if:

1) max_pass < batch_size && total_scan >= max_pass

and

2) we're tight on memory, i.e. the current delta is high (otherwise
total_scan will be biased as max_pass / 2 and condition 1 won't be
satisfied).

>From our discussion it seems condition 2 is not necessary at all, but it
follows directly from the biasing rule. So I propose to tweak the
biasing a bit so that total_scan won't be lowered < batch_size:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eea668d..78ddd5e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -267,7 +267,7 @@ shrink_slab_node(struct shrink_control *shrinkctl,
struct shrinker *shrinker,
      * a large delta change is calculated directly.
      */
     if (delta < max_pass / 4)
-        total_scan = min(total_scan, max_pass / 2);
+        total_scan = min(total_scan, max(max_pass / 2, batch_size));
 
     /*
      * Avoid risking looping forever due to too large nr value:
@@ -281,7 +281,7 @@ shrink_slab_node(struct shrink_control *shrinkctl,
struct shrinker *shrinker,
                 nr_pages_scanned, lru_pages,
                 max_pass, delta, total_scan);
 
-    while (total_scan >= batch_size) {
+    while (total_scan >= batch_size || total_scan >= max_pass) {
         unsigned long ret;
 
         shrinkctl->nr_to_scan = batch_size;

The first hunk guarantees that total_scan will always accumulate at
least batch_size objects no matter how small max_pass is. That means
that when max_pass is < batch_size we will eventually get >= max_pass
objects to scan and shrink the slab to 0 as we need. What do you think
about that?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
