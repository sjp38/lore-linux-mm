Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4AJjSjk022481
	for <linux-mm@kvack.org>; Wed, 10 May 2006 15:45:28 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4AJjODO238686
	for <linux-mm@kvack.org>; Wed, 10 May 2006 15:45:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k4AJjOQ6005451
	for <linux-mm@kvack.org>; Wed, 10 May 2006 15:45:24 -0400
Message-ID: <446242CB.4090106@us.ibm.com>
Date: Wed, 10 May 2006 14:45:15 -0500
From: Brian Twichell <tbrian@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2][RFC] New version of shared page tables
References: <1146671004.24422.20.camel@wildcat.int.mccr.org> <Pine.LNX.4.64.0605031650190.3057@blonde.wat.veritas.com> <57DF992082E5BD7D36C9D441@[10.1.1.4]> <Pine.LNX.4.64.0605061620560.5462@blonde.wat.veritas.com> <445FA0CA.4010008@us.ibm.com> <44600F9B.1060207@yahoo.com.au>
In-Reply-To: <44600F9B.1060207@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> Brian Twichell wrote:
>
>>
>> If we had to choose between pagetable sharing for small pages and 
>> hugepages, we would be in favor of retaining pagetable sharing for 
>> small pages.  That is where the discernable benefit is for customers 
>> that run with "out-of-the-box" settings.  Also, there is still some 
>> benefit there on x86-64 for customers that use hugepages for the 
>> bufferpools.
>
>
> Of course if it was free performance then we'd want it. The downsides 
> are that it
> is a significant complexity for a pretty small (3%) performance gain 
> for your apparent
> target workload, which is pretty uncommon among all Linux users.

Our performance data demonstrated that the potential gain for the 
non-hugepage case is much higher than 3%.

>
> Ignoring the complexity, it is still not free. Sharing data across 
> processes adds to
> synchronisation overhead and hurts scalability. Some of these page 
> fault scalability
> scenarios have shown to be important enough that we have introduced 
> complexity _there_.

True, but this needs to be balanced against the fact that pagetable 
sharing will reduce the number of page faults when it is achieved.  
Let's say you have N processes which touch all the pages in an M page 
shared memory region.  Without shared pagetables this requires N*M page 
faults; if pagetable sharing is achieved, only M pagefaults are required.

>
> And it seems customers running "out-of-the-box" settings really want 
> to start using
> hugepages if they're interested in getting the most performance 
> possible, no?

My perspective is that, once the customer is required to invoke "echo 
XXX > /proc/sys/vm/nr_hugepages" they've left the "out-of-the-box" 
domain, and entered the domain of hoping that the number of hugepages is 
sufficient, because if it's not, they'll probably need to reboot, which 
can be pretty inconvenient for a production transaction-processing 
application.

Cheers,
Brian



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
