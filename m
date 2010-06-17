Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 724916B01AC
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:39 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1paQT005933
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:36 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 359D145DE52
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 03C1C45DE56
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FE28E38006
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C6172E18003
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/9] oom: oom_kill_process() doesn't select kthread child
In-Reply-To: <20100616150232.GC9278@barrios-desktop>
References: <20100616203126.72DD.A69D9226@jp.fujitsu.com> <20100616150232.GC9278@barrios-desktop>
Message-Id: <20100617084154.FB33.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Jun 16, 2010 at 08:32:08PM +0900, KOSAKI Motohiro wrote:
> > Now, select_bad_process() have PF_KTHREAD check, but oom_kill_process
> > doesn't. It mean oom_kill_process() may choose wrong task, especially,
> > when the child are using use_mm().
> Now oom_kill_process is called by three place. 
> 
> 1. mem_cgroup_out_of_memory
> 2. out_of_memory with sysctl_oom_kill_allocating_task
> 3. out_of_memory with non-sysctl_oom_kill_allocating_task
> 
> I think it's no problem in 1 and 3 since select_bad_process already checks
> PF_KTHREAD. The problem in in 2. 
> So How about put the check before calling oom_kill_process in case of
> sysctl_oom_kill_allocating task?
> 
> if (sysctl_oom_kill_allocating_task) {
>         if (!current->flags & PF_KTHREAD)
>                 oom_kill_process();
>                         
> It can remove duplicated PF_KTHREAD check in select_bad_process and
> oom_kill_process. 

This patch changed child selection logic. select_bad_process() doesn't
check victim's child. IOW, this is necessary when all 1-3.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
