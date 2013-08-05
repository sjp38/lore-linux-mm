Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 680AC6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 12:30:05 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id e11so1783952qcx.36
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 09:30:04 -0700 (PDT)
Date: Mon, 5 Aug 2013 12:29:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET cgroup/for-3.12] cgroup: make cgroup_event specific to
 memcg
Message-ID: <20130805162958.GF19631@mtj.dyndns.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
 <20130805160107.GM10146@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130805160107.GM10146@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lizefan@huawei.com, hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Michal.

On Mon, Aug 05, 2013 at 06:01:07PM +0200, Michal Hocko wrote:
> Could you be more specific about what is so "overboard" about this
> interface? I am not familiar with internals much, so I cannot judge the
> complexity part, but I thought that eventfd was intended for this kind
> of kernel->userspace notifications.

It's just way over-engineered like many other things in cgroup, most
likely misguided by the appearance that cgroup could be delegated and
accessed by multiple actors concurrently.

The most clear example would be the vmpressure event.  When it could
have just called fsnotify_modify() unconditionally when the state
changes, now it involves parsing, dynamic list of events and so on
without actually adding any benefits.  For the usage ones,
configurability makes some sense but even then just giving it a single
array of event points of limited size would be sufficient.

It's just way over-done.

> So you think that vmpressure, oom notification or thresholds are
> an abuse of this interface? What would you consider a reasonable
> replacement for those notifications?  Or do you think that controller
> shouldn't be signaling any conditions to the userspace at all?

I don't think the ability to generate events are an abuse, just that
the facility itself is way over-engineered.  Just generate a file
changed event unconditionally for vmpressure and oom and maybe
implement configureable cadence or single set of threshold array for
threshold events.  These are things which can and should be done in a
a few tens of lines of code with far simpler interface.  There's no
need for this obsecenely flexible event infrastructure, which of
course leads to things like shared contiguous threshold table without
any size limit and allocated with kmalloc().

So, let's please move towards something simple.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
