Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 72763600375
	for <linux-mm@kvack.org>; Mon, 10 May 2010 12:05:19 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.1/8.13.1) with ESMTP id o4AG5A0X023419
	for <linux-mm@kvack.org>; Mon, 10 May 2010 16:05:10 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4AG5AMJ1212434
	for <linux-mm@kvack.org>; Mon, 10 May 2010 18:05:10 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4AG59Qf002913
	for <linux-mm@kvack.org>; Mon, 10 May 2010 18:05:10 +0200
Date: Mon, 10 May 2010 18:05:05 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
Message-ID: <20100510180505.3e60e2da@mschwide.boeblingen.de.ibm.com>
In-Reply-To: <1272643680.23895.2537.camel@nimitz>
References: <4BD16D09.2030803@redhat.com>
	<b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
	<4BD1A74A.2050003@redhat.com>
	<4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>
	<4BD1B427.9010905@redhat.com>
	<4BD1B626.7020702@redhat.com>
	<5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>
	<4BD3377E.6010303@redhat.com>
	<1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>
	<ce808441-fae6-4a33-8335-f7702740097a@default>
	<20100428055538.GA1730@ucw.cz>
	<1272591924.23895.807.camel@nimitz
 4BDA8324.7090409@redhat.com>
	<084f72bf-21fd-4721-8844-9d10cccef316@default>
	<1272643680.23895.2537.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Avi Kivity <avi@redhat.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 30 Apr 2010 09:08:00 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Fri, 2010-04-30 at 08:59 -0700, Dan Magenheimer wrote:
> > Dave or others can correct me if I am wrong, but I think CMM2 also
> > handles dirty pages that must be retained by the hypervisor.  The
> > difference between CMM2 (for dirty pages) and frontswap is that
> > CMM2 sets hints that can be handled asynchronously while frontswap
> > provides explicit hooks that synchronously succeed/fail.
> 
> Once pages were dirtied (or I guess just slightly before), they became
> volatile, and I don't think the hypervisor could do anything with them.
> It could still swap them out like usual, but none of the CMM-specific
> optimizations could be performed.

Well, almost correct :-)
A dirty page (or one that is about to become dirty) can be in one of two
CMMA states:
1) stable
This is the case for pages where the kernel is doing some operation on
the page that will make it dirty, e.g. I/O. Before the kernel can
allow the operation the page has to be made stable. If the state
conversion to stable fails because the hypervisor removed the page the
page needs to get deleted from page cache and recreated from scratch.
2) potentially-volatile
This state is used for page cache pages for which a writable mapping
exists. The page can be removed by the hypervisor as long as the
physical per-page dirty bit is not set. As soon as the bit is set the
page is considered stable although the CMMA state still is potentially-
volatile.

In both cases the only thing the hypervisor can do with a dirty page is
to swap it as usual.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
