Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D8C356B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 11:52:49 -0500 (EST)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0OGo9An002612
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:50:09 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0OGqZxr101232
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:52:37 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0OGqY8A005223
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:52:35 -0700
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110123180532.GA3509@n2100.arm.linux.org.uk>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
	 <1295544047.9039.609.camel@nimitz>
	 <20110120180146.GH6335@n2100.arm.linux.org.uk>
	 <1295547087.9039.694.camel@nimitz>
	 <20110123180532.GA3509@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Mon, 24 Jan 2011 08:52:17 -0800
Message-ID: <1295887937.11047.119.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: KyongHo Cho <pullip.cho@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>, linux-kernel@vger.kernel.org, Ilho Lee <ilho215.lee@samsung.com>, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Sun, 2011-01-23 at 18:05 +0000, Russell King - ARM Linux wrote:
> On Thu, Jan 20, 2011 at 10:11:27AM -0800, Dave Hansen wrote:
> > On Thu, 2011-01-20 at 18:01 +0000, Russell King - ARM Linux wrote:
> > > > The x86 version of show_mem() actually manages to do this without any
> > > > #ifdefs, and works for a ton of configuration options.  It uses
> > > > pfn_valid() to tell whether it can touch a given pfn.
> > > 
> > > x86 memory layout tends to be very simple as it expects memory to
> > > start at the beginning of every region described by a pgdat and extend
> > > in one contiguous block.  I wish ARM was that simple.
> > 
> > x86 memory layouts can be pretty funky and have been that way for a long
> > time.  That's why we *have* to handle holes in x86's show_mem().  My
> > laptop even has a ~1GB hole in its ZONE_DMA32:
> 
> If x86 is soo funky, I suggest you try the x86 version of show_mem()
> on an ARM platform with memory holes.  Make sure you try it with
> sparsemem as well...

x86 uses the generic lib/ show_mem().  It works for any holes, as long
as they're expressed in one of the memory models so that pfn_valid()
notices them.

ARM looks like its pfn_valid() is backed up by searching the (ASM
arch-specific) memblocks.  That looks like it would be fairly slow
compared to the other pfn_valid() implementations and I can see why it's
being avoided in show_mem().

Maybe we should add either the MAX_ORDER or section_nr() trick to the
lib/ implementation.  I bet that would use pfn_valid() rarely enough to
meet any performance concerns.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
