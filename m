Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C0C866B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 03:08:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5N78tVK012295
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 23 Jun 2009 16:08:55 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A36DA45DE51
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:08:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 725A745DE4E
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:08:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 576EF1DB8041
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:08:54 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FFCE1DB803E
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:08:54 +0900 (JST)
Date: Tue, 23 Jun 2009 16:07:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/2] memcg: cgroup fix rmdir hang
Message-Id: <20090623160720.36230fa2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

previous discussion was this => http://marc.info/?t=124478543600001&r=1&w=2

This patch tries to fix problem as
  - rmdir can sleep very very long if swap entry is shared between multiple
    cgroups

Now, cgroup's rmdir path does following

==
again:
	check there are no tasks and children group.
	call pre_destroy()
	check css's refcnt
	if (refcnt > 0) {
		sleep until css's refcnt goes down to 0.
		goto again
	}
==

Unfortunately, memory cgroup does following at charge.

	css_get(&memcg->css)
	....
	charge(memcg) (increase USAGE)
	...
And this "memcg" is not necessary to include the caller, task.

pre_destroy() tries to reduce memory usage until USAGE goes down to 0.
Then, there is a race that
	- css's refcnt > 0 (and memcg's usage > 0)
	- rmdir() caller sleeps until css->refcnt goes down 0.
	- But to make css->refcnt be 0, pre_destroy() should be called again.

This patch tries to fix this in asyhcnrounos way (i.e. without big lock.)
Any comments are welcome.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
