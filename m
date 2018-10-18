Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C16D86B0008
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 07:24:01 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m45-v6so18441269edc.2
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 04:24:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x16-v6si4347239ejc.242.2018.10.18.04.24.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 04:24:00 -0700 (PDT)
Date: Thu, 18 Oct 2018 13:23:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181018112358.GB18839@dhcp22.suse.cz>
References: <20181017102821.GM18839@dhcp22.suse.cz>
 <20181017111724.GA459@jagdpanzerIV>
 <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018065519.GV18839@dhcp22.suse.cz>
 <6bbb0449-1f22-4d05-9e2a-636965b7dbc6@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6bbb0449-1f22-4d05-9e2a-636965b7dbc6@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On Thu 18-10-18 19:37:18, Tetsuo Handa wrote:
> On 2018/10/18 15:55, Michal Hocko wrote:
> > On Thu 18-10-18 11:46:50, Tetsuo Handa wrote:
> >> This is essentially a ratelimit approach, roughly equivalent with:
> >>
> >>   static DEFINE_RATELIMIT_STATE(oom_no_victim_rs, 60 * HZ, 1);
> >>   oom_no_victim_rs.flags |= RATELIMIT_MSG_ON_RELEASE;
> >>
> >>   if (__ratelimit(&oom_no_victim_rs)) {
> >>     dump_header(oc, NULL);
> >>     pr_warn("Out of memory and no killable processes...\n");
> >>     oom_no_victim_rs.begin = jiffies;
> >>   }
> > 
> > Then there is no reason to reinvent the wheel. So use the standard
> > ratelimit approach. Or put it in other words, this place is no special
> > to any other that needs some sort of printk throttling. We surely do not
> > want an ad-hoc solutions all over the kernel.
> 
> netdev_wait_allrefs() in net/core/dev.c is doing the same thing. Since
> out_of_memory() is serialized by oom_lock mutex, there is no need to use
> "struct ratelimit_state"->lock field. Plain "unsigned long" is enough.

That code probably predates generalized ratelimit api.

> > And once you realize that the ratelimit api is the proper one (put aside
> > any potential improvements in the implementation of this api) then you
> > quickly learn that we already do throttle oom reports and it would be
> > nice to unify that and ... we are back to a naked patch. So please stop
> > being stuborn and try to cooperate finally.
> 
> I don't think that ratelimit API is the proper one, for I am touching
> "struct ratelimit_state"->begin field which is not exported by ratelimit API.
> But if you insist on ratelimit API version, I can tolerate with below one.

I just give up. I do not really see why you always have to make the code
more complex than necessary and squash different things together. This
is a complete kernel code development antipattern.

I am not goging to reply to this thread more but let me note that this
is beyond fun in any aspect I can think off (and yeah I have considered
dark sense of humor as well).

> 
>  mm/oom_kill.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f10aa53..7c6118e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1106,6 +1106,12 @@ bool out_of_memory(struct oom_control *oc)
>  	select_bad_process(oc);
>  	/* Found nothing?!?! */
>  	if (!oc->chosen) {
> +		static DEFINE_RATELIMIT_STATE(no_eligible_rs, 60 * HZ, 1);
> +
> +		ratelimit_set_flags(&no_eligible_rs, RATELIMIT_MSG_ON_RELEASE);
> +		if ((is_sysrq_oom(oc) || is_memcg_oom(oc)) &&
> +		    !__ratelimit(&no_eligible_rs))
> +			return false;
>  		dump_header(oc, NULL);
>  		pr_warn("Out of memory and no killable processes...\n");
>  		/*
> @@ -1115,6 +1121,7 @@ bool out_of_memory(struct oom_control *oc)
>  		 */
>  		if (!is_sysrq_oom(oc) && !is_memcg_oom(oc))
>  			panic("System is deadlocked on memory\n");
> +		no_eligible_rs.begin = jiffies;
>  	}
>  	if (oc->chosen && oc->chosen != (void *)-1UL)
>  		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
