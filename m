Message-ID: <467B3242.9000403@openvz.org>
Date: Fri, 22 Jun 2007 06:21:54 +0400
From: Pavel Emelianov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC] mm-controller
References: <1182418364.21117.134.camel@twins> <467A5B1F.5080204@linux.vnet.ibm.com> <1182433855.21117.160.camel@twins> <467AB5EA.50100@linux.vnet.ibm.com>
In-Reply-To: <467AB5EA.50100@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Paul Menage <menage@google.com>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>, Roy Huang <royhuang9@gmail.com>, Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:

[snip]

>> With the current dual list approach, something like that could be done
>> by treating the container lists as pure FIFO (and ignore the reference
>> bit and all that) and make container reclaim only unmap, not write out
>> pages.
>>
>> Then global reclaim will do the work (if needed), and containers get
>> churn, equating the page ownership.
>>
> 
> I did implement the unmap only logic for shared pages in version 2
> of my RSS controller
> 
> http://lkml.org/lkml/2007/2/19/10
> 
> It can be added back if required quite easily. Pavel what do you think
> about it?

I think it's wrong. Look, when the container hits the limit and just
unmaps the pages the following situation may occur: some *other* container
will hit the global shortage and will have to wait till the other's
pages are flushed to disk. This is not a true isolation. If we send the
pages to the disk right when the container hits the limit we spend its
time, its IO bandwidth, etc and allow for others to have the free set of
pages without additional efforts.

[snip]

>>>> Because, if the data is shared between containers isolation is broken anyway
>>>> and we might as well charge them equally [1].
>>>>
>>>> Move the full reclaim structures from struct zone to these structures.
>>>>
>>>>
>>>> 	struct reclaim;
>>>>
>>>> 	struct reclaim_zone {
>>>> 		spinlock_t		lru_lock;
>>>>
>>>> 		struct list_head 	active;
>>>> 		struct list_head 	inactive;
>>>>
>>>> 		unsigned long		nr_active;
>>>> 		unsigned long		nr_inactive;
>>>>
>>>> 		struct reclaim		*reclaim;
>>>> 	};
>>>>
>>>> 	struct reclaim {
>>>> 		struct reclaim_zone	zone_reclaim[MAX_NR_ZONES];
>>>>
>>>> 		spinlock_t		containers_lock;
>>>> 		struct list_head	containers;
>>>> 		unsigned long		nr_containers;
>>>> 	};
>>>>
>>>>
>>>> 	struct address_space {
>>>> 		...
>>>> 		struct reclaim reclaim;
>>>> 	};
>>>>

Peter, could you prepare some POC patches instead? See, when looking at
the patches is simpler to understand what is going on then when reading
the plain text. Moreover, when making the patches some unexpected details 
of the kernel internals arise and the ideas begin to change...

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
