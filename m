Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBAANjYN011851
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Dec 2008 19:23:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E092145DE4F
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 19:23:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C7A4E45DD72
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 19:23:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B1FDD1DB8038
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 19:23:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CC401DB803F
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 19:23:44 +0900 (JST)
Message-ID: <61242.10.75.179.61.1228904624.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <6599ad830812100100i54132600he52504b4785542ec@mail.gmail.com>
References: <20081205172642.565661b1.kamezawa.hiroyu@jp.fujitsu.com><20081205172845.2b9d89a5.kamezawa.hiroyu@jp.fujitsu.com><6599ad830812050139l5797f16kaf511f831b09e8f4@mail.gmail.com><62469.10.75.179.62.1228476245.squirrel@webmail-b.css.fujitsu.com>
    <6599ad830812100100i54132600he52504b4785542ec@mail.gmail.com>
Date: Wed, 10 Dec 2008 19:23:44 +0900 (JST)
Subject: Re: [RFC][PATCH 1/4] New css->refcnt implementation.
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Paul Menage said:
> On Fri, Dec 5, 2008 at 3:24 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>> The basic rule is that you're only supposed to increment the css
>>> refcount if you have:
>>>
>>> - a reference to a task in the cgroup (that is pinned via task_lock()
>>> so it can't be moved away)
>>> or
>>> - an existing reference to the css
>>>
>> My problem is that we can do css_get() after pre_destroy() and
>> css's refcnt goes down to 0.
>
> But where are you getting the reference from in order to do css_get()?
> Which call in mem cgroup are you concerned about?
>
mem_cgroup_try_charge_swapin() at el. all swap-in codes.
In that functions, follwoing occurs.
==
    assume swp_entry which is being swapped-in
    lookup swap_cgroup for swp_entry.
    get memcg from swap_cgroup.
    charge() against memcg got by swap_cgroup. charge() will do css_get()
==
Currently, mem_cgroup->obsolete is used for making this never happen.
But, mem_cgroup->obsolete flag is broken,now.
I'm looking for alternative. (see other patches. I know there are several
ways to go.)

*AND* any kinds of hierarchy-tree-walk algorithm may call css_get() against
cgroup under rmdir() if it's not marked as REMOVED.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
