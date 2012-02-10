Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 5921F6B13F3
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 00:52:25 -0500 (EST)
Received: by vbip1 with SMTP id p1so2280647vbi.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 21:52:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost> <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 9 Feb 2012 21:52:03 -0800
Message-ID: <CAHH2K0bmZn-hthrMasw8FdmgERct2m-8gwsumXpV1q=WQzUW1A@mail.gmail.com>
Subject: Re: memcg writeback (was Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>

(removed lsf-pc@lists.linux-foundation.org because this really isn't
program committee matter)

On Wed, Feb 1, 2012 at 11:52 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> Unfortunately the memcg partitioning could fundamentally make the
> dirty throttling more bumpy.
>
> Imagine 10 memcgs each with
>
> - memcg_dirty_limit=50MB
> - 1 dd dirty task
>
> The flusher thread will be working on 10 inodes in turn, each time
> grabbing the next inode and taking ~0.5s to write ~50MB of its dirty
> pages to the disk. So each inode will be flushed on every ~5s.

Does the flusher thread need to write 50MB/inode in this case?  Would
there be problems interleaving writes by declaring some max write
limit (e.g. 8 MiB/write).  Such interleaving would be beneficial if
there are multiple memcg expecting service from the single bdi flusher
thread.  I suspect certain filesystems might have increased
fragmentation with this, but I am not sure if appending writes can
easily expand an extent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
