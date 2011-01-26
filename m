Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6146B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:06:11 -0500 (EST)
Received: from davide-MacBookPro
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S37074E> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Wed, 26 Jan 2011 10:05:19 -0500
Date: Wed, 26 Jan 2011 07:05:07 -0800 (PST)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [patch]
 epoll-fix-compiler-warning-and-optimize-the-non-blocking-path-fix
In-Reply-To: <20110126102020.GA2244@cmpxchg.org>
Message-ID: <alpine.DEB.2.00.1101260704050.1889@localhost6.localdomain6>
References: <201101260021.p0Q0LxsS016458@imap1.linux-foundation.org> <20110126102020.GA2244@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, shawn.bohrer@gmail.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, mm-commits@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jan 2011, Johannes Weiner wrote:

> The non-blocking ep_poll path optimization introduced skipping over
> the return value setup.
> 
> Initialize it properly, my userspace gets upset by epoll_wait()
> returning random things.
> 
> In addition, remove the reinitialization at the fetch_events label,
> the return value is garuanteed to be zero when execution reaches
> there.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Shawn Bohrer <shawn.bohrer@gmail.com>
> Cc: Davide Libenzi <davidel@xmailserver.org>

Thank you for posting it. Obvious ACK.



> ---
>  fs/eventpoll.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/eventpoll.c b/fs/eventpoll.c
> index f7cb6cb..afe4238 100644
> --- a/fs/eventpoll.c
> +++ b/fs/eventpoll.c
> @@ -1147,7 +1147,7 @@ static int ep_send_events(struct eventpoll *ep,
>  static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
>  		   int maxevents, long timeout)
>  {
> -	int res, eavail, timed_out = 0;
> +	int res = 0, eavail, timed_out = 0;
>  	unsigned long flags;
>  	long slack = 0;
>  	wait_queue_t wait;
> @@ -1173,7 +1173,6 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
>  fetch_events:
>  	spin_lock_irqsave(&ep->lock, flags);
>  
> -	res = 0;
>  	if (!ep_events_available(ep)) {
>  		/*
>  		 * We don't have any available event to return to the caller.
> -- 
> 1.7.3.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
