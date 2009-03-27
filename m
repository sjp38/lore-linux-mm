Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B748C6B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 19:03:44 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2RN0kXp031289
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 17:00:46 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2RN3kv5231084
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 17:03:46 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2RN3jrL020674
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 17:03:46 -0600
Subject: Re: [patch 0/6] Guest page hinting version 7.
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090327150905.819861420@de.ibm.com>
References: <20090327150905.819861420@de.ibm.com>
Content-Type: text/plain
Date: Fri, 27 Mar 2009 16:03:43 -0700
Message-Id: <1238195024.8286.562.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 2009-03-27 at 16:09 +0100, Martin Schwidefsky wrote:
> If the host picks one of the
> pages the guest can recreate, the host can throw it away instead of writing
> it to the paging device. Simple and elegant.

Heh, simple and elegant for the hypervisor.  But I'm not sure I'm going
to call *anything* that requires a new CPU instruction elegant. ;)

I don't see any description of it in there any more, but I thought this
entire patch set was to get rid of the idiotic triple I/Os in the
following scenario:

1. Hypervisor picks a page and evicts it out to disk, pays the I/O cost
   to get it written out. (I/O #1)
2. Linux comes along (being a bit late to the party) and picks the same
   page, also decides it needs to be out to disk
3. Linux tries to write the page to disk, but touches it in the 
   process, pulling the page back in from the store where the hypervisor
   wrote it. (I/O #2)
4. Linux writes the page to its swap device (I/O #3)

I don't see that mentioned at all in the current description.
Simplifying the hypervisor is hard to get behind, but cutting system I/O
by 2/3 is a much nicer benefit for 1200 lines of invasive code. ;)

Can we persuade the hypervisor to tell us which pages it decided to page
out and just skip those when we're scanning the LRU?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
