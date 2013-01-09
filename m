Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 93D756B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 00:15:53 -0500 (EST)
Received: by mail-da0-f44.google.com with SMTP id z20so553408dae.17
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 21:15:52 -0800 (PST)
Date: Tue, 8 Jan 2013 21:15:47 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
In-Reply-To: <50EA7E07.4070902@jp.fujitsu.com>
Message-ID: <alpine.LNX.2.00.1301082030100.5319@eggly.anvils>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com> <1356456367-14660-1-git-send-email-handai.szj@taobao.com> <20130102104421.GC22160@dhcp22.suse.cz> <CAFj3OHXKyMO3gwghiBAmbowvqko-JqLtKroX2kzin1rk=q9tZg@mail.gmail.com>
 <alpine.LNX.2.00.1301061135400.29149@eggly.anvils> <50EA7E07.4070902@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Sha Zhengju <handai.szj@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, dchinner@redhat.com, Sha Zhengju <handai.szj@taobao.com>

On Mon, 7 Jan 2013, Kamezawa Hiroyuki wrote:
> (2013/01/07 5:02), Hugh Dickins wrote:
> > 
> > Forgive me, I must confess I'm no more than skimming this thread,
> > and don't like dumping unsigned-off patches on people; but thought
> > that on balance it might be more helpful than not if I offer you a
> > patch I worked on around 3.6-rc2 (but have updated to 3.8-rc2 below).
> > 
> > I too was getting depressed by the constraints imposed by
> > mem_cgroup_{begin,end}_update_page_stat (good job though Kamezawa-san
> > did to minimize them), and wanted to replace by something freer, more
> > RCU-like.  In the end it seemed more effort than it was worth to go
> > as far as I wanted, but I do think that this is some improvement over
> > what we currently have, and should deal with your recursion issue.
> > 
> In what case does this improve performance ?

Perhaps none.  I was aiming to not degrade performance at the stats
update end, and make it more flexible, so new stats can be updated which
would be problematic today (for lock ordering and recursion reasons).

I've not done any performance measurement on it, and don't have enough
cpus for an interesting report; but if someone thinks it might solve a
problem for them, and has plenty of cpus to test with, please go ahead,
we'd be glad to hear the results.

> Hi, this patch seems interesting but...doesn't this make move_account() very
> slow if the number of cpus increases because of scanning all cpus per a page
> ?
> And this looks like reader-can-block-writer percpu rwlock..it's too heavy to
> writers if there are many readers.

I was happy to make the relatively rare move_account end considerably
heavier.  I'll be disappointed if it turns out to be prohibitively
heavy at that end - if we're going to make move_account impossible,
there are much easier ways to achieve that! - but it is a possibility.

Something you might have missed when considering many readers (stats
updaters): the move_account end does not wait for a moment when there
are no readers, that would indeed be a losing strategy; it just waits
for each cpu that's updating page stats to leave that section, so every
cpu is sure to notice and hold off if it then tries to update the page
which is to be moved.  (I may not be explaining that very well!)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
