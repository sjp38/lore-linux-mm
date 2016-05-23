Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 149BB6B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 18:02:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so384854725pfy.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 15:02:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j2si1071213paw.80.2016.05.23.15.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 15:02:03 -0700 (PDT)
Date: Mon, 23 May 2016 15:02:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, migrate: increment fail count on ENOMEM
Message-Id: <20160523150202.70702708ce323b36ad94cbab@linux-foundation.org>
In-Reply-To: <20160520133121.GB5215@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1605191510230.32658@chino.kir.corp.google.com>
	<20160520130649.GB5197@dhcp22.suse.cz>
	<573F0ED0.4010908@suse.cz>
	<20160520133121.GB5215@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 20 May 2016 15:31:21 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 20-05-16 15:19:12, Vlastimil Babka wrote:
> > On 05/20/2016 03:06 PM, Michal Hocko wrote:
> [...]
> > > Why don't we need also to count also retries?
> > 
> > We could, but not like you suggest.
> > 
> > > ---
> > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > index 53ab6398e7a2..ef9c5211ae3c 100644
> > > --- a/mm/migrate.c
> > > +++ b/mm/migrate.c
> > > @@ -1190,9 +1190,9 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> > >   			}
> > >   		}
> > >   	}
> > > +out:
> > >   	nr_failed += retry;
> > >   	rc = nr_failed;
> > 
> > This overwrites rc == -ENOMEM, which at least compaction needs to recognize.
> > But we could duplicate "nr_failed += retry" in the case -ENOMEM.
> 
> Right you are. So we should do
> ---
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 53ab6398e7a2..123fed94022b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1171,6 +1171,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  
>  			switch(rc) {
>  			case -ENOMEM:
> +				nr_failed += retry + 1;
>  				goto out;
>  			case -EAGAIN:
>  				retry++;
> 	
> 

argh, this was lost.  Please resend as a real patch sometime?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
