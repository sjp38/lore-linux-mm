Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0963D6B0299
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 09:03:15 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y16so19727759wmd.6
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:03:14 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id q19si18631829wju.89.2016.12.19.06.03.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 06:03:13 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id m203so18777803wma.3
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:03:13 -0800 (PST)
Date: Mon, 19 Dec 2016 15:03:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: simplify node/zone name printing
Message-ID: <20161219140312.GG5164@dhcp22.suse.cz>
References: <20161216123232.26307-1-mhocko@kernel.org>
 <2094d241-f40b-2f21-b90b-059374bcd2c2@suse.cz>
 <20161219073228.GA1339@jagdpanzerIV.localdomain>
 <20161219081210.GA32389@dhcp22.suse.cz>
 <20161219102759.GM393@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219102759.GM393@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon 19-12-16 11:27:59, Petr Mladek wrote:
> On Mon 2016-12-19 09:12:10, Michal Hocko wrote:
> > On Mon 19-12-16 16:32:28, Sergey Senozhatsky wrote:
> > [...]
> > > as far as I can tell, now for_each_populated_zone() iterations are
> > > split by non-CONT printk() from show_zone_node(), which previously
> > > has been   printk(KERN_CONT "%s: ", zone->name), so pr_cont(\n)
> > > between iterations was important, but now that non-CONT printk()
> > > should do the trick. it's _a bit_ hacky, though.
> > 
> > Do you consider that more hacky than the original? At least for me,
> > starting with KERN_CONT and relying on an explicit \n sounds more error
> > prone than leaving the last pr_cont without \n and relying on the
> > implicit flushing.
> 
> The missing '\n' will cause the string will not be flushed
> until another printk happens. It is not a problem here because
> other printk follows. But it might take a while in general.
> 
> There was a commit[1] that flushed the cont lines when the log
> buffer was read via /dev/kmsg or syslog. Also there was a patch[2]
> that flushed cont lines using a timer. But the commit caused problems
> and was reverted[3]. Also the patch needs more testing. So, it might
> take a while until flushing partial cont lines is "guaranteed".

OK, fair enough. If the flushing partial cont lines is not guaranteed
then this cleanup makes less sense. I was under impression this has been
solved but as per your list of commits we are not there yet.

So let's just drop this patch and I will try to remember to double check
later.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
