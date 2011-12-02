Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 738526B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 06:36:48 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so2925386vcb.14
        for <linux-mm@kvack.org>; Fri, 02 Dec 2011 03:36:46 -0800 (PST)
Message-ID: <1322825802.2607.10.camel@edumazet-laptop>
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Dec 2011 12:36:42 +0100
In-Reply-To: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: cl@linux.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Le vendredi 02 dA(C)cembre 2011 A  16:23 +0800, Alex Shi a A(C)crit :
> From: Alex Shi <alexs@intel.com>
> 
> Times performance regression were due to slub add to node partial head
> or tail. That inspired me to do tunning on the node partial adding, to
> set a criteria for head or tail position selection when do partial
> adding.
> My experiment show, when used objects is less than 1/4 total objects
> of slub performance will get about 1.5% improvement on netperf loopback
> testing with 2048 clients, wherever on our 4 or 2 sockets platforms,
> includes sandbridge or core2.
> 
> Signed-off-by: Alex Shi <alex.shi@intel.com>
> ---
>  mm/slub.c |   18 ++++++++----------
>  1 files changed, 8 insertions(+), 10 deletions(-)
> 

netperf (loopback or ethernet) is a known stress test for slub, and your
patch removes code that might hurt netperf, but benefit real workload.

Have you tried instead this far less intrusive solution ?

if (tail == DEACTIVATE_TO_TAIL ||
    page->inuse > page->objects / 4)
         list_add_tail(&page->lru, &n->partial);
else
         list_add(&page->lru, &n->partial);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
