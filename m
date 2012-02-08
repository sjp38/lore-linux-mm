Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 4BD096B13F2
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 02:55:26 -0500 (EST)
Received: by qcsd16 with SMTP id d16so162153qcs.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 23:55:25 -0800 (PST)
MIME-Version: 1.0
From: Greg Thelen <gthelen@google.com>
Date: Tue, 7 Feb 2012 23:55:05 -0800
Message-ID: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
Subject: memcg writeback (was Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, Feb 3, 2012 at 1:40 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> If moving dirty pages out of the memcg to the 20% global dirty pages
> pool on page reclaim, the above OOM can be avoided. It does change the
> meaning of memory.limit_in_bytes in that the memcg tasks can now
> actually consume more pages (up to the shared global 20% dirty limit).

This seems like an easy change, but unfortunately the global 20% pool
has some shortcomings for my needs:

1. the global 20% pool is not moderated.  One cgroup can dominate it
    and deny service to other cgroups.

2. the global 20% pool is free, unaccounted memory.  Ideally cgroups only
    use the amount of memory specified in their memory.limit_in_bytes.  The
    goal is to sell portions of a system.  Global resource like the 20% are an
    undesirable system-wide tax that's shared by jobs that may not even
    perform buffered writes.

3. Setting aside 20% extra memory for system wide dirty buffers is a lot of
    memory.  This becomes a larger issue when the global dirty_ratio is
    higher than 20%.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
