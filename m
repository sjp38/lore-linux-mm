Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8850F6B0035
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 02:01:28 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so10421518pab.9
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 23:01:28 -0800 (PST)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id va10si973541pbc.218.2014.02.12.23.01.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 23:01:27 -0800 (PST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Thu, 13 Feb 2014 17:01:24 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 02D7F3578056
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 18:01:21 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1D717DX6357256
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 18:01:07 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1D71JCf013196
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 18:01:19 +1100
Message-ID: <52FC6F2A.30905@linux.vnet.ibm.com>
Date: Thu, 13 Feb 2014 12:37:22 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com> <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org> <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com> <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com> <52F4B8A4.70405@linux.vnet.ibm.com> <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com> <52F88C16.70204@linux.vnet.ibm.com> <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com> <52F8C556.6090006@linux.vnet.ibm.com> <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/11/2014 03:05 AM, David Rientjes wrote:
> On Mon, 10 Feb 2014, Raghavendra K T wrote:
>
>> So I understood that you are suggesting implementations like below
>>
>> 1) I do not have problem with the below approach, I could post this in
>> next version.
>> ( But this did not include 4k limit Linus mentioned to apply)
>>
>> unsigned long max_sane_readahead(unsigned long nr)
>> {
>>          unsigned long local_free_page;
>>          int nid;
>>
>>          nid = numa_mem_id();
>>
>>          /*
>>           * We sanitize readahead size depending on free memory in
>>           * the local node.
>>           */
>>          local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
>>                            + node_page_state(nid, NR_FREE_PAGES);
>>          return min(nr, local_free_page / 2);
>> }
>>
>> 2) I did not go for below because Honza (Jan Kara) had some
>> concerns for 4k limit for normal case, and since I am not
>> the expert, I was waiting for opinions.
>>
>> unsigned long max_sane_readahead(unsigned long nr)
>> {
>>          unsigned long local_free_page, sane_nr;
>>          int nid;
>>
>>          nid = numa_mem_id();
>> 	/* limit the max readahead to 4k pages */
>> 	sane_nr = min(nr, MAX_REMOTE_READAHEAD);
>>
>>          /*
>>           * We sanitize readahead size depending on free memory in
>>           * the local node.
>>           */
>>          local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
>>                            + node_page_state(nid, NR_FREE_PAGES);
>>          return min(sane_nr, local_free_page / 2);
>> }
>>
>
> I have no opinion on the 4KB pages, either of the above is just fine.
>

I was able to test (1) implementation on the system where readahead 
problem occurred. Unfortunately it did not help.

Reason seem to be that CONFIG_HAVE_MEMORYLESS_NODES dependency of
numa_mem_id(). The PPC machine I am facing problem has topology like
this:

numactl -H
---------
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 12 13 14 15 16 17 18 19 20 21 22 23 24 25
...
node 0 size: 0 MB
node 0 free: 0 MB
node 1 cpus: 8 9 10 11 32 33 34 35 ...
node 1 size: 8071 MB
node 1 free: 2479 MB
node distances:
node   0   1
   0:  10  20
   1:  20  10

So it seems numa_mem_id() does not help for all the configs..
Am I missing something ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
