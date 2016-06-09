Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D82B56B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 19:50:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so86523157pfa.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 16:50:38 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id r26si10008290pfa.108.2016.06.09.16.50.29
        for <linux-mm@kvack.org>;
        Thu, 09 Jun 2016 16:50:34 -0700 (PDT)
Date: Fri, 10 Jun 2016 08:51:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix build warnings in <linux/compaction.h>
Message-ID: <20160609235141.GD29779@bbox>
References: <5759A1F9.2070302@infradead.org>
 <20160609152716.1093ada2f52bbcc426e6ddb6@linux-foundation.org>
 <20160609233143.GC29779@bbox>
 <20160609163719.5af286badfa9b5314700fece@linux-foundation.org>
MIME-Version: 1.0
In-Reply-To: <20160609163719.5af286badfa9b5314700fece@linux-foundation.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, Linux MM <linux-mm@kvack.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Thu, Jun 09, 2016 at 04:37:19PM -0700, Andrew Morton wrote:
> On Fri, 10 Jun 2016 08:31:43 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Hi Andrew,
> > 
> > On Thu, Jun 09, 2016 at 03:27:16PM -0700, Andrew Morton wrote:
> > > On Thu, 9 Jun 2016 10:06:01 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> > > 
> > > > From: Randy Dunlap <rdunlap@infradead.org>
> > > > 
> > > > Fix build warnings when struct node is not defined:
> > > > 
> > > > In file included from ../include/linux/balloon_compaction.h:48:0,
> > > >                  from ../mm/balloon_compaction.c:11:
> > > > ../include/linux/compaction.h:237:51: warning: 'struct node' declared inside parameter list [enabled by default]
> > > >  static inline int compaction_register_node(struct node *node)
> > > > ../include/linux/compaction.h:237:51: warning: its scope is only this definition or declaration, which is probably not what you want [enabled by default]
> > > > ../include/linux/compaction.h:242:54: warning: 'struct node' declared inside parameter list [enabled by default]
> > > >  static inline void compaction_unregister_node(struct node *node)
> > > > 
> > > > ...
> > > >
> > > > --- linux-next-20160609.orig/include/linux/compaction.h
> > > > +++ linux-next-20160609/include/linux/compaction.h
> > > > @@ -233,6 +233,7 @@ extern int compaction_register_node(stru
> > > >  extern void compaction_unregister_node(struct node *node);
> > > >  
> > > >  #else
> > > > +struct node;
> > > >  
> > > >  static inline int compaction_register_node(struct node *node)
> > > >  {
> > > 
> > > Well compaction.h has no #includes at all and obviously depends on its
> > > including file(s) to bring in the definitions which it needs.
> > > 
> > > So if we want to keep that (odd) model then we should fix
> > > mm-balloon-use-general-non-lru-movable-page-feature.patch thusly:
> > 
> > How about fixing such odd model in this chance?
> > Otherwise, every non-lru page migration driver should include
> > both compaction.h and node.h which is weired to me. :(
> > 
> > I think there are two ways.
> > 
> > 1. compaction.h include node.h directly so user of compaction.h don't
> > need to take care about node.h
> > 
> > 2. Randy's fix
> > 
> > I looked up who use compaction_[un]register_node and found it's used
> > only drivers/base/node.c which already include node.h so no problem.
> > 
> > 1) I believe it's rare those functions to be needed by other files.
> > 2) Those functions works if CONFIG_NUMA as well as CONFIG_COMPACTION
> > which is rare configuration for many not-server system.
> 
> If we're going to convert compaction.h to be standalone then it will
> need to include a whole bunch of things - what's special about node.h?

Fair enough.
I realize it would be better to relocate non-lru page migration functions to
new separate header but I don't have an good idea to name that file. :(
Anyway, I will work for it.

> 
> > So, I prefer Randy's fix.
> 
> Doesn't matter much.  But note that Randy's patch declared struct node
> at line 233.  It should be sone at approximatley line 1, to prevent
> future duplicated declarations.

with removing 218 forward declaration 'struct node;' by me. ;(
I'm okay either approach until I fix the problem by introducing new header
for non-lru page migration.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
