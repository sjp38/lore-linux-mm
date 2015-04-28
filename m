Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A714F6B006C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:41:37 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so164322157pdb.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 06:41:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gy10si24455150pbd.243.2015.04.28.06.41.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 06:41:36 -0700 (PDT)
Date: Tue, 28 Apr 2015 06:48:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/13] mm: meminit: Initialise a subset of struct pages
 if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
Message-Id: <20150428064810.0882ad36.akpm@linux-foundation.org>
In-Reply-To: <20150428095323.GK2449@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
	<1429785196-7668-8-git-send-email-mgorman@suse.de>
	<20150427154344.421fd9f151bf27d365d02fd2@linux-foundation.org>
	<20150428095323.GK2449@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 28 Apr 2015 10:53:23 +0100 Mel Gorman <mgorman@suse.de> wrote:

> > > +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> > > +#define __defermem_init __meminit
> > > +#define __defer_init    __meminit
> > > +#else
> > > +#define __defermem_init
> > > +#define __defer_init __init
> > > +#endif
> > 
> > Could we get some comments describing these?  What they do, when and
> > where they should be used.  I have a suspicion that the naming isn't
> > good, but I didn't spend a lot of time reverse-engineering the
> > intent...
> > 
> 
> Of course. The next version will have
> 
> +/*
> + * Deferred struct page initialisation requires some early init functions that
> + * are removed before kswapd is up and running. The feature depends on memory
> + * hotplug so put the data and code required by deferred initialisation into 
> + * the __meminit section where they are preserved.
> + */

I'm still not getting it even a little bit :(  You say "data and code",
so I'd expect to see

#define __defer_meminitdata __meminitdata
#define __defer_meminit __meminit

But the patch doesn't mention the data segment at all.

The patch uses both __defermem_init and __defer_init to tag functions
(ie: text) and I can't work out why.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
