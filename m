Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFF1900134
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 12:30:47 -0400 (EDT)
Received: by wyg36 with SMTP id 36so5506901wyg.14
        for <linux-mm@kvack.org>; Tue, 05 Jul 2011 09:30:44 -0700 (PDT)
Subject: Re: [RFC] non-preemptible kernel socket for RAMster
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Jul 2011 18:30:30 +0200
Message-ID: <1309883430.2271.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: netdev@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

Le mardi 05 juillet 2011 A  08:54 -0700, Dan Magenheimer a A(C)crit :
> In working on a kernel project called RAMster* (where RAM on a
> remote system may be used for clean page cache pages and for swap
> pages), I found I have need for a kernel socket to be used when
> in non-preemptible state.  I admit to being a networking idiot,
> but I have been successfully using the following small patch.
> I'm not sure whether I am lucky so far... perhaps more
> sockets or larger/different loads will require a lot more
> changes (or maybe even make my objective impossible).
> So I thought I'd post it for comment.  I'd appreciate
> any thoughts or suggestions.
> 
> Thanks,
> Dan
> 
> * http://events.linuxfoundation.org/events/linuxcon/magenheimer 
> 
> diff -Napur linux-2.6.37/net/core/sock.c linux-2.6.37-ramster/net/core/sock.c
> --- linux-2.6.37/net/core/sock.c	2011-07-03 19:14:52.267853088 -0600
> +++ linux-2.6.37-ramster/net/core/sock.c	2011-07-03 19:10:04.340980799 -0600
> @@ -1587,6 +1587,14 @@ static void __lock_sock(struct sock *sk)
>  	__acquires(&sk->sk_lock.slock)
>  {
>  	DEFINE_WAIT(wait);
> +	if (!preemptible()) {
> +		while (sock_owned_by_user(sk)) {
> +			spin_unlock_bh(&sk->sk_lock.slock);
> +			cpu_relax();
> +			spin_lock_bh(&sk->sk_lock.slock);
> +		}
> +		return;
> +	}

Hmm, was this tested on UP machine ?

>  
>  	for (;;) {
>  		prepare_to_wait_exclusive(&sk->sk_lock.wq, &wait,
> @@ -1623,7 +1631,8 @@ static void __release_sock(struct sock *
>  			 * This is safe to do because we've taken the backlog
>  			 * queue private:
>  			 */
> -			cond_resched_softirq();
> +			if (preemptible())
> +				cond_resched_softirq();
>  			skb = next;
>  		} while (skb != NULL);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
