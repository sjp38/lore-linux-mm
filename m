Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B0C696B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 00:11:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5FA0F3EE0BD
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:11:02 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 46D5A45DF56
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:11:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D8C245DF54
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:11:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2027C1DB802C
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:11:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D9B861DB8038
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:11:01 +0900 (JST)
Message-ID: <4DE46A4B.40401@jp.fujitsu.com>
Date: Tue, 31 May 2011 13:10:51 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system have
 > gigabytes memory  (aka CAI founded issue)
References: <2135926037.315785.1306805582148.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <2135926037.315785.1306805582148.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: caiqian@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

(2011/05/31 10:33), CAI Qian wrote:
> Hello,
> 
> Have tested those patches rebased from KOSAKI for the latest mainline.
> It still killed random processes and recevied a panic at the end by
> using root user. The full oom output can be found here.
> http://people.redhat.com/qcai/oom

You ran fork-bomb as root. Therefore unprivileged process was killed at first.
It's no random. It's intentional and desirable. I mean

- If you run the same progream as non-root, python will be killed at first.
  Because it consume a lot of memory than daemons.
- If you run the same program as root, non root process and privilege explicit
  dropping processes (e.g. irqbalance) will be killed at first.


Look, your log says, highest oom score process was killed first.

Out of memory: Kill process 5462 (abrtd) points:393 total-vm:262300kB, anon-rss:1024kB, file-rss:0kB
Out of memory: Kill process 5277 (hald) points:303 total-vm:25444kB, anon-rss:1116kB, file-rss:0kB
Out of memory: Kill process 5720 (sshd) points:258 total-vm:97684kB, anon-rss:824kB, file-rss:0kB
Out of memory: Kill process 5457 (pickup) points:236 total-vm:78672kB, anon-rss:768kB, file-rss:0kB
Out of memory: Kill process 5451 (master) points:235 total-vm:78592kB, anon-rss:796kB, file-rss:0kB
Out of memory: Kill process 5458 (qmgr) points:233 total-vm:78740kB, anon-rss:764kB, file-rss:0kB
Out of memory: Kill process 5353 (sshd) points:189 total-vm:63992kB, anon-rss:620kB, file-rss:0kB
Out of memory: Kill process 1626 (dhclient) points:129 total-vm:9148kB, anon-rss:484kB, file-rss:0kB


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
