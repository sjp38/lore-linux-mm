Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 1529F6B004F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 19:23:22 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 108D13EE0BC
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:23:20 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EC64F45DE4D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:23:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D447445DE67
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:23:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C61D71DB802C
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:23:19 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 809A21DB803A
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:23:19 +0900 (JST)
Date: Tue, 17 Jan 2012 09:22:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 3/7 v2] memcg: remove PCG_MOVE_LOCK flag from
 pc->flags
Message-Id: <20120117092203.73d9c303.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120116125526.GB25981@shutemov.name>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
	<20120116125526.GB25981@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Mon, 16 Jan 2012 14:55:26 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Jan 13, 2012 at 05:40:19PM +0900, KAMEZAWA Hiroyuki wrote:
> > 
> > From 1008e84d94245b1e7c4d237802ff68ff00757736 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 12 Jan 2012 15:53:24 +0900
> > Subject: [PATCH 3/7] memcg: remove PCG_MOVE_LOCK flag from pc->flags.
> > 
> > PCG_MOVE_LOCK bit is used for bit spinlock for avoiding race between
> > memcg's account moving and page state statistics updates.
> > 
> > Considering page-statistics update, very hot path, this lock is
> > taken only when someone is moving account (or PageTransHuge())
> > And, now, all moving-account between memcgroups (by task-move)
> > are serialized.
> > 
> > So, it seems too costly to have 1bit per page for this purpose.
> > 
> > This patch removes PCG_MOVE_LOCK and add hashed rwlock array
> > instead of it. This works well enough. Even when we need to
> > take the lock, we don't need to disable IRQ in hot path because
> > of using rwlock.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ...
> 
> > +#define NR_MOVE_ACCOUNT_LOCKS	(NR_CPUS)
> > +#define move_account_hash(page) ((page_to_pfn(page) % NR_MOVE_ACCOUNT_LOCKS))
> 
> You still tend to add too many parentheses into macros ;)
> 

Ah, yes. Maybe my bad habit..
Will be fixed in the next patch.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
