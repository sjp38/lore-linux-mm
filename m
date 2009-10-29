Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AB57C6B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 12:00:19 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9TFvhMC002926
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 09:57:43 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9TFxu8s131996
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 09:59:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9TFw6e1011551
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 09:58:06 -0600
Subject: Re: RFC: Transparent Hugepage support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1256741656.5613.15.camel@aglitke>
References: <20091026185130.GC4868@random.random>
	 <87ljiwk8el.fsf@basil.nowhere.org> <20091027193007.GA6043@random.random>
	 <20091028042805.GJ7744@basil.fritz.box>
	 <20091028120050.GD9640@random.random>
	 <20091028141803.GQ7744@basil.fritz.box>  <1256741656.5613.15.camel@aglitke>
Content-Type: text/plain
Date: Thu, 29 Oct 2009 08:59:53 -0700
Message-Id: <1256831993.26826.11.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Adam Litke <agl@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-10-28 at 09:54 -0500, Adam Litke wrote:
> PowerPC does not require specific virtual addresses for huge pages, but
> does require that a consistent page size be used for each slice of the
> virtual address space.  Slices are 256M in size from 0 to 4G and 1TB in
> size above 1TB while huge pages are 64k, 16M, or 16G.  Unless the PPC
> guys can work some more magic with their mmu, split_huge_page() in its
> current form just plain won't work on PowerPC.

One answer, at least in the beginning, would be to just ignore this
detail.  Try to make 16MB pages wherever possible, probably even as 16MB
pages in the Linux pagetables.  But, we can't promote the MMU to use
them until get get a 256MB or 1TB chunk.  It will definitely mean some
ppc-specific bits when we're changing the segment mapping size, but it's
not impossible.

That's not going to do any good for the desktop-type users.  But, it
should be just fine for the HPC or JVM folks.  It restricts the users
pretty severely, but it gives us *something*.

There will be some benefit to using a 16MB Linux page and pte even if we
can't back it with 16MB MMU pages, anyway.  Remember, a big chunk of the
benefit of using 64k pages can be seen even on systems with no 64k
hardware pages.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
