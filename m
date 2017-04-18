Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B713C6B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 10:42:45 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u12so9946283qku.16
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 07:42:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e49si14042109qtf.126.2017.04.18.07.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 07:42:44 -0700 (PDT)
Date: Tue, 18 Apr 2017 16:42:39 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: Make truncate_inode_pages_range() killable
Message-ID: <20170418144238.GA13692@redhat.com>
References: <20170414215507.27682-1-bart.vanassche@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170414215507.27682-1-bart.vanassche@sandisk.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Mike Snitzer <snitzer@redhat.com>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.com>, linux-mm@kvack.org

On 04/14, Bart Van Assche wrote:
>
> On Fri, 2017-04-14 at 14:55 -0700, Bart Van Assche wrote:
> > diff --git a/mm/truncate.c b/mm/truncate.c
> > index 6263affdef88..91abd16d74f8 100644
> > --- a/mm/truncate.c
> > +++ b/mm/truncate.c
> > @@ -20,6 +20,7 @@
> >  #include <linux/task_io_accounting_ops.h>
> >  #include <linux/buffer_head.h>	/* grr. try_to_release_page,
> >  				   do_invalidatepage */
> > +#include <linux/sched/signal.h>
> >  #include <linux/shmem_fs.h>
> >  #include <linux/cleancache.h>
> >  #include <linux/rmap.h>
> > @@ -366,7 +367,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
> >  		return;
> >
> >  	index = start;
> > -	for ( ; ; ) {
> > +	for ( ; !signal_pending_state(TASK_WAKEKILL, current); ) {

you could just use fatal_signal_pending(current)

> Sorry but a small part of this patch got left out accidentally:
>
> diff --git a/kernel/signal.c b/kernel/signal.c
> index 7e59ebc2c25e..a02b273a4a1c 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -869,10 +869,10 @@ static inline int wants_signal(int sig, struct task_struct *p)
>  {
>  	if (sigismember(&p->blocked, sig))
>  		return 0;
> -	if (p->flags & PF_EXITING)
> -		return 0;
>  	if (sig == SIGKILL)
>  		return 1;
> +	if (p->flags & PF_EXITING)
> +		return 0;

Oh. This is the user-visible change. With this change you send a private signal to
a zombie thread and it will kill the process. Perhaps this is even good, and in fact
I was thinking about this change too many times, but I am not sure.

And afaics it won't really help. If the exiting task is multithreaded then another
kill(SIGKILL) won't wake other threads up, you will need tkill(tid_of_bloked_thread).

OTOH. Please note that fatal_signal_pending(exiting_thread) can be true even if you
do not send another SIGKILL.

But the main problem is that the behaviour of signal sent to PF_EXITING task is not
defined, it is not clear to me what do we actually want to do.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
