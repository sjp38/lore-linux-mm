Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 15FAA6B006E
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:56:37 -0400 (EDT)
Received: by wgen6 with SMTP id n6so154363038wge.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:56:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ez17si38857399wjc.157.2015.04.28.07.56.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 07:56:35 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:56:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/13] mm: meminit: Initialise a subset of struct pages
 if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
Message-ID: <20150428145632.GN2449@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
 <1429785196-7668-8-git-send-email-mgorman@suse.de>
 <20150427154344.421fd9f151bf27d365d02fd2@linux-foundation.org>
 <20150428095323.GK2449@suse.de>
 <20150428064810.0882ad36.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150428064810.0882ad36.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 28, 2015 at 06:48:10AM -0700, Andrew Morton wrote:
> On Tue, 28 Apr 2015 10:53:23 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > > > +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> > > > +#define __defermem_init __meminit
> > > > +#define __defer_init    __meminit
> > > > +#else
> > > > +#define __defermem_init
> > > > +#define __defer_init __init
> > > > +#endif
> > > 
> > > Could we get some comments describing these?  What they do, when and
> > > where they should be used.  I have a suspicion that the naming isn't
> > > good, but I didn't spend a lot of time reverse-engineering the
> > > intent...
> > > 
> > 
> > Of course. The next version will have
> > 
> > +/*
> > + * Deferred struct page initialisation requires some early init functions that
> > + * are removed before kswapd is up and running. The feature depends on memory
> > + * hotplug so put the data and code required by deferred initialisation into 
> > + * the __meminit section where they are preserved.
> > + */
> 
> I'm still not getting it even a little bit :(  You say "data and code",
> so I'd expect to see
> 
> #define __defer_meminitdata __meminitdata
> #define __defer_meminit __meminit
> 
> But the patch doesn't mention the data segment at all.
> 

Take 2. Suggestions on different names are welcome because they are poor.

/*
 * Deferred struct page initialisation requires init functions that are freed
 * before kswapd is available. Reuse the memory hotplug section annotation
 * to mark the required code.
 *
 * __defermem_init is code that always exists but is annotated __meminit to
 *      avoid section warnings.
 * __defer_init code gets marked __meminit when deferring struct page
 *      initialistion but is otherwise in the init section.
 */


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
