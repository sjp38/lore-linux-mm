Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 596A26B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 21:56:06 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 26 Jul 2013 07:16:05 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 135BA1258052
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 07:25:24 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6Q1tXiu48562384
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 07:25:54 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6Q1tZkd010548
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 11:55:36 +1000
Date: Fri, 26 Jul 2013 09:55:34 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: mincore() & fincore()
Message-ID: <20130726015534.GA24060@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <201307251658.33548.cedric@2ndquadrant.com>
 <201307251707.11159.cedric@2ndquadrant.com>
 <20130725153207.GA17975@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130725153207.GA17975@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: =?iso-8859-1?Q?C=E9dric?= Villemain <cedric@2ndquadrant.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, Jul 25, 2013 at 11:32:07AM -0400, Johannes Weiner wrote:
>On Thu, Jul 25, 2013 at 05:07:10PM +0200, Cedric Villemain wrote:
>> [sorry, previous mail was sent earlier than expected]
>> 
>> > First, the proposed changes in this email are to be used at least for 
>> > PostgreSQL extensions, maybe for core.
>> > 
>> > Purpose is to offer better monitoring/tracking of the hot/cold areas (and 
>> > read/write paterns) in the tables and indexes, in PostgreSQL those are by default 
>> > written in segments of 1GB.
>> > 
>> > There are some possible usecase already:
>> > 
>> >  * planning of hardware upgrade
>> >  * easier configuration setup (both PostgreSQL and linux)
>> >  * provide more informations to the planner/executor of PostgreSQL
>> > 
>> > My ideas so far are to 
>> > 
>> >  * improve mincore() in linux and add it information like in freeBSD (at 
>> >    least adding 'mincore_modified' to track clean vs dirty pages).
>> >  * adding fincore() to make the information easier to grab from PostgreSQL (no 
>> >    mmap)
>> >  * maybe some access to those stats in /proc/
>> > 
>> > It makes years that libprefetch, mincore() and fincore() are discussed on linux 
>> > mailling lists. And they got a good feedback... So I hope it is ok to keep on 
>> > those and provide updated patches.
>> 
>> Johannes, I add you in CC because you're the last one who proposed something. 
>> Can I update your patch with previous suggestions from reviewers ?
>
>Absolutely!
>
>> I'm also asking for feedback in this area, others ideas are very welcome.
>
>Andrew didn't like the idea of the one byte per covered page
>representation but all proposals to express continuous ranges in a

mincore utilize byte array and the least significant bit is used to
check if the corresponding page is currently resident in memory, I 
don't know the history, what's the reason for not using bitmap?

>more compact fashion had worse worst cases and a much more involved
>interface.
>
>I do wonder if we should model fincore() after mincore() and add a
>separate syscall to query page cache coverage with statistical output
>(x present [y dirty, z active, whatever] in specified area) rather
>than describing individual pages or continuous chunks of pages in
>address order.  That might leave us with better interfaces than trying
>to integrate all of this into one arcane syscall.
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
