Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 9FE2B6B0034
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 07:21:08 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id c10so5261987wiw.5
        for <linux-mm@kvack.org>; Wed, 17 Jul 2013 04:21:07 -0700 (PDT)
Date: Wed, 17 Jul 2013 14:20:58 +0300
From: Dan Carpenter <error27@gmail.com>
Subject: Re: list_lru: per-node list infrastructure
Message-ID: <20130717112058.GA12134@mwanda>
References: <20130628142202.GA16774@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130628142202.GA16774@elgon.mountain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com
Cc: linux-mm@kvack.org

Ping?

Btw, here is the code from list_lru_walk_node():

		if ((*nr_to_walk)-- == 0)
			break;

As you can see it wraps to ULONG_MAX before returning.

regards,
dan carpenter

On Fri, Jun 28, 2013 at 05:22:02PM +0300, Dan Carpenter wrote:
> Hi Dave,
> 
> The patch a8739514fa91: "list_lru: per-node list infrastructure" in -mm
> has a signedness bug.
> 
> include/linux/list_lru.h
>    116  static inline unsigned long
>    117  list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
>    118                void *cb_arg, unsigned long nr_to_walk)
>    119  {
>    120          long isolated = 0;
>    121          int nid;
>    122  
>    123          for_each_node_mask(nid, lru->active_nodes) {
>    124                  isolated += list_lru_walk_node(lru, nid, isolate,
>    125                                                 cb_arg, &nr_to_walk);
>    126                  if (nr_to_walk <= 0)
>                             ^^^^^^^^^^^^^^^
> nr_to_walk is unsigned so the timeout value from list_lru_walk_node() is
> ULONG_MAX (it's not zero).
> 
>    127                          break;
>    128          }
>    129          return isolated;
>    130  }
> 
> regards,
> dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
