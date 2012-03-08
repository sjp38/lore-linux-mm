Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 74C546B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 00:32:22 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 614503EE0BB
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:32:20 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 482B645DE59
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:32:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FDAC45DE58
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:32:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FDC31DB8047
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:32:20 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CC649E08002
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:32:19 +0900 (JST)
Date: Thu, 8 Mar 2012 14:30:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/7 v2] mm: rework __isolate_lru_page() file/anon filter
Message-Id: <20120308143034.f3521b1e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1203061904570.18675@eggly.anvils>
References: <20120229091547.29236.28230.stgit@zurg>
	<20120303091327.17599.80336.stgit@zurg>
	<alpine.LSU.2.00.1203061904570.18675@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 6 Mar 2012 19:22:21 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Sat, 3 Mar 2012, Konstantin Khlebnikov wrote:
> 
> > This patch adds file/anon filter bits into isolate_mode_t,
> > this allows to simplify checks in __isolate_lru_page().
> > 
> > v2:
> > * use switch () instead of if ()
> > * fixed lumpy-reclaim isolation mode
> > 
> > Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> 
> I'm sorry to be messing you around on this one, Konstantin, but...
> 
> (a) if you do go with the switch statements,
> in kernel we align the "case"s underneath the "switch"
> 
> but
> 
> (b) I seem to be at odds with Kamezawa-san, I much preferred your
> original, which did in 2 lines what the switches do in 10 lines.
> And I'd say there's more opportunity for error in 10 lines than 2.
> 
> What does the compiler say (4.5.1 here, OPTIMIZE_FOR_SIZE off)?
>    text	   data	    bss	    dec	    hex	filename
>   17723	    113	     17	  17853	   45bd	vmscan.o.0
>   17671	    113	     17	  17801	   4589	vmscan.o.1
>   17803	    113	     17	  17933	   460d	vmscan.o.2
> 
> That suggests that your v2 is the worst and your v1 the best.
> Kame, can I persuade you to let the compiler decide on this?
> 

Hmm. How about Costa' proposal ? as

int tmp_var = PageActive(page) ? ISOLATE_ACTIVE : ISOLATE_INACTIVE
if (!(mode & tmp_var))
    ret;

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
