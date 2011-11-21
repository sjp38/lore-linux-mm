Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EFC336B006E
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 05:57:06 -0500 (EST)
Subject: Re: [BUG] 3.2-rc2: BUG kmalloc-8: Redzone overwritten
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <1321870915.2552.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321866845.3831.7.camel@lappy>
	 <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321870915.2552.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 21 Nov 2011 10:58:30 +0000
Message-ID: <1321873110.2710.13.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, David Miller <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, Chrissie Caulfield <ccaulfie@redhat.com>

Hi,

On Mon, 2011-11-21 at 11:21 +0100, Eric Dumazet wrote:
> Le lundi 21 novembre 2011 A  11:15 +0100, Eric Dumazet a A(C)crit :
> 
> > 
> > Hmm, trinity tries to crash decnet ;)
> > 
> > Maybe we should remove this decnet stuff for good instead of tracking
> > all bugs just for the record. Is there anybody still using decnet ?
> >
The best place to ask that question is on the decnet mailing list:
linux-decnet-user@lists.sourceforge.net. I've BCC'd this message since
that list requires you to be subscribed in order to post there.

I have to say that I've been wondering lately whether it has got to the
point where it is no longer useful. Has anybody actually tested it
lately against "real" DEC implementations?

Steve.

>  
> > For example dn_start_slow_timer() starts a timer without holding a
> > reference on struct sock, this is highly suspect.
> > 
> > [PATCH] decnet: proper socket refcounting
> > 
> > Better use sk_reset_timer() / sk_stop_timer() helpers to make sure we
> > dont access already freed/reused memory later.
> > 
> > Reported-by: Sasha Levin <levinsasha928@gmail.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Hmm, I forgot to remove the sock_hold(sk) call from dn_slow_timer(),
> here is V2 :
> 
> [PATCH] decnet: proper socket refcounting
> 
> Better use sk_reset_timer() / sk_stop_timer() helpers to make sure we
> dont access already freed/reused memory later.
> 
> Reported-by: Sasha Levin <levinsasha928@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> V2: remove sock_hold(sk) call from dn_slow_timer()
> 
>  net/decnet/dn_timer.c |   17 +++++------------
>  1 file changed, 5 insertions(+), 12 deletions(-)
> 
> diff --git a/net/decnet/dn_timer.c b/net/decnet/dn_timer.c
> index 67f691b..d9c150c 100644
> --- a/net/decnet/dn_timer.c
> +++ b/net/decnet/dn_timer.c
> @@ -36,16 +36,13 @@ static void dn_slow_timer(unsigned long arg);
>  
>  void dn_start_slow_timer(struct sock *sk)
>  {
> -	sk->sk_timer.expires	= jiffies + SLOW_INTERVAL;
> -	sk->sk_timer.function	= dn_slow_timer;
> -	sk->sk_timer.data	= (unsigned long)sk;
> -
> -	add_timer(&sk->sk_timer);
> +	setup_timer(&sk->sk_timer, dn_slow_timer, (unsigned long)sk);
> +	sk_reset_timer(sk, &sk->sk_timer, jiffies + SLOW_INTERVAL);
>  }
>  
>  void dn_stop_slow_timer(struct sock *sk)
>  {
> -	del_timer(&sk->sk_timer);
> +	sk_stop_timer(sk, &sk->sk_timer);
>  }
>  
>  static void dn_slow_timer(unsigned long arg)
> @@ -53,12 +50,10 @@ static void dn_slow_timer(unsigned long arg)
>  	struct sock *sk = (struct sock *)arg;
>  	struct dn_scp *scp = DN_SK(sk);
>  
> -	sock_hold(sk);
>  	bh_lock_sock(sk);
>  
>  	if (sock_owned_by_user(sk)) {
> -		sk->sk_timer.expires = jiffies + HZ / 10;
> -		add_timer(&sk->sk_timer);
> +		sk_reset_timer(sk, &sk->sk_timer, jiffies + HZ / 10);
>  		goto out;
>  	}
>  
> @@ -100,9 +95,7 @@ static void dn_slow_timer(unsigned long arg)
>  			scp->keepalive_fxn(sk);
>  	}
>  
> -	sk->sk_timer.expires = jiffies + SLOW_INTERVAL;
> -
> -	add_timer(&sk->sk_timer);
> +	sk_reset_timer(sk, &sk->sk_timer, jiffies + SLOW_INTERVAL);
>  out:
>  	bh_unlock_sock(sk);
>  	sock_put(sk);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
