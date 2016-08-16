Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4ABA76B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 06:12:05 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id f123so157555553ywd.2
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 03:12:05 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id n2si20503252wjh.243.2016.08.16.03.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Aug 2016 03:12:04 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id q128so15548621wma.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 03:12:04 -0700 (PDT)
Date: Tue, 16 Aug 2016 12:12:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/6] Reduce memory waste by page extension user
Message-ID: <20160816101202.GD17417@dhcp22.suse.cz>
References: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160816095300.GC17417@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160816095300.GC17417@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue 16-08-16 11:53:00, Michal Hocko wrote:
> On Tue 16-08-16 11:51:13, Joonsoo Kim wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > v2:
> > Fix rebase mistake (per Vlastimil)
> > Rename some variable/function to prevent confusion (per Vlastimil)
> > Fix header dependency (per Sergey)
> > 
> > This patchset tries to reduce memory waste by page extension user.
> > 
> > First case is architecture supported debug_pagealloc. It doesn't
> > requires additional memory if guard page isn't used. 8 bytes per
> > page will be saved in this case.
> > 
> > Second case is related to page owner feature. Until now, if page_ext
> > users want to use it's own fields on page_ext, fields should be
> > defined in struct page_ext by hard-coding. It has a following problem.
> > 
> > struct page_ext {
> >  #ifdef CONFIG_A
> > 	int a;
> >  #endif
> >  #ifdef CONFIG_B
> > 	int b;
> >  #endif
> > };
> > 
> > Assume that kernel is built with both CONFIG_A and CONFIG_B.
> > Even if we enable feature A and doesn't enable feature B at runtime,
> > each entry of struct page_ext takes two int rather than one int.
> > It's undesirable waste so this patch tries to reduce it. By this patchset,
> > we can save 20 bytes per page dedicated for page owner feature
> > in some configurations.
> 
> FWIW I like this. I have only glanced over those patches so I do not
> feel comfortable to give my a-b but the approach is sensible and the
> memory savings are really attractive. Page owner is a really great
> debugging feauture so enabling it makes a lot of sense on production
> servers where the memory wasting is a no-go.

OK, I have missed that page_ext is only allocated if there is at least
one feature which requires it enabled. So normally there shouldn't be
too much of wasted memory. Anyway allocating per feature makes a lot of
sense regardless.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
