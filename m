Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 58F276B0038
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 13:11:47 -0500 (EST)
Received: by ykdr82 with SMTP id r82so78016616ykd.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:11:47 -0800 (PST)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id q8si3707844ywb.43.2015.11.18.10.11.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 10:11:46 -0800 (PST)
Received: by ykdr82 with SMTP id r82so78016303ykd.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:11:46 -0800 (PST)
Date: Wed, 18 Nov 2015 13:11:42 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] writeback: initialize m_dirty to avoid compile warning
Message-ID: <20151118181142.GC11496@mtj.duckdns.org>
References: <1447439201-32009-1-git-send-email-yang.shi@linaro.org>
 <20151117153855.99d2acd0568d146c29defda5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151117153855.99d2acd0568d146c29defda5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yang Shi <yang.shi@linaro.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

Hello,

On Tue, Nov 17, 2015 at 03:38:55PM -0800, Andrew Morton wrote:
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -1542,7 +1542,7 @@ static void balance_dirty_pages(struct address_space *mapping,
> >  	for (;;) {
> >  		unsigned long now = jiffies;
> >  		unsigned long dirty, thresh, bg_thresh;
> > -		unsigned long m_dirty, m_thresh, m_bg_thresh;
> > +		unsigned long m_dirty = 0, m_thresh = 0, m_bg_thresh = 0;
> >  
> >  		/*
> >  		 * Unstable writes are a feature of certain networked
> 
> Adding runtime overhead to suppress a compile-time warning is Just
> Wrong.
> 
> With gcc-4.4.4 the above patch actually reduces page-writeback.o's
> .text by 36 bytes, lol.  With gcc-4.8.4 the patch saves 19 bytes.  No
> idea what's going on there...
> 
> 
> And initializing locals in the above fashion can hide real bugs -
> looky:

This was the main reason the code was structured the way it is.  If
cgroup writeback is not enabled, any derefs of mdtc variables should
trigger warnings.  Ugh... I don't know.  Compiler really should be
able to tell this much.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
