Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 290006B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 02:17:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a136so5238812wme.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 23:17:29 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id e127si21438266wmd.83.2016.05.23.23.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 23:17:27 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q62so2853194wmg.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 23:17:27 -0700 (PDT)
Date: Tue, 24 May 2016 08:17:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, migrate: increment fail count on ENOMEM
Message-ID: <20160524061724.GA8259@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1605191510230.32658@chino.kir.corp.google.com>
 <20160520130649.GB5197@dhcp22.suse.cz>
 <573F0ED0.4010908@suse.cz>
 <20160520133121.GB5215@dhcp22.suse.cz>
 <20160523150202.70702708ce323b36ad94cbab@linux-foundation.org>
 <alpine.LSU.2.11.1605231618360.22555@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1605231618360.22555@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 23-05-16 16:32:56, Hugh Dickins wrote:
> On Mon, 23 May 2016, Andrew Morton wrote:
> > On Fri, 20 May 2016 15:31:21 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > > On Fri 20-05-16 15:19:12, Vlastimil Babka wrote:
> > > > On 05/20/2016 03:06 PM, Michal Hocko wrote:
> > > [...]
> > > > > Why don't we need also to count also retries?
> > > > 
> > > > We could, but not like you suggest.
> > > > 
> > > > > ---
> > > > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > > > index 53ab6398e7a2..ef9c5211ae3c 100644
> > > > > --- a/mm/migrate.c
> > > > > +++ b/mm/migrate.c
> > > > > @@ -1190,9 +1190,9 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> > > > >   			}
> > > > >   		}
> > > > >   	}
> > > > > +out:
> > > > >   	nr_failed += retry;
> > > > >   	rc = nr_failed;
> > > > 
> > > > This overwrites rc == -ENOMEM, which at least compaction needs to recognize.
> > > > But we could duplicate "nr_failed += retry" in the case -ENOMEM.
> > > 
> > > Right you are. So we should do
> > > ---
> > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > index 53ab6398e7a2..123fed94022b 100644
> > > --- a/mm/migrate.c
> > > +++ b/mm/migrate.c
> > > @@ -1171,6 +1171,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> > >  
> > >  			switch(rc) {
> > >  			case -ENOMEM:
> > > +				nr_failed += retry + 1;
> > >  				goto out;
> > >  			case -EAGAIN:
> > >  				retry++;
> > > 	
> > > 
> > 
> > argh, this was lost.  Please resend as a real patch sometime?
> 
> It's not correct.  "retry" is reset to 0 each time around the
> loop, and it's only a meaningful number to add on to nr_failed, in
> the case when we've gone through the whole list: not in this "goto
> out" case. 

You are right! I've missed that, my bad.

> We could add another loop to count how many are left
> when we hit -ENOMEM, and add that on to nr_failed; but I'm not
> convinced that it's worth the bother.

Agreed!

Sorry about the noise!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
