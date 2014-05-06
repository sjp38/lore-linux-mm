Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id A71F76B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 18:21:23 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so157719eek.16
        for <linux-mm@kvack.org>; Tue, 06 May 2014 15:21:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si14517887eew.168.2014.05.06.15.21.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 15:21:22 -0700 (PDT)
Date: Tue, 6 May 2014 23:21:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/17] mm: page_alloc: Use jump labels to avoid checking
 number_of_cpusets
Message-ID: <20140506222118.GB23991@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-4-git-send-email-mgorman@suse.de>
 <20140506202350.GE1429@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140506202350.GE1429@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, May 06, 2014 at 10:23:50PM +0200, Peter Zijlstra wrote:
> On Thu, May 01, 2014 at 09:44:34AM +0100, Mel Gorman wrote:
> > If cpusets are not in use then we still check a global variable on every
> > page allocation. Use jump labels to avoid the overhead.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  include/linux/cpuset.h | 31 +++++++++++++++++++++++++++++++
> >  kernel/cpuset.c        |  8 ++++++--
> >  mm/page_alloc.c        |  3 ++-
> >  3 files changed, 39 insertions(+), 3 deletions(-)
> > 
> > diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> > index b19d3dc..2b89e07 100644
> > --- a/include/linux/cpuset.h
> > +++ b/include/linux/cpuset.h
> > @@ -17,6 +17,35 @@
> >  
> >  extern int number_of_cpusets;	/* How many cpusets are defined in system? */
> >  
> > +#ifdef HAVE_JUMP_LABEL
> > +extern struct static_key cpusets_enabled_key;
> > +static inline bool cpusets_enabled(void)
> > +{
> > +	return static_key_false(&cpusets_enabled_key);
> > +}
> > +#else
> > +static inline bool cpusets_enabled(void)
> > +{
> > +	return number_of_cpusets > 1;
> > +}
> > +#endif
> > +
> > +static inline void cpuset_inc(void)
> > +{
> > +	number_of_cpusets++;
> > +#ifdef HAVE_JUMP_LABEL
> > +	static_key_slow_inc(&cpusets_enabled_key);
> > +#endif
> > +}
> > +
> > +static inline void cpuset_dec(void)
> > +{
> > +	number_of_cpusets--;
> > +#ifdef HAVE_JUMP_LABEL
> > +	static_key_slow_dec(&cpusets_enabled_key);
> > +#endif
> > +}
> 
> Why the HAVE_JUMP_LABEL and number_of_cpusets thing? When
> !HAVE_JUMP_LABEL the static_key thing reverts to an atomic_t and
> static_key_false() becomes:
> 

Because number_of_cpusets is used to size a kmalloc(). Potentially I could
abuse the internals of static keys and use the value of key->enabled but
that felt like abuse of the API.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
