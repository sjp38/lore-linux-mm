Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B10C56B0139
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 07:15:22 -0500 (EST)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o2CCFJZg003168
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 12:15:19 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2CCF95T606256
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 12:15:19 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o2CCF9Or013525
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 12:15:09 GMT
Message-ID: <4B9A3049.7010602@linux.vnet.ibm.com>
Date: Fri, 12 Mar 2010 13:15:05 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <20100311154124.e1e23900.akpm@linux-foundation.org> <4B99E19E.6070301@linux.vnet.ibm.com> <20100312020526.d424f2a8.akpm@linux-foundation.org> <20100312104712.GB18274@csn.ul.ie>
In-Reply-To: <20100312104712.GB18274@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Fri, Mar 12, 2010 at 02:05:26AM -0500, Andrew Morton wrote:
>> On Fri, 12 Mar 2010 07:39:26 +0100 Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:
>>
>>>
>>> Andrew Morton wrote:
>>>> On Mon,  8 Mar 2010 11:48:20 +0000
>>>> Mel Gorman <mel@csn.ul.ie> wrote:
[...]

>> If not, we broke it again.
>>
> 
> We were broken with respect to this in the first place. That
> cond_reched() is badly placed and waiting on congestion when congestion
> might not be involved is also a bit odd.
> 
> It's possible that Christian's specific problem would also be addressed
> by the following patch. Christian, willing to test?

Will is here, but no chance before monday/tuesday to get a free machine 
slot - I'll post results as soon as I get them.

> It still feels a bit unnatural though that the page allocator waits on
> congestion when what it really cares about is watermarks. Even if this
> patch works for Christian, I think it still has merit so will kick it a
> few more times.

In whatever way I can look at it watermark_wait should be supperior to 
congestion_wait. Because as Mel points out waiting for watermarks is 
what is semantically correct there.

If there eventually some day comes a solution without any of those waits 
I'm fine too - e.g. by closing whatever races we have and fixing that 
one context can never run into this in direct_reclaim:
1. free pages with try_to_free
2. not getting one in the subsequent get_page call

But as long as we have a wait - watermark waiting > congestion waiting 
(IMHO).

> ==== CUT HERE ====
> page-allocator: Attempt page allocation immediately after direct reclaim
[...]
-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
