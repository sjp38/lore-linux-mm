Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 203B16B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 11:18:33 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id r15so3876565ead.27
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 08:18:32 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id g47si36592788eet.24.2014.02.03.08.18.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 08:18:31 -0800 (PST)
Date: Mon, 3 Feb 2014 11:18:23 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 4/5] memcg: make sure that memcg is not offline when
 charging
Message-ID: <20140203161823.GJ6963@cmpxchg.org>
References: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
 <1387295130-19771-5-git-send-email-mhocko@suse.cz>
 <20140130172906.GE6963@cmpxchg.org>
 <20140203133313.GF2495@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140203133313.GF2495@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Feb 03, 2014 at 02:33:13PM +0100, Michal Hocko wrote:
> On Thu 30-01-14 12:29:06, Johannes Weiner wrote:
> > On Tue, Dec 17, 2013 at 04:45:29PM +0100, Michal Hocko wrote:
> > > The current charge path might race with memcg offlining because holding
> > > css reference doesn't stop css offline. As a result res counter might be
> > > charged after mem_cgroup_reparent_charges (called from memcg css_offline
> > > callback) and so the charge would never be freed. This has been worked
> > > around by 96f1c58d8534 (mm: memcg: fix race condition between memcg
> > > teardown and swapin) which tries to catch such a leaked charges later
> > > during css_free. It is more optimal to heal this race in the long term
> > > though.
> > 
> > We already deal with the race, so IMO the only outstanding improvement
> > is to take advantage of the teardown synchronization provided by the
> > cgroup core and get rid of our one-liner workaround in .css_free.
> 
> I am not sure I am following you here. Which teardown synchronization do
> you have in mind? rcu_read_lock & css_tryget?

Yes.  It provides rcu synchronization between establishing new
references and offlining, as long as you establish references
atomically in one RCU read-side section:

repeat:
  rcu_read_lock()
  css_tryget()
  res_counter_charge()
  rcu_read_unlock()
  if retries++ < RECLAIM_RETRIES:
    reclaim
    goto repeat

> > > In order to make this raceless we would need to hold rcu_read_lock since
> > > css_tryget until res_counter_charge. This is not so easy unfortunately
> > > because mem_cgroup_do_charge might sleep so we would need to do drop rcu
> > > lock and do css_tryget tricks after each reclaim.
> > 
> > Yes, why not?
> 
> Although css_tryget is cheap these days I thought that a simple flag
> check would be even heaper in this hot path. Changing the patch to use
> css_tryget rather than offline check is trivial if you really think it
> is better?

You already changed it to do css_tryget() on every single charge.

Direct reclaim is invoked only from a fraction of all charges, it's
already a slowpath, I don't think another percpu counter op will be
the final straw that makes this path too fat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
