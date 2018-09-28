Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 817FC8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 06:05:59 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id d16-v6so275788wrr.17
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 03:05:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t127-v6sor1103171wme.22.2018.09.28.03.05.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 03:05:57 -0700 (PDT)
Date: Fri, 28 Sep 2018 11:05:55 +0100
From: Aaron Tomlin <atomlin@redhat.com>
Subject: Re: [PATCH v2] slub: extend slub debug to handle multiple slabs
Message-ID: <20180928100555.bvv75beo3c57g6vw@atomlin.usersys.com>
References: <20180920200016.11003-1-atomlin@redhat.com>
 <20180921163412.de1b331a639a8031aaf85d4f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180921163412.de1b331a639a8031aaf85d4f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 2018-09-21 16:34 -0700, Andrew Morton wrote:
> On Thu, 20 Sep 2018 21:00:16 +0100 Aaron Tomlin <atomlin@redhat.com> wrote:
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1283,9 +1283,37 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
> >  	/*
> >  	 * Enable debugging if selected on the kernel commandline.
> >  	 */
> 
> The above comment is in a strange place.  Can we please move it to
> above the function definition in the usual fashion?  And make it
> better, if anything seems to be missing.

OK.

> > -	if (slub_debug && (!slub_debug_slabs || (name &&
> > -		!strncmp(slub_debug_slabs, name, strlen(slub_debug_slabs)))))
> > -		flags |= slub_debug;
> > +
> > +	char *end, *n, *glob;
> 
> `end' and `glob' could be local to the loop which uses them, which I
> find a bit nicer.

OK.

> `n' is a rotten identifier.  Can't we think of something which
> communicates meaning?

OK.

> > +	int len = strlen(name);
> > +
> > +	/* If slub_debug = 0, it folds into the if conditional. */
> > +	if (!slub_debug_slabs)
> > +		return flags | slub_debug;
> 
> If we take the above return, the call to strlen() was wasted cycles. 
> Presumably gcc is smart enough to prevent that, but why risk it.

OK.

> > +	n = slub_debug_slabs;
> > +	while (*n) {
> > +		int cmplen;
> > +
> > +		end = strchr(n, ',');
> > +		if (!end)
> > +			end = n + strlen(n);
> > +
> > +		glob = strnchr(n, end - n, '*');
> > +		if (glob)
> > +			cmplen = glob - n;
> > +		else
> > +			cmplen = max(len, (int)(end - n));
> 
> max_t() exists for this.  Or maybe make `len' size_t, but I expect that
> will still warn - that subtraction returns a ptrdiff_t, yes?

I think max_t(size_t, ...) should be appropriate?

I'll address the above and in the next version.


> > +
> > +		if (!strncmp(name, n, cmplen)) {
> > +			flags |= slub_debug;
> > +			break;
> > +		}
> > +
> > +		if (!*end)
> > +			break;
> > +		n = end + 1;
> > +	}
> The code in this loop hurts my brain a bit. I hope it's correct ;)

It works :)



-- 
Aaron Tomlin
