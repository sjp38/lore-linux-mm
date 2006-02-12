Message-ID: <43EEB4DA.6030501@yahoo.com.au>
Date: Sun, 12 Feb 2006 15:08:58 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Get rid of scan_control
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com> <20060211045355.GA3318@dmt.cnet> <20060211013255.20832152.akpm@osdl.org> <20060211014649.7cb3b9e2.akpm@osdl.org> <43EEAC93.3000803@yahoo.com.au> <Pine.LNX.4.62.0602111941480.25758@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0602111941480.25758@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sun, 12 Feb 2006, Nick Piggin wrote:
> 
> 
>>I agree with Marcelo, I prefer scan_control. I'm not sure if it was
>>modelled on writeback_control or not, but it is certianly very different:
>>writeback_control is spread over many files and subsystems. scan_control
>>is vmscan local and is simply used to alleviate the passing of many
>>values back and forth between vmscan functions.
> 
> 
> The trouble with scan_control is that it contains diverse variables. For 
> example it caches nr_mapped, its used to pass results back to the caller 
> etc. 
> 

But I don't see why that is trouble if you would otherwise need to do
it by passing pointers to variables individually.

Sure you don't get an idea (from the call signature) of exactly what is
modified or how things are used... but you never really got (a complete
picture of) that anyway.

> 
>>Luckily there are very limited call stacks which modify this stuff so it isn't
>>too hard to keep all in your head at once after you start doing a bit of work
>>in vmscan. That said, we could implement a commenting convention to help
>>things.
>>
>>/*
>> * refill_inactive_list
>> * input:
>> * sc.nr_scan - specifies the number of ...
>> * sc.blah ...
>> *
>> * modifies:
>> * sc.nr_scan - blah blah
>> */
> 
> 
> Could we at least pass the number of pages reclaimed back as the return 
> value of the functions? I believe most of the savings that Andrew saw was 
> due to the number of reclaimed pages being processed directly in 
> registers.

What savings are you interested in, exactly? Your initial patch
would definitely have slowed down page reclaim on big systems
due to the read_page_state...

I think most of the cost apart from locking (because that will
depend on contention) is hitting random cachelines of struct pages
then hitting random radix tree cachelines to remove them. Not
much you can do about that.

That said I'm never against microoptimisations provided they
weigh in on the right side of the (subjective) complexity /
improvement ratio.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
