Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id A3A426B0069
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 15:52:23 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id z12so2881060lbi.2
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 12:52:23 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j10si8060943laf.95.2014.10.02.12.52.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Oct 2014 12:52:22 -0700 (PDT)
Date: Thu, 2 Oct 2014 15:52:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20141002195214.GA2705@cmpxchg.org>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
 <20140930110622.GB4456@dhcp22.suse.cz>
 <20141002150135.GA1394@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141002150135.GA1394@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 02, 2014 at 11:01:35AM -0400, Johannes Weiner wrote:
> On Tue, Sep 30, 2014 at 01:06:22PM +0200, Michal Hocko wrote:
> > > +/**
> > > + * page_counter_limit - limit the number of pages allowed
> > > + * @counter: counter
> > > + * @limit: limit to set
> > > + *
> > > + * Returns 0 on success, -EBUSY if the current number of pages on the
> > > + * counter already exceeds the specified limit.
> > > + *
> > > + * The caller must serialize invocations on the same counter.
> > > + */
> > > +int page_counter_limit(struct page_counter *counter, unsigned long limit)
> > > +{
> > > +	for (;;) {
> > > +		unsigned long old;
> > > +		long count;
> > > +
> > > +		count = atomic_long_read(&counter->count);
> > > +
> > > +		old = xchg(&counter->limit, limit);
> > > +
> > > +		if (atomic_long_read(&counter->count) != count) {
> > > +			counter->limit = old;
> > > +			continue;
> > > +		}
> > > +
> > > +		if (count > limit) {
> > > +			counter->limit = old;
> > > +			return -EBUSY;
> > > +		}
> > 
> > Ordering doesn't make much sense to me here. Say you really want to set
> > limit < count. You are effectively pushing all concurrent charges to
> > the reclaim even though you would revert your change and return with
> > EBUSY later on.
> >
> > Wouldn't (count > limit) check make more sense right after the first
> > atomic_long_read?
> > Also the second count check should be sufficient to check > count and
> > retry only when the count has increased.
> > Finally continuous flow of charges can keep this loop running for quite
> > some time and trigger lockup detector. cond_resched before continue
> > would handle that. Something like the following:
> > 
> > 	for (;;) {
> > 		unsigned long old;
> > 		long count;
> > 
> > 		count = atomic_long_read(&counter->count);
> > 		if (count > limit)
> > 			return -EBUSY;
> > 
> > 		old = xchg(&counter->limit, limit);
> > 
> > 		/* Recheck for concurrent charges */
> > 		if (atomic_long_read(&counter->count) > count) {
> > 			counter->limit = old;
> > 			cond_resched();
> > 			continue;
> > 		}
> > 
> > 		return 0;
> > 	}
> 
> This is susceptible to spurious -EBUSY during races with speculative
> charges and uncharges.  My code avoids that by retrying until we set
> the limit without any concurrent counter operations first, before
> moving on to implementing policy and rollback.
> 
> Some reclaim activity caused by a limit that the user is trying to set
> anyway should be okay.  I'd rather have a reliable syscall.
> 
> But the cond_resched() is a good idea, I'll add that, thanks.

Thinking more about it, my code doesn't really avoid that if the
speculative charges persist over the two reads, it just widens the
window a bit.  But your suggestion seems indeed more readable,
although I'd invert the second branch.

How about this delta on top?

diff --git a/mm/page_counter.c b/mm/page_counter.c
index 4bdab1c7a057..7eb17135d4a4 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -19,8 +19,8 @@ int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
 
 	new = atomic_long_sub_return(nr_pages, &counter->count);
 
-	if (WARN_ON_ONCE(new < 0))
-		atomic_long_add(nr_pages, &counter->count);
+	/* More uncharges than charges? */
+	WARN_ON_ONCE(new < 0);
 
 	return new > 0;
 }
@@ -146,29 +146,29 @@ int page_counter_limit(struct page_counter *counter, unsigned long limit)
 		unsigned long old;
 		long count;
 
-		count = atomic_long_read(&counter->count);
 		/*
+		 * Update the limit while making sure that it's not
+		 * below the (concurrently changing) counter value.
+		 *
 		 * The xchg implies two full memory barriers before
 		 * and after, so the read-swap-read is ordered and
 		 * ensures coherency with page_counter_try_charge():
 		 * that function modifies the count before checking
 		 * the limit, so if it sees the old limit, we see the
-		 * modified counter and retry.  This guarantees we
-		 * never successfully set a limit below the counter.
+		 * modified counter and retry.
 		 */
-		old = xchg(&counter->limit, limit);
-
-		if (atomic_long_read(&counter->count) != count) {
-			counter->limit = old;
-			continue;
-		}
+		count = atomic_long_read(&counter->count);
 
-		if (count > limit) {
-			counter->limit = old;
+		if (count > limit)
 			return -EBUSY;
-		}
 
-		return 0;
+		old = xchg(&counter->limit, limit);
+
+		if (atomic_long_read(&counter->count) <= count)
+			return 0;
+
+		counter->limit = old;
+		cond_resched();
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
