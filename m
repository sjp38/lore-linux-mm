Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D40ED6B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 22:30:43 -0500 (EST)
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <1322825802.2607.10.camel@edumazet-laptop>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
	 <1322825802.2607.10.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 05 Dec 2011 11:28:43 +0800
Message-ID: <1323055723.16790.138.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2011-12-02 at 19:36 +0800, Eric Dumazet wrote:
> Le vendredi 02 dA(C)cembre 2011 A  16:23 +0800, Alex Shi a A(C)crit :
> > From: Alex Shi <alexs@intel.com>
> > 
> > Times performance regression were due to slub add to node partial head
> > or tail. That inspired me to do tunning on the node partial adding, to
> > set a criteria for head or tail position selection when do partial
> > adding.
> > My experiment show, when used objects is less than 1/4 total objects
> > of slub performance will get about 1.5% improvement on netperf loopback
> > testing with 2048 clients, wherever on our 4 or 2 sockets platforms,
> > includes sandbridge or core2.
> > 
> > Signed-off-by: Alex Shi <alex.shi@intel.com>
> > ---
> >  mm/slub.c |   18 ++++++++----------
> >  1 files changed, 8 insertions(+), 10 deletions(-)
> > 
> 
> netperf (loopback or ethernet) is a known stress test for slub, and your
> patch removes code that might hurt netperf, but benefit real workload.
> 
> Have you tried instead this far less intrusive solution ?
> 
> if (tail == DEACTIVATE_TO_TAIL ||
>     page->inuse > page->objects / 4)
>          list_add_tail(&page->lru, &n->partial);
> else
>          list_add(&page->lru, &n->partial);

For loopback netperf, it has no clear performance change on all
platforms. 
For hackbench testing, it has a bit worse on 2P NHM 0.5~1%, but it is
helpful to increase about 2% on 4P(8cores * 2SMT) NHM machine. 

I was thought no much cache effect on hot or cold after per cpu partial
adding. but seems for hackbench, node partial still has much effect. 


> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
