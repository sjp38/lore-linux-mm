Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 965EC6B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 22:01:51 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0E31mAH031770
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Jan 2009 12:01:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 27AEF45DD76
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 12:01:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 04BB845DD75
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 12:01:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FBA21DB803E
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 12:01:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E4FA91DB8041
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 12:01:47 +0900 (JST)
Date: Wed, 14 Jan 2009 12:00:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/4] cgroup-memcg fix frequent EBUSY at rmdir
Message-Id: <20090114120044.2ecf13db.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830901131848gf7f6996iead1276bc50753b8@mail.gmail.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901131848gf7f6996iead1276bc50753b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jan 2009 18:48:43 -0800
Paul Menage <menage@google.com> wrote:

> On Thu, Jan 8, 2009 at 1:35 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > +       if (ret == -EAGAIN) { /* subsys asks us to retry later */
> > +               mutex_unlock(&cgroup_mutex);
> > +               cond_resched();
> > +               goto retry;
> > +       }
> 
> This spinning worries me a bit. It might be better to do an
> interruptible sleep until the relevant CSS's refcount goes down to
> zero. 

Hmm, add wait_queue to css and wake it up at css_put() ?

like this ?
==
__css_put()
{
	if (atomi_dec_return(&css->refcnt) == 1) {
		if (notify_on_release(cgrp) {
			.....
		}
		if (someone_waiting_rmdir(css)) {
			wake_up_him().
		}
	}
}
==

> And is there no way that the memory controller can hang on to a
> reference indefinitely, if the cgroup still has some pages charged to
> it?
> 
pre_destroy() is for that.  Now, If there are still references from "page"
after pre_destroy(), it's bug.
swap-in after pre_destory() may add new refs from pages.
(I implemented reference from "swap" to be memcg internal refcnt not to css.)

Allowing Ctrl-C/alarm() here by signal_pending() will be better, anyway.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
