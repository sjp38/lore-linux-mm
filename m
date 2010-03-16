Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 05A1C6B01FC
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 20:05:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2G04xOW006407
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Mar 2010 09:04:59 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F3B145DE60
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:04:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D8FF45DE4D
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:04:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B5CA1DB803A
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:04:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 36CC21DB8037
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:04:58 +0900 (JST)
Date: Tue, 16 Mar 2010 09:01:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] memcg: oom wakeup filter
Message-Id: <20100316090124.ab20e093.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100315145013.ee5919fd.akpm@linux-foundation.org>
References: <20100312143137.f4cf0a04.kamezawa.hiroyu@jp.fujitsu.com>
	<20100315145013.ee5919fd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kirill@shutemov.name" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Mar 2010 14:50:13 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 12 Mar 2010 14:31:37 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > +static int memcg_oom_wake_function(wait_queue_t *wait,
> > +	unsigned mode, int sync, void *arg)
> > +{
> > +	struct mem_cgroup *wake_mem = (struct mem_cgroup *)arg;
> > +	struct oom_wait_info *oom_wait_info;
> > +
> > +	/* both of oom_wait_info->mem and wake_mem are stable under us */
> > +	oom_wait_info = container_of(wait, struct oom_wait_info, wait);
> > +
> > +	if (oom_wait_info->mem == wake_mem)
> > +		goto wakeup;
> > +	/* if no hierarchy, no match */
> > +	if (!oom_wait_info->mem->use_hierarchy || !wake_mem->use_hierarchy)
> > +		return 0;
> > +	/* check hierarchy */
> > +	if (!css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css) &&
> > +	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css))
> > +		return 0;
> > +
> > +wakeup:
> > +	return autoremove_wake_function(wait, mode, sync, arg);
> > +}
> 
> What are the locking rules for calling css_is_ancestor()?

css_is_ancestor is checking css->id (and hierarchy stack). What we need here is
to guarantee css is valid object.

Here, we have reference count of both of oom_wait_info->mem and wake_mem.
Then, ->css is always vaild and it's "id" is stable under us.

Hmm, maybe this comment is too short.
/* both of oom_wait_info->mem and wake_mem are stable under us */
I'll prepare some update.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
