Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 309F36B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 02:34:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e9so88516778pgc.5
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 23:34:12 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id 71si1141151pfj.64.2016.12.14.23.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 23:34:11 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id c4so2394768pfb.3
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 23:34:11 -0800 (PST)
Date: Thu, 15 Dec 2016 16:34:17 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161215073417.GD485@jagdpanzerIV.localdomain>
References: <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161214093706.GA16064@pathway.suse.cz>
 <20161214102600.GF25573@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214102600.GF25573@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Petr Mladek <pmladek@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, sergey.senozhatsky@gmail.com

On (12/14/16 11:26), Michal Hocko wrote:
> On Wed 14-12-16 10:37:06, Petr Mladek wrote:
> > On Tue 2016-12-13 21:06:57, Tetsuo Handa wrote:
> [...]
> > > Although it is fine to make warn_alloc() less verbose, this is not
> > > a problem which can be avoided by simply reducing printk(). Unless
> > > we give enough CPU time to the OOM killer and OOM victims, it is
> > > trivial to lockup the system.
> > 
> > You could try to use printk_deferred() in warn_alloc(). It will not
> > handle console.
> 
> the problem is, however, _any_ printk under the oom_lock. So all of them
> would have to be converted AFAIU.
> 
> > It will help to be sure that the blocked printk()
> > is the main problem.
> 
> I think we should rather ratelimit those messages than tweak the way how
> the printk is used. The source of the heavy printk might be completely
> different so this has to be addressed at the printk level.

yes, rate limiting seems to be the only right thing to do. if not for
lockup avoidance (async printk can help here), then for logbuf overflow
and lost messages avoidance (async printk can't prevent this from
happening).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
