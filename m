Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA16627
	for <linux-mm@kvack.org>; Mon, 3 Feb 2003 13:34:43 -0800 (PST)
Date: Mon, 3 Feb 2003 13:29:29 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030203132929.40f0d9c0.akpm@digeo.com>
In-Reply-To: <m1n0ld1jvv.fsf@frodo.biederman.org>
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030202025546.2a29db61.akpm@digeo.com>
	<20030202195908.GD29981@holomorphy.com>
	<20030202124943.30ea43b7.akpm@digeo.com>
	<m1n0ld1jvv.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: wli@holomorphy.com, davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ebiederm@xmission.com (Eric W. Biederman) wrote:
>
> > 
> > Expanding ftruncate would be nice, but the current way of performing
> > the page instantiation at mmap() time seems sufficient.
> 
> Having an expanding/shrinking ftruncate will trivially allow posix shared
> memory semantics.   
> 
> I am trying to digest the idea of a mmap that grows a file.  There isn't
> anything else that works that way is there?

Not that I can think of.

> It looks like you are removing the limit checking from hugetlbfs, by
> removing the expansion code from ftruncate.

There was no expansion code.

The code I took out was vestigial.  We can put it all back if we decide to
add a new expand-with-ftruncate feature to hugetlbfs.

>  And given the fact that
> nothing else grows in mmap, I suspect the code will be much easier to
> write and maintain if the growth is constrained to happen in ftruncate.

That would require a fault handler.  We don't have one of those for hugetlbs.
 Probably not hard to add one though.

> I may be missing something but it looks like there is not code present
> to prevent multiple page allocations at the same time conflicting
> when i_size is grown. 

All the mmap code runs under down_write(current->mm->mmap_sem);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
