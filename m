Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id mBAAeEQd020911
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 02:40:14 -0800
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by zps75.corp.google.com with ESMTP id mBAAeDWT022983
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 02:40:13 -0800
Received: by qyk10 with SMTP id 10so627013qyk.18
        for <linux-mm@kvack.org>; Wed, 10 Dec 2008 02:40:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 10 Dec 2008 02:40:13 -0800
Message-ID: <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 9, 2008 at 3:06 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> better name for new flag is welcome.
>
> ==
> Because pre_destroy() handler is moved out to cgroup_lock() for
> avoiding dead-lock, now, cgroup's rmdir() does following sequence.
>
>        cgroup_lock()
>        check children and tasks.
>        (A)
>        cgroup_unlock()
>        (B)
>        pre_destroy() for subsys;-----(1)
>        (C)
>        cgroup_lock();
>        (D)
>        Second check:check for -EBUSY again because we released the lock.
>        (E)
>        mark cgroup as removed.
>        (F)
>        unlink from lists.
>        cgroup_unlock();
>        dput()
>        => when dentry's refcnt goes down to 0
>                destroy() handers for subsys

The reason for needing this patch is because of the non-atomic locking
in cgroup_rmdir() that was introduced due to the circular locking
dependency between the hotplug lock and the cgroup_mutex.

But rather than adding a whole bunch more complexity, this looks like
another case that could be solved by the hierarchy_mutex patches that
I posted a while ago.

Those allow the cpuset hotplug notifier (and any other subsystem that
wants a stable hierarchy) to take ss->hierarchy_mutex, to prevent
mkdir/rmdir/bind in its hierarchy, which helps to remove the deadlock
that the above dropping of cgroup_mutex was introduced to work around.

>
> Considering above sequence, new tasks can be added while
>        (B) and (C)
> swap-in recored can be charged back to a cgroup after pre_destroy()
>        at (C) and (D), (E)
> (means cgrp's refcnt not comes from task but from other persistent objects.)

Which "persistent object" are you getting the css refcount from?

Is the problem that swap references aren't refcounted because you want
to avoid swap from keeping a cgroup alive? But you still want to be
able to do css_get() on the mem_cgroup* obtained from a swap
reference, and be safely synchronized with concurrent rmdir operations
without having to take a heavy lock?

The solution that I originally tried to use for this in an early
version of cgroups (but dropped as I thought it was not needed) was to
treat css->refcount as follows:

 0 => trying to remove or removed
 1 => normal state with no additional refs

So to get a reference on a possibly removed css we'd have:

int css_tryget(css) {
  while (!atomic_inc_not_zero(&css->refcount)) {
    if (test_bit(CSS_REMOVED, &css->flags)) {
      return 0;
    }
  }
  return 1;
}

and cgroup_rmdir would do:

for_each_subsys() {
  if (cmpxchg(&css->refcount, 0, -1)) {
    // busy, roll back -1s to 0s, give error
    ...
  }
}
// success
for_each_subsys() {
  set_bit(CSS_REMOVED, &css->flags);
}

This makes it easy to have weak references to a css that can be
dropped in a destroy() callback. Would this maybe even remove the need
for mem_cgroup_pre_destroy()?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
