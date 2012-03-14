Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A32F26B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 20:30:05 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C28543EE0BB
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 09:30:03 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B2A245DE52
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 09:30:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4189B45DE51
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 09:30:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 294A0E08001
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 09:30:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C8E511DB8040
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 09:30:02 +0900 (JST)
Date: Wed, 14 Mar 2012 09:28:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC REPOST] cgroup: removing css reference drain wait during
 cgroup removal
Message-Id: <20120314092828.3321731c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120313163914.GD7349@google.com>
References: <20120312213155.GE23255@google.com>
	<20120312213343.GF23255@google.com>
	<20120313151148.f8004a00.kamezawa.hiroyu@jp.fujitsu.com>
	<20120313163914.GD7349@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, gthelen@google.com, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, Jens Axboe <axboe@kernel.dk>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 09:39:14 -0700
Tejun Heo <tj@kernel.org> wrote:

> Hello, KAMEZAWA.
> 
> On Tue, Mar 13, 2012 at 03:11:48PM +0900, KAMEZAWA Hiroyuki wrote:
> > The trouble for pre_destroy() is _not_ refcount, Memory cgroup has its own refcnt
> > and use it internally. The problem is 'charges'. It's not related to refcnt.
> 
> Hmmm.... yeah, I'm not familiar with memcg internals at all.  For
> blkcg, refcnt matters but if it doesn't for memcg, great.
> 
> > Cgroup is designed to exists with 'tasks'. But memory may not be related to any
> > task...just related to a cgroup.
> > 
> > But ok, pre_destory() & rmdir() is complicated, I agree.
> > 
> > Now, we prevent rmdir() if we can't move charges to its parent. If pre_destory()
> > shouldn't fail, I can think of some alternatives.
> > 
> >  * move all charges to the parent and if it fails...move all charges to
> >    root cgroup.
> >    (drop_from_memory may not work well in swapless system.)
> 
> I think this one is better and this shouldn't fail if hierarchical
> mode is in use, right?
> 

Right.


> > I think.. if pre_destory() never fails, we don't need pre_destroy().
> 
> For memcg maybe, blkcg still needs it.
> 
> > >   The last one seems more tricky.  On destruction of cgroup, the
> > >   charges are transferred to its parent and the parent may not have
> > >   enough room for that.  Greg told me that this should only be a
> > >   problem for !hierarchical case.  I think this can be dealt with by
> > >   dumping what's left over to root cgroup with a warning message.
> > 
> > I don't like warning ;) 
> 
> I agree this isn't perfect but then again failing rmdir isn't perfect
> either and given that the condition can be wholly avoided in
> hierarchical mode, which should be the default anyway (is there any
> reason to keep flat mode except for backward compatibility?), I don't
> think the trade off is too bad.
> 

One reason is 'performance'. You can see performance trouble when you
creates deep tree of memcgs in hierarchy mode. The deeper memcg tree,
the more res_coutners will be shared.

For example, libvirt creates cgroup tree as

	/cgroup/memory/libvirt/qemu/GuestXXX/....
        /cgroup/memory/libvirt/lxc/GuestXXX/...

No one don't want to count up 4 res_coutner, which is very very heavy,
for handling independent workloads of "Guest".

IIUC, in general, even in the processes are in a tree, in major case
of servers, their workloads are independent.
I think FLAT mode is the dafault. 'heararchical' is a crazy thing which
cannot be managed.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
