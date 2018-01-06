Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D91E0280297
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 08:34:20 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b82so1663661wmd.5
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 05:34:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n17si4906639wmh.204.2018.01.06.05.34.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Jan 2018 05:34:19 -0800 (PST)
Date: Sat, 6 Jan 2018 14:34:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: ratelimit end_swap_bio_write() error
Message-ID: <20180106133417.GA23629@dhcp22.suse.cz>
References: <20180106043407.25193-1-sergey.senozhatsky@gmail.com>
 <20180106094124.GB16576@dhcp22.suse.cz>
 <20180106100313.GA527@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180106100313.GA527@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 06-01-18 19:03:13, Sergey Senozhatsky wrote:
> Hello,
> 
> On (01/06/18 10:41), Michal Hocko wrote:
> > On Sat 06-01-18 13:34:07, Sergey Senozhatsky wrote:
> > > Use the ratelimited printk() version for swap-device write error
> > > reporting. We can use ZRAM as a swap-device, and the tricky part
> > > here is that zsmalloc() stores compressed objects in memory, thus
> > > it has to allocates pages during swap-out. If the system is short
> > > on memory, then we begin to flood printk() log buffer with the
> > > same "Write-error on swap-device XXX" error messages and sometimes
> > > simply lockup the system.
> > 
> > Should we print an error in such a situation at all? Write-error
> > certainly sounds scare and it suggests something went really wrong.
> > My understading is that zram failed swap-out is not critical and
> > therefore the error message is not really useful.
> 
> I don't mind to get rid of it. up to you :)

I do not think we can get rid of it for all swap backends.

> > Or what should an admin do when seeing it?
> 
> zsmalloc allocation is just one possibility; an error in
> compressing algorithm is another one, yet is rather unlikely.
> most likely it's OOM which can cause problems. but in any case
> it's sort of unclear what should be done. an error can be a
> temporary one or a fatal one, just like in __swap_writepage()
> case. so may be both write error printk()-s can be dropped.

Then I would suggest starting with sorting out which of those errors are
critical and which are not and report the error accordingly. I am sorry
to be fuzzy here but I am not familiar with the code to be more
specific. Anyway ratelimiting sounds more like a paper over than a real
solution. Also it sounds quite scary that you can see so many failures
to actually lock up the system just by printing a message...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
