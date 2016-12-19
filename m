Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41CC86B0287
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 05:28:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so18755199wmw.0
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 02:28:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kv9si17927401wjb.50.2016.12.19.02.28.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Dec 2016 02:28:00 -0800 (PST)
Date: Mon, 19 Dec 2016 11:27:59 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm: simplify node/zone name printing
Message-ID: <20161219102759.GM393@pathway.suse.cz>
References: <20161216123232.26307-1-mhocko@kernel.org>
 <2094d241-f40b-2f21-b90b-059374bcd2c2@suse.cz>
 <20161219073228.GA1339@jagdpanzerIV.localdomain>
 <20161219081210.GA32389@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219081210.GA32389@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon 2016-12-19 09:12:10, Michal Hocko wrote:
> On Mon 19-12-16 16:32:28, Sergey Senozhatsky wrote:
> [...]
> > as far as I can tell, now for_each_populated_zone() iterations are
> > split by non-CONT printk() from show_zone_node(), which previously
> > has been   printk(KERN_CONT "%s: ", zone->name), so pr_cont(\n)
> > between iterations was important, but now that non-CONT printk()
> > should do the trick. it's _a bit_ hacky, though.
> 
> Do you consider that more hacky than the original? At least for me,
> starting with KERN_CONT and relying on an explicit \n sounds more error
> prone than leaving the last pr_cont without \n and relying on the
> implicit flushing.

The missing '\n' will cause the string will not be flushed
until another printk happens. It is not a problem here because
other printk follows. But it might take a while in general.

There was a commit[1] that flushed the cont lines when the log
buffer was read via /dev/kmsg or syslog. Also there was a patch[2]
that flushed cont lines using a timer. But the commit caused problems
and was reverted[3]. Also the patch needs more testing. So, it might
take a while until flushing partial cont lines is "guaranteed".

I would personally prefer to keep that pr_cont("\n") call when
it was already there. It makes it clear that the line is over.
It does not rely on any further printk's or fallbacks.

[1] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=bfd8d3f23b51018388be0411ccbc2d56277fe294
[2]
https://lkml.kernel.org/r/CA+55aFwKYnrMJr_vSE+GfDGszeUGyd=CPUD15-zZ8yWQW61GBA@mail.gmail.com
[3] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f5c9f9c72395c3291c2e35c905dedae2b98475a4

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
