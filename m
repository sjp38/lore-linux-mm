Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8031A6B00BD
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 22:30:12 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K2U6TU014021
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 20 Oct 2010 11:30:07 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A21145DE56
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:30:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BA9C45DE4E
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:30:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 277EDE08004
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:30:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 126C6E1800D
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:29:59 +0900 (JST)
Date: Wed, 20 Oct 2010 11:24:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 02/11] memcg: document cgroup dirty memory interfaces
Message-Id: <20101020112431.b76b861d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101020101421.05325710.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-3-git-send-email-gthelen@google.com>
	<20101019172744.45e0a8dc.nishimura@mxp.nes.nec.co.jp>
	<xr93lj5t5245.fsf@ninji.mtv.corp.google.com>
	<20101020091109.ccd7b39a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101020094821.75c70fe3.nishimura@mxp.nes.nec.co.jp>
	<20101020101421.05325710.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Oct 2010 10:14:21 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 20 Oct 2010 09:48:21 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Wed, 20 Oct 2010 09:11:09 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Tue, 19 Oct 2010 14:00:58 -0700
> > > Greg Thelen <gthelen@google.com> wrote:
> > > 
> > (snip)
> > > > +When use_hierarchy=0, each cgroup has independent dirty memory usage and limits.
> > > > +
> > > > +When use_hierarchy=1, a parent cgroup increasing its dirty memory usage will
> > > > +compare its total_dirty memory (which includes sum of all child cgroup dirty
> > > > +memory) to its dirty limits.  This keeps a parent from explicitly exceeding its
> > > > +dirty limits.  However, a child cgroup can increase its dirty usage without
> > > > +considering the parent's dirty limits.  Thus the parent's total_dirty can exceed
> > > > +the parent's dirty limits as a child dirties pages.
> > > 
> > > Hmm. in short, dirty_ratio in use_hierarchy=1 doesn't work as an user expects.
> > > Is this a spec. or a current implementation ?
> > > 
> > > I think as following.
> > >  - add a limitation as "At setting chidlren's dirty_ratio, it must be below parent's.
> > >    If it exceeds parent's dirty_ratio, EINVAL is returned."
> > > 
> > > Could you modify setting memory.dirty_ratio code ?
> > > Then, parent's dirty_ratio will never exceeds its own. (If I understand correctly.)
> > > 
> > > "memory.dirty_limit_in_bytes" will be a bit more complecated, but I think you can.
> > > 
> > I agree.
> > 
> > At the first impression, this limitation seems a bit overkill for me, because
> > we allow memory.limit_in_bytes of a child bigger than that of parent now.
> > But considering more, the situation is different, because usage_in_bytes never
> > exceeds limit_in_bytes.
> > 
> 
> I'd like to consider a patch.
> Please mention that "use_hierarchy=1 case depends on implemenation." for now.
> 

BTW, how about supporing dirty_limit_in_bytes when use_hierarchy=0 or leave it as
broken when use_hierarchy=1 ?
It seems we can only support dirty_ratio when hierarchy is used.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
