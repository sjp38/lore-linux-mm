Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AF97C9000BD
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 15:25:18 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8FJ1YU3009636
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 15:01:34 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8FJPF3N239358
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 15:25:16 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8FJP0an029613
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 15:25:05 -0400
Message-ID: <4E725109.3010609@linux.vnet.ibm.com>
Date: Thu, 15 Sep 2011 14:24:57 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com> <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org> <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org> <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org 4E72284B.2040907@linux.vnet.ibm.com> <075c4e4c-a22d-47d1-ae98-31839df6e722@default>
In-Reply-To: <075c4e4c-a22d-47d1-ae98-31839df6e722@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On 09/15/2011 12:29 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
>>
>> Hey Nitin,
>>
>> So this is how I see things...
>>
>> Right now xvmalloc is broken for zcache's application because
>> of its huge fragmentation for half the valid allocation sizes
>> (> PAGE_SIZE/2).
> 
> Um, I have to disagree here. It is broken for zcache for
> SOME set of workloads/data, where the AVERAGE compression
> is poor (> PAGE_SIZE/2).
> 

True.

But are we not in agreement that xvmalloc needs to be replaced
with an allocator that doesn't have this issue? I thought we all
agreed on that...

>> My xcfmalloc patches are _a_ solution that is ready now.  Sure,
>> it doesn't so compaction yet, and it has some metadata overhead.
>> So it's not "ideal" (if there is such I thing). But it does fix
>> the brokenness of xvmalloc for zcache's application.
> 
> But at what cost?  As Dave Hansen pointed out, we still do
> not have a comprehensive worst-case performance analysis for
> xcfmalloc.  Without that (and without an analysis over a very
> large set of workloads), it is difficult to characterize
> one as "better" than the other.
> 

I'm not sure what you mean by "comprehensive worst-case performance
analysis".  If you're talking about theoretical worst-case runtimes
(i.e. O(whatever)) then apparently we are going to have to
talk to an authority on algorithm analysis because we can't agree
how to determine that.  However, it isn't difficult to look at the
code and (within your own understanding) see what it is.

I'd be interested so see what Nitin thinks is the worst-case runtime
bound.

How would you suggest that I measure xcfmalloc performance on a "very
large set of workloads".  I guess another form of that question is: How
did xvmalloc do this?

>> So I see two ways going forward:
>>
>> 1) We review and integrate xcfmalloc now.  Then, when you are
>> done with your allocator, we can run them side by side and see
>> which is better by numbers.  If yours is better, you'll get no
>> argument from me and we can replace xcfmalloc with yours.
>>
>> 2) We can agree on a date (sooner rather than later) by which your
>> allocator will be completed.  At that time we can compare them and
>> integrate the best one by the numbers.
>>
>> Which would you like to do?
> 
> Seth, I am still not clear why it is not possible to support
> either allocation algorithm, selectable at runtime.  Or even
> dynamically... use xvmalloc to store well-compressible pages
> and xcfmalloc for poorly-compressible pages.  I understand
> it might require some additional coding, perhaps even an
> ugly hack or two, but it seems possible.

But why do an ugly hack if we can just use a single allocator
that has the best overall performance for the allocation range
the zcache requires.  Why make it more complicated that it
needs to be?

> 
> Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
