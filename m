Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 66C638D0039
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 03:36:09 -0500 (EST)
Received: by bwz17 with SMTP id 17so49646bwz.14
        for <linux-mm@kvack.org>; Sat, 19 Feb 2011 00:36:02 -0800 (PST)
Subject: [PATCH] tcp: fix inet_twsk_deschedule()
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <m1sjvl2i3q.fsf@fess.ebiederm.org>
References: <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	 <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	 <20110218122938.GB26779@tiehlicka.suse.cz>
	 <20110218162623.GD4862@tiehlicka.suse.cz>
	 <AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
	 <m17hcx43m3.fsf@fess.ebiederm.org>
	 <AANLkTikh4oaR6CBK3NBazer7yjhE0VndsUB5FCDRsbJc@mail.gmail.com>
	 <20110218190128.GF13211@ghostprotocols.net>
	 <20110218191146.GG13211@ghostprotocols.net>
	 <m1sjvl2i3q.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 19 Feb 2011 09:35:56 +0100
Message-ID: <1298104556.8559.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, David Miller <davem@davemloft.net>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>, Daniel Lezcano <daniel.lezcano@free.fr>

Le vendredi 18 fA(C)vrier 2011 A  12:38 -0800, Eric W. Biederman a A(C)crit :
> Arnaldo Carvalho de Melo <acme@redhat.com> writes:
> 
> > Em Fri, Feb 18, 2011 at 05:01:28PM -0200, Arnaldo Carvalho de Melo escreveu:
> >> Em Fri, Feb 18, 2011 at 10:48:18AM -0800, Linus Torvalds escreveu:
> >> > This seems to be a fairly straightforward bug.
> >> > 
> >> > In net/ipv4/inet_timewait_sock.c we have this:
> >> > 
> >> >   /* These are always called from BH context.  See callers in
> >> >    * tcp_input.c to verify this.
> >> >    */
> >> > 
> >> >   /* This is for handling early-kills of TIME_WAIT sockets. */
> >> >   void inet_twsk_deschedule(struct inet_timewait_sock *tw,
> >> >                             struct inet_timewait_death_row *twdr)
> >> >   {
> >> >           spin_lock(&twdr->death_lock);
> >> >           ..
> >> > 
> >> > and the intention is clearly that that spin_lock is BH-safe because
> >> > it's called from BH context.
> >> > 
> >> > Except that clearly isn't true. It's called from a worker thread:
> >> > 
> >> > > stack backtrace:
> >> > > Pid: 10833, comm: kworker/u:1 Not tainted 2.6.38-rc4-359399.2010AroraKernelBeta.fc14.x86_64 #1
> >> > > Call Trace:
> >> > >  [<ffffffff81460e69>] ? inet_twsk_deschedule+0x29/0xa0
> >> > >  [<ffffffff81460fd6>] ? inet_twsk_purge+0xf6/0x180
> >> > >  [<ffffffff81460f10>] ? inet_twsk_purge+0x30/0x180
> >> > >  [<ffffffff814760fc>] ? tcp_sk_exit_batch+0x1c/0x20
> >> > >  [<ffffffff8141c1d3>] ? ops_exit_list.clone.0+0x53/0x60
> >> > >  [<ffffffff8141c520>] ? cleanup_net+0x100/0x1b0
> >> > >  [<ffffffff81068c47>] ? process_one_work+0x187/0x4b0
> >> > >  [<ffffffff81068be1>] ? process_one_work+0x121/0x4b0
> >> > >  [<ffffffff8141c420>] ? cleanup_net+0x0/0x1b0
> >> > >  [<ffffffff8106a65c>] ? worker_thread+0x15c/0x330
> >> > 
> >> > so it can deadlock with a BH happening at the same time, afaik.
> >> > 
> >> > The code (and comment) is all from 2005, it looks like the BH->worker
> >> > thread has broken the code. But somebody who knows that code better
> >> > should take a deeper look at it.
> >> > 
> >> > Added acme to the cc, since the code is attributed to him back in 2005
> >> > ;). Although I don't know how active he's been in networking lately
> >> > (seems to be all perf-related). Whatever, it can't hurt.
> >> 
> >> Original code is ANK's, I just made it possible to use with DCCP, and
> >> yeah, the smiley is appropriate, something 6 years old and the world
> >> around it changing continually... well, thanks for the git blame ;-)
> >
> > But yeah, your analisys seems correct, with the bug being introduced by
> > one of these world around it changing continually issues, networking
> > namespaces broke the rules of the game on its cleanup_net() routine,
> > adding Pavel to the CC list since it doesn't hurt ;-)
> 
> Which probably gets the bug back around to me.
> 
> I guess this must be one of those ipv4 cases that where the cleanup
> simply did not exist in the rmmod sense that we had to invent.
> 
> I think that was Daniel who did the time wait sockets.  I do remember
> they were a real pain.
> 
> Would a bh_disable be sufficient?  I guess I should stop remembering and
> look at the code now.
> 

Here is the patch to fix the problem

Daniel commit (d315492b1a6ba29d (netns : fix kernel panic in timewait
socket destruction) was OK (it did use local_bh_disable())

Problem comes from commit 575f4cd5a5b6394577
(net: Use rcu lookups in inet_twsk_purge.) added in 2.6.33

Thanks !

[PATCH] tcp: fix inet_twsk_deschedule()

Eric W. Biederman reported a lockdep splat in inet_twsk_deschedule()

This is caused by inet_twsk_purge(), run from process context,
and commit 575f4cd5a5b6394577 (net: Use rcu lookups in inet_twsk_purge.)
removed the BH disabling that was necessary.

Add the BH disabling but fine grained, right before calling
inet_twsk_deschedule(), instead of whole function.

With help from Linus Torvalds and Eric W. Biederman

Reported-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Daniel Lezcano <daniel.lezcano@free.fr>
CC: Pavel Emelyanov <xemul@openvz.org>
CC: Arnaldo Carvalho de Melo <acme@redhat.com>
CC: stable <stable@kernel.org> (# 2.6.33+)
---
 net/ipv4/inet_timewait_sock.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index c5af909..3c8dfa1 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -505,7 +505,9 @@ restart:
 			}
 
 			rcu_read_unlock();
+			local_bh_disable();
 			inet_twsk_deschedule(tw, twdr);
+			local_bh_enable();
 			inet_twsk_put(tw);
 			goto restart_rcu;
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
