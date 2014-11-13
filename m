Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id ED7996B00DF
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 15:40:38 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id h15so396052igd.8
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 12:40:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z10si41782453icm.74.2014.11.13.12.40.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Nov 2014 12:40:37 -0800 (PST)
Date: Thu, 13 Nov 2014 12:40:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/5] mm/page_ext: resurrect struct page extending
 code for debugging
Message-Id: <20141113124035.35bc5bb743affddf7f425825@linux-foundation.org>
In-Reply-To: <20141113064035.GB18369@js1304-P5Q-DELUXE>
References: <1415780835-24642-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1415780835-24642-2-git-send-email-iamjoonsoo.kim@lge.com>
	<54638BE4.3080509@sr71.net>
	<20141113064035.GB18369@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Dave Hansen <dave@sr71.net>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Alexander Nyberg <alexn@dsv.su.se>, Dave Hansen <dave@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 13 Nov 2014 15:40:35 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Wed, Nov 12, 2014 at 08:33:40AM -0800, Dave Hansen wrote:
> > On 11/12/2014 12:27 AM, Joonsoo Kim wrote:
> > > @@ -1092,6 +1096,14 @@ struct mem_section {
> > >  
> > >  	/* See declaration of similar field in struct zone */
> > >  	unsigned long *pageblock_flags;
> > > +#ifdef CONFIG_PAGE_EXTENSION
> > > +	/*
> > > +	 * If !SPARSEMEM, pgdat doesn't have page_ext pointer. We use
> > > +	 * section. (see page_ext.h about this.)
> > > +	 */
> > > +	struct page_ext *page_ext;
> > > +	unsigned long pad;
> > > +#endif
> > 
> > Will the distributions be amenable to enabling this?  If so, I'm all for
> > it if it gets us things like page_owner at runtime.
> 
> Yes, I hope so.
> At least, I can make it default to our product. But, how distributions
> will do is beyond my power. :)
> 

>From my reading of the code, the overhead is very low if nobody is
using it.  In which case things should be OK and we can perhaps do away
with CONFIG_PAGE_EXTENSION altogether.

But my reading of the code may be wrong.  It is very poorly documented.
As far as I can tell, invoke_need_callbacks() works out whether there
are any clients of this feature and if not, we avoid allocating that
huge chunk of memory.

And the way we register clients is to enter a pointer into the global
page_ext_ops[].  So this requires a kernel rebuild anyway, so there's
no point in distros enabling CONFIG_PAGE_EXTENSION.  The way to do this
is for CONFIG_PAGE_OWNER (for example) to `select'
CONFIG_PAGE_EXTENSION.

It's unclear to me why invoke_need_callbacks() walks the page_ext_ops[]
entries, inspecting them.  Perhaps this is so that clients of
CONFIG_PAGE_EXTENSION can be enabled/disabled at boot time, dunno.

Please, can we get all this design and behaviour appropriately
documented in the code and changelogs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
