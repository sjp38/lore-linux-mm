Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 9153B6B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 09:25:58 -0400 (EDT)
Date: Fri, 12 Jul 2013 15:25:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 5/6] memcg: patch
 mem_cgroup_{begin,end}_update_page_stat() out if only root memcg exists
Message-ID: <20130712132550.GD15307@dhcp22.suse.cz>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
 <1373045623-27712-1-git-send-email-handai.szj@taobao.com>
 <20130711145625.GK21667@dhcp22.suse.cz>
 <CAFj3OHV=6YDcbKmSeuF3+oMv1HfZF1RxXHoiLgTk0wH5cJVsiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFj3OHV=6YDcbKmSeuF3+oMv1HfZF1RxXHoiLgTk0wH5cJVsiQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Sha Zhengju <handai.szj@taobao.com>

On Fri 12-07-13 20:59:24, Sha Zhengju wrote:
> Add cc to Glauber
> 
> On Thu, Jul 11, 2013 at 10:56 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Sat 06-07-13 01:33:43, Sha Zhengju wrote:
> >> From: Sha Zhengju <handai.szj@taobao.com>
> >>
> >> If memcg is enabled and no non-root memcg exists, all allocated
> >> pages belongs to root_mem_cgroup and wil go through root memcg
> >> statistics routines.  So in order to reduce overheads after adding
> >> memcg dirty/writeback accounting in hot paths, we use jump label to
> >> patch mem_cgroup_{begin,end}_update_page_stat() in or out when not
> >> used.
> >
> > I do not think this is enough. How much do you save? One atomic read.
> > This doesn't seem like a killer.
> >
> > I hoped we could simply not account at all and move counters to the root
> > cgroup once the label gets enabled.
> 
> I have thought of this approach before, but it would probably run into
> another issue, e.g, each zone has a percpu stock named ->pageset to
> optimize the increment and decrement operations, and I haven't figure out a
> simpler and cheaper approach to handle that stock numbers if moving global
> counters to root cgroup, maybe we can just leave them and can afford the
> approximation?

You can read per-cpu diffs during transition and tolerate small
races. Or maybe simply summing NR_FILE_DIRTY for all zones would be
sufficient.

> Glauber have already done lots of works here, in his previous patchset he
> also tried to move some global stats to root (
> http://comments.gmane.org/gmane.linux.kernel.cgroups/6291). May I steal
> some of your ideas here, Glauber? :P
> 
> 
> >
> > Besides that, the current patch is racy. Consider what happens when:
> >
> > mem_cgroup_begin_update_page_stat
> >                                         arm_inuse_keys
> >								mem_cgroup_move_account
> > mem_cgroup_move_account_page_stat
> > mem_cgroup_end_update_page_stat
> >
> > The race window is small of course but it is there. I guess we need
> > rcu_read_lock at least.
> 
> Yes, you're right. I'm afraid we need to take care of the racy in the next
> updates as well. But mem_cgroup_begin/end_update_page_stat() already have
> rcu lock, so here we maybe only need a synchronize_rcu() after changing
> memcg_inuse_key?

Your patch doesn't take rcu_read_lock. synchronize_rcu might work but I
am still not sure this would help to prevent from the overhead which
IMHO comes from the accounting not a single atomic_read + rcu_read_lock
which is the hot path of mem_cgroup_{begin,end}_update_page_stat.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
