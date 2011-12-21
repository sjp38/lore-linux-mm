Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id BF85B6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 23:02:11 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AF7763EE0CD
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 13:02:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D81645DE4F
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 13:02:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 733F145DE53
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 13:02:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 60F611DB8044
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 13:02:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 007091DB803F
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 13:02:09 +0900 (JST)
Date: Wed, 21 Dec 2011 13:00:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: reset to root_mem_cgroup at bypassing
Message-Id: <20111221130056.2f4a39b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112201847500.1310@eggly.anvils>
References: <20111219165146.4d72f1bb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1112191218350.3639@eggly.anvils>
	<CABEgKgrk4X13V2Ra_g+V5J0echpj2YZfK20zaFRKP-PhWRWiYQ@mail.gmail.com>
	<20111221091347.4f1a10d8.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1112201847500.1310@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Tue, 20 Dec 2011 19:25:04 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Wed, 21 Dec 2011, KAMEZAWA Hiroyuki wrote:
> > On Tue, 20 Dec 2011 09:24:47 +0900
> > Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com> wrote:
> > > 2011/12/20 Hugh Dickins <hughd@google.com>:
> > > 
> > > > I speak from experience: I did *exactly* the same at "bypass" when
> > > > I introduced our mem_cgroup_reset_page(), which corresponds to your
> > > > mem_cgroup_reset_owner(); it seemed right to me that a successful
> > > > (return 0) call to try_charge() should provide a good *ptr.
> > > >
> > > ok.
> > > 
> > > > But others (Ying and Greg) pointed out that it changes the semantics
> > > > of __mem_cgroup_try_charge() in this case, so you need to justify the
> > > > change to all those places which do something like "if (ret || !memcg)"
> > > > after calling it. A Perhaps it is a good change everywhere, but that's
> > > > not obvious, so we chose caution.
> > > >
> > > > Doesn't it lead to bypass pages being marked as charged to root, so
> > > > they don't get charged to the right owner next time they're touched?
> > > >
> > > Yes. You're right.
> > > Hm. So, it seems I should add reset_owner() to the !memcg path
> > > rather than here.
> > > 
> > Considering this again..
> > 
> > Now, we catch 'charge' event only once in lifetime of anon/file page.
> > So, it doesn't depend on that it's marked as PCG_USED or not.
> 
> That's an interesting argument, I hadn't been looking at it that way.
> It's not true of swapcache, but I guess we don't need to preserve its
> peculiarities in this case.
> 
> I've not checked the (ret || !memcg) cases yet to see if any change
> needed there.
> 
> I certainly like that the success return guarantees that memcg is set.
> 
Hmm. Ok, then....I'll update patch description to be precise.
And check I can remove !memcg case in the same patch. Then, repost v2.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
