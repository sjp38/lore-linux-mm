Message-ID: <456EBACB.9080304@yahoo.com.au>
Date: Thu, 30 Nov 2006 22:04:43 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
References: <20061129030655.941148000@menage.corp.google.com>	 <456E8A74.5080905@yahoo.com.au>	 <6599ad830611292357q745eb2f8y1ad9d4fb5a85c41d@mail.gmail.com>	 <456E95C4.5020809@yahoo.com.au>	 <6599ad830611300039m334e276i9cb3141cc5358d00@mail.gmail.com>	 <456E9C90.4020909@yahoo.com.au>	 <6599ad830611300106w5f5deb60q6d83a684fd679d06@mail.gmail.com>	 <456EA28C.8070508@yahoo.com.au>	 <6599ad830611300145gae22510te7eaa63edf539ad1@mail.gmail.com>	 <456EAF4D.5000804@yahoo.com.au> <6599ad830611300240x388ef00s60183bc3a105ed2a@mail.gmail.com>
In-Reply-To: <6599ad830611300240x388ef00s60183bc3a105ed2a@mail.gmail.com>
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
>>
>> I know it doesn't do what you want. It is an example of using page
>> migration under a higher level API, which I thought is what you
>> wanted to see.
> 
> 
> I'd been talking about the possibility of doing "try to move all
> memory from this node to this other set of nodes"; that wasn't an
> example of such an API.

Oh, well I was talking about using higher level API rather than
migrate directly!

>> Now you're talking about physical nodes as well, which is definitely
>> a problem you get when mixing the two.
>>
>> But there is no reason why you shouldn't be able to specify physical
>> nodes, while also altering the reservation. Even if that does mean
>> hiding the fake nodes from the cpuset interface.
> 
> 
> I think it should be possible to expose the real numa topology via the
> fake topology (e.g. all fake nodes on the same real node appear to be
> fairly close together, compared to any fake nodes on a different real
> node). So I don't think it's necessary to have a separate abstraction
> for fake vs physical nodes.

Well if you want to do (real) node affinity then you need some
separation of course.

But I'm not sure that there is a good reason to use the same
abstraction. Maybe there is, but I think it needs more discussion
(unless I missed something in the past couple of weeks were you
managed to get all memory resource controller groups to agree with
your fakenodes approach).

>> >> If it is exporting any kind of implementation details, then it needs
>> >> to be justified with a specific user that can't be implemented in a
>> >> better way, IMO.
>> >
>> >
>> > It's not really exporting any more implementation details than the
>> > existing cpusets API (i.e. explicitly binding a job to a set of nodes
>> > chosen by userspace). The only true exposed implementation detail is
>> > the "priority" value from try_to_free_pages, and that could be
>> > abstracted away as a value in some range 0-N where 0 means "try very
>> > hard" and N means "hardly try at all", and it wouldn't have to be
>> > directly linked to the try_to_free_pages() priority.
>>
>> Or the fact that memory reservation is implemented with nodes.
> 
> 
> Right, but to me that's a pretty fundamental design decision, rather
> than an implementation detail.

It is a design of the implementation.

The policy is to be able to reserve memory for specific groups of tasks.
And the best API is one where userspace specifies policy. Now there
might be a few tweaks or lower level hints or calls needed to make the
implementation work really optimally. But those should be added later,
and when they are found to be required (and not just maybe useful).

So I see nothing wrong with your exposing these things to userspace if
the goal is to test implementation or get a prototype working quickly.
But if you're talking about the upstream kernel, then I think you need
to start at a much higher level.

>> I'm
>> still not convinced that idea is the best way to export memory
>> control to userspace, regardless of whether it is quick and easy to
>> develop (or even deploy, at google).
> 
> 
> Maybe not the best way for all memory control, but it has certain big
> advantages, such as leveraging the existing numa support, and not
> requiring additional per-page overhead or LRU complexity.

Oh I agree. And I think it is one of the better implementations I have
seen. But I don't like the API.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
