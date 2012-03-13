Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 34B8C6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 02:26:28 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 532773EE0BD
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:26:26 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E75F45DEBC
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:26:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 13DCD45DEB8
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:26:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F0CE71DB8038
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:26:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A3CD71DB803E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:26:25 +0900 (JST)
Date: Tue, 13 Mar 2012 15:24:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 02/13] memcg: Kernel memory accounting
 infrastructure.
Message-Id: <20120313152446.28b0d696.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F5C5E54.2020408@parallels.com>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
	<1331325556-16447-3-git-send-email-ssouhlal@FreeBSD.org>
	<4F5C5E54.2020408@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@FreeBSD.org>, cgroups@vger.kernel.org, suleiman@google.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On Sun, 11 Mar 2012 12:12:04 +0400
Glauber Costa <glommer@parallels.com> wrote:

> On 03/10/2012 12:39 AM, Suleiman Souhlal wrote:
> > Enabled with CONFIG_CGROUP_MEM_RES_CTLR_KMEM.
> >
> > Adds the following files:
> >      - memory.kmem.independent_kmem_limit
> >      - memory.kmem.usage_in_bytes
> >      - memory.kmem.limit_in_bytes
> >
> > Signed-off-by: Suleiman Souhlal<suleiman@google.com>
> > ---
> >   mm/memcontrol.c |  136 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> >   1 files changed, 135 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 37ad2cb..e6fd558 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -220,6 +220,10 @@ enum memcg_flags {
> >   				 */
> >   	MEMCG_MEMSW_IS_MINIMUM,	/* Set when res.limit == memsw.limit */
> >   	MEMCG_OOM_KILL_DISABLE,	/* OOM-Killer disable */
> > +	MEMCG_INDEPENDENT_KMEM_LIMIT,	/*
> > +					 * kernel memory is not counted in
> > +					 * memory.usage_in_bytes
> > +					 */
> >   };


After looking codes, I think we need to think
whether independent_kmem_limit is good or not....

How about adding MEMCG_KMEM_ACCOUNT flag instead of this and use only
memcg->res/memcg->memsw rather than adding a new counter, memcg->kmem ?

if MEMCG_KMEM_ACCOUNT is set     -> slab is accoutned to mem->res/memsw.
if MEMCG_KMEM_ACCOUNT is not set -> slab is never accounted.

(I think On/Off switch is required..)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
