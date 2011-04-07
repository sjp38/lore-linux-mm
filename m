Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 56EC58D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 07:21:06 -0400 (EDT)
Received: by iyf13 with SMTP id 13so3287837iyf.14
        for <linux-mm@kvack.org>; Thu, 07 Apr 2011 04:21:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4D9D8FAA.9080405@suse.cz>
References: <20110315132527.130FB80018F1@mail1005.cent>
	<20110317001519.GB18911@kroah.com>
	<20110407120112.E08DCA03@pobox.sk>
	<4D9D8FAA.9080405@suse.cz>
Date: Thu, 7 Apr 2011 19:21:00 +0800
Message-ID: <BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com>
Subject: Re: Regression from 2.6.36
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

On Thu, Apr 7, 2011 at 6:19 PM, Jiri Slaby <jslaby@suse.cz> wrote:
> Cced few people.
>
> Also the series which introduced this were discussed at:
> http://lkml.org/lkml/2010/5/3/53
>

I guess this is due to that lots of fdt are allocated by kmalloc(),
not vmalloc(), and we kfree() them in rcu callback.

How about deferring all of the removal to workqueue? This may
hurt performance I think.

Anyway, like the patch below... makes sense?

Not-yet-signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

---
diff --git a/fs/file.c b/fs/file.c
index 0be3447..34dc355 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -96,20 +96,14 @@ void free_fdtable_rcu(struct rcu_head *rcu)
                                container_of(fdt, struct files_struct, fdtab));
                return;
        }
-       if (!is_vmalloc_addr(fdt->fd) && !is_vmalloc_addr(fdt->open_fds)) {
-               kfree(fdt->fd);
-               kfree(fdt->open_fds);
-               kfree(fdt);
-       } else {
-               fddef = &get_cpu_var(fdtable_defer_list);
-               spin_lock(&fddef->lock);
-               fdt->next = fddef->next;
-               fddef->next = fdt;
-               /* vmallocs are handled from the workqueue context */
-               schedule_work(&fddef->wq);
-               spin_unlock(&fddef->lock);
-               put_cpu_var(fdtable_defer_list);
-       }
+
+       fddef = &get_cpu_var(fdtable_defer_list);
+       spin_lock(&fddef->lock);
+       fdt->next = fddef->next;
+       fddef->next = fdt;
+       schedule_work(&fddef->wq);
+       spin_unlock(&fddef->lock);
+       put_cpu_var(fdtable_defer_list);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
