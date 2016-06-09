Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61C796B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 19:30:38 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id lp2so73715736igb.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 16:30:38 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id q16si22129313itc.78.2016.06.09.16.30.36
        for <linux-mm@kvack.org>;
        Thu, 09 Jun 2016 16:30:36 -0700 (PDT)
Date: Fri, 10 Jun 2016 08:31:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix build warnings in <linux/compaction.h>
Message-ID: <20160609233143.GC29779@bbox>
References: <5759A1F9.2070302@infradead.org>
 <20160609152716.1093ada2f52bbcc426e6ddb6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160609152716.1093ada2f52bbcc426e6ddb6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, Linux MM <linux-mm@kvack.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

Hi Andrew,

On Thu, Jun 09, 2016 at 03:27:16PM -0700, Andrew Morton wrote:
> On Thu, 9 Jun 2016 10:06:01 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> 
> > From: Randy Dunlap <rdunlap@infradead.org>
> > 
> > Fix build warnings when struct node is not defined:
> > 
> > In file included from ../include/linux/balloon_compaction.h:48:0,
> >                  from ../mm/balloon_compaction.c:11:
> > ../include/linux/compaction.h:237:51: warning: 'struct node' declared inside parameter list [enabled by default]
> >  static inline int compaction_register_node(struct node *node)
> > ../include/linux/compaction.h:237:51: warning: its scope is only this definition or declaration, which is probably not what you want [enabled by default]
> > ../include/linux/compaction.h:242:54: warning: 'struct node' declared inside parameter list [enabled by default]
> >  static inline void compaction_unregister_node(struct node *node)
> > 
> > ...
> >
> > --- linux-next-20160609.orig/include/linux/compaction.h
> > +++ linux-next-20160609/include/linux/compaction.h
> > @@ -233,6 +233,7 @@ extern int compaction_register_node(stru
> >  extern void compaction_unregister_node(struct node *node);
> >  
> >  #else
> > +struct node;
> >  
> >  static inline int compaction_register_node(struct node *node)
> >  {
> 
> Well compaction.h has no #includes at all and obviously depends on its
> including file(s) to bring in the definitions which it needs.
> 
> So if we want to keep that (odd) model then we should fix
> mm-balloon-use-general-non-lru-movable-page-feature.patch thusly:

How about fixing such odd model in this chance?
Otherwise, every non-lru page migration driver should include
both compaction.h and node.h which is weired to me. :(

I think there are two ways.

1. compaction.h include node.h directly so user of compaction.h don't
need to take care about node.h

2. Randy's fix

I looked up who use compaction_[un]register_node and found it's used
only drivers/base/node.c which already include node.h so no problem.

1) I believe it's rare those functions to be needed by other files.
2) Those functions works if CONFIG_NUMA as well as CONFIG_COMPACTION
which is rare configuration for many not-server system.

So, I prefer Randy's fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
