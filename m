Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 5B3076B00E8
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 23:48:41 -0500 (EST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp [192.51.44.35])
	by fgwmail8.fujitsu.co.jp (Postfix) with ESMTP id 5E425179446E
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 13:06:08 +0900 (JST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 66CA03EE0C3
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 13:02:05 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4986B45DEB6
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 13:02:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1571A45DEA6
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 13:02:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F351CE18001
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 13:02:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A44CB1DB803B
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 13:02:04 +0900 (JST)
Date: Fri, 9 Mar 2012 13:00:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 2/2] memcg: avoid THP split in task migration
Message-Id: <20120309130031.8740beef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120309122448.92931dc6.kamezawa.hiroyu@jp.fujitsu.com>
References: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1330719189-20047-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20120309101658.8b36ce4f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1203081816170.18242@eggly.anvils>
	<20120309122448.92931dc6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri, 9 Mar 2012 12:24:48 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 8 Mar 2012 18:33:14 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > On Fri, 9 Mar 2012, KAMEZAWA Hiroyuki wrote:
> > > > +
> > > > +	page = pmd_page(pmd);
> > > > +	VM_BUG_ON(!page || !PageHead(page));
> > > > +	if (!move_anon() || page_mapcount(page) != 1)
> > > > +		return 0;
> > > 
> > > Could you add this ?
> > > ==
> > > static bool move_check_shared_map(struct page *page)
> > > {
> > >   /*
> > >    * Handling of shared pages between processes is a big trouble in memcg.
> > >    * Now, we never move shared-mapped pages between memcg at 'task' moving because
> > >    * we have no hint which task the page is really belongs to. For example, 
> > >    * When a task does "fork()-> move to the child other group -> exec()", the charges
> > >    * should be stay in the original cgroup. 
> > >    * So, check mapcount to determine we can move or not.
> > >    */
> > >    return page_mapcount(page) != 1;
> > > }
> > 
> > That's a helpful elucidation, thank you.  However...
> > 
> > That is not how it has actually been behaving for the last 18 months
> > (because of the "> 2" bug), so in practice you are asking for a change
> > in behaviour there.
> > 
> Yes.
> 
> 
> > And it's not how it has been and continues to behave with file pages.
> > 
> It's ok to add somethink like..
> 
> 	if (PageAnon(page) && !move_anon())
> 		return false;
> 	...
> 
> > Isn't getting that behaviour in fork-move-exec just a good reason not
> > to set move_charge_at_immigrate?
> > 
> Hmm. Maybe.
> 
> > I think there are other scenarios where you do want all the pages to
> > move if move_charge_at_immigrate: and that's certainly easier to
> > describe and to understand and to code.
> > 
> > But if you do insist on not moving the shared, then it needs to involve
> > something like mem_cgroup_count_swap_user() on PageSwapCache pages,
> > rather than just the bare page_mapcount().
> > 
> 
> This 'moving swap account' was a requirement from a user (NEC?).
> But no user doesn't say 'I want to move shared pages between cgroups at task
> move !' and I don't like to move shared objects.
> 
> > I'd rather delete than add code here!
> > 
> 
> As a user, for Fujitsu, I believe it's insane to move task between cgroups.
> So, I have no benefit from this code, at all.
> Ok, maybe I'm not a stakeholder,here.
> 

Considering again, in my personal opinion, 
at fork() -> move() -> exec(), parent's RSS charge should not be moved.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
