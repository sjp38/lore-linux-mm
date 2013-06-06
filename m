Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 4DD416B0034
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 21:45:34 -0400 (EDT)
Date: Thu, 6 Jun 2013 11:45:09 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 03/35] dcache: convert dentry_stat.nr_unused to
 per-cpu counters
Message-ID: <20130606014509.GN29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <1370287804-3481-4-git-send-email-glommer@openvz.org>
 <20130605160731.91a5cd3ff700367f5e155d83@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605160731.91a5cd3ff700367f5e155d83@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Wed, Jun 05, 2013 at 04:07:31PM -0700, Andrew Morton wrote:
> On Mon,  3 Jun 2013 23:29:32 +0400 Glauber Costa <glommer@openvz.org> wrote:
> 
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Before we split up the dcache_lru_lock, the unused dentry counter
> > needs to be made independent of the global dcache_lru_lock. Convert
> > it to per-cpu counters to do this.
> > 
> > ...
> >
> > --- a/fs/dcache.c
> > +++ b/fs/dcache.c
> > @@ -118,8 +118,10 @@ struct dentry_stat_t dentry_stat = {
> >  };
> >  
> >  static DEFINE_PER_CPU(long, nr_dentry);
> > +static DEFINE_PER_CPU(long, nr_dentry_unused);
> >  
> >  #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
> > +/* scan possible cpus instead of online and avoid worrying about CPU hotplug. */
> 
> That's a poor comment.  It explains what the code does (which is dead
> obvious) but fails to explain *why* the code does it.
> 
> > @@ -129,10 +131,20 @@ static long get_nr_dentry(void)
> >  	return sum < 0 ? 0 : sum;
> >  }
> >  
> > +static long get_nr_dentry_unused(void)
> > +{
> > +	int i;
> > +	long sum = 0;
> > +	for_each_possible_cpu(i)
> > +		sum += per_cpu(nr_dentry_unused, i);
> > +	return sum < 0 ? 0 : sum;
> > +}
> 
> And I'm sure we've asked and answered ad nauseum why this code needed
> to open-code the counters instead of using the provided library code,
> yet the answer to that *still* isn't in the code comments or even in
> the changelog.  It should be.

<sigh>

They were, originally, generic per-cpu counters:

312d3ca fs: use percpu counter for nr_dentry and nr_dentry_unused
cffbc8a fs: Convert nr_inodes and nr_unused to per-cpu counters

but then, well, let me just point you at the last time someone asked
this:

http://lwn.net/Articles/546587/

This is how we ended up with these fucked-up custom per-cpu
counters:

86c8749 vfs: revert per-cpu nr_unused counters for dentry and inodes
3e880fb fs: use fast counters for vfs caches

And so here we are now reverting 86c8749 because we're now
implementing the side of the scalability pile that requires the
unused counters to scale globally. I don't care to revisit 3e880fb
in this patch series, so this patch just duplicates existing
infrastructure.

> Given that the existing proc_nr_dentry() will suck mud rocks on
> large-cpu-count machines (due to get_nr_dentry()), I guess we can
> assume that nobody will be especially hurt by making proc_nr_dentry()
> suck even harder...

Yup, another reason I don't like the current implementation, too.
But making this better was labelled "optimising the slow path" and
so roundly dismissed.

Andrew, if you want to push the changes back to generic per-cpu
counters through to Linus, then I'll write the patches for you.  But
- and this is a big but - I'll only do this if you are going to deal
with the "performance trumps all other concerns" fanatics over
whether it should be merged or not. I have better things to do
with my time have a flamewar over trivial details like this.

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
