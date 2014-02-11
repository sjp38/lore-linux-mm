Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 374706B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:45:02 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so8324623pbc.0
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:45:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sd3si20323122pbb.102.2014.02.11.13.45.01
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 13:45:01 -0800 (PST)
Date: Tue, 11 Feb 2014 13:44:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] drop_caches: add some documentation and info message
Message-Id: <20140211134459.551dd07d697a888e29f1c7b1@linux-foundation.org>
In-Reply-To: <20140210215416.GK6963@cmpxchg.org>
References: <1391794851-11412-1-git-send-email-hannes@cmpxchg.org>
	<52F51E19.9000406@redhat.com>
	<20140207181332.GG6963@cmpxchg.org>
	<20140207123129.84f9fb0aaf32f0e09c78851a@linux-foundation.org>
	<20140207212601.GI6963@cmpxchg.org>
	<20140210125102.86de67241664da038676af7d@linux-foundation.org>
	<20140210215416.GK6963@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 10 Feb 2014 16:54:16 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> How about this: we allow disabling the log message, but print the line
> of the disabling call so it's clear who dunnit.  To make sure valuable
> info is not missing in bug reports, add counters for the two events in
> /proc/vmstat.
> 
> Does that sound acceptable?

Yes, I really don't know what's the right thing to do here or where the
best tradeoff point is situated.  Let's start off this way and see what
happens I guess.

> --- a/fs/drop_caches.c
> +++ b/fs/drop_caches.c
> @@ -59,10 +59,22 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
>  	if (ret)
>  		return ret;
>  	if (write) {
> -		if (sysctl_drop_caches & 1)
> +		static int stfu;

That identifier wasn't serious, but I kinda like it.

> +
> +		if (sysctl_drop_caches & 1) {
>  			iterate_supers(drop_pagecache_sb, NULL);
> -		if (sysctl_drop_caches & 2)
> +			count_vm_event(DROP_PAGECACHE);
> +		}
> +		if (sysctl_drop_caches & 2) {
>  			drop_slab();
> +			count_vm_event(DROP_SLAB);
> +		}
> +		if (!stfu) {
> +			pr_info("%s (%d): drop_caches: %d\n",
> +				current->comm, task_pid_nr(current),
> +				sysctl_drop_caches);
> +		}
> +		stfu |= sysctl_drop_caches & 4;
>  	}
>  	return 0;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
