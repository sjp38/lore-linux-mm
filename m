Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5736B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 23:08:22 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g202so5348497ita.4
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 20:08:22 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id e7si663207ita.132.2018.02.01.20.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 20:08:21 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] lru_lock scalability
References: <2a16be43-0757-d342-abfb-d4d043922da9@oracle.com>
 <20180201094431.GA20742@bombadil.infradead.org>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <af831ebd-6acf-1f83-c531-39895ab2eddb@oracle.com>
Date: Thu, 1 Feb 2018 23:07:56 -0500
MIME-Version: 1.0
In-Reply-To: <20180201094431.GA20742@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, steven.sistare@oracle.com, pasha.tatashin@oracle.com, yossi.lev@oracle.com, Dave.Dice@oracle.com, akpm@linux-foundation.org, mhocko@kernel.org, ldufour@linux.vnet.ibm.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ak@linux.intel.com, mgorman@suse.de

On 02/01/2018 04:44 AM, Matthew Wilcox wrote:
> On Wed, Jan 31, 2018 at 11:44:29PM -0500, Daniel Jordan wrote:
>> I'd like to propose a discussion of lru_lock scalability on the mm track.  Since this is similar to Laurent Dufour's mmap_sem topic, it might make sense to discuss these around the same time.
>>
>> On large systems, lru_lock is one of the hottest locks in the kernel, showing up on many memory-intensive benchmarks such as decision support.  It also inhibits scalability in many of the mm paths that could be parallelized, such as freeing pages during exit/munmap and inode eviction.
>>
>> I'd like to discuss the following two ways of solving this problem, as well as any other approaches or ideas people have.
> 
> Something I've been thinking about is changing the LRU from an embedded
> list_head to an external data structure that I call the XQueue.
> It's based on the XArray, but is used like a queue; pushing items onto
> the end of the queue and popping them off the beginning.  You can also
> remove items from the middle of the queue.
> 
> Removing items from the list usually involves dirtying three cachelines.
> With the XQueue, you'd only dirty one.  That's going to reduce lock
> hold time.  There may also be opportunities to reduce lock hold time;
> removal and addition can be done in parallel as long as there's more
> than 64 entries between head and tail of the list.
> 
> The downside is that adding to the queue would require memory allocation.
> And I don't have time to work on it at the moment.

I like the idea of touching fewer cachelines.

I looked through your latest XArray series (v6).  Am I understanding it correctly that a removal (xa_erase) is an exclusive operation within one XArray, i.e. that only one thread can do this at once?  Not sure how XQueue would implement removal though, so the answer might be different for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
