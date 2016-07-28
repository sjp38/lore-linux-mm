Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8926B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 14:12:14 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id d65so96190588ith.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 11:12:14 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0003.hostedemail.com. [216.40.44.3])
        by mx.google.com with ESMTPS id g131si14167047iof.190.2016.07.28.11.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 11:12:13 -0700 (PDT)
Message-ID: <1469729529.3998.59.camel@perches.com>
Subject: Re: [BUG -next] "random: make /dev/urandom scalable for silly
 userspace programs" causes crash
From: Joe Perches <joe@perches.com>
Date: Thu, 28 Jul 2016 11:12:09 -0700
In-Reply-To: <20160728034601.GC20032@thunk.org>
References: <20160727071400.GA3912@osiris>
	 <20160728034601.GC20032@thunk.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-next@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, 2016-07-27 at 23:46 -0400, Theodore Ts'o wrote:
> On Wed, Jul 27, 2016 at 09:14:00AM +0200, Heiko Carstens wrote:
> > 
> > it looks like your patch "random: make /dev/urandom scalable for silly
> > userspace programs" within linux-next seems to be a bit broken:
> > 
> > It causes this allocation failure and subsequent crash on s390 with fake
> > NUMA enabled
> Thanks for reporting this.  This patch fixes things for you, yes?

trivia:

> diff --git a/drivers/char/random.c b/drivers/char/random.c
[]
> @@ -1668,13 +1668,12 @@ static int rand_initialize(void)
>  #ifdef CONFIG_NUMA
>  	pool = kmalloc(num_nodes * sizeof(void *),
>  		       GFP_KERNEL|__GFP_NOFAIL|__GFP_ZERO);

The __GFP_ZERO is unusual and this could use kcalloc instead.

> -	for (i=0; i < num_nodes; i++) {
> +	for_each_online_node(i) {
>  		crng = kmalloc_node(sizeof(struct crng_state),
>  				    GFP_KERNEL | __GFP_NOFAIL, i);
>  		spin_lock_init(&crng->lock);
>  		crng_initialize(crng);
>  		pool[i] = crng;
> -
>  	}
>  	mb();
>  	crng_node_pool = pool;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
