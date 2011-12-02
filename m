Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9FB6B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 00:46:21 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BAE6F3EE0C1
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 14:46:16 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A119E3266C3
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 14:46:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8699445DE6C
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 14:46:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 74BEF1DB8051
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 14:46:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 250191DB804A
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 14:46:16 +0900 (JST)
Date: Fri, 2 Dec 2011 14:44:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [3.2-rc3] OOM killer doesn't kill the obvious memory hog
Message-Id: <20111202144441.4c2ff29e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111202033148.GA7046@dastard>
References: <20111201093644.GW7046@dastard>
	<20111201185001.5bf85500.kamezawa.hiroyu@jp.fujitsu.com>
	<20111201124634.GY7046@dastard>
	<alpine.DEB.2.00.1112011432110.27778@chino.kir.corp.google.com>
	<20111202015921.GZ7046@dastard>
	<20111202033148.GA7046@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2 Dec 2011 14:31:48 +1100
Dave Chinner <david@fromorbit.com> wrote:

> So, it's a distro bug - sshd should never be started from from udev
> context because of this inherited oom_score_adj thing.
> Interestingly, the ifup ssh restart script says this:
> 
> # We'd like to use 'reload' here, but it has some problems; see #502444.
> if [ -x /usr/sbin/invoke-rc.d ]; then
>         invoke-rc.d ssh restart >/dev/null 2>&1 || true
> else
>         /etc/init.d/ssh restart >/dev/null 2>&1 || true
> fi
> 
> Bug 502444 describes the exact startup race condition that I've just
> found. It does a ssh server restart because reload causes the sshd
> server to fail to start if a start is currently in progress.  So,
> rather than solving the start vs reload race condition, it got a
> bandaid (use restart to restart sshd from the reload context) and
> left it as a landmine.....
> 

Thank you for chasing. 
Hm, BTW, do you think this kind of tracepoint is useful for debugging ?
This patch is just an example.

==
