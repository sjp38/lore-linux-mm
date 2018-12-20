Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9428E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:41:35 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so2365231edd.16
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 05:41:35 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id s16si5737310edd.300.2018.12.20.05.41.33
        for <linux-mm@kvack.org>;
        Thu, 20 Dec 2018 05:41:33 -0800 (PST)
Date: Thu, 20 Dec 2018 14:41:32 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220134132.6ynretwlndmyupml@d104.suse.de>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
 <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
 <20181220091228.GB14234@dhcp22.suse.cz>
 <20181220124925.itwuuacgztpgsk7s@d104.suse.de>
 <20181220130606.GG9104@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220130606.GG9104@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2018 at 02:06:06PM +0100, Michal Hocko wrote:
> On Thu 20-12-18 13:49:28, Oscar Salvador wrote:
> > On Thu, Dec 20, 2018 at 10:12:28AM +0100, Michal Hocko wrote:
> > > > <--
> > > > skip_pages = (1 << compound_order(head)) - (page - head);
> > > > iter = skip_pages - 1;
> > > > --
> > > > 
> > > > which looks more simple IMHO.
> > > 
> > > Agreed!
> > 
> > Andrew, can you please apply the next diff chunk on top of the patch:
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 4812287e56a0..978576d93783 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -8094,7 +8094,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> >  				goto unmovable;
> >  
> >  			skip_pages = (1 << compound_order(head)) - (page - head);
> > -			iter = round_up(iter + 1, skip_pages) - 1;
> > +			iter = skip_pages - 1;
> 
> You did want iter += skip_pages - 1 here right?

Bleh, yeah.
I am taking vacation today so my brain has left me hours ago, sorry.
Should be:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4812287e56a0..0634fbdef078 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8094,7 +8094,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
                                goto unmovable;
 
                        skip_pages = (1 << compound_order(head)) - (page - head);
-                       iter = round_up(iter + 1, skip_pages) - 1;
+                       iter += skip_pages - 1;
                        continue;
                }


-- 
Oscar Salvador
SUSE L3
