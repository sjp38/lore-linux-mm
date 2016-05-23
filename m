Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB54C6B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 19:39:35 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id dr7so838411pac.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 16:39:35 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id n65si55265952pfn.76.2016.05.23.16.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 16:39:34 -0700 (PDT)
Received: by mail-pa0-x22c.google.com with SMTP id tb2so226430pac.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 16:39:34 -0700 (PDT)
Date: Mon, 23 May 2016 16:32:56 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mm, migrate: increment fail count on ENOMEM
In-Reply-To: <20160523150202.70702708ce323b36ad94cbab@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1605231618360.22555@eggly.anvils>
References: <alpine.DEB.2.10.1605191510230.32658@chino.kir.corp.google.com> <20160520130649.GB5197@dhcp22.suse.cz> <573F0ED0.4010908@suse.cz> <20160520133121.GB5215@dhcp22.suse.cz> <20160523150202.70702708ce323b36ad94cbab@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 23 May 2016, Andrew Morton wrote:
> On Fri, 20 May 2016 15:31:21 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 20-05-16 15:19:12, Vlastimil Babka wrote:
> > > On 05/20/2016 03:06 PM, Michal Hocko wrote:
> > [...]
> > > > Why don't we need also to count also retries?
> > > 
> > > We could, but not like you suggest.
> > > 
> > > > ---
> > > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > > index 53ab6398e7a2..ef9c5211ae3c 100644
> > > > --- a/mm/migrate.c
> > > > +++ b/mm/migrate.c
> > > > @@ -1190,9 +1190,9 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> > > >   			}
> > > >   		}
> > > >   	}
> > > > +out:
> > > >   	nr_failed += retry;
> > > >   	rc = nr_failed;
> > > 
> > > This overwrites rc == -ENOMEM, which at least compaction needs to recognize.
> > > But we could duplicate "nr_failed += retry" in the case -ENOMEM.
> > 
> > Right you are. So we should do
> > ---
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 53ab6398e7a2..123fed94022b 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1171,6 +1171,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> >  
> >  			switch(rc) {
> >  			case -ENOMEM:
> > +				nr_failed += retry + 1;
> >  				goto out;
> >  			case -EAGAIN:
> >  				retry++;
> > 	
> > 
> 
> argh, this was lost.  Please resend as a real patch sometime?

It's not correct.  "retry" is reset to 0 each time around the
loop, and it's only a meaningful number to add on to nr_failed, in
the case when we've gone through the whole list: not in this "goto
out" case.  We could add another loop to count how many are left
when we hit -ENOMEM, and add that on to nr_failed; but I'm not
convinced that it's worth the bother.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
