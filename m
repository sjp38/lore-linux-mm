Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C3BB76B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 19:20:42 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 387E83EE0BB
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:20:40 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 201D845DE57
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:20:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F38B445DE56
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:20:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E68351DB8037
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:20:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D3981DB8038
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:20:39 +0900 (JST)
Date: Wed, 19 Jan 2011 09:14:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [LSF/MM TOPIC] memory control groups
Message-Id: <20110119091429.e69ce1f8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110118102006.GL2212@cmpxchg.org>
References: <20110117191359.GI2212@cmpxchg.org>
	<20110118101057.51d20ed7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110118084013.GK2212@cmpxchg.org>
	<20110118181757.2aefcf87.kamezawa.hiroyu@jp.fujitsu.com>
	<20110118102006.GL2212@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Michel Lespinasse <walken@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011 11:20:06 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Tue, Jan 18, 2011 at 06:17:57PM +0900, KAMEZAWA Hiroyuki wrote: 
> > > > - I'm not sure PCG_MIGRATION. It's for avoiding races.
> > > 
> > > That's also a scary patch...  Yeah, it's to prevent uncharging of
> > > oldpage in case migration fails and it has to be reused.  I changed
> > > the migration sequence for memcg a bit so that we don't have to do
> > > that anymore.  It survived basic testing.
> > > 
> > 
> > Hmm. I saw level down of migration under memcg several times. So, I don't
> > want to modify running one without enough reason.
> > I guess all SECTION_BITS can be encoded to pc->flags without diet of flags.
> 
> That's true, there is enough room for that.
> 
> Those reduction patches I only wrote to also pack the pc->mem_cgroup
> ID into pc->flags, but these are two independent problems.
> 

That packing is dangerous because we have lock bit on pc->flags and
some access to pc->mem_cgroup is lockless. IIUC, it's difficult to
avoid race with modifying pc->mem_cgroup.
Hm, if we remove PCG_ACCT_LRU, it may be possible but I'm not sure
how FILESTAT etc. is safe.


> I would not have finished the patch only for that one tiny flag, but
> it actually saved code and made it IMO a bit easier to understand.  I
> consider this a serious upside of code that has a history of breaking.
> 
> But one at the time, first I will finish testing and benchmarking the
> pc->page removal.
> 
Sure.

> > > E.g. I have a suspicion that we might be able to do dirty accounting
> > > without all the flags (we have them in the page anyway!) but use
> > > proportionals instead.  It's not page-accurate, but I think the
> > > fundamental problem is solved: when the dirty ratio is exceeded,
> > > throttle the cgroup with the biggest dirty share.
> > 
> > Using proportionals is a choice. But, IIUC, users of memcg wants 
> > something like /proc/meminfo. It doesn't match.
> > If I'm an user of container, I want an information like /proc/meminfo for
> > container.
> 
> I totally agree that this is information that needs exporting.
> 
> But you can easily calculate an absolute number of bytes by applying a
> memcg's relative proportion to the absolute amount of dirty pages for
> example.  The only difference is that it probably won't be 100%
> accurate, but a few pages difference should really not matter for
> user-visible statistics.
> 
> No?
> 
With proportionals, we can't handle account moving between cgroups.
That means rmdir, force_empty, task_move can break dirty statistics
into mess.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
