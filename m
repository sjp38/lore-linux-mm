Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2A26B0262
	for <linux-mm@kvack.org>; Fri, 20 May 2016 09:31:25 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id m138so10015526lfm.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 06:31:25 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id y88si4633565wmh.72.2016.05.20.06.31.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 06:31:23 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id q62so1069408wmg.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 06:31:23 -0700 (PDT)
Date: Fri, 20 May 2016 15:31:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, migrate: increment fail count on ENOMEM
Message-ID: <20160520133121.GB5215@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1605191510230.32658@chino.kir.corp.google.com>
 <20160520130649.GB5197@dhcp22.suse.cz>
 <573F0ED0.4010908@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573F0ED0.4010908@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 20-05-16 15:19:12, Vlastimil Babka wrote:
> On 05/20/2016 03:06 PM, Michal Hocko wrote:
[...]
> > Why don't we need also to count also retries?
> 
> We could, but not like you suggest.
> 
> > ---
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 53ab6398e7a2..ef9c5211ae3c 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1190,9 +1190,9 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> >   			}
> >   		}
> >   	}
> > +out:
> >   	nr_failed += retry;
> >   	rc = nr_failed;
> 
> This overwrites rc == -ENOMEM, which at least compaction needs to recognize.
> But we could duplicate "nr_failed += retry" in the case -ENOMEM.

Right you are. So we should do
---
diff --git a/mm/migrate.c b/mm/migrate.c
index 53ab6398e7a2..123fed94022b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1171,6 +1171,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 
 			switch(rc) {
 			case -ENOMEM:
+				nr_failed += retry + 1;
 				goto out;
 			case -EAGAIN:
 				retry++;
	

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
