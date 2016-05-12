Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB4216B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 11:09:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x67so129691891oix.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 08:09:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n18si14057000igi.63.2016.05.12.08.09.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 May 2016 08:09:23 -0700 (PDT)
Subject: Re: [PATCH v5] mm: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <004b01d1a9d1$3817fc10$a847f430$@alibaba-inc.com>
	<006e01d1a9d8$5c7a15f0$156e41d0$@alibaba-inc.com>
In-Reply-To: <006e01d1a9d8$5c7a15f0$156e41d0$@alibaba-inc.com>
Message-Id: <201605130009.EAJ35441.JLtFVOHFOSOMQF@I-love.SAKURA.ne.jp>
Date: Fri, 13 May 2016 00:09:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hillf.zj@alibaba-inc.com, mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hillf Danton wrote:
> > +struct memalloc_info {
> > +	/*
> > +	 * 0: not doing __GFP_RECLAIM allocation.
> > +	 * 1: doing non-recursive __GFP_RECLAIM allocation.
> > +	 * 2: doing recursive __GFP_RECLAIM allocation.
> > +	 */
> > +	u8 valid;
> > +	/*
> > +	 * bit 0: Will be reported as OOM victim.
> > +	 * bit 1: Will be reported as dying task.
> > +	 * bit 2: Will be reported as stalling task.
> > +	 * bit 3: Will be reported as exiting task.
> > +	 * bit 7: Will be reported unconditionally.
> > +	 */
> > +	u8 type;
> > +	/* Index used for memalloc_in_flight[] counter. */
> > +	u8 idx;
> 
> 	u8 __pad;	is also needed perhaps.
> 

Since this structure is not marked as __packed, I think that
the compiler will automatically pad it.

> The numbers assigned to type may be replaced with texts, 
> for instance,
> 	MEMALLOC_TYPE_VICTIM 
> 	MEMALLOC_TYPE_DYING 
> 	MEMALLOC_TYPE_STALLING
> 	MEMALLOC_TYPE_EXITING
> 	MEMALLOC_TYPE_REPORT
> 

I can define them as bit shift numbers. Thanks.



Michal, this version eliminated overhead of walking the process list
when nothing is wrong. You are aware of the possibility of
debug_show_all_locks() failing to report the culprit, aren't you?
So, what are unacceptable major problems for you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
