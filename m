Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id ACFE66B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 03:42:09 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so287398yho.16
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 00:42:09 -0800 (PST)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id 25si184487yhd.152.2014.01.08.00.42.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 00:42:08 -0800 (PST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Wed, 8 Jan 2014 14:11:52 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 1FB22E0024
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 14:14:35 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s088fe8S49348690
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 14:11:41 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s088flFC016596
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 14:11:47 +0530
Message-ID: <52CD1113.2070003@linux.vnet.ibm.com>
Date: Wed, 08 Jan 2014 14:19:23 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V3] mm readahead: Fix the readahead fail in case of
 empty numa node
References: <1389003715-29733-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140106141300.4e1c950d45c614d6c29bdd8f@linux-foundation.org>
In-Reply-To: <20140106141300.4e1c950d45c614d6c29bdd8f@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, jack@suse.cz, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/07/2014 03:43 AM, Andrew Morton wrote:
> On Mon,  6 Jan 2014 15:51:55 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:
>
>> +	/*
>> +	 * Readahead onto remote memory is better than no readahead when local
>> +	 * numa node does not have memory. We sanitize readahead size depending
>> +	 * on free memory in the local node but limiting to 4k pages.
>> +	 */
>> +	return local_free_page ? min(sane_nr, local_free_page / 2) : sane_nr;
>>   }
>
> So if the local node has two free pages, we do just one page of
> readahead.
>
> Then the local node has one free page and we do zero pages readahead.
>
> Assuming that bug(!) is fixed, the local node now has zero free pages
> and we suddenly resume doing large readahead.
>
> This transition from large readahead to very small readahead then back
> to large readahead is illogical, surely?
>
>

Hi Andrew, Thanks for having a look at this.

You are correct that there is a transition from small readahead to
large once we have zero free pages.
I am not sure I can defend well, but 'll give a try :).

Hoping that we have evenly distributed cpu/memory load, if we have very
less free+inactive memory may be we are in really bad shape already.

But in the case where we have a situation like below [1] (cpu does not 
have any local memory node populated) I had mentioned
earlier where we will have to depend on remote node always,
is it not that sanitized readahead onto remote memory seems better?

But having said that I am not able to get an idea of sane implementation
to solve this readahead failure bug overcoming the anomaly you pointed
:(.  hints/ideas.. ?? please let me know.


[1]: IBM P730
----------------------------------
# numactl -H
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 
23 24 25 26 27 28 29 30 31
node 0 size: 0 MB
node 0 free: 0 MB
node 1 cpus:
node 1 size: 12288 MB
node 1 free: 10440 MB
node distances:
node   0   1
0:  10  40
1:  40  10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
