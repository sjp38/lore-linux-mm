Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA14644
	for <linux-mm@kvack.org>; Sun, 8 Sep 2002 13:54:24 -0700 (PDT)
Message-ID: <3D7BBC68.E139D60@digeo.com>
Date: Sun, 08 Sep 2002 14:08:56 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slabasap-mm5_A2
References: <200209071006.18869.tomlins@cam.org> <200209081142.02839.tomlins@cam.org> <3D7BB97A.6B6E4CA5@digeo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> ...
> If we have the pruner callbacks then vmscan can just do:
> 
>         kmem_shrink_stuff(ratio);
> 
> and then kmem_shrink_stuff() can do:
> 
>         cachep->nr_to_prune += cacheb->inuse / ratio;
>         if (cachep->nr_to_prune > cachep->prune_batch) {
>                 int prune = cachep->nr_to_prune;
> 
>                 cachep->nr_to_prune = 0;
>                 (*cachep->pruner)(nr_to_prune);
>         }

OK, I get it.  `ratio' here can easily be 100,000, which would
result in zero objects to prune all the time.  So it's

	cachep->nr_to_prune += cacheb->inuse / ratio + 1;

yes?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
