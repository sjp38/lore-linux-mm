Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 203826B0085
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 05:10:53 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o979Ap27010279
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Oct 2010 18:10:51 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C962F45DE52
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 18:10:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C32445DE51
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 18:10:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6ED56E38003
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 18:10:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 244021DB8014
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 18:10:50 +0900 (JST)
Date: Thu, 7 Oct 2010 18:05:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: lock-free clear page writeback  (Was Re: [PATCH
 04/10] memcg: disable local interrupts in lock_page_cgroup()
Message-Id: <20101007180529.1240e79a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101007152422.c5919517.kamezawa.hiroyu@jp.fujitsu.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
	<20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
	<20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152422.c5919517.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Oct 2010 15:24:22 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Greg, I think clear_page_writeback() will not require _any_ locks with this patch.
> But set_page_writeback() requires it...
> (Maybe adding a special function for clear_page_writeback() is better rather than
>  adding some complex to switch() in update_page_stat())
> 

I'm testing a code like this.
==
       /* pc->mem_cgroup is unstable ? */
        if (unlikely(mem_cgroup_stealed(mem))) {
                /* take a lock against to access pc->mem_cgroup */
                if (!in_interrupt()) {
                        lock_page_cgroup(pc);
                        need_unlock = true;
                        mem = pc->mem_cgroup;
                        if (!mem || !PageCgroupUsed(pc))
                                goto out;
                } else if (idx == MEMCG_NR_FILE_WRITEBACK && (val < 0)) {
                        /* This is allowed */
                } else
                        BUG();
        }
==
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
