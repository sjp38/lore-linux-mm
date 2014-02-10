Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id CAF2A6B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:13:38 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so6747686pbc.0
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:13:38 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id bq5si16546415pbb.18.2014.02.10.12.13.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 12:13:37 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so6630892pad.36
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:13:35 -0800 (PST)
Date: Mon, 10 Feb 2014 12:12:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 3/8] memcg: update comment about charge reparenting on
 cgroup exit
In-Reply-To: <20140210142344.GI7117@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1402101208290.1516@eggly.anvils>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org> <1391792665-21678-4-git-send-email-hannes@cmpxchg.org> <20140210142344.GI7117@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 10 Feb 2014, Michal Hocko wrote:
> On Fri 07-02-14 12:04:20, Johannes Weiner wrote:
> > Reparenting memory charges in the css_free() callback was meant as a
> > temporary fix for charges that race with offlining, but after some
> > follow-up discussion, it turns out that this is really the right place
> > to reparent charges because it guarantees none are in-flight.

Perhaps: I'm not as gung-ho for this new orthodoxy as you are.

> > 
> > Make clear that the reparenting in css_offline() is an optimistic
> > sweep of established charges because swapout records might hold up
> > css_free() indefinitely, but that in fact the css_free() reparenting
> > is the properly synchronized one.

It worries me that you keep referring to the memsw usage, but
forget the kmem usage, which also delays css_free() indefinitely.

Or am I out-of-date?  Seems not, mem_cgroup_reparent_chages() still
waits for memcg->res - memcg->kmem to reach 0, knowing there's not
much certainty that kmem will reach 0 any time soon.

I think you need a plan for what to do with the kmem pinning,
before going much further in reworking the memsw pinning.

Or at the least, please mention it in this patch's comment.

Hugh

> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> OK, I am still thinking about 2 stage reparenting. LRU drain part called
> from css_offline and charge drain from css_free. But this is a
> sufficient for now.
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
