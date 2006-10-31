Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id k9VALwFU234642
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 21:22:04 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9VAEqMt211330
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 21:15:03 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9VABQrQ022931
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 21:11:26 +1100
Message-ID: <45472133.9090109@in.ibm.com>
Date: Tue, 31 Oct 2006 15:40:59 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [ckrm-tech] RFC: Memory Controller
References: <20061030103356.GA16833@in.ibm.com> <4545D51A.1060808@in.ibm.com> <4546212B.4010603@openvz.org> <454638D2.7050306@in.ibm.com> <45463F70.1010303@in.ibm.com> <45470FEE.6040605@openvz.org> <45471510.4070407@in.ibm.com> <45471679.90103@openvz.org>
In-Reply-To: <45471679.90103@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@openvz.org>
Cc: vatsa@in.ibm.com, dev@openvz.org, sekharan@us.ibm.com, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, pj@sgi.com, matthltc@us.ibm.com, dipankar@in.ibm.com, rohitseth@google.com, menage@google.com, linux-mm@kvack.org, Vaidyanathan S <svaidy@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Pavel Emelianov wrote:
> Balbir Singh wrote:
>> Pavel Emelianov wrote:
>>> [snip]
>>>
>>>>> But in general I agree, these are the three important resources for
>>>>> accounting and control
>>>> I missed out to mention, I hope you were including the page cache in
>>>> your definition of reclaimable memory.
>>> As far as page cache is concerned my opinion is the following.
>>> (If I misunderstood you, please correct me.)
>>>
>>> Page cache is designed to keep in memory as much pages as
>>> possible to optimize performance. If we start limiting the page
>>> cache usage we cut the performance. What is to be controlled is
>>> _used_ resources (touched pages, opened file descriptors, mapped
>>> areas, etc), but not the cached ones. I see nothing bad if the
>>> page that belongs to a file, but is not used by ANY task in BC,
>>> stays in memory. I think this is normal. If kernel wants it may
>>> push this page out easily it won't event need to try_to_unmap()
>>> it. So cached pages must not be accounted.
>>>
>> The idea behind limiting the page cache is this
>>
>> 1. Lets say one container fills up the page cache.
>> 2. The other containers will not be able to allocate memory (even
>> though they are within their limits) without the overhead of having
>> to flush the page cache and freeing up occupied cache. The kernel
>> will have to pageout() the dirty pages in the page cache.
>>
>> Since it is easy to push the page out (as you said), it should be
>> easy to impose a limit on the page cache usage of a container.
> 
> If a group is limited with memory _consumption_ it won't fill
> the page cache...
> 

So you mean the memory _consumption_ limit is already controlling
the page cache? That's what we need the ability for a container
not to fill up the page cache :)

I don't remember correctly, but do you account for dirty page cache usage in
the latest patches of BC?

>>> I've also noticed that you've [snip]-ed on one of my questions.
>>>
>>>  > How would you allocate memory on NUMA in advance?
>>>
>>> Please, clarify this.
>> I am not quite sure I understand the question. Could you please rephrase
>> it and highlight some of the difficulty?
> 
> I'd like to provide a guarantee for a newly created group. According
> to your idea I have to preallocate some pages in advance. OK. How to
> select a NUMA node to allocate them from?

The idea of pre-allocation was discussed as a possibility in the case
that somebody needed hard guarantees, but most of us don't need it.
I was in the RFC for the sake of completeness.

Coming back to your question

Why do you need to select a NUMA node? For performance?

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
