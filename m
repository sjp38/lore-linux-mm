Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 2D7F36B0039
	for <linux-mm@kvack.org>; Thu,  9 May 2013 12:57:31 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 9 May 2013 12:57:30 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 13638C9001A
	for <linux-mm@kvack.org>; Thu,  9 May 2013 12:57:28 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r49GvSxJ306020
	for <linux-mm@kvack.org>; Thu, 9 May 2013 12:57:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r49GvIYs026187
	for <linux-mm@kvack.org>; Thu, 9 May 2013 12:57:19 -0400
Date: Thu, 9 May 2013 11:57:17 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: misunderstanding of the virtual memory
Message-ID: <20130509165717.GA9548@medulla>
References: <518BB132.5050802@gmail.com>
 <518BB3B1.8010207@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <518BB3B1.8010207@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Teissier <ben.teissier@gmail.com>
Cc: linux-mm@kvack.org

On Thu, May 09, 2013 at 10:33:21AM -0400, Ben Teissier wrote:
> 
> Hi,
> 
> I'm Benjamin and I'm studying the kernel. I write you this email
> because I've a trouble with the mmu and the virtual memory. I try to
> understand how a program (user land) can write something into the stack
> (push ebp, for example), indeed, the program works with virtual address
> (between 0x00000 and 0x8... if my memory is good) but at the hardware
> side the address is not the same (that's why mmu was created, if I'm right).

Yes, this is the purpose of pages tables; to map virtual addresses to real
memory addresses (more precisely virtual memory _pages_ to real memory pages).

> 
> My problem is the following : how the data is wrote on the physical
> memory. When I try a strace (kernel 2.6.32 on a simple program) I have
> no hint on the transfer of data. Moreover, according to the wikipedia
> web page on syscall (
> https://en.wikipedia.org/wiki/System_call#The_library_as_an_intermediary
> ), a call is not managed by the kernel. So, how the transfer between
> virtual memory and physical memory is possible ?

That is because writing to a memory location in userspace isn't an operation
that requires a syscall or any kind of kernel intervention at all.  It is an
assembly store instruction executed directly on the CPU by the program.  The
only time the kernel is involved in a store operation is if the virtual address
translation doesn't exist in the TLB (or is write-protected, etc..), in which
case the hardware generates a fault so the kernel take the required action to
populate the TLB with the translation.

Hope this answers your question.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
