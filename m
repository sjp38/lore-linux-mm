Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB686B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 07:42:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w79so1992013wme.7
        for <linux-mm@kvack.org>; Wed, 31 May 2017 04:42:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u22si2103971wrb.323.2017.05.31.04.42.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 04:42:39 -0700 (PDT)
Date: Wed, 31 May 2017 13:42:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/4] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
Message-ID: <20170531114236.GJ27783@dhcp22.suse.cz>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-3-mhocko@kernel.org>
 <87a861ivem.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87a861ivem.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

[I am sorry but I didn't get to this earlier]

On Thu 25-05-17 11:21:05, NeilBrown wrote:
> On Tue, Mar 07 2017, Michal Hocko wrote:
> 
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 2bfcfd33e476..60af7937c6f2 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -25,7 +25,7 @@ struct vm_area_struct;
> >  #define ___GFP_FS		0x80u
> >  #define ___GFP_COLD		0x100u
> >  #define ___GFP_NOWARN		0x200u
> > -#define ___GFP_REPEAT		0x400u
> > +#define ___GFP_RETRY_MAYFAIL		0x400u
> >  #define ___GFP_NOFAIL		0x800u
> >  #define ___GFP_NORETRY		0x1000u
> >  #define ___GFP_MEMALLOC		0x2000u
> > @@ -136,26 +136,38 @@ struct vm_area_struct;
> >   *
> >   * __GFP_RECLAIM is shorthand to allow/forbid both direct and kswapd reclaim.
> >   *
> > - * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
> > - *   _might_ fail.  This depends upon the particular VM implementation.
> > + * The default allocator behavior depends on the request size. We have a concept
> > + * of so called costly allocations (with order > PAGE_ALLOC_COSTLY_ORDER).
> 
> Boundary conditions is one of my pet peeves....
> The description here suggests that an allocation of
> "1<<PAGE_ALLOC_COSTLY_ORDER" pages is not "costly", which is
> inconsistent with how those words would normally be interpreted.
> 
> Looking at the code I see comparisons like:
> 
>    order < PAGE_ALLOC_COSTLY_ORDER
> or
>    order >= PAGE_ALLOC_COSTLY_ORDER
> 
> which supports the documented (but incoherent) meaning.
> 
> But I also see:
> 
>   order = max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);

this smells fishy. Very similarly to other PAGE_ALLOC_COSTLY_ORDER usage
out of the mm proper. Many of them can be simply changed to use
kvmalloc. I will put this on my todo list for a later cleanup. There
shouldn't be any real need to care about PAGE_ALLOC_COSTLY_ORDER.

> which looks like it is trying to perform the largest non-costly
> allocation, but is making a smaller allocation than necessary.
> 
> I would *really* like it if the constant actually meant what its name
> implied.
> 
>  PAGE_ALLOC_MAX_NON_COSTLY
> ??

Yeah, I can see how this can be confusing. Maybe this is worth a
separate cleanup? I wouldn't like to conflate it with this patch.
 
> > + * !costly allocations are too essential to fail so they are implicitly
> > + * non-failing (with some exceptions like OOM victims might fail) by default while
> > + * costly requests try to be not disruptive and back off even without invoking
> > + * the OOM killer. The following three modifiers might be used to override some of
> > + * these implicit rules
> > + *
> > + * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
> > + *   return NULL when direct reclaim and memory compaction have failed to allow
> > + *   the allocation to succeed.  The OOM killer is not called with the current
> > + *   implementation. This is a default mode for costly allocations.
> 
> The name here is "NORETRY", but the text says "not retry indefinitely".
> So does it retry or not?
> I would assuming it "tried" once, and only once.
> However it could be that a "try" is not a simple well defined task.

This is the case unfortunatelly. E.g. we have that node_reclaim thing
which will try to reclaim a local node before falling back to other
nodes. And that counts as a direct reclaim attempt and that happens in
the allocator fast path. We do get to the allocator slow path where we
do the full direct reclaim attempt and give up only if that fails.
Confusing? I can see how...

> Maybe some escalation happens on the 2nd or 3rd "try", so they are really
> trying different things?
> 
> The word "indefinitely" implies there is a definite limit.  It might
> help to say what that is, or at least say that it is small.

OK.
 
> Also, this documentation is phrased to tell the VM implementor what is,
> or is not, allowed.  Most readers will be more interested is the
> responsibilities of the caller.
> 
>   __GFP_NORETRY: The VM implementation will not retry after all
>      reasonable avenues for finding free memory have been pursued.  The
>      implementation may sleep (i.e. call 'schedule()'), but only while
>      waiting for another task to perform some specific action.
>      The caller must handle failure.  This flag is suitable when failure can
>      easily be handled at small cost, such as reduced throughput.

The above is not precise. What about the following?

__GFP_NORETRY: The VM implementation will not try only very lightweight
memory direct reclaim to get some memory under memory pressure (thus
it can sleep). It will avoid disruptive actions like OOM killer. The
caller must handle the failure which is quite likely to happen under
heavy memory pressure. The flag is suitable when failure can easily be
handled at small cost, such as reduced throughput


> > + *
> > + * __GFP_RETRY_MAYFAIL: Try hard to allocate the memory, but the allocation attempt
> > + *   _might_ fail. All viable forms of memory reclaim are tried before the fail.
> > + *   The OOM killer is excluded because this would be too disruptive. This can be
> > + *   used to override non-failing default behavior for !costly requests as well as
> > + *   fortify costly requests.
> 
> What does "Try hard" mean?
> In part, it means "retry everything a few more times", I guess in the
> hope that something happened in the mean time.
> It also seems to mean waiting for compaction to happen, which I
> guess is only relevant for >PAGE_SIZE allocations?
> Maybe it also means waiting for page-out to complete.
> So the summary would be that it waits for a little while, hoping for a
> miracle.
> 
>    __GFP_RETRY_MAYFAIL:  The VM implementation will retry memory reclaim
>      procedures that have previously failed if there is some indication
>      that progress has been made else where.  It can wait for other
>      tasks to attempt high level approaches to freeing memory such as
>      compaction (which removed fragmentation) and page-out.
>      There is still a definite limit to the number of retries, but it is
>      a larger limit than with __GFP_NORERY.
>      Allocations with this flag may fail, but only when there is
>      genuinely little unused memory. While these allocations do not
>      directly trigger the OOM killer, their failure indicates that the
>      system is likely to need to use the OOM killer soon.
>      The caller must handle failure, but can reasonably do so by failing
>      a higher-level request, or completing it only in a much less
>      efficient manner.
>      If the allocation does fail, and the caller is in a position to
>      free some non-essential memory, doing so could benefit the system
>      as a whole.

OK

> >   *
> >   * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
> >   *   cannot handle allocation failures. New users should be evaluated carefully
> >   *   (and the flag should be used only when there is no reasonable failure
> >   *   policy) but it is definitely preferable to use the flag rather than
> > - *   opencode endless loop around allocator.
> > - *
> > - * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
> > - *   return NULL when direct reclaim and memory compaction have failed to allow
> > - *   the allocation to succeed.  The OOM killer is not called with the current
> > - *   implementation.
> > + *   opencode endless loop around allocator. Using this flag for costly allocations
> > + *   is _highly_ discouraged.
> 
> Should this explicitly say that the OOM killer might be invoked in an attempt
> to satisfy this allocation?

Well that depends. Normally it does but E.g. __GFP_NOFAIL | GFP_NOFS
will not trigger the OOM killer because we never trigger OOM killer for
NOFS requests as a lot of metadata might be pinned under the current fs
context.

> Is the OOM killer *only* invoked from
> allocations with __GFP_NOFAIL ?

No. Most !costly allocation requests with __GFP_DIRECT_RECLAIM are
allowed to trigger the OOM killer. There are some exceptions described
in  __alloc_pages_may_oom. I am not sure we want to docment those in the
high level documentation. 

> Maybe be extra explicit "The allocation could block indefinitely but
> will never return with failure.  Testing for failure is pointless.".

OK

> I've probably got several specifics wrong.  I've tried to answer the
> questions that I would like to see answered by the documentation.   If
> you can fix it up so that those questions are answered correctly, that
> would be great.

This is what I will fold into the patch:
---
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 60af7937c6f2..9c96c739d726 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -144,23 +144,40 @@ struct vm_area_struct;
  * the OOM killer. The following three modifiers might be used to override some of
  * these implicit rules
  *
- * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
- *   return NULL when direct reclaim and memory compaction have failed to allow
- *   the allocation to succeed.  The OOM killer is not called with the current
- *   implementation. This is a default mode for costly allocations.
- *
- * __GFP_RETRY_MAYFAIL: Try hard to allocate the memory, but the allocation attempt
- *   _might_ fail. All viable forms of memory reclaim are tried before the fail.
- *   The OOM killer is excluded because this would be too disruptive. This can be
- *   used to override non-failing default behavior for !costly requests as well as
- *   fortify costly requests.
+ * __GFP_NORETRY: The VM implementation will not try only very lightweight
+ *   memory direct reclaim to get some memory under memory pressure (thus
+ *   it can sleep). It will avoid disruptive actions like OOM killer. The
+ *   caller must handle the failure which is quite likely to happen under
+ *   heavy memory pressure. The flag is suitable when failure can easily be
+ *   handled at small cost, such as reduced throughput
+ *
+ * __GFP_RETRY_MAYFAIL: The VM implementation will retry memory reclaim
+ *   procedures that have previously failed if there is some indication
+ *   that progress has been made else where.  It can wait for other
+ *   tasks to attempt high level approaches to freeing memory such as
+ *   compaction (which removed fragmentation) and page-out.
+ *   There is still a definite limit to the number of retries, but it is
+ *   a larger limit than with __GFP_NORERY.
+ *   Allocations with this flag may fail, but only when there is
+ *   genuinely little unused memory. While these allocations do not
+ *   directly trigger the OOM killer, their failure indicates that
+ *   the system is likely to need to use the OOM killer soon.  The
+ *   caller must handle failure, but can reasonably do so by failing
+ *   a higher-level request, or completing it only in a much less
+ *   efficient manner.
+ *   If the allocation does fail, and the caller is in a position to
+ *   free some non-essential memory, doing so could benefit the system
+ *   as a whole.
  *
  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
- *   cannot handle allocation failures. New users should be evaluated carefully
- *   (and the flag should be used only when there is no reasonable failure
- *   policy) but it is definitely preferable to use the flag rather than
- *   opencode endless loop around allocator. Using this flag for costly allocations
- *   is _highly_ discouraged.
+ *   cannot handle allocation failures. The allocation could block
+ *   indefinitely but will never return with failure. Testing for
+ *   failure is pointless.
+ *   New users should be evaluated carefully (and the flag should be
+ *   used only when there is no reasonable failure policy) but it is
+ *   definitely preferable to use the flag rather than opencode endless
+ *   loop around allocator.
+ *   Using this flag for costly allocations is _highly_ discouraged.
  */
 #define __GFP_IO	((__force gfp_t)___GFP_IO)
 #define __GFP_FS	((__force gfp_t)___GFP_FS)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
