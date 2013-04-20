Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 9BBEE6B0006
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 23:35:33 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id lf11so2373183vcb.34
        for <linux-mm@kvack.org>; Fri, 19 Apr 2013 20:35:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130420004221.GB17179@mtj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org> <20130420004221.GB17179@mtj.dyndns.org>
From: Greg Thelen <gthelen@google.com>
Date: Fri, 19 Apr 2013 20:35:12 -0700
Message-ID: <CAHH2K0aeNke1NzcnyeeyHH1XvGLGxFG0_fXKAi3JH+HMtYjV=Q@mail.gmail.com>
Subject: Re: memcg: softlimit on internal nodes
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>

On Fri, Apr 19, 2013 at 5:42 PM, Tejun Heo <tj@kernel.org> wrote:
> On Fri, Apr 19, 2013 at 05:26:20PM -0700, Tejun Heo wrote:
>> If such actual soft limit is desired (I don't know, it just seems like
>> a very fundamental / logical feature to me), please don't try to
>> somehow overload "softlimit".  They are two fundamentally different
>> knobs, both make sense in their own ways, and when you stop confusing
>> the two, there's nothing ambiguous about what what each knob means in
>> hierarchical situations.  This goes the same for the "untrusted" flag
>> Ying told me, which seems like another confused way to overload two
>> meanings onto "softlimit".  Don't overload!
>
> As for how actually to clean up this yet another mess in memcg, I
> don't know.  Maybe introduce completely new knobs - say,
> oom_threshold, reclaim_threshold, and reclaim_trigger - and alias
> hardlimit to oom_threshold and softlimit to recalim_trigger?  BTW,
> "softlimit" should default to 0.  Nothing else makes any sense.

I agree that the hard limit could be called the oom_threshold.

The meaning of the term reclaim_threshold is not obvious to me.  I'd
prefer to call the soft limit a reclaim_target.  System global
pressure can steal memory from a cgroup until its usage drops to the
soft limit (aka reclaim_target).  Pressure will try to avoid stealing
memory below the reclaim target.  The soft limit (reclaim_target) is
not checked until global pressure exists.  Currently we do not have a
knob to set a reclaim_threshold, such that when usage exceeds the
reclaim_threshold async reclaim is queued.  We are not discussing
triggering anything when soft limit is exceeded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
