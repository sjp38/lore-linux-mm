Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 41B788D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 03:15:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D7DB13EE0C0
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:15:25 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BDD3345DE9F
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:15:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A64B745DEA5
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:15:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AFC11DB803C
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:15:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 506D2E18005
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:15:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to expand_upwards
In-Reply-To: <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com> <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com>
Message-Id: <20110420161615.462D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Apr 2011 16:15:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

> On Wed, Apr 20, 2011 at 4:23 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > I'm worry about this patch. A lot of mm code assume !NUMA systems
> > only have node 0. Not only SLUB.
> 
> So is that a valid assumption or not? Christoph seems to think it is
> and James seems to think it's not. Which way should we aim to fix it?
> Would be nice if other people chimed in as we already know what James
> and Christoph think.

I'm sorry. I don't know it really. The fact was gone into historical myst. ;-)

Now, CONFIG_NUMA has mainly five meanings.

1) system may has !0 node id.
2) compile mm/mempolicy.c (ie enable mempolicy APIs)
3) Allocator (kmalloc, vmalloc, alloc_page, et al) awake NUMA topology.
4) enable zone-reclaim feature
5) scheduler makes per-node load balancing scheduler domain

Anyway, we have to fix this issue.  I'm digging which fixing way has least risk.


btw, x86 don't have an issue. Probably it's a reason why this issue was neglected
long time.

arch/x86/Kconfig
-------------------------------------
config ARCH_DISCONTIGMEM_ENABLE
        def_bool y
        depends on NUMA && X86_32



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
