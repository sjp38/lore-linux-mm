Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 06BC96B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 16:26:14 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id d17so1760976eek.37
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 13:26:14 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id g47si10599565eet.66.2014.02.07.13.26.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 13:26:13 -0800 (PST)
Date: Fri, 7 Feb 2014 16:26:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] drop_caches: add some documentation and info message
Message-ID: <20140207212601.GI6963@cmpxchg.org>
References: <1391794851-11412-1-git-send-email-hannes@cmpxchg.org>
 <52F51E19.9000406@redhat.com>
 <20140207181332.GG6963@cmpxchg.org>
 <20140207123129.84f9fb0aaf32f0e09c78851a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140207123129.84f9fb0aaf32f0e09c78851a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 07, 2014 at 12:31:29PM -0800, Andrew Morton wrote:
> On Fri, 7 Feb 2014 13:13:32 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > @@ -63,6 +64,9 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
> >  			iterate_supers(drop_pagecache_sb, NULL);
> >  		if (sysctl_drop_caches & 2)
> >  			drop_slab();
> > +		printk_ratelimited(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> > +				   current->comm, task_pid_nr(current),
> > +				   sysctl_drop_caches);
> >  	}
> >  	return 0;
> >  }
> 
> My concern with this is that there may be people whose
> other-party-provided software uses drop_caches.  Their machines will
> now sit there emitting log messages and there's nothing they can do
> about it, apart from whining at their vendors.

Ironically, we have a customer that is complaining that we currently
do not log these events, and they want to know who in their stack is
being idiotic.

> We could do something like this?

They can already change the log level.  The below will suppress
valuable debugging information in a way that still results in
inconspicuous looking syslog excerpts, which somewhat undermines the
original motivation for this change.

So I'm not fond of it, but I'd rather have this patch with it than no
patch at all.  As long as the message is printed per default.

> --- a/fs/drop_caches.c~drop_caches-add-some-documentation-and-info-message-fix
> +++ a/fs/drop_caches.c
> @@ -60,13 +60,17 @@ int drop_caches_sysctl_handler(ctl_table
>  	if (ret)
>  		return ret;
>  	if (write) {
> +		static int stfu;
> +
>  		if (sysctl_drop_caches & 1)
>  			iterate_supers(drop_pagecache_sb, NULL);
>  		if (sysctl_drop_caches & 2)
>  			drop_slab();
> -		printk_ratelimited(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> -				   current->comm, task_pid_nr(current),
> -				   sysctl_drop_caches);
> +		stfu |= sysctl_drop_caches & 4;
> +		if (!stfu)
> +			pr_info_ratelimited("%s (%d): dropped kernel caches: %d\n",
> +					   current->comm, task_pid_nr(current),
> +					   sysctl_drop_caches);
>  	}
>  	return 0;
>  }
> _
> 
> (note switch to pr_info_ratelimited)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
