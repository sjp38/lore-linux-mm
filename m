Message-ID: <45A602F0.1090405@yahoo.com.au>
Date: Thu, 11 Jan 2007 20:27:12 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [REGRESSION] 2.6.19/2.6.20-rc3 buffered write slowdown
References: <20070110223731.GC44411608@melbourne.sgi.com> <Pine.LNX.4.64.0701101503310.22578@schroedinger.engr.sgi.com> <20070110230855.GF44411608@melbourne.sgi.com> <45A57333.6060904@yahoo.com.au> <20070111003158.GT33919298@melbourne.sgi.com> <45A58DFA.8050304@yahoo.com.au> <20070111012404.GW33919298@melbourne.sgi.com>
In-Reply-To: <20070111012404.GW33919298@melbourne.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Chinner wrote:
> On Thu, Jan 11, 2007 at 12:08:10PM +1100, Nick Piggin wrote:

>>>So, what I've attached is three files which have both
>>>'vmstat 5' output and 'iostat 5 |grep dm-' output in them.
>>
>>Ahh, sorry to be unclear, I meant:
>>
>>  cat /proc/vmstat > pre
>>  run_test
>>  cat /proc/vmstat > post
> 
> 
> Ok, I'll get back to you on that one - even at 600+MB/s, writing 5TB
> of data takes some time....

OK, according to your vmstat deltas, you are doing an order of magnitude
more writeout off the LRU with 2.6.20-rc3 default than with the smaller
dirty_ratio (53GB of data vs 4GB of data). 2.6.18 does not have that stat,
unfortunately.

allocstall and direct reclaim are way down when the dirty ratio is lower,
but those numbers with vanilla 2.6.20-rc3 are comparable to 2.6.18, so
that shows that kswapd in 2.6.18 is probably also having trouble which may
mean it is also writing out a lot off the LRU.

You're not turning on zone_reclaim, by any chance, are you?

Otherwise, nothing jumps out at me yet. I'll have a bit of a look through
changelogs tomorrow. I guess it could be a pdflush or vmscan change (XFS,
maybe?).

Can you narrow it down at all?

THanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
