Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6D31B6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:31:33 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so3217437pdb.38
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:31:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id q5si6313632pae.27.2014.02.07.12.31.30
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 12:31:31 -0800 (PST)
Date: Fri, 7 Feb 2014 12:31:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] drop_caches: add some documentation and info message
Message-Id: <20140207123129.84f9fb0aaf32f0e09c78851a@linux-foundation.org>
In-Reply-To: <20140207181332.GG6963@cmpxchg.org>
References: <1391794851-11412-1-git-send-email-hannes@cmpxchg.org>
	<52F51E19.9000406@redhat.com>
	<20140207181332.GG6963@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 7 Feb 2014 13:13:32 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> @@ -63,6 +64,9 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
>  			iterate_supers(drop_pagecache_sb, NULL);
>  		if (sysctl_drop_caches & 2)
>  			drop_slab();
> +		printk_ratelimited(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> +				   current->comm, task_pid_nr(current),
> +				   sysctl_drop_caches);
>  	}
>  	return 0;
>  }

My concern with this is that there may be people whose
other-party-provided software uses drop_caches.  Their machines will
now sit there emitting log messages and there's nothing they can do
about it, apart from whining at their vendors.


We could do something like this?

--- a/fs/drop_caches.c~drop_caches-add-some-documentation-and-info-message-fix
+++ a/fs/drop_caches.c
@@ -60,13 +60,17 @@ int drop_caches_sysctl_handler(ctl_table
 	if (ret)
 		return ret;
 	if (write) {
+		static int stfu;
+
 		if (sysctl_drop_caches & 1)
 			iterate_supers(drop_pagecache_sb, NULL);
 		if (sysctl_drop_caches & 2)
 			drop_slab();
-		printk_ratelimited(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
-				   current->comm, task_pid_nr(current),
-				   sysctl_drop_caches);
+		stfu |= sysctl_drop_caches & 4;
+		if (!stfu)
+			pr_info_ratelimited("%s (%d): dropped kernel caches: %d\n",
+					   current->comm, task_pid_nr(current),
+					   sysctl_drop_caches);
 	}
 	return 0;
 }
_

(note switch to pr_info_ratelimited)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
