Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 9BA566B0206
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 23:31:05 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BD5053EE0BC
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:31:03 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A2BA745DEB7
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:31:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D1CE45DEB6
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:31:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 609D41DB8038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:31:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 08D4E1DB803E
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:31:03 +0900 (JST)
Date: Tue, 13 Dec 2011 13:29:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: Use gfp_mask __GFP_NORETRY in try charge
Message-Id: <20111213132949.c6eecaa5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323742587-9084-1-git-send-email-yinghan@google.com>
References: <1323742587-9084-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Mon, 12 Dec 2011 18:16:27 -0800
Ying Han <yinghan@google.com> wrote:

> In __mem_cgroup_try_charge() function, the parameter "oom" is passed from the
> caller indicating whether or not the charge should enter memcg oom kill. In
> fact, we should be able to eliminate that by using the existing gfp_mask and
> __GFP_NORETRY flag.
> 
> This patch removed the "oom" parameter, and add the __GFP_NORETRY flag into
> gfp_mask for those doesn't want to enter memcg oom. There is no functional
> change for those setting false to "oom" like mem_cgroup_move_parent(), but
> __GFP_NORETRY now is checked for those even setting true to "oom".
> 
> The __GFP_NORETRY is used in page allocator to bypass retry and oom kill. I
> believe there is a reason for callers to use that flag, and in memcg charge
> we need to respect it as well.
> 
> Signed-off-by: Ying Han <yinghan@google.com>


I don't like this. _GFP_NORETRY is included in GFP_RECLAIM_MASK and
may be affeced by future changes in vmscan.c


Bye,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
