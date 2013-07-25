Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id C019B6B0034
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 02:28:30 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 25 Jul 2013 16:25:03 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 6C74C2BB0051
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 16:27:42 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6P6C4Dl52822166
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 16:12:08 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6P6RbI3032372
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 16:27:38 +1000
Message-ID: <51F0C47E.4000900@linux.vnet.ibm.com>
Date: Thu, 25 Jul 2013 11:53:58 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: Restructure free-page stealing code and fix a
 bug
References: <20130722184805.9573.78514.stgit@srivatsabhat.in.ibm.com> <20130725031040.GA29193@hacker.(null)>
In-Reply-To: <20130725031040.GA29193@hacker.(null)>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, minchan@kernel.org, cody@linux.vnet.ibm.com, rostedt@goodmis.org, jiang.liu@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/25/2013 08:40 AM, Wanpeng Li wrote:
> On Tue, Jul 23, 2013 at 12:18:06AM +0530, Srivatsa S. Bhat wrote:
>> The free-page stealing code in __rmqueue_fallback() is somewhat hard to
>> follow, and has an incredible amount of subtlety hidden inside!
>>
>> First off, there is a minor bug in the reporting of change-of-ownership of
>> pageblocks. Under some conditions, we try to move upto 'pageblock_nr_pages'
>> no. of pages to the preferred allocation list. But we change the ownership
>> of that pageblock to the preferred type only if we manage to successfully
>> move atleast half of that pageblock (or if page_group_by_mobility_disabled
>> is set).
>>
>> However, the current code ignores the latter part and sets the 'migratetype'
>> variable to the preferred type, irrespective of whether we actually changed
>> the pageblock migratetype of that block or not. So, the page_alloc_extfrag
>> tracepoint can end up printing incorrect info (i.e., 'change_ownership'
>> might be shown as 1 when it must have been 0).
>>
>> So fixing this involves moving the update of the 'migratetype' variable to
>> the right place. But looking closer, we observe that the 'migratetype' variable
>> is used subsequently for checks such as "is_migrate_cma()". Obviously the
>> intent there is to check if the *fallback* type is MIGRATE_CMA, but since we
>> already set the 'migratetype' variable to start_migratetype, we end up checking
>> if the *preferred* type is MIGRATE_CMA!!
>>
>> To make things more interesting, this actually doesn't cause a bug in practice,
>> because we never change *anything* if the fallback type is CMA.
>>
>> So, restructure the code in such a way that it is trivial to understand what
>> is going on, and also fix the above mentioned bug. And while at it, also add a
>> comment explaining the subtlety behind the migratetype used in the call to
>> expand().
>>
> 
> Greate catch!
> 

Thank you :-)

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
