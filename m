Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB26MJqN010910
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Dec 2008 15:22:19 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E13745DD75
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 15:22:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1189445DD6F
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 15:22:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D99471DB8042
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 15:22:18 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 87E0F1DB803C
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 15:22:18 +0900 (JST)
Date: Tue, 2 Dec 2008 15:21:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] cgroup: fix pre_destroy and semantics of
 css->refcnt
Message-Id: <20081202152129.d795da96.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4934D27B.4020904@cn.fujitsu.com>
References: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>
	<20081201150208.6b24506b.kamezawa.hiroyu@jp.fujitsu.com>
	<4934D27B.4020904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 02 Dec 2008 14:15:23 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Now, final check of refcnt is done after pre_destroy(), so rmdir() can fail
> > after pre_destroy().
> > memcg set mem->obsolete to be 1 at pre_destroy and this is buggy..
> > 
> > Several ways to fix this can be considered. This is an idea.
> > 
> 
> I don't see what's the difference with css_under_removal() in this patch and
> cgroup_is_removed() which is currently available.
> 
> CGRP_REMOVED flag is set in cgroup_rmdir() when it's confirmed that rmdir can
> be sucessfully performed.
> 
> So mem->obsolete can be replaced with:
> 
> bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
> {
> 	return cgroup_is_removed(mem->css.cgroup);
> }
> 
> Or am I missing something?
> 
Yes.
	1. "cgroup" and "css" object are different object.
	2. css object may not be freed at destroy() (as current memcg does.)

Some of css objects cannot be freed even when there are no tasks because
of reference from some persistent object or temporal refcnt.

Please consider css_under_removal() as a kind of css_tryget() which doesn't
increase any refcnt.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
