Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l0Q5xX3C6774980
	for <linux-mm@kvack.org>; Fri, 26 Jan 2007 04:59:33 -0100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0PI0d58085778
	for <linux-mm@kvack.org>; Fri, 26 Jan 2007 05:00:39 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0PHv9wq016294
	for <linux-mm@kvack.org>; Fri, 26 Jan 2007 04:57:10 +1100
Message-ID: <45B8EF74.6010704@in.ibm.com>
Date: Thu, 25 Jan 2007 23:27:08 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com> <45B75208.90208@linux.vnet.ibm.com> <Pine.LNX.4.64.0701240655400.9696@schroedinger.engr.sgi.com> <45B82F41.9040705@linux.vnet.ibm.com> <45B835FE.6030107@redhat.com> <45B844E3.4050203@linux.vnet.ibm.com> <45B8D5AB.8040803@redhat.com>
In-Reply-To: <45B8D5AB.8040803@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Christoph Lameter <clameter@sgi.com>, Aubrey Li <aubreylee@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Vaidyanathan Srinivasan wrote:
>> Rik van Riel wrote:
> 
>>> There are a few databases out there that mmap the whole
>>> thing.  Sleepycat for one...
>>
>> That is why my suggestion would be not to touch mmapped pagecache
>> pages in the current pagecache limit code.  The limit should concern
>> only unmapped pagecache pages.
> 
> So you want to limit how much data the kernel caches for mysql
> or postgresql, but not limit how much of the rpm database is
> cached ?!
> 
> IMHO your proposal does the exact opposite of what would be
> right for my systems :)
> 

<Jumping in late into the discussion>

One scenario I can think of is

A group of I/O intensive task can cause readahead and
dirty page I/O and make good forward progress, but
they'll hit another group of processes by swapping
their pages out. How do we make fair forward progress?
The system administrator can currently control the
amount of swappiness by setting it, but swappiness is
a reclaim time control parameter.

We can control dirty page I/O by setting vm_dirty_ratio.
Readahead is also tuneable with fadvise(), but not many
applications use fadvise.

The question now is, is it easier for the system administrator
to say, limit my page cache usage to say 30% of total memory available,
so that other allocations do not have to wait on disk I/O or page
reclaim (consider slab allocations, other kernel data structures).

A low priority task might run infrequently and end up spending all
it's time either swapping in pages or reclaiming memory and by
the time it runs again, it ends up doing the same thing.

I understand the swap token mitigates this problem to some extent,
but limiting the page cache will give the system administrator
control over system memory behaviour.

-- 
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
