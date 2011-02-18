Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1E4418D003A
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 14:12:33 -0500 (EST)
Date: Fri, 18 Feb 2011 17:11:46 -0200
From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
	2.6.38-rc4
Message-ID: <20110218191146.GG13211@ghostprotocols.net>
References: <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com> <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org> <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com> <20110218122938.GB26779@tiehlicka.suse.cz> <20110218162623.GD4862@tiehlicka.suse.cz> <AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com> <m17hcx43m3.fsf@fess.ebiederm.org> <AANLkTikh4oaR6CBK3NBazer7yjhE0VndsUB5FCDRsbJc@mail.gmail.com> <20110218190128.GF13211@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110218190128.GF13211@ghostprotocols.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>

Em Fri, Feb 18, 2011 at 05:01:28PM -0200, Arnaldo Carvalho de Melo escreveu:
> Em Fri, Feb 18, 2011 at 10:48:18AM -0800, Linus Torvalds escreveu:
> > This seems to be a fairly straightforward bug.
> > 
> > In net/ipv4/inet_timewait_sock.c we have this:
> > 
> >   /* These are always called from BH context.  See callers in
> >    * tcp_input.c to verify this.
> >    */
> > 
> >   /* This is for handling early-kills of TIME_WAIT sockets. */
> >   void inet_twsk_deschedule(struct inet_timewait_sock *tw,
> >                             struct inet_timewait_death_row *twdr)
> >   {
> >           spin_lock(&twdr->death_lock);
> >           ..
> > 
> > and the intention is clearly that that spin_lock is BH-safe because
> > it's called from BH context.
> > 
> > Except that clearly isn't true. It's called from a worker thread:
> > 
> > > stack backtrace:
> > > Pid: 10833, comm: kworker/u:1 Not tainted 2.6.38-rc4-359399.2010AroraKernelBeta.fc14.x86_64 #1
> > > Call Trace:
> > >  [<ffffffff81460e69>] ? inet_twsk_deschedule+0x29/0xa0
> > >  [<ffffffff81460fd6>] ? inet_twsk_purge+0xf6/0x180
> > >  [<ffffffff81460f10>] ? inet_twsk_purge+0x30/0x180
> > >  [<ffffffff814760fc>] ? tcp_sk_exit_batch+0x1c/0x20
> > >  [<ffffffff8141c1d3>] ? ops_exit_list.clone.0+0x53/0x60
> > >  [<ffffffff8141c520>] ? cleanup_net+0x100/0x1b0
> > >  [<ffffffff81068c47>] ? process_one_work+0x187/0x4b0
> > >  [<ffffffff81068be1>] ? process_one_work+0x121/0x4b0
> > >  [<ffffffff8141c420>] ? cleanup_net+0x0/0x1b0
> > >  [<ffffffff8106a65c>] ? worker_thread+0x15c/0x330
> > 
> > so it can deadlock with a BH happening at the same time, afaik.
> > 
> > The code (and comment) is all from 2005, it looks like the BH->worker
> > thread has broken the code. But somebody who knows that code better
> > should take a deeper look at it.
> > 
> > Added acme to the cc, since the code is attributed to him back in 2005
> > ;). Although I don't know how active he's been in networking lately
> > (seems to be all perf-related). Whatever, it can't hurt.
> 
> Original code is ANK's, I just made it possible to use with DCCP, and
> yeah, the smiley is appropriate, something 6 years old and the world
> around it changing continually... well, thanks for the git blame ;-)

But yeah, your analisys seems correct, with the bug being introduced by
one of these world around it changing continually issues, networking
namespaces broke the rules of the game on its cleanup_net() routine,
adding Pavel to the CC list since it doesn't hurt ;-)

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
