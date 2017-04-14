Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA6486B03A1
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 19:45:11 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r203so76696522oib.15
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 16:45:11 -0700 (PDT)
Received: from esa6.hgst.iphmx.com (esa6.hgst.iphmx.com. [216.71.154.45])
        by mx.google.com with ESMTPS id e136si215153oig.212.2017.04.14.16.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 16:45:10 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: [PATCH] mm: Make truncate_inode_pages_range() killable
Date: Fri, 14 Apr 2017 23:45:05 +0000
Message-ID: <1492213503.2644.23.camel@sandisk.com>
References: <20170414215507.27682-1-bart.vanassche@sandisk.com>
In-Reply-To: <20170414215507.27682-1-bart.vanassche@sandisk.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <5A980E8A8B6D7F46BD178AB261FC89DD@namprd04.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "hughd@google.com" <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "snitzer@redhat.com" <snitzer@redhat.com>, "oleg@redhat.com" <oleg@redhat.com>, "hare@suse.com" <hare@suse.com>, "mhocko@suse.com" <mhocko@suse.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "jack@suse.cz" <jack@suse.cz>

On Fri, 2017-04-14 at 14:55 -0700, Bart Van Assche wrote:
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 6263affdef88..91abd16d74f8 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -20,6 +20,7 @@
>  #include <linux/task_io_accounting_ops.h>
>  #include <linux/buffer_head.h>	/* grr. try_to_release_page,
>  				   do_invalidatepage */
> +#include <linux/sched/signal.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/cleancache.h>
>  #include <linux/rmap.h>
> @@ -366,7 +367,7 @@ void truncate_inode_pages_range(struct address_space =
*mapping,
>  		return;
> =20
>  	index =3D start;
> -	for ( ; ; ) {
> +	for ( ; !signal_pending_state(TASK_WAKEKILL, current); ) {
>  		cond_resched();
>  		if (!pagevec_lookup_entries(&pvec, mapping, index,
>  			min(end - index, (pgoff_t)PAGEVEC_SIZE), indices)) {
> @@ -400,7 +401,8 @@ void truncate_inode_pages_range(struct address_space =
*mapping,
>  				continue;
>  			}
> =20
> -			lock_page(page);
> +			if (lock_page_killable(page))
> +				break;
>  			WARN_ON(page_to_index(page) !=3D index);
>  			wait_on_page_writeback(page);
>  			truncate_inode_page(mapping, page);

Sorry but a small part of this patch got left out accidentally:

diff --git a/kernel/signal.c b/kernel/signal.c
index 7e59ebc2c25e..a02b273a4a1c 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -869,10 +869,10 @@ static inline int wants_signal(int sig, struct task_s=
truct *p)
=A0{
=A0	if (sigismember(&p->blocked, sig))
=A0		return 0;
-	if (p->flags & PF_EXITING)
-		return 0;
=A0	if (sig =3D=3D SIGKILL)
=A0		return 1;
+	if (p->flags & PF_EXITING)
+		return 0;
=A0	if (task_is_stopped_or_traced(p))
=A0		return 0;
=A0	return task_curr(p) || !signal_pending(p);

Does anyone who is on the CC-list of this e-mail know whether this change
is acceptable? As far as I can see the most recent change to that function
was made through the following commit:

commit 188a1eafa03aaa5e5fe6f53e637e704cd2c31c7c
Author: Linus Torvalds <torvalds@g5.osdl.org>
Date: =A0=A0Fri Sep 23 13:22:21 2005 -0700

=A0=A0=A0=A0Make sure SIGKILL gets proper respect

Thanks,

Bart.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
