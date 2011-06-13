Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5620D6B004A
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 22:01:16 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C34FB3EE0BB
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 11:01:11 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7F9D45DE5F
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 11:01:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7948C45DE59
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 11:01:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B7AD1DB803B
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 11:01:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 18A871DB803E
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 11:01:11 +0900 (JST)
Date: Mon, 13 Jun 2011 10:54:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
Message-Id: <20110613105410.e06720f1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1106121828220.31463@sister.anvils>
References: <BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com>
	<BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
	<20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1106091812030.4904@sister.anvils>
	<20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1106101425400.28334@sister.anvils>
	<20110610235442.GA21413@cmpxchg.org>
	<20110611175136.GA31154@cmpxchg.org>
	<alpine.LSU.2.00.1106121828220.31463@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, 12 Jun 2011 18:41:58 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Sat, 11 Jun 2011, Johannes Weiner wrote:
> > On Sat, Jun 11, 2011 at 01:54:42AM +0200, Johannes Weiner wrote:
> > > On Fri, Jun 10, 2011 at 02:49:35PM -0700, Hugh Dickins wrote:
> > > > On Fri, 10 Jun 2011, KAMEZAWA Hiroyuki wrote:
> > > > > 
> > > > > I think this can be a fix. 
> > > > 
> > > > Sorry, I think not: I've not digested your rationale,
> > > > but three things stand out:
> > > > 
> > > > 1. Why has this only just started happening?  I may not have run that
> > > >    test on 3.0-rc1, but surely I ran it for hours with 2.6.39;
> > > >    maybe not with khugepaged, but certainly with ksmd.
> > > > 
> > > > 2. Your hunk below:
> > > > > -	if (!mm_need_new_owner(mm, p))
> > > > > +	if (!mm_need_new_owner(mm, p)) {
> > > > > +		rcu_assign_pointer(mm->owner, NULL);
> > > >    is now setting mm->owner to NULL at times when we were sure it did not
> > > >    need updating before (task is not the owner): you're damaging mm->owner.
> > 
> > This is a problem with the patch, but I think Kame's analysis and
> > approach to fix it are still correct.
> 
> Yes, I was looking at his patch, when I should have spent more time
> reading his comments: you're right, the analysis is fine, and I too
> dislike stale pointers.
> 
> > 
> > mm_update_next_owner() does not set mm->owner to NULL when the last
> > possible owner goes away, but leaves it pointing to a possibly stale
> > task struct.
> > 
> > Noone cared before khugepaged, and up to Andrea's patch khugepaged
> > prevented the last possible owner from exiting until the call into the
> > memory controller had finished.
> > 
> > Here is a revised version of Kame's fix.
> 
> It seems to be strangely difficult to get right!
> I have no idea what your
> 	if (atomic_read(&mm->mm_users <= 1)) {
> actually ends up doing, I'm surprised it only gives compiler warnings
> rather than an error.
> 
> The version I've signed off and am actually testing is below;
> but I've not had enough time to spare on the machine which reproduced
> it before, and another I thought I'd delegate it to last night,
> failed to reproduce without the patch.  Try again tonight.
> 
> Thought I'd better respond despite inadequate testing, given the flaw
> in the posted patch.  Hope the one below is flawless.
> 

Thank you, I'll do test, too.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
