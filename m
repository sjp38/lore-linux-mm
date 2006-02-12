Message-ID: <43EEAC93.3000803@yahoo.com.au>
Date: Sun, 12 Feb 2006 14:33:39 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Get rid of scan_control
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>	<20060211045355.GA3318@dmt.cnet>	<20060211013255.20832152.akpm@osdl.org> <20060211014649.7cb3b9e2.akpm@osdl.org>
In-Reply-To: <20060211014649.7cb3b9e2.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: marcelo.tosatti@cyclades.com, clameter@engr.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> 
>>I found that scan_control wasn't
>> really a success.  We had one bug due to failing to initialise something in
>> it, and we're fiddling with fields all over the place.  It just seemed to
>> obfuscate the code, make it harder to work with, harder to check that
>> everything was correct.
> 

I agree with Marcelo, I prefer scan_control. I'm not sure if it was
modelled on writeback_control or not, but it is certianly very different:
writeback_control is spread over many files and subsystems. scan_control
is vmscan local and is simply used to alleviate the passing of many
values back and forth between vmscan functions.

> 
> I spose we could do this, which is a bit of an improvement.
> 
> But the problems do remain, really.  The one which creeps me out is looking
> at a piece of code which does:
> 
> 
> 	foo(&sc);
> 	if (sc.bar ...)
> 
> and just not knowing whether foo() altered sc.bar.
> 

Luckily there are very limited call stacks which modify this stuff so it isn't
too hard to keep all in your head at once after you start doing a bit of work
in vmscan. That said, we could implement a commenting convention to help things.

/*
  * refill_inactive_list
  * input:
  * sc.nr_scan - specifies the number of ...
  * sc.blah ...
  *
  * modifies:
  * sc.nr_scan - blah blah
  */

?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
