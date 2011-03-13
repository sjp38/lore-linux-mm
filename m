Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 43B308D003A
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 07:36:51 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2441D3EE0AE
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 20:36:46 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EFE345DE50
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 20:36:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC28545DE4D
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 20:36:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DE3981DB803F
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 20:36:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7D111DB802F
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 20:36:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] oom: TIF_MEMDIE/PF_EXITING fixes
In-Reply-To: <20110312134341.GA27275@redhat.com>
References: <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com>
Message-Id: <20110313202321.411F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Mar 2011 20:36:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>

> > Note also the note about "p == current" check. it should be fixed too.
> 
> I am resending the fixes above plus the new one.
> 
> David, Kosaki, what do you think?

Oleg, could you please give me some testing time? Now TIF_MEMDIE has
really unclear and nasty meanings. mainly 1) to prevent multiple oom-killer
(see select_bad_process) and 2) to allow to use zone's last resort reserved
memory (see gfp_to_alloc_flags).  The latter has really problematic even if
apply or not apply your patch.

If no apply your patch, multi thread application have a lot of risk
to fail to exit when oom killed. because sub threads can't use reserved
memory and may get stucked exiting path.

if apply your patch, multi thread application also have a lot of risk
to fail to exit when oom killed. because if all thread used a little
reserved memory but it is not enough successful exit. It become deadlock.

The optimal way is, take a bonus one thread and successfull thread exiting
pass a bonus to sibling thread. But, who want to put performance overhead
into thread exiting path for only really really rare oom events? this is
the problem. therefore, I can't put ack until I've finished some test.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
