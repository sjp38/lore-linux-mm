Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5C3B86B0062
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 05:07:18 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5H97SEr021235
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Jun 2009 18:07:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A3EC45DE52
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 18:07:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DA90E45DE4D
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 18:07:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C5EC21DB8040
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 18:07:27 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 80F441DB803C
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 18:07:27 +0900 (JST)
Date: Wed, 17 Jun 2009 18:05:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX] memcg: rmdir doesn't return
Message-Id: <20090617180555.98f88d09.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090617073521.GG7646@balbir.in.ibm.com>
References: <20090615171715.53743dce.kamezawa.hiroyu@jp.fujitsu.com>
	<20090616114735.c7a91b8b.nishimura@mxp.nes.nec.co.jp>
	<20090616140050.4172f988.kamezawa.hiroyu@jp.fujitsu.com>
	<20090616153810.fd710c5b.nishimura@mxp.nes.nec.co.jp>
	<20090616154820.c9065809.kamezawa.hiroyu@jp.fujitsu.com>
	<20090616174436.5a4b6577.kamezawa.hiroyu@jp.fujitsu.com>
	<20090617045643.GE7646@balbir.in.ibm.com>
	<20090617141109.8d9a47ea.kamezawa.hiroyu@jp.fujitsu.com>
	<20090617054955.GF7646@balbir.in.ibm.com>
	<20090617152748.6b6c643e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090617073521.GG7646@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jun 2009 13:05:21 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-17 15:27:48]:

> > And even if release_agent() is called, it will do rmdir and see -EBUSY.
> 
> Because of hierarchy? But we need to cleanup hierarchy before rmdir()
> no?
> 

Assume following (I think my patch in git explains this.)

/cgroup/A/01
	 /02
	 /03
	 /04
A and 01,02,03,04 is under hierarchy.

Now, 04 has no task and it can be removed by rmdir.
Case 1) 01,02,03 hits memory limit heavily and hirerchical memory recalim
walks. In this case, 04's css refcnt is got/put very often.
Case 2) read statistics of cgroup/A very frequently, this means
css_put/get is called very often agatinst 04.

Case 3)....

04's refcnt is put/get when other group under hierarchy is busy and
rmdir against 04 returns -EBUSY in some amount of possiblitly.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
