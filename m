Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 82058900138
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 19:52:08 -0400 (EDT)
Date: Thu, 8 Sep 2011 16:51:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V8 2/4] mm: frontswap: core code
Message-Id: <20110908165147.ff46f5bf.akpm@linux-foundation.org>
In-Reply-To: <896345e2-ded0-404a-8e64-490584ec2b4e@default>
References: <20110829164908.GA27200@ca-server1.us.oracle.com
 20110907162510.3547d67a.akpm@linux-foundation.org>
	<896345e2-ded0-404a-8e64-490584ec2b4e@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Thu, 8 Sep 2011 08:00:36 -0700 (PDT)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > From: Andrew Morton [mailto:akpm@linux-foundation.org]
> > Subject: Re: [PATCH V8 2/4] mm: frontswap: core code
> 
> Thanks very much for taking the time for this feedback!
> 
> Please correct me if I am presumptuous or misreading
> SubmittingPatches, but after making the changes below,
> I am thinking this constitutes a "Reviewed-by"?

Not really.  More like Briefly-browsed-by:.

> > > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > > Subject: [PATCH V8 2/4] mm: frontswap: core code
> > >
> > > This second patch of four in this frontswap series provides the core code
> > > for frontswap that interfaces between the hooks in the swap subsystem and
> > > +
> > > +struct frontswap_ops {
> > > +	void (*init)(unsigned);
> > > +	int (*put_page)(unsigned, pgoff_t, struct page *);
> > > +	int (*get_page)(unsigned, pgoff_t, struct page *);
> > > +	void (*flush_page)(unsigned, pgoff_t);
> > > +	void (*flush_area)(unsigned);
> > > +};
> > 
> > Please don't use the term "flush".  In both the pagecache code and the
> > pte code it is interchangably used to refer to both writeback and
> > invalidation.  The way to avoid this ambiguity and confusion is to use
> > the terms "writeback" and "invalidate" instead.
> > 
> > Here, you're referring to invalidation.
> 
> While the different name is OK, changing this consistently would now
> require simultaneous patches in cleancache, zcache, and xen (not
> to mention lots of docs inside and outside the kernel).  I suspect
> it would be cleaner to do this later across all affected code
> with a single commit.  Hope that's OK.

Well, if you can make that happen...

> (Personally, I find "invalidate" to be inaccurate because common
> usage of the term doesn't imply that the space used in the cache
> is recovered, i.e. garbage collection, which is the case here.
> To me, "flush" implies invalidate PLUS recover space.)

invalidate is close enough.  Consider block/blk-flush.c, sigh.

> 
> > > +/*
> > > + * Useful stats available in /sys/kernel/mm/frontswap.  These are for
> > > + * information only so are not protected against increment/decrement races.
> > > + */
> > > +static unsigned long frontswap_gets;
> > > +static unsigned long frontswap_succ_puts;
> > > +static unsigned long frontswap_failed_puts;
> > > +static unsigned long frontswap_flushes;
> > 
> > If they're in /sys/kernel/mm then they rather become permanent parts of
> > the exported kernel interface.  We're stuck with them.  Plus they're
> > inaccurate and updating them might be inefficient, so we don't want to
> > be stuck with them.
> > 
> > I suggest moving these to debugfs from where we can remove them if we
> > feel like doing so.
> 
> The style (and code) for this was mimicked from ksm and hugepages, which
> expose the stats the same way... as does cleancache now.  slub is also
> similar.  I'm OK with using a different approach (e.g. debugfs), but
> think it would be inconsistent and confusing to expose these stats
> differently than cleancache (or ksm and hugepages).  I'd support
> and help with a massive cleanup commit across all of mm later though.
> Hope that's OK for now.

These are boring internal counters for a few developers.  They're so
uninteresting to end users that the developer didn't even bother to
document them ;)

They should be in debugfs.  Probably some/all of the existing
cleancache/ksm/hugepage stats should be in debugfs too.  This a mistake
we often make.  Please let's be extremely miserly with the kernel API.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
