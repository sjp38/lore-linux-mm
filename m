Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 18CE88D0039
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 03:27:31 -0500 (EST)
Received: by bwz17 with SMTP id 17so637193bwz.14
        for <linux-mm@kvack.org>; Sun, 20 Feb 2011 00:27:27 -0800 (PST)
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <AANLkTik8kjt1TZ5vOoAm_y0f7toGtOSpxOsgCXO-bey9@mail.gmail.com>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
	 <20110216193700.GA6377@elte.hu>
	 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
	 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
	 <20110217090910.GA3781@tiehlicka.suse.cz>
	 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	 <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	 <20110218122938.GB26779@tiehlicka.suse.cz>
	 <20110218162623.GD4862@tiehlicka.suse.cz>
	 <AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
	 <m1oc68ilw7.fsf@fess.ebiederm.org>
	 <AANLkTincrnq1kMcAYEWYLf5vdbQ4DYbYObbg=0cLfHnm@mail.gmail.com>
	 <m1oc67zcov.fsf@fess.ebiederm.org>
	 <AANLkTik8kjt1TZ5vOoAm_y0f7toGtOSpxOsgCXO-bey9@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 20 Feb 2011 09:27:20 +0100
Message-ID: <1298190440.8559.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>

Le samedi 19 fA(C)vrier 2011 A  22:15 -0800, Linus Torvalds a A(C)crit :
> On Sat, Feb 19, 2011 at 6:01 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
> >
> > So I think the change below to fix dev_deactivate which Eric D. missed
> > will fix this problem.  Now to go test that.
> 
> You know what? I think the whole thing is crap. I did a simple grep
> for 'unregister_netdevice_many()', and they are all buggy.
> 


> Look in net/ipv4/ip_gre.c, net/ipv4/ipip.c,net/ipv4/ipmr.c,
> net/ipv6/sit.c, look in net/ipv6/ip6mr.c, just just about anywhere.
> Those people *all* do basically a list-head on the stack, and then
> they do unregister_netdevice_many() on those things, and they clearly
> expect the list to be gone.

If they use rtnl_unlock() they are fine, since by the time rtnl_unlock()
returns, devices have been freed. LIST_HEAD content is void, or else we
have more serious bugs.

> 
> I suspect that the right thing to do really is to change the semantics
> of those functions that take that kill-list *entirely*. Namely that
> they will literall ykill the list too, not just the entries on the
> list.
> 
> So unregister_netdevice_many() should always return with the list
> empty and destroyed. There is no valid use of a list of netdevices
> after you've unregistered them.
> 
> Now, dev_deactivate_many() actually has uses of that list after
> they've been de-activated (__dev_close_many will deactivate them, and
> then after that do the whole ndo_stop dance too, so I guess all (two)
> callers of that function need to get rid of their list manually. So I
> think your patch to sch_generic.c is good, but I really think the
> semantics of unregister_netdevice_many() should just be changed.
> 
> And I think the networking people need to do some serious code review
> of this whole thing. The whole "let's build a list on the stack, then
> leave it around, and later use it randomly when the stack head pointer
> is long gone" thing is just incredible crapola. We shouldn't be
> finding these things one-by-one as a list debugging thing fires.
> People need tolook at their code and fix it before the bugs start
> triggering.

This code is run with RTNL locked anyway, so we could use a global list
head, like net_todo_list list (net/core/dev.c line 4980)

I believe the dev->unreg_list had a precise meaning when I introduced it
in 2009 (commits 44a0873d52282f24b1894c58c0f157e0f626ddc9,
9b5e383c11b08784eb0087617f880077982ef769,
23289a37e2b127dfc4de1313fba15bb4c9f0cd5b) .

devices were added to the LIST_HEAD, but never removed. (devices were
freed anyway, and list manipulated inside RNTL by a single thread)

But as Eric B. said, it was re-used for other roles.

We need to track these changes precisely and make appropriate fixes.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
