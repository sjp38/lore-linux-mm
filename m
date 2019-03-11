Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A64E5C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 16:37:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66F5E205F4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 16:37:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="RUl5P7Bl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66F5E205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 024F58E0004; Mon, 11 Mar 2019 12:37:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F17C18E0002; Mon, 11 Mar 2019 12:37:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E06F98E0004; Mon, 11 Mar 2019 12:37:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B6C688E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:37:13 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o56so5788835qto.9
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 09:37:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=G27fHy4oX6lVvV0AJGT0kD4xGV/ixARd1cxmGlNoTEs=;
        b=NI3uGcyBG5d9DnCSQUEhGCr7/HwA6CzKFiOrcSwWkfruH6MxA1OdITreD7MR/GWu8g
         VUbG1gDpf2sENlPwgXhmTAPLis0S9SJb/CObG8/7DVLrBtn74zonQbCfFBVOHIXKawMu
         iEoektSkZnRugL2BjWK6RvMoi3q/RG5/ZmLLgXqjo7I13Sfa+sc43ZIXplxoCYHukN1d
         VRx9AEt+k/P/KV80ysinEwRt8cv/eyNMy91LYjkxr44UI0CiaWVSDmwf+Z5z20OKiheo
         rwM1euMmrXL2gNtL4PgdvXuRlV7j2L1lvszmLy9urJpLo/jN3LM8F7+qO5YKTvyJVbFE
         dCdg==
X-Gm-Message-State: APjAAAUHkdezaOtFIwgrqqd86KRcApdqeHxp7v/DoJGDlYbmtbOr6oqD
	y6EjDXpCcFrPTtKPlhcL4w31QQuFdfuit3biyDO1mb2E/KCNJVOtwatcfO3qJyB47mJgUyK10W9
	2SvK2woNhQsKvRY+F/3cYz7fZKvhnLEiJyNgwnvFp7AFaPv/7AucgTu1t0SOMmswu5XfU/yj9Mx
	y0mw2+qbsQXLo7yty0Lg1brDMu9uUTQvlUU3XYOSOiOMl/M5f6JvRG/1ATT8mr+8+UC6MnYgOHb
	T5ihujnaVtSJg2MyWfACgdOvfC1S5J6+pVSwtVj4cVcxIXE5qSKATsMVzUoYYtmQedUORnA+eGD
	8EtcmbxEqU23TxhQv3piiEg74U/R2hLK3flqXvToLkDBPvp1Ec/9FKsm+f54LiUxE5j+nfZOI2j
	6
X-Received: by 2002:ae9:ea13:: with SMTP id f19mr17553711qkg.135.1552322233530;
        Mon, 11 Mar 2019 09:37:13 -0700 (PDT)
X-Received: by 2002:ae9:ea13:: with SMTP id f19mr17553666qkg.135.1552322232761;
        Mon, 11 Mar 2019 09:37:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552322232; cv=none;
        d=google.com; s=arc-20160816;
        b=xhwEB/bYtbKabKlCB5gGLZIihL6aTob8VDoIQSALDqGPcPsdSfY11Wi5GjAKwBJh1r
         K6fuh/bv4X/DdJGX2OuScKXTJZSfV6gtr7JfnB1rmkerBBo6PMRp1a25Kt8cmCnuvvS/
         kUk+iexVfXXKWARMP84GwUphB4ciE8P+JWXDyy5GmD8VhbaKyY0QY0JM94jbGSkfQ1dN
         2os8wxHCmtKNlN/2WcJSqz+b+HUJcHJsQFbe/5FhZPZG/dFe7UIer6ioUzMR3WhDASxf
         HFvxAr+paAExnacbXdCAuhro0wxmjWGwGXdrZTvW5tHqUN2T1fmUQdvjrQc7SFyZa6Ha
         HS/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=G27fHy4oX6lVvV0AJGT0kD4xGV/ixARd1cxmGlNoTEs=;
        b=vFq31ag/jq/0VlqKjX+vCJec4V+tI4bZ5p0RzjFFVE9UX2qfA8cOFaOd19ESLOzNUu
         mLVjNnZvRJgpgqPfgTKlUoYcN0EeI77YIJ1g0gk1+0TUsd8Aq2M6DmxJFIKd9ZN7VHfo
         7WeDfg46rBv7uW8HHrWuQQzMLBSp4pVPR73kNkBkS+BzB+cQXv6x6urJxMnkrNrBFyAz
         k3L2EqvtIfj8IeG0Ko7JYjXBwjBqLf7MNCHqWpUMrP1kCKD6g5H/dE7kYOZDN8g6PFhd
         Qli1jPA0RRH62c46gnvMB0pctsetCrcIZXlxzTXqP+FDWFVWPIlVnKgAFA8kEOH2jGZ5
         Ireg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=RUl5P7Bl;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r46sor4746542qvj.46.2019.03.11.09.37.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 09:37:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=RUl5P7Bl;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=G27fHy4oX6lVvV0AJGT0kD4xGV/ixARd1cxmGlNoTEs=;
        b=RUl5P7Blvh5Vjd1STtbCd0DJ2LW8Ekj48hesKpURIwtD0KTGXrQWOfplvH+jDXSaqM
         IJNnrRxS8R9X/RxSzE36dSwSLDNBUgUsjweaiQyAWWyx5NCH5vju+KzSG+MIv4RyH3OW
         Y2G4tcWDhiMBxXaMF1v9PuGSrkLYLHl8jaEz8=
X-Google-Smtp-Source: APXvYqznvEKmcXKhClZinaN40B17zN0KWGOs1yBTG0qLudTRViQAXn4RMBDPBw62it/E4rkoGIpYkQ==
X-Received: by 2002:a0c:ac93:: with SMTP id m19mr26410101qvc.27.1552322232394;
        Mon, 11 Mar 2019 09:37:12 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id c2sm4667103qtc.41.2019.03.11.09.37.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 09:37:11 -0700 (PDT)
Date: Mon, 11 Mar 2019 12:37:10 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org,
	devel@driverdev.osuosl.org, linux-mm@kvack.org,
	Suren Baghdasaryan <surenb@google.com>,
	Tim Murray <timmurray@google.com>, mhocko@kernel.org,
	vbabka@suse.cz, hannes@cmpxchg.org
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190311163710.GA72600@google.com>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311163233.GA34252@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311163233.GA34252@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 12:32:33PM -0400, Joel Fernandes wrote:
> On Sun, Mar 10, 2019 at 01:34:03PM -0700, Sultan Alsawaf wrote:
> [...]
> >  
> >  	/* Perform scheduler related setup. Assign this task to a CPU. */
> >  	retval = sched_fork(clone_flags, p);
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 3eb01dedf..fd0d697c6 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -67,6 +67,7 @@
> >  #include <linux/lockdep.h>
> >  #include <linux/nmi.h>
> >  #include <linux/psi.h>
> > +#include <linux/simple_lmk.h>
> >  
> >  #include <asm/sections.h>
> >  #include <asm/tlbflush.h>
> > @@ -967,6 +968,11 @@ static inline void __free_one_page(struct page *page,
> >  		}
> >  	}
> >  
> > +#ifdef CONFIG_ANDROID_SIMPLE_LMK
> > +	if (simple_lmk_page_in(page, order, migratetype))
> > +		return;
> > +#endif
> > +
> >  	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
> >  out:
> >  	zone->free_area[order].nr_free++;
> > @@ -4427,6 +4433,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	if (costly_order && !(gfp_mask & __GFP_RETRY_MAYFAIL))
> >  		goto nopage;
> >  
> > +#ifdef CONFIG_ANDROID_SIMPLE_LMK
> > +	page = simple_lmk_oom_alloc(order, ac->migratetype);
> > +	if (page)
> > +		prep_new_page(page, order, gfp_mask, alloc_flags);
> > +	goto got_pg;
> > +#endif
> > +
> 
> Hacking generic MM code with Android-specific callback is probably a major
> issue with your patch.
>
> Also I CC'd -mm maintainers and lists since your patch
> touches page_alloc.c. Always run get_maintainer.pl before sending a patch. I
> added them this time.

I see you CC'd linux-mm on your initial patch, so I apologize. Ignore this
part of my reply. Thanks.



> Have you looked at the recent PSI work that Suren and Johannes have been
> doing [1]?  As I understand, userspace lmkd may be migrated to use that at some
> point.  Suren can provide more details. I am sure AOSP contributions to make
> LMKd better by using the PSI backend would be appreciated. Please consider
> collaborating on that and help out, thanks. Check the cover-letter of that
> patch [1] where LMKd is mentioned.
 

