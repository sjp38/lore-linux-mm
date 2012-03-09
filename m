Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id B51976B004D
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 01:04:22 -0500 (EST)
Date: Fri, 9 Mar 2012 15:01:09 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v3 2/2] memcg: avoid THP split in task migration
Message-Id: <20120309150109.51ba8ea1.nishimura@mxp.nes.nec.co.jp>
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
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

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
I agree that moving tasks between cgroup is not a sane operation,
users won't do it so frequently, but I cannot prevent that.
That's why I implemented this feature.

> If users say all shared pages should be moved, ok, let's move.
> But change of behavior should be documented and implemented in an independet
> patch. CC'ed Nishimura-san, he implemetned this, a real user.
> 
To be honest, shared anon is not my concern. My concern is 
shared memory(that's why, mapcount is not checked as for file pages.
I assume all processes sharing the same shared memory will be moved together).
So, it's all right for me to change the behavior for shared anon(or leave
it as it is).


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
