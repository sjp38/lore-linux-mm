Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4979C6B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 07:08:49 -0400 (EDT)
Date: Thu, 15 Oct 2009 20:08:39 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH 1/8] cgroup: introduce cancel_attach()
Message-Id: <20091015200839.f6c01bdb.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <6599ad830910150037j7aca0020mfbe29d6c03befbf7@mail.gmail.com>
References: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
	<20091013135027.c60285a8.nishimura@mxp.nes.nec.co.jp>
	<6599ad830910150037j7aca0020mfbe29d6c03befbf7@mail.gmail.com>
Reply-To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Thank you for your comments.

On Thu, 15 Oct 2009 00:37:23 -0700
Paul Menage <menage@google.com> wrote:
> On Mon, Oct 12, 2009 at 9:50 PM, Daisuke Nishimura
> <nishimura@mxp.nes.nec.co.jp> wrote:
> > A int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
> > A {
> > A  A  A  A int retval = 0;
> > - A  A  A  struct cgroup_subsys *ss;
> > + A  A  A  struct cgroup_subsys *ss, *fail = NULL;
> 
> Maybe give this a more descriptive name, such as "failed_subsys" ?
> 
will fix.

> > @@ -1553,8 +1553,10 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
> > A  A  A  A for_each_subsys(root, ss) {
> > A  A  A  A  A  A  A  A if (ss->can_attach) {
> > A  A  A  A  A  A  A  A  A  A  A  A retval = ss->can_attach(ss, cgrp, tsk, false);
> > - A  A  A  A  A  A  A  A  A  A  A  if (retval)
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  return retval;
> > + A  A  A  A  A  A  A  A  A  A  A  if (retval) {
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  fail = ss;
> 
> Comment here on why you set "fail" ?
> > +out:
> > + A  A  A  if (retval)
> > + A  A  A  A  A  A  A  for_each_subsys(root, ss) {
> > + A  A  A  A  A  A  A  A  A  A  A  if (ss == fail)
> 
> Comment here?
> 
"fail" is used to call ->cancel_attach() only for subsystems
->can_attach() of which have succeeded.

> The problem with this API is that the subsystem doesn't know how long
> it needs to hold on to the potential rollback state for. The design
> for transactional cgroup attachment that I sent out over a year ago
> presented a more robust API, but I've not had time to work on it. So
> maybe this patch could be a stop-gap.
> 
I digged my mail box and read your RFC, and I agree those APIs would be
more desirable.
In 2-8 of this patch-set, I do similar things as you proposed in the RFC.
I use ->can_attach() as prepare_attach_sleep(), ->attach() as commit_attach(),
and ->cancel_attach() as abort_attach_sleep(), so I think it wouldn't be so
difficult to adapt my interfaces to new API when it comes.
The reason why I introduced ->cancel_attach() is I need to cancel(do rollback)
the charge reservation against @to cgroup, which I've reserved in ->can_attach(),
and this patch is enough for my purpose for now.

Anyway, I'll add more comments.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
