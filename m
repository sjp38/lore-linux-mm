Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id mB59d4tX004076
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 01:39:05 -0800
Received: from rv-out-0506.google.com (rvfb25.prod.google.com [10.140.179.25])
	by wpaz1.hot.corp.google.com with ESMTP id mB59d0kO031332
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 01:39:01 -0800
Received: by rv-out-0506.google.com with SMTP id b25so4281957rvf.49
        for <linux-mm@kvack.org>; Fri, 05 Dec 2008 01:39:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081205172845.2b9d89a5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081205172642.565661b1.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081205172845.2b9d89a5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 5 Dec 2008 01:39:00 -0800
Message-ID: <6599ad830812050139l5797f16kaf511f831b09e8f4@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/4] New css->refcnt implementation.
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 5, 2008 at 12:28 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>
>
> Now, the last check of refcnt is done after pre_destroy(), so rmdir() can fail
> after pre_destroy(). But memcg set mem->obsolete to be 1 at pre_destroy.
> This is a bug. So, removing memcg->obsolete flag is sane.
>
> But there is no interface to confirm "css" is oboslete or not. I.e. there is
> no flag to check whether we can increase css_refcnt or not!

The basic rule is that you're only supposed to increment the css
refcount if you have:

- a reference to a task in the cgroup (that is pinned via task_lock()
so it can't be moved away)
or
- an existing reference to the css

>
> This patch changes this css->refcnt rule as following
>        - css->refcnt is no longer private counter, just point to
>          css->cgroup->css_refcnt.

The reason I didn't do this is that I'd like to keep the ref counts
separate to make it possible to add/remove subsystems from a hiearchy
- if they're all mingled into a single refcount, it's impossible to
tell if a particular subsystem has refcounts.

>
>        - css_put() is changed not to call notify_on_release().
>
>          From documentation, notify_on_release() is called when there is no
>          tasks/children in cgroup. On implementation, notify_on_release is
>          not called if css->refcnt > 0.

The documentation is a little inaccurate - it's called when the cgroup
is removable. In the original cpusets this implied that there were no
tasks or children; in cgroups, a refcount can keep the group alive
too, so it's right to not call notify_on_release if there are
remaining refcounts.

>          This is problem. Memcg has css->refcnt by each page even when
>          there are no tasks. Release handler will be never called.

Right, because it can't remove the dir if there are still refcounts.

Early in the development of cgroups I did have a css refcount scheme
similar to what you have, with tryget, etc, but still with separate
refcounts for each subsystem; I got rid of it since it seemed more
complicated than we needed at the time. But I'll see if I can dig it
up.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
