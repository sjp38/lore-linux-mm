Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id DFD4A6B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 03:19:59 -0500 (EST)
Message-ID: <511B4CC8.9040309@parallels.com>
Date: Wed, 13 Feb 2013 12:20:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Few things I would like to discuss
References: <20130205123515.GA26229@dhcp22.suse.cz> <511AE0B5.4020502@jp.fujitsu.com>
In-Reply-To: <511AE0B5.4020502@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>

> 
> Other points related to memcg is ...
> 
> + kernel memory accounting + per-zone-per-memcg inode/dentry caching.
>   Glaubler tries to account inode/dentry in kmem controller. To do that,
>   I think inode and dentry should be hanldled per zone, at first. IIUC,
> there are
>   ongoing work but not merged yet.
> 

Yes, I've already managed to post an initial version - comments appreciated.

Actually, Johannes correctly pointed out to me once that memcg pressure
is never per-zone, so there is no reason for us to keep per-zone
information. The logic behind this is that if there is per-zone
pressure, it is always global pressure; memcg can only provide go/no-go
signals, and knows nothing about zones.

The only reason I am actually keeping per-zone information, is to avoid
keeping the inodes/dentries in two lists. Without per-zone, we would
have to keep it in a nodeless memcg list, and then in a per-zone (it is
actually per-node) list, and then when global pressure kicks in, follow
the zone lists. This means extra 16 bytes per objects, which adds up
quickly to a large memory overhead.


> + overheads by memcg
>   Mel explained memcg's big overheads last year's MM summit. AFAIK, we
> have not
>   made any progress with that. If someone have detailed data, please
> share again...
> 

I had a patch for that, but didn't manage to go back to it again. Jeff
Liu did some extra work to handle lazy swap enablement as well, that
would go all right with it.

I can probably find the time to resuscitate it before the summit. We
could focus on what is still missing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
