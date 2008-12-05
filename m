Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB5BO7IO028434
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 20:24:07 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED54845DE5D
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 20:24:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E5A945DE55
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 20:24:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89E2B1DB803F
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 20:24:06 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B72E1DB803B
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 20:24:06 +0900 (JST)
Message-ID: <62469.10.75.179.62.1228476245.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <6599ad830812050139l5797f16kaf511f831b09e8f4@mail.gmail.com>
References: <20081205172642.565661b1.kamezawa.hiroyu@jp.fujitsu.com><20081205172845.2b9d89a5.kamezawa.hiroyu@jp.fujitsu.com>
    <6599ad830812050139l5797f16kaf511f831b09e8f4@mail.gmail.com>
Date: Fri, 5 Dec 2008 20:24:05 +0900 (JST)
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

Thank you for comments.

Paul Menage said:
> On Fri, Dec 5, 2008 at 12:28 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>
>>
>> Now, the last check of refcnt is done after pre_destroy(), so rmdir()
>> can fail
>> after pre_destroy(). But memcg set mem->obsolete to be 1 at pre_destroy.
>> This is a bug. So, removing memcg->obsolete flag is sane.
>>
>> But there is no interface to confirm "css" is oboslete or not. I.e.
>> there is
>> no flag to check whether we can increase css_refcnt or not!
>
> The basic rule is that you're only supposed to increment the css
> refcount if you have:
>
> - a reference to a task in the cgroup (that is pinned via task_lock()
> so it can't be moved away)
> or
> - an existing reference to the css
>
My problem is that we can do css_get() after pre_destroy() and
css's refcnt goes down to 0.

>>
>> This patch changes this css->refcnt rule as following
>>        - css->refcnt is no longer private counter, just point to
>>          css->cgroup->css_refcnt.
>
> The reason I didn't do this is that I'd like to keep the ref counts
> separate to make it possible to add/remove subsystems from a hiearchy
> - if they're all mingled into a single refcount, it's impossible to
> tell if a particular subsystem has refcounts.
>
It's not problem. please see memcg, it has its own refcnt.
and memcg subsystem is not destroyed at destroy(), now.

What I want to is atomic check to

   "Can I access css->group ?"

   I once tried to do
    --
    rcu_read_lock();
    css_get(&memcg->css);
    if (cgroup_is_removed(&memcg->css.cgroup)) {
         css_put(&memcg->css);
         return 0;
    }
    --
    But this seems not to work.


>>
>>        - css_put() is changed not to call notify_on_release().
>>
>>          From documentation, notify_on_release() is called when there is
>> no
>>          tasks/children in cgroup. On implementation, notify_on_release
>> is
>>          not called if css->refcnt > 0.
>
> The documentation is a little inaccurate - it's called when the cgroup
> is removable. In the original cpusets this implied that there were no
> tasks or children; in cgroups, a refcount can keep the group alive
> too, so it's right to not call notify_on_release if there are
> remaining refcounts.
>

>>          This is problem. Memcg has css->refcnt by each page even when
>>          there are no tasks. Release handler will be never called.
>
> Right, because it can't remove the dir if there are still refcounts.
>
> Early in the development of cgroups I did have a css refcount scheme
> similar to what you have, with tryget, etc, but still with separate
> refcounts for each subsystem; I got rid of it since it seemed more
> complicated than we needed at the time. But I'll see if I can dig it
> up.
O.K.

I'll not do extra work on this "notify handler" for a while.
But please, it's now broken.

Hmm...but removing memcg->obsolete flag is difficult. Because
I can't guarantee memcg->css.cgroup is valid pointer.

Can I add a flag CSS_REMOVED ? (set after CGROUP_REMOVED flag) ?
Then, I'll be able to have some work around.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
