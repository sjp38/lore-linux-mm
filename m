Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 328666B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 04:46:05 -0400 (EDT)
Received: by widdi4 with SMTP id di4so9407670wid.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 01:46:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m1si2876849wjy.52.2015.04.30.01.46.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 01:46:03 -0700 (PDT)
Date: Thu, 30 Apr 2015 09:45:58 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/13] mm: meminit: Initialise a subset of struct pages
 if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
Message-ID: <20150430084558.GV2449@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <1430231830-7702-8-git-send-email-mgorman@suse.de>
 <20150429141901.df10d11cc8fa2d5df377922f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150429141901.df10d11cc8fa2d5df377922f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 29, 2015 at 02:19:01PM -0700, Andrew Morton wrote:
> On Tue, 28 Apr 2015 15:37:04 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > +/*
> > + * Deferred struct page initialisation requires some early init functions that
> > + * are removed before kswapd is up and running. The feature depends on memory
> > + * hotplug so put the data and code required by deferred initialisation into
> > + * the __meminit section where they are preserved.
> > + */
> > +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> > +#define __defermem_init __meminit
> > +#define __defer_init    __meminit
> > +#else
> > +#define __defermem_init
> > +#define __defer_init __init
> > +#endif
> 
> I still don't get it :(
> 

This version was sent out at roughly the same minute you asked the time
before so the comment was not updated. I suggested this as a possible
alternative.

/*
 * Deferred struct page initialisation requires init functions that are freed
 * before kswapd is available. Reuse the memory hotplug section annotation
 * to mark the required code.
 *
 * __defermem_init is code that always exists but is annotated __meminit * to
 *      avoid section warnings.
 * __defer_init code gets marked __meminit when deferring struct page
 *      initialistion but is otherwise in the init section.
 */

Suggestions on better names are welcome.

> __defermem_init:
> 
> 	if (CONFIG_DEFERRED_STRUCT_PAGE_INIT) {
> 		if (CONFIG_MEMORY_HOTPLUG)
> 			retain
> 	} else {
> 		retain
> 	}
> 
>     but CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on
>     CONFIG_MEMORY_HOTPLUG, so this becomes
> 
> 	if (CONFIG_DEFERRED_STRUCT_PAGE_INIT) {
> 		retain
> 	} else {
> 		retain
> 	}
> 
>     which becomes
> 
> 	retain
> 
>     so why does __defermem_init exist?
> 

It suppresses section warnings. Another possibility is that I get rid of
it entirely and use __refok but I feared that it might hide a real problem
in the future.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
