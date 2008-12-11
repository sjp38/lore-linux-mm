Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBB0MhXr019856
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Dec 2008 09:22:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9651345DD7D
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 09:22:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 74B8445DD7B
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 09:22:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 57D001DB803C
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 09:22:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 09D971DB8038
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 09:22:43 +0900 (JST)
Date: Thu, 11 Dec 2008 09:21:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
Message-Id: <20081211092150.b62f8c20.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830812101100v4dc7f124jded0d767b92e541a@mail.gmail.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	<20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
	<29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
	<6599ad830812101035v33dbc6cfh57aa5510f6d65d54@mail.gmail.com>
	<6599ad830812101100v4dc7f124jded0d767b92e541a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 2008 11:00:35 -0800
Paul Menage <menage@google.com> wrote:

> On Wed, Dec 10, 2008 at 10:35 AM, Paul Menage <menage@google.com> wrote:
> > On Wed, Dec 10, 2008 at 3:29 AM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >>
> >> (BTW, I don't like hierarchy-walk-by-small-locks approarch now because
> >>  I'd like to implement scan-and-stop-continue routine.
> >>  See how readdir() aginst /proc scans PID. It's very roboust against
> >>  very temporal PIDs.)
> >
> > So you mean that you want to be able to sleep, and then contine
> > approximately where you left off, without keeping any kind of
> > reference count on the last cgroup that you touched? OK, so in that
> > case I agree that you would need some kind of hierarch
> 
> Oops, didn't finish that sentence.
> 
> I agree that you'd need some kind of hierarchical-restart. But I'd
> like to play with / look at your cgroup-id patch more closely and see
> if we can come up with something simpler that still does what you
> want.
> 
Sure, I have to do, too. It's still too young.

> One particular problem with the patch as it stands is that the ids
> should be per-css, not per-cgroup, since a css can move between
> hierarchies and hence between cgroups. (Currently only at bind/unbind
> time, but it still results in a cgroup change).
> 

If per-css, looking up function will be
==
struct cgroup_subsys_state *cgroup_css_lookup(subsys_id, id)
==
Do you mean this ? 

ok, I'll implement and see what happens. Maybe I'll move hooks to prepare/destroy IDs
to subsys layer and assign ID only when subsys want IDs.

-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
