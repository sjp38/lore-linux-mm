Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6E7A6B48CC
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 20:11:58 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p5-v6so1654862pfh.11
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 17:11:58 -0700 (PDT)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id w4-v6si2207237pfb.52.2018.08.28.17.11.56
        for <linux-mm@kvack.org>;
        Tue, 28 Aug 2018 17:11:57 -0700 (PDT)
Date: Wed, 29 Aug 2018 10:11:53 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] fs/dcache: Track & report number of negative dentries
Message-ID: <20180829001153.GD1572@dastard>
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-2-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1535476780-5773-2-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Aug 28, 2018 at 01:19:39PM -0400, Waiman Long wrote:
> The current dentry number tracking code doesn't distinguish between
> positive & negative dentries. It just reports the total number of
> dentries in the LRU lists.
> 
> As excessive number of negative dentries can have an impact on system
> performance, it will be wise to track the number of positive and
> negative dentries separately.
> 
> This patch adds tracking for the total number of negative dentries in
> the system LRU lists and reports it in the /proc/sys/fs/dentry-state
> file. The number, however, does not include negative dentries that are
> in flight but not in the LRU yet.
> 
> The number of positive dentries in the LRU lists can be roughly found
> by subtracting the number of negative dentries from the total.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  Documentation/sysctl/fs.txt | 19 +++++++++++++------
>  fs/dcache.c                 | 45 +++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/dcache.h      |  7 ++++---
>  3 files changed, 62 insertions(+), 9 deletions(-)
> 
> diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
> index 819caf8..118bb93 100644
> --- a/Documentation/sysctl/fs.txt
> +++ b/Documentation/sysctl/fs.txt
> @@ -63,19 +63,26 @@ struct {
>          int nr_unused;
>          int age_limit;         /* age in seconds */
>          int want_pages;        /* pages requested by system */
> -        int dummy[2];
> +        int nr_negative;       /* # of unused negative dentries */
> +        int dummy;
>  } dentry_stat = {0, 0, 45, 0,};

That's not a backwards compatible ABI change. Those dummy fields
used to represent some metric we no longer calculate, and there are
probably still monitoring apps out there that think they still have
the old meaning. i.e. they are still visible to userspace:

$ cat /proc/sys/fs/dentry-state 
83090	67661	45	0	0	0
$

IOWs, you can add new fields for new metrics to the end of the
structure, but you can't re-use existing fields even if they
aren't calculated anymore.

[....]

> @@ -214,6 +226,28 @@ static inline int dentry_string_cmp(const unsigned char *cs, const unsigned char
>  
>  #endif
>  
> +static inline void __neg_dentry_dec(struct dentry *dentry)
> +{
> +	this_cpu_dec(nr_dentry_neg);
> +}
> +
> +static inline void neg_dentry_dec(struct dentry *dentry)
> +{
> +	if (unlikely(d_is_negative(dentry)))
> +		__neg_dentry_dec(dentry);

unlikely() considered harmful.

The workload you are trying to optimise is whe negative dentries are
the common case. IOWs, static branch prediction hints like this will
be wrong exactly when we want the branch to be predicted correctly
by the hardware.

> +}
> +
> +static inline void __neg_dentry_inc(struct dentry *dentry)
> +{
> +	this_cpu_inc(nr_dentry_neg);
> +}
> +
> +static inline void neg_dentry_inc(struct dentry *dentry)
> +{
> +	if (unlikely(d_is_negative(dentry)))
> +		__neg_dentry_inc(dentry);
> +}

These wrappers obfuscate the code - they do not do what the
name suggests and instead are conditional on dentry state.

I'd just open code this stuff - the code is much better without
the wrappers.

> +
>  static inline int dentry_cmp(const struct dentry *dentry, const unsigned char *ct, unsigned tcount)
>  {
>  	/*
> @@ -331,6 +365,8 @@ static inline void __d_clear_type_and_inode(struct dentry *dentry)
>  	flags &= ~(DCACHE_ENTRY_TYPE | DCACHE_FALLTHRU);
>  	WRITE_ONCE(dentry->d_flags, flags);
>  	dentry->d_inode = NULL;
> +	if (dentry->d_flags & DCACHE_LRU_LIST)
> +		__neg_dentry_inc(dentry);
>  }
>  
>  static void dentry_free(struct dentry *dentry)
> @@ -395,6 +431,7 @@ static void d_lru_add(struct dentry *dentry)
>  	dentry->d_flags |= DCACHE_LRU_LIST;
>  	this_cpu_inc(nr_dentry_unused);
>  	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
> +	neg_dentry_inc(dentry);

Like this - why on earth would we increment the negative dentry
count for every dentry that is added to LRU? Open coding

 	this_cpu_inc(nr_dentry_unused);
+	if (d_is_negative(dentry))
+		this_cpu_inc(nr_dentry_neg);
 	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));

That's obvious to the reader what we are doing, and it aggregates
all the accounting in a single location. Same for the rest of the
code.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
