Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BBCE76B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 20:41:14 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o970fCKq001233
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Oct 2010 09:41:12 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F3FAD45DE54
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:41:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B1CC845DE51
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:41:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 993351DB8017
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:41:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D30AE38004
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:41:11 +0900 (JST)
Date: Thu, 7 Oct 2010 09:35:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 04/10] memcg: disable local interrupts in
 lock_page_cgroup()
Message-Id: <20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010 09:15:34 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> First of all, we could add your patch as it is and I don't expect any
> regression report about interrupt latency.
> That's because many embedded guys doesn't use mmotm and have a
> tendency to not report regression of VM.
> Even they don't use memcg. Hmm...
> 
> I pass the decision to MAINTAINER Kame and Balbir.
> Thanks for the detail explanation.
> 

Hmm. IRQ delay is a concern. So, my option is this. How do you think ?

1. remove local_irq_save()/restore() in lock/unlock_page_cgroup().
   yes, I don't like it.

2. At moving charge, do this:
	a) lock_page()/ or trylock_page()
	b) wait_on_page_writeback()
	c) do move_account under lock_page_cgroup().
	c) unlock_page()


Then, Writeback updates will never come from IRQ context while
lock/unlock_page_cgroup() is held by move_account(). There will be no race.

Do I miss something ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
