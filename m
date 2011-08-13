Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DAE096B0169
	for <linux-mm@kvack.org>; Sat, 13 Aug 2011 19:56:18 -0400 (EDT)
Date: Sun, 14 Aug 2011 01:56:11 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110813235611.GA16581@redhat.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
 <20110807142532.GC1823@barrios-desktop>
 <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
 <20110812153616.GH7959@redhat.com>
 <20110812160813.GF2395@linux.vnet.ibm.com>
 <20110812164325.GK7959@redhat.com>
 <20110812172758.GL2395@linux.vnet.ibm.com>
 <CANN689GmsnRXwuy2GGWQopic_68LbEiDGNzbJCTDAN=FvDKXJg@mail.gmail.com>
 <20110813015741.GZ2395@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110813015741.GZ2395@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 06:57:41PM -0700, Paul E. McKenney wrote:
> But if we are getting much below 100 milliseconds, we need to rethink
> this.

The delay may be low in some corner case but this still benefits by
running it only once. You can mmap() bzero, mremap(+4096) (if mremap
moves the pages to a not aligned 2m address, it forces a
split_huge_page, an hardware issue) and all pages will be splitted in
potentially less than 100msec if they're only a few. At least we'll be
running synchronize_rcu only once instead of for every hugepage, as
long as it runs only once I guess we're ok. Normally it shouldn't
happen so fast. My current /proc/vmstat says there are 271 splits for
97251 THP allocated and they're not so likely to have happened within
100msec.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
