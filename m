Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 73B618D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 16:23:42 -0400 (EDT)
Date: Mon, 14 Mar 2011 16:23:25 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-ID: <20110314202324.GG31120@redhat.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org>
 <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>

On Mon, Mar 14, 2011 at 11:29:17AM -0700, Greg Thelen wrote:

[..]
> > We could just crawl the memcg's page LRU and bring things under control
> > that way, couldn't we?  That would fix it.  What were the reasons for
> > not doing this?
> 
> My rational for pursuing bdi writeback was I/O locality.  I have heard that
> per-page I/O has bad locality.  Per inode bdi-style writeback should have better
> locality.
> 
> My hunch is the best solution is a hybrid which uses a) bdi writeback with a
> target memcg filter and b) using the memcg lru as a fallback to identify the bdi
> that needed writeback.  I think the part a) memcg filtering is likely something
> like:
>  http://marc.info/?l=linux-kernel&m=129910424431837
> 
> The part b) bdi selection should not be too hard assuming that page-to-mapping
> locking is doable.

Greg, 

IIUC, option b) seems to be going through pages of particular memcg and
mapping page to inode and start writeback on particular inode?

If yes, this might be reasonably good. In the case when cgroups are not
sharing inodes then it automatically maps one inode to one cgroup and
once cgroup is over limit, it starts writebacks of its own inode.

In case inode is shared, then we get the case of one cgroup writting
back the pages of other cgroup. Well I guess that also can be handeled
by flusher thread where a bunch or group of pages can be compared with
the cgroup passed in writeback structure. I guess that might hurt us
more than benefit us.

IIUC how option b) works then we don't even need option a) where an N level
deep cache is maintained?

Thanks
Vivek 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
