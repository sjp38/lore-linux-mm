Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6D89C6B0038
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:49:20 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so3160311eek.23
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:49:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id p9si21202388eew.34.2013.12.11.14.49.19
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:49:19 -0800 (PST)
Date: Wed, 11 Dec 2013 23:49:17 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH RFC] mm readahead: Fix the readahead fail in case of
 empty numa node
Message-ID: <20131211224917.GF1163@quack.suse.cz>
References: <1386066977-17368-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <20131203143841.11b71e387dc1db3a8ab0974c@linux-foundation.org>
 <529EE811.5050306@linux.vnet.ibm.com>
 <20131204004125.a06f7dfc.akpm@linux-foundation.org>
 <529EF0FB.2050808@linux.vnet.ibm.com>
 <20131204134838.a048880a1db9e9acd14a39e4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131204134838.a048880a1db9e9acd14a39e4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Wed 04-12-13 13:48:38, Andrew Morton wrote:
> On Wed, 04 Dec 2013 14:38:11 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:
> 
> > On 12/04/2013 02:11 PM, Andrew Morton wrote:
> > > On Wed, 04 Dec 2013 14:00:09 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:
> > >
> > >> Unfaortunately, from my search, I saw that the code belonged to pre git
> > >> time, so could not get much information on that.
> > >
> > > Here: https://lkml.org/lkml/2004/8/20/242
> > >
> > > It seems it was done as a rather thoughtless performance optimisation.
> > > I'd say it's time to reimplement max_sane_readahead() from scratch.
> > >
> > 
> > Ok. Thanks for the link. I think after that,
> > Here it was changed to pernode:
> > https://lkml.org/lkml/2004/8/21/9 to avoid iteration all over.
> > 
> > do you think above patch (+comments) with some sanitized nr (thus
> > avoiding iteration over nodes in remote numa readahead case) does look
> > better?
> > or should we iterate all memory.
> 
> I dunno, the whole thing smells of arbitrary woolly thinking to me. 
> Going back further in time..
> 
> : commit f76d03dc9fcff7ac88e2d23c5814fd0f50c59bb6
> : Author:     akpm <akpm>
> : AuthorDate: Sun Dec 15 03:18:58 2002 +0000
> : Commit:     akpm <akpm>
> : CommitDate: Sun Dec 15 03:18:58 2002 +0000
> : 
> :     [PATCH] madvise_willneed() maximum readahead checking
> :     
> :     madvise_willneed() currently has a very strange check on how much readahead
> :     it is prepared to do.
> :     
> :       It is based on the user's rss limit.  But this is usually enormous, and
> :       the user isn't necessarily going to map all that memory at the same time
> :       anyway.
> :     
> :       And the logic is wrong - it is comparing rss (which is in bytes) with
> :       `end - start', which is in pages.
> :     
> :       And it returns -EIO on error, which is not mentioned in the Open Group
> :       spec and doesn't make sense.
> :     
> :     
> :     This patch takes it all out and applies the same upper limit as is used in
> :     sys_readahead() - half the inactive list.
> : 
> : +/*
> : + * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
> : + * sensible upper limit.
> : + */
> : +unsigned long max_sane_readahead(unsigned long nr)
> : +{
> : +       unsigned long active;
> : +       unsigned long inactive;
> : +
> : +       get_zone_counts(&active, &inactive);
> : +       return min(nr, inactive / 2);
> : +}
> 
> And one would need to go back further still to understand the rationale
> for the sys_readahead() decision and that even predates the BK repo.
> 
> iirc the thinking was that we need _some_ limit on readahead size so
> the user can't go and do ridiculously large amounts of readahead via
> sys_readahead().  But that doesn't make a lot of sense because the user
> could do the same thing with plain old read().
> 
> So for argument's sake I'm thinking we just kill it altogether and
> permit arbitrarily large readahead:
> 
> --- a/mm/readahead.c~a
> +++ a/mm/readahead.c
> @@ -238,13 +238,12 @@ int force_page_cache_readahead(struct ad
>  }
>  
>  /*
> - * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
> - * sensible upper limit.
> + * max_sane_readahead() is disabled.  It can later be removed altogether, but
> + * let's keep a skeleton in place for now, in case disabling was the wrong call.
>   */
>  unsigned long max_sane_readahead(unsigned long nr)
>  {
> -	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
> -		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
> +	return nr;
>  }
>  
>  /*
> 
> Can anyone see a problem with this?
  Well, the downside seems to be that if userspace previously issued
MADV/FADV_WILLNEED on a huge file, we trimmed the request to a sensible
size. Now we try to read the whole huge file which is pretty much
guaranteed to be useless (as we'll be pushing out of cache data we just
read a while ago). And guessing the right readahead size from userspace
isn't trivial so it would make WILLNEED advice less useful. What do you
think?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
