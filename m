Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF8D56B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 17:27:20 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g1-v6so4393712plm.2
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:27:20 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d16-v6si13138443plr.141.2018.04.16.14.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 14:27:19 -0700 (PDT)
Date: Mon, 16 Apr 2018 17:27:15 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416172017.4499f914@gandalf.local.home>
In-Reply-To: <CA+55aFxiUhaFVBDhrTGJmgKZid2nO0efh6Mng1NQJ0JK4EHqMg@mail.gmail.com>
References: <20180416153031.GA5039@amd>
	<20180416155031.GX2341@sasha-vm>
	<20180416160608.GA7071@amd>
	<20180416122019.1c175925@gandalf.local.home>
	<20180416162757.GB2341@sasha-vm>
	<20180416163952.GA8740@amd>
	<20180416164310.GF2341@sasha-vm>
	<20180416125307.0c4f6f28@gandalf.local.home>
	<20180416170936.GI2341@sasha-vm>
	<20180416133321.40a166a4@gandalf.local.home>
	<20180416174236.GL2341@sasha-vm>
	<20180416142653.0f017647@gandalf.local.home>
	<CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com>
	<20180416144117.5757ee70@gandalf.local.home>
	<CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com>
	<20180416152429.529e3cba@gandalf.local.home>
	<CA+55aFwjSRZDT1f99QdY-Q5R4W_asb_1mZgM69YOqRR9-efmwA@mail.gmail.com>
	<20180416153816.292a5b5c@gandalf.local.home>
	<CA+55aFwXRjgfLfAWSaLBdajjzh4gt8-5M2N-bmjKt8nrJT+vWQ@mail.gmail.com>
	<20180416160232.2b807ff1@gandalf.local.home>
	<CA+55aFxiUhaFVBDhrTGJmgKZid2nO0efh6Mng1NQJ0JK4EHqMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 13:17:24 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Apr 16, 2018 at 1:02 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > But this is going way off topic to what we were discussing. The
> > discussion is about what gets backported. Is automating the process
> > going to make stable better? Or is it likely to add more regressions.
> >
> > Sasha's response has been that his automated process has the same rate
> > of regressions as what gets tagged by authors. My argument is that
> > perhaps authors should tag less to stable.  
> 
> The ones who should matter most for that discussion is the distros,
> since they are the actual users of stable (as well as the people doing
> the work, of course - ie Sasha and Greg and the rest of the stable
> gang).

That was actually my final conclusion before we started out
discussion ;-)

http://lkml.kernel.org/r/20180416143510.79ba5c63@gandalf.local.home

> 
> And I suspect that they actually do want all the noise, and all the
> stuff that isn't "critical". That's often the _easy_ choice. It's the
> stuff that I suspect the stable maintainers go "this I don't even have
> to think about", because it's a new driver ID or something.

Although Red Hat doesn't base off of the stable kernel. At least it
didn't when I was there. They may look at the stable kernel, but they
make their own decisions.

If we want the distros to use stable as the base, it should be the
least common factor among them. Otherwise, if stable includes commits
that a distro would rather not backport, then they wont use stable.

> 
> Because the bulk of stable tends to be driver updates, afaik. Which
> distros very much tend to want.
> 
> Will developers think that their patches matter so much that they
> should go to stable? Yes they will. Will they overtag as a result?
> Probably. But the reverse likely also happens, where people simply
> don't think about stable at all, and just want to fix a bug.
> 
> In many ways "Fixes" is likely a better thing to check for in stable
> backports, but that doesn't always exist either.
> 
> And just judging by the amount of stable email I get - and by how
> excited _I_ would be about stable work, I think "automated process" is
> simply not an option. It's a _requirement_. You'd go completely crazy
> if you didn't automate 99% of all the stable work.
> 
> So can you trust the "Cc: stable" as being perfect? Hell no. But
> what's your alternative? Manually selecting things for stable? Asking
> the developers separately?
> 
> Because "criticality" definitely isn't what determines it. If it was,
> we'd never add driver ID's etc to stable - they're clearly not
> "critical".

True. But I believe the driver ID's was given the "exception".


> 
> Yet it feels like that's sometimes those driver things are the _bulk_
> of it, and it is usually fairly safe (not quite as obviously safe as
> you'd think, because a driver ID addition has occasionally meant not
> just "now it's supported", but instead "now the generic driver doesn't
> trigger for it any more", so it can actually break things).
> 
> So I think - and _hope_ - that 99% of stable should be the
> non-critical stuff that people don't even need to think about.
> 
> The critical stuff is hopefully a tiny tiny percentage.

Well, I'm not sure that's really the case.

$ git log --oneline v4.14.33..v4.14.34 | head -20
ffebeb0d7c37 Linux 4.14.34
fdae5b620566 net/mlx4_core: Fix memory leak while delete slave's resources
9fdeb33e1913 vhost_net: add missing lock nesting notation
8c316b625705 team: move dev_mc_sync after master_upper_dev_link in team_port_add
233ba28e1862 route: check sysctl_fib_multipath_use_neigh earlier than hash
2f8aa659d4c0 vhost: validate log when IOTLB is enabled
72b880f43990 net/mlx5e: Fix traffic being dropped on VF representor
9408bceb0649 net/mlx4_en: Fix mixed PFC and Global pause user control requests
477c73abf26a strparser: Fix sign of err codes
1c71bfe84deb net/sched: fix NULL dereference on the error path of tcf_skbmod_init()
a19024a3f343 net/sched: fix NULL dereference in the error path of tunnel_key_init()
e096c8bf4fb8 net/mlx5e: Sync netdev vxlan ports at open
baab1f0c4885 net/mlx5e: Don't override vport admin link state in switchdev mode
1ec7966ab7db ipv6: sr: fix seg6 encap performances with TSO enabled
e52a45bb392f nfp: use full 40 bits of the NSP buffer address
ddf79878f1e0 net/mlx5e: Fix memory usage issues in offloading TC flows
9282181c1cc5 net/mlx5e: Avoid using the ipv6 stub in the TC offload neigh update path
b9c6ddda3805 vti6: better validate user provided tunnel names
109dce20c6ed ip6_tunnel: better validate user provided tunnel names
72363c63b070 ip6_gre: better validate user provided tunnel names

The majority of those appear to be on the critical side.

-- Steve
