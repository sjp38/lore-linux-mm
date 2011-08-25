Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0679B6B016C
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 15:19:30 -0400 (EDT)
Date: Thu, 25 Aug 2011 14:19:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
In-Reply-To: <1314299115.26922.2.camel@twins>
Message-ID: <alpine.DEB.2.00.1108251413130.27407@router.home>
References: <1313650253-21794-1-git-send-email-gthelen@google.com>  <20110818144025.8e122a67.akpm@linux-foundation.org>  <1314284272.27911.32.camel@twins>  <alpine.DEB.2.00.1108251009120.27407@router.home>  <1314289208.3268.4.camel@mulgrave>
 <alpine.DEB.2.00.1108251128460.27407@router.home>  <986ca4ed-6810-426f-b32f-5c8687e3a10b@email.android.com>  <alpine.DEB.2.00.1108251206440.27407@router.home>  <1e295500-5d1f-45dd-aa5b-3d2da2cf1a62@email.android.com>  <alpine.DEB.2.00.1108251341230.27407@router.home>
 <1314299115.26922.2.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: James Bottomley <James.bottomley@HansenPartnership.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-arch@vger.kernel.org

On Thu, 25 Aug 2011, Peter Zijlstra wrote:

> Also, I thought this_cpu thing's were at best locally atomic. If you
> make them full blown atomic ops then even __this_cpu ops will have to be
> full atomic ops, otherwise:
>
>
> CPU0			CPU(1)
>
> this_cpu_inc(&foo);	preempt_disable();
> 			__this_cpu_inc(&foo);
> 			preempt_enable();
>
> might step on each other's toes.

They would both have their own instance of "foo". per cpu atomicity is
only one requirement of this_cpu_ops. The other is the ability to relocate
accesses relative to the current per cpu area.

Full blown atomicity is almost a superset of per cpu atomicity but its
only usable if the full atomic instructions can also relocate accesses
relative to some base.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
