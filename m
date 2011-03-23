Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 195FF8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 00:30:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 301183EE0BD
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:30:38 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 12E3045DE55
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:30:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F004B45DE4E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:30:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E239CE18001
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:30:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A48281DB8038
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:30:37 +0900 (JST)
Date: Wed, 23 Mar 2011 13:23:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/3] A forkbomb killer and mm tracking system
Message-Id: <20110323132323.f223fc6d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "rientjes@google.com" <rientjes@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, avagin@openvz.org, kirill@shutemov.name

Hi,

This is a new one. All design was changed.

While testing Andrey's case, I confirmed I need to reboot the system by
power off when I ran a fork-bomb. The speed of fork() is much faster
than some smart killing as pkill(1) and oom-killer cannot reach the speed.
I wonder it's better to have a fork-bomb killer.


In previous version, the kernel finds guilty processes(forkbomb) by chasing
task's process tree chain. But, it cannot kill a famous forkbomb

# forkbomb(){ forkbomb|forkbomb & } ; forkbomb
(see wikipedia.)

To kill this bomb, we need to track dead processes. This version uses
a mm_struct tracking system. All mm_structs are recorded with its
parent-chidlren, start_time information. (A periodic work will erase
that information.) And forkbomb killer kills tasks by using the map
of relationship among mm_structs.

I tested with
# forkbomb(){ forkbomb|forkbomb & } ; forkbomb
# make -j Kernel
# Andrey's case

and all bombs are removed by ForkBomb Killer. 
Maybe more tests and development will be required.

(If there is swap, it's hard to kill bombs automatically....I used Sysrq.)

Any comments are welcome.

Thanks,
-Kame











--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
