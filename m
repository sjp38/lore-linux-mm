Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CCBF18D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 13:24:34 -0500 (EST)
Date: Fri, 28 Jan 2011 19:24:07 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110128182407.GO16981@random.random>
References: <20110127160301.GA29291@csn.ul.ie>
 <20110127185215.GE16981@random.random>
 <20110127213106.GA25933@csn.ul.ie>
 <4D41FD2F.3050006@redhat.com>
 <20110128103539.GA14669@csn.ul.ie>
 <20110128162831.GH16981@random.random>
 <20110128164624.GA23905@csn.ul.ie>
 <4D42F9E3.2010605@redhat.com>
 <20110128174644.GM16981@random.random>
 <4D430506.2070502@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D430506.2070502@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 01:03:50PM -0500, Rik van Riel wrote:
> My point is, the behaviour you describe would be WRONG :)
> 
> The reason is that the different zones can contain data
> that is either heavily used or rarely used, often some
> mixture of the two, but sometimes the zones are out of
> balance in how much the data in memory gets touched.
> 
> We need to reclaim and reuse the lightly used memory
> a little faster than the heavily used memory, to even
> out the memory pressure between zones.

I've no idea how kswapd can reclaim the lightly used memory a little
faster when it blocks at high+gap. Unless the allocator is eating into
the gap, kswapd will be stuck at 700M free, and no rotation in the lru
will ever happen in the lower zones. You can't control it from kswapd
but only from the allocator and regardless the size of the gap the
rotation won't alter. As eventually in the "cp /dev/sda /dev/null"
example workload (but simulating what happens normally during any file
read) the "high+gap" will be reached in 5 sec then it'll be like if
there's no gap for the next 2 hours.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
