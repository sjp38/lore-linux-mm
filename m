Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 34AC98D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 05:29:15 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 14A093EE0AE
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:29:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EF8DA45DE51
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:29:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D64B445DE50
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:29:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C7B2A1DB803B
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:29:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 947D41DB802F
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:29:08 +0900 (JST)
Date: Thu, 24 Mar 2011 18:22:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4] forkbomb killer
Message-Id: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>


Cleaned up and fixed unclear logics. and removed RFC.
Maybe this version is easy to be read.


When we see forkbomb, it tends can be a fatal one.

 When A user makes a forkbomb (and sometimes reaches ulimit....
   In this case, 
   - If the system is not in OOM, the admin may be able to kill all threads by
     hand..but forkbomb may be faster than pkill() by admin.
   - If the system is in OOM, the admin needs to reboot system.
     OOM killer is slow than forkbomb.

So, I think forkbomb killer is appreciated. It's better than reboot.

At implementing forkbomb killer, one of difficult case is like this

# forkbomb(){ forkbomb|forkbomb & } ; forkbomb

With this, parent tasks will exit() before the system goes under OOM.
So, it's difficult to know the whole image of forkbomb.

This patch introduce a subsystem to track mm's history and records it
even after the task exit. (It will be flushed periodically.)

I tested with several forkbomb cases and this patch seems work fine.

Maybe some more 'heuristics' can be added....but I think this simple
one works enough. Any comments are welcome.
Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
