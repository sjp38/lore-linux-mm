Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9UISRIa028244
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 14:28:27 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9UISRNj132452
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 14:28:27 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9UISQO1012294
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 14:28:26 -0400
Message-ID: <472777C4.2010307@linux.vnet.ibm.com>
Date: Tue, 30 Oct 2007 23:58:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [-mm PATCH] Memory controller fix swap charging context
 in unuse_pte()
References: <20071005041406.21236.88707.sendpatchset@balbir-laptop> <Pine.LNX.4.64.0710071735530.13138@blonde.wat.veritas.com> <4713A2F2.1010408@linux.vnet.ibm.com> <Pine.LNX.4.64.0710221933570.21262@blonde.wat.veritas.com> <471F3732.5050407@linux.vnet.ibm.com> <Pine.LNX.4.64.0710252002540.25735@blonde.wat.veritas.com> <4724F0BC.1020209@linux.vnet.ibm.com> <20071028203219.GA7145@linux.vnet.ibm.com> <Pine.LNX.4.64.0710292101510.23980@blonde.wat.veritas.com> <47265842.5040506@linux.vnet.ibm.com> <Pine.LNX.4.64.0710301635290.11007@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0710301635290.11007@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 30 Oct 2007, Balbir Singh wrote:
>> At this momemnt, I suspect one of two things
>>
>> 1. Our mods to swap_state.c are different
> 
> I believe they're the same (just take swap_state.c back to how it
> was without mem_cgroup mods) - or would be, if after finding this
> effect I hadn't added a "swap_in_cg" switch to move between the
> two behaviours to study it better (though I do need to remember
> to swapoff and swapon between the two: sometimes I do forget).
> 
>> 2. Our configuration is different, main-memory to swap-size ratio
> 
> I doubt the swapsize is relevant: just so long as there's some (a
> little more than 200M I guess); I've got 1GB-2GB on different boxes.
> 

I agree, just wanted to make sure that there is enough swap

> There may well be something about our configs that's significantly
> different.  I'd failed to mention SMP (4 cpu), and that I happen
> to have /proc/sys/vm/swappiness 100; but find it happens on UP
> also, and when I go back to default swappiness 60.
> 

OK.. so those are out of the equation

> I've reordered your mail for more dramatic effect...
>> On a real box - a powerpc machine that I have access to
> 
> I've tried on 3 Intel and 1 PowerPC now: the Intels show the OOMs
> and the PowerPC does not.  I rather doubt it's an Intel versus
> PowerPC issue as such, but interesting that we see the same.
> 

Very surprising, I am surprised that it's architecture dependent.
Let me try and grab an Intel box and try.

>> 1. I don't see the OOM with the mods removed (I have swap
>>    space at-least twice of RAM - with mem=512M, I have at-least
>>    1G of swap).
> 
> mem=512M with 1G of swap, yes, I'm the same.
> 
>> 2. Running under the container is much much faster than running
>>    swapout in the root container. The machine is almost unusable
>>    if swapout is run under the root container
> 
> That's rather interesting, isn't it?  Probably irrelevant to the
> OOM issue we're investigating, but worthy of investigation in itself.
> 

Yes, it irrelevant, but I find it to be a good use case for using the
memory controller :-) I found that kswapd running at prio -5, seemed
to hog quite a bit of the CPU. But it needs more independent
investigation, like you've suggested.

> Maybe I saw the same on the PowerPC: I simply forgot to set up the
> cgroup one time, and my sequence of three swapouts (sometimes only
> two out of three OOM, on those boxes that do OOM) seemed to take a
> very long time (but I wasn't trying to do anything else on it at
> the same time, so didn't notice if it was "unusable").
> 
> I'll probe on.
> 

Me too.. I'll try and acquire a good x86_64 box and test on it.

> Hugh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
