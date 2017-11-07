Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B88BA280264
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 10:43:53 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y42so1697991wrd.23
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 07:43:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 24si1440945edv.505.2017.11.07.07.43.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Nov 2017 07:43:52 -0800 (PST)
Date: Tue, 7 Nov 2017 16:43:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Avoid KERN_CONT uses in warn_alloc
Message-ID: <20171107154351.ebtitvjyo5v3bt26@dhcp22.suse.cz>
References: <b31236dfe3fc924054fd7842bde678e71d193638.1509991345.git.joe@perches.com>
 <20171107125055.cl5pyp2zwon44x5l@dhcp22.suse.cz>
 <1510068865.1000.19.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510068865.1000.19.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 07-11-17 07:34:25, Joe Perches wrote:
> On Tue, 2017-11-07 at 13:50 +0100, Michal Hocko wrote:
> > On Mon 06-11-17 10:02:56, Joe Perches wrote:
> > > KERN_CONT/pr_cont uses should be avoided where possible.
> > > Use single pr_warn calls instead.
> []
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> []
> > > @@ -3275,19 +3275,17 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
> > >  	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
> > >  		return;
> > >  
> > > -	pr_warn("%s: ", current->comm);
> > > -
> > >  	va_start(args, fmt);
> > >  	vaf.fmt = fmt;
> > >  	vaf.va = &args;
> > > -	pr_cont("%pV", &vaf);
> > > -	va_end(args);
> > > -
> > > -	pr_cont(", mode:%#x(%pGg), nodemask=", gfp_mask, &gfp_mask);
> > >  	if (nodemask)
> > > -		pr_cont("%*pbl\n", nodemask_pr_args(nodemask));
> > > +		pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=%*pbl\n",
> > > +			current->comm, &vaf, gfp_mask, &gfp_mask,
> > > +			nodemask_pr_args(nodemask));
> > >  	else
> > > -		pr_cont("(null)\n");
> > > +		pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=(null)\n",
> > > +			current->comm, &vaf, gfp_mask, &gfp_mask);
> > > +	va_end(args);
> > >  
> > >  	cpuset_print_current_mems_allowed();
> > 
> > I do not like the duplication. It just calls for inconsistencies over
> > time. Can we instead make %*pbl consume NULL nodemask instead?
> > Something like the following pseudo patch + the if/else removed.
> > If this would be possible we could simplify other code as well I think
> > (at least oom code has to special case NULL nodemask).
> > 
> > What do you think?
> 
> I think it would be fine to have a single pr_warn.
> 
> > ---
> > diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> []
> > @@ -104,7 +104,7 @@ extern nodemask_t _unused_nodemask_arg_;
> >   *
> >   * Can be used to provide arguments for '%*pb[l]' when printing a nodemask.
> >   */
> > -#define nodemask_pr_args(maskp)		MAX_NUMNODES, (maskp)->bits
> > +#define nodemask_pr_args(maskp)		MAX_NUMNODES, (maskp) ? (maskp)->bits : NULL
> >  
> >  /*
> >   * The inline keyword gives the compiler room to decide to inline, or
> > diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> []
> > @@ -902,6 +902,9 @@ char *bitmap_list_string(char *buf, char *end, unsigned long *bitmap,
> >  	int cur, rbot, rtop;
> >  	bool first = true;
> >  
> > +	if (!bitmap)
> > +		return buf;
> 
> I believe this is not necessary as any NULL pointer argument
> passed to lib/vsprintf.c:pointer() (any %p<foo>) emits
> "[2 or 10 spaces](null)" on 32bit or 64 bit systems.

OK, I see
	if (!ptr && *fmt != 'K') {
		/*
		 * Print (null) with the same width as a pointer so it makes
		 * tabular output look nice.
		 */
		if (spec.field_width == -1)
			spec.field_width = default_width;
		return string(buf, end, "(null)", spec);
	}

 
> I believe, but have not tested, that using a specific width
> as an argument to %*pb[l] will constrain the number of
> spaces before the '(null)' output in any NULL pointer use.
> 
> So how about a #define like
> 
> /*
>  * nodemask_pr_args is only used with a "%*pb[l]" format for a nodemask.
>  * A NULL nodemask uses 6 to emit "(null)" without leading spaces.
>  */
> #define nodemask_pr_args(maskp)			\
> 	(maskp) ? MAX_NUMNODES : 6,		\
> 	(maskp) ? (maskp)->bits : NULL

Why not -1 then?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
