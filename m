Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 554D36B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:59:06 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBFNx2El016447
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 08:59:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9922B45DE50
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 08:59:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 76BA545DE4F
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 08:59:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 588B41DB8038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 08:59:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F02321DB803A
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 08:59:01 +0900 (JST)
Date: Wed, 16 Dec 2009 08:55:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC v2 1/4] cgroup: implement eventfd-based generic API
  for notifications
Message-Id: <20091216085552.91ebc559.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab0912150703qcfe6458paa7da71cb032cb93@mail.gmail.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	<cc557aab0912150111k41517b41t8999568db3bd8daa@mail.gmail.com>
	<20091215183533.1a1e87d9.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab0912150703qcfe6458paa7da71cb032cb93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009 17:03:37 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> >> > + A  A  A  /*
> >> > + A  A  A  A * Unregister events and notify userspace.
> >> > + A  A  A  A * FIXME: How to avoid race with cgroup_event_remove_work()
> >> > + A  A  A  A * A  A  A  A which runs from workqueue?
> >> > + A  A  A  A */
> >> > + A  A  A  mutex_lock(&cgrp->event_list_mutex);
> >> > + A  A  A  list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
> >> > + A  A  A  A  A  A  A  cgroup_event_remove(event);
> >> > + A  A  A  A  A  A  A  eventfd_signal(event->eventfd, 1);
> >> > + A  A  A  }
> >> > + A  A  A  mutex_unlock(&cgrp->event_list_mutex);
> >> > +
> >> > +out:
> >> > A  A  A  A return ret;
> >> > A }
> >
> > How ciritical is this FIXME ?
> > But Hmm..can't we use RCU ?
> 
> It's not reasonable to have RCU here, since event_list isn't mostly-read.
> 
ok.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
