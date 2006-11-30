Message-ID: <456EAF4D.5000804@yahoo.com.au>
Date: Thu, 30 Nov 2006 21:15:41 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
References: <20061129030655.941148000@menage.corp.google.com>	 <456D23A0.9020008@yahoo.com.au>	 <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>	 <456E8A74.5080905@yahoo.com.au>	 <6599ad830611292357q745eb2f8y1ad9d4fb5a85c41d@mail.gmail.com>	 <456E95C4.5020809@yahoo.com.au>	 <6599ad830611300039m334e276i9cb3141cc5358d00@mail.gmail.com>	 <456E9C90.4020909@yahoo.com.au>	 <6599ad830611300106w5f5deb60q6d83a684fd679d06@mail.gmail.com>	 <456EA28C.8070508@yahoo.com.au> <6599ad830611300145gae22510te7eaa63edf539ad1@mail.gmail.com>
In-Reply-To: <6599ad830611300145gae22510te7eaa63edf539ad1@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 11/30/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>> >> AFAIK they do that in their higher level APIs (at least HPC numa 
>> does).
>> >
>> >
>> > Could you point me at an example?
>>
>> kernel/cpuset.c:cpuset_migrate_mm
> 
> 
> No, that doesn't really do what we want. It basically just calls
> do_migrate_pages, which has the drawbacks of:

I know it doesn't do what you want. It is an example of using page
migration under a higher level API, which I thought is what you
wanted to see.

>> How about "try to change the memory reservation charge of this
>> 'container' from xMB to yMB"? Underneath that API, your fakenode
>> controller would do the node reclaim and consolidation stuff --
>> but it could be implemented completely differently in the case of
>> a different type of controller.
> 
> 
> How would it make decisions such as which node to free up (e.g.
> userspace might have a strong preference for keeping a job on one
> particular real node, or moving it to a different one.) I think that
> policy decisions like this belong in userspace, in the same way that
> the existing cpusets API provides a way to say "this cpuset uses these
> nodes" rather than "this cpuset should have N nodes".

Now you're talking about physical nodes as well, which is definitely
a problem you get when mixing the two.

But there is no reason why you shouldn't be able to specify physical
nodes, while also altering the reservation. Even if that does mean
hiding the fake nodes from the cpuset interface.

>> If it is exporting any kind of implementation details, then it needs
>> to be justified with a specific user that can't be implemented in a
>> better way, IMO.
> 
> 
> It's not really exporting any more implementation details than the
> existing cpusets API (i.e. explicitly binding a job to a set of nodes
> chosen by userspace). The only true exposed implementation detail is
> the "priority" value from try_to_free_pages, and that could be
> abstracted away as a value in some range 0-N where 0 means "try very
> hard" and N means "hardly try at all", and it wouldn't have to be
> directly linked to the try_to_free_pages() priority.

Or the fact that memory reservation is implemented with nodes. I'm
still not convinced that idea is the best way to export memory
control to userspace, regardless of whether it is quick and easy to
develop (or even deploy, at google).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
