Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CBF8C8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:16:50 -0500 (EST)
Message-ID: <4D42F9E3.2010605@redhat.com>
Date: Fri, 28 Jan 2011 12:16:19 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: too big min_free_kbytes
References: <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110127160301.GA29291@csn.ul.ie> <20110127185215.GE16981@random.random> <20110127213106.GA25933@csn.ul.ie> <4D41FD2F.3050006@redhat.com> <20110128103539.GA14669@csn.ul.ie> <20110128162831.GH16981@random.random> <20110128164624.GA23905@csn.ul.ie>
In-Reply-To: <20110128164624.GA23905@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On 01/28/2011 11:46 AM, Mel Gorman wrote:
> On Fri, Jan 28, 2011 at 05:28:31PM +0100, Andrea Arcangeli wrote:

>> In previous email you asked me how kswapd get stuck in D state and
>> never stops working, and that it should stop earlier. This sounds
>> impossible, kswapd behavior can't possibly change, simply there is
>> less memory freed by lowering that "gap".
>
> There might be less memory freed by lowering that gap but it still needs to
> exit balance_pgdat() and go to sleep. Otherwise it'll keep freeing zones up
> to the high watermark + gap and calling congestion_wait (hence the D state).

The gap works because kswapd has different thresholds for
different things:

1) get woken up if every zone on an allocator's zone list
    is below the low watermark

2) exit the loop if _every_ zone is at or above the
    high watermark

3) skip a zone in the freeing loop if the zone has more
    than high + gap free memory

Continuing the loop as long as one zone is below the low
watermark is what equalizes memory pressure between zones.

Skipping the freeing of pages in a zone that already has
excessive amounts of free memory helps avoid memory waste
and excessive swapping.  We simply equalize the balance
between zones a little more slowly.  What matters is that
the memory pressure gets equalized over time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
