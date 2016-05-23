Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id A40D16B0253
	for <linux-mm@kvack.org>; Mon, 23 May 2016 17:36:06 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id q17so18655628lbn.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 14:36:06 -0700 (PDT)
Received: from emh03.mail.saunalahti.fi (emh03.mail.saunalahti.fi. [62.142.5.109])
        by mx.google.com with ESMTPS id jd5si15428696lbc.59.2016.05.23.14.36.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 May 2016 14:36:05 -0700 (PDT)
Date: Tue, 24 May 2016 00:36:04 +0300
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: __napi_alloc_skb failures locking up the box
Message-ID: <20160523213604.GB1253@raspberrypi.musicnaut.iki.fi>
References: <20160430192402.GA8366@raspberrypi.musicnaut.iki.fi>
 <1462046052.5535.190.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462046052.5535.190.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Sat, Apr 30, 2016 at 12:54:12PM -0700, Eric Dumazet wrote:
> On Sat, 2016-04-30 at 22:24 +0300, Aaro Koskinen wrote:
> > Hi,
> > 
> > I have old NAS box (Thecus N2100) with 512 MB RAM, where rsync from NFS ->
> > disk reliably results in temporary out-of-memory conditions.
> > 
> > When this happens the dmesg gets flooded with below logs. If the serial
> > console logging is enabled, this will lock up the box completely and
> > the backup is not making any progress.
> > 
> > Shouldn't these allocation failures be ratelimited somehow (or even made
> > silent)? It doesn't sound right if I can lock up the system simply by
> > copying files...
> 
> Agreed.
> 
> All napi_alloc_skb() callers handle failure just fine.
> 
> If they did not, a NULL deref would produce a proper stack dump.
> 
> When memory gets this tight, other traces will be dumped anyway.
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 15d0df943466..0652709fe81a 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2423,7 +2423,7 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi,
>  static inline struct sk_buff *napi_alloc_skb(struct napi_struct *napi,
>  					     unsigned int length)
>  {
> -	return __napi_alloc_skb(napi, length, GFP_ATOMIC);
> +	return __napi_alloc_skb(napi, length, GFP_ATOMIC | __GFP_NOWARN);
>  }
>  void napi_consume_skb(struct sk_buff *skb, int budget);

Care to send this as a formal patch, so I can reply with my Tested-by?

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
