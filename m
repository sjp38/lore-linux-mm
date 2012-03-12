Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id E1EF46B004A
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 14:44:12 -0400 (EDT)
Received: by dadv6 with SMTP id v6so6244406dad.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 11:44:12 -0700 (PDT)
Date: Mon, 12 Mar 2012 11:43:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3.3] memcg: free mem_cgroup by RCU to fix oops
In-Reply-To: <20120312150945.GA14551@redhat.com>
Message-ID: <alpine.LSU.2.00.1203121118500.1796@eggly.anvils>
References: <alpine.LSU.2.00.1203072155140.11048@eggly.anvils> <alpine.LSU.2.00.1203091138260.19300@eggly.anvils> <20120312150945.GA14551@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Tejun Heo <tj@kernel.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 12 Mar 2012, Stanislaw Gruszka wrote:
> On Fri, Mar 09, 2012 at 11:58:34AM -0800, Hugh Dickins wrote:
> > On Wed, 7 Mar 2012, Hugh Dickins wrote:
> > > 
> > > I'm posting this a little prematurely to get eyes on it, since it's
> > > more than a two-liner, but 3.3 time is running out.  If it is what's
> > > needed to fix my oopses, I won't really be sure before Friday morning.
> > > What's running now on the machine affected is using kfree_rcu(), but I
> > > did hack it earlier to check that the vfree_rcu() alternative works.
> > 
> > Yes, please do send that patch on to Linus for 3.3.
> > 
> > It did not get as much as the 36 hours of testing I had hoped for, only
> > 25 hours so far.  12 hours while I was out yesterday got wasted by a
> > wireless driver interrupt spewing approximately one million messages:
> > 
> > iwl3945 0000:08:00.0: MAC is in deep sleep!. CSR_GP_CNTRL = 0xFFFFFFFF
> 
> I replaced that with WARN_ONCE
> http://marc.info/?l=linux-wireless&m=132912863701997&w=2
> (the patch is currently in net-next).

That's very welcome, thank you.  One message will suit me better than
a million.  But I didn't mention that for every seven of those, there
was one slightly different message coming too:

iwl3945 0000:08:00.0: UNKNOWN (0xFFFFFFFF) 4294967295 ... (I got bored)

> 
> > which I've not suffered from before, and hope not again.  Having kdb
> > in, I did take a look what was going on with the memcg load when it was
> > interrupted: it appeared to be normal, and I've no reason to suppose that
> > my kfree_rcu() was in any way responsible for the wireless aberration.

I didn't see it again.  I rebooted and ran the test for 63 hours and
it went fine this time with no interference from the wifi.  I did have
the laptop differently positioned this time: maybe it was overheating
up against the wall, though that position gave no trouble in the past.

> 
> I don't know if is possible if test patch influence pci or mac80211 code
> (we use rcu quite intensively in mac8021).

It's very very unlikely that the patch I was testing had a significant
effect on RCU usage: the test ends up doing just one extra call_rcu every
minute.  There's a heavy swapping load running alongside, which shouldn't
be disturbing PCI config at all; but it's possible that a temporarily
failing memory allocation, or overheat, drove iwl3945 down a strange
path on this one occasion, and once there it couldn't recover.

Hugh

> Those "MAC is in deep sleep" 
> usually mean that wireless device registers can not be read through pcie
> bus - i.e. when pcie bridge is erroneously disabled like in report here:
> http://marc.info/?l=linux-wireless&m=132577331132329&w=2
> 
> Note that wireless device is one of a few connected through pcie bridge
> on most of the laptops, others external pcie devices like mmc are not
> used frequently, hence breakage in pci code looks frequently like
> breakage in wireless driver. Not sure if that was the case here though.
> 
> Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
