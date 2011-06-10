Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 278BF6B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 20:20:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 01F803EE0BD
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:20:53 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE48045DE67
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:20:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C74F445DE61
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:20:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B8CCD1DB8038
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:20:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 874E81DB8037
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 09:20:52 +0900 (JST)
Date: Fri, 10 Jun 2011 09:13:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 3.0rc2 oops in mem_cgroup_from_task
Message-Id: <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
References: <20110609212956.GA2319@redhat.com>
	<BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com>
	<BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Thu, 9 Jun 2011 16:42:09 -0700
Ying Han <yinghan@google.com> wrote:

> ++cc Hugh who might have seen similar crashes on his machine.
> 

Thank you for forwarding. Hmm. It seems the panic happens at khugepaged's 
page collapse_huge_page().

==
        count_vm_event(THP_COLLAPSE_ALLOC);
        if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
==
It passes target mm to memcg and memcg gets a cgroup by
==
 mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
==
Panic here means....mm->owner's task_subsys_state contains bad pointer ?

I'll dig. Thanks.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
