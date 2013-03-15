Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id EE9266B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 12:19:05 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 15 Mar 2013 21:44:40 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 3F557E0054
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 21:50:22 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2FGIuvo3670454
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 21:48:56 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2FGIwCJ008171
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 03:18:59 +1100
Message-ID: <514349EA.9070404@linux.vnet.ibm.com>
Date: Fri, 15 Mar 2013 11:18:50 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: zsmalloc limitations and related topics
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default> <20130313151359.GA3130@linux.vnet.ibm.com> <4ab899f6-208c-4d61-833c-d1e5e8b1e761@default> <514104D5.9020700@linux.vnet.ibm.com> <5141BC5D.9050005@oracle.com> <20130314132046.GA3172@linux.vnet.ibm.com> <006139fe-542e-46f0-8b6c-b05efeb232d6@default>
In-Reply-To: <006139fe-542e-46f0-8b6c-b05efeb232d6@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Robert Jennings <rcj@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, minchan@kernel.org, Nitin Gupta <nitingupta910@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

On 03/14/2013 01:54 PM, Dan Magenheimer wrote:
>> From: Robert Jennings [mailto:rcj@linux.vnet.ibm.com]
>> Sent: Thursday, March 14, 2013 7:21 AM
>> To: Bob
>> Cc: Seth Jennings; Dan Magenheimer; minchan@kernel.org; Nitin Gupta; Konrad Wilk; linux-mm@kvack.org;
>> linux-kernel@vger.kernel.org; Bob Liu; Luigi Semenzato; Mel Gorman
>> Subject: Re: zsmalloc limitations and related topics
>>
>> * Bob (bob.liu@oracle.com) wrote:
>>> On 03/14/2013 06:59 AM, Seth Jennings wrote:
>>>> On 03/13/2013 03:02 PM, Dan Magenheimer wrote:
>>>>>> From: Robert Jennings [mailto:rcj@linux.vnet.ibm.com]
>>>>>> Subject: Re: zsmalloc limitations and related topics
>>>>>
>> <snip>
>>>>> Yes.  And add pageframe-reclaim to this list of things that
>>>>> zsmalloc should do but currently cannot do.
>>>>
>>>> The real question is why is pageframe-reclaim a requirement?  What
>>>> operation needs this feature?
>>>>
>>>> AFAICT, the pageframe-reclaim requirements is derived from the
>>>> assumption that some external control path should be able to tell
>>>> zswap/zcache to evacuate a page, like the shrinker interface.  But this
>>>> introduces a new and complex problem in designing a policy that doesn't
>>>> shrink the zpage pool so aggressively that it is useless.
>>>>
>>>> Unless there is another reason for this functionality I'm missing.
>>>>.
>>>
>>> Perhaps it's needed if the user want to enable/disable the memory
>>> compression feature dynamically.
>>> Eg, use it as a module instead of recompile the kernel or even
>>> reboot the system.
> 
> It's worth thinking about: Under what circumstances would a user want
> to turn off compression?  While unloading a compression module should
> certainly be allowed if it makes a user comfortable, in my opinion,
> if a user wants to do that, we have done our job poorly (or there
> is a bug).
> 
>> To unload zswap all that is needed is to perform writeback on the pages
>> held in the cache, this can be done by extending the existing writeback
>> code.
> 
> Actually, frontswap supports this directly.  See frontswap_shrink.

frontswap_shrink() is a best-effort attempt to fault in all the pages
stored in the backend.  However, if there is not enough RAM to hold all
the pages, then it can not completely evacuate the backend.

Module exit functions must return void, so there is no way to fail a
module unload.  If you implement an exit function for your module, you
must insure that it can always complete successfully.  For this reason
frontswap_shrink() is unsuitable for module unloading.  You'd need to
use a mechanism like writeback that could surely evacuate the backend
(baring I/O failures).

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
