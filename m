Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF0D8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 13:11:42 -0500 (EST)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0KI6dLv025691
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:06:39 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0KIBXm5154250
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:11:33 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0KIBX0Z008602
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:11:33 -0700
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110120180146.GH6335@n2100.arm.linux.org.uk>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
	 <1295544047.9039.609.camel@nimitz>
	 <20110120180146.GH6335@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 20 Jan 2011 10:11:27 -0800
Message-ID: <1295547087.9039.694.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: KyongHo Cho <pullip.cho@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>, linux-kernel@vger.kernel.org, Ilho Lee <ilho215.lee@samsung.com>, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-20 at 18:01 +0000, Russell King - ARM Linux wrote:
> > The x86 version of show_mem() actually manages to do this without any
> > #ifdefs, and works for a ton of configuration options.  It uses
> > pfn_valid() to tell whether it can touch a given pfn.
> 
> x86 memory layout tends to be very simple as it expects memory to
> start at the beginning of every region described by a pgdat and extend
> in one contiguous block.  I wish ARM was that simple.

x86 memory layouts can be pretty funky and have been that way for a long
time.  That's why we *have* to handle holes in x86's show_mem().  My
laptop even has a ~1GB hole in its ZONE_DMA32:

[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x0013c000

But:

Node 0, zone    DMA32
  pages free     82877
        min      12783
        low      15978
        high     19174
        scanned  0
        spanned  1044480
        present  765672

See how the present is ~1GB less than spanned?  That's because of an I/O
hole from ~3-4GB:

        # cat /proc/iomem  | grep RAM
        00010000-0009d7ff : System RAM
        00100000-bf6affff : System RAM
        100000000-13bffffff : System RAM

I guess if we were being really smart we'd just shrink the DMA32 zone
down and not even cover that area.  But, we don't.

Memory hotplug was the original reason that we put sparsemem in place,
but we also have plenty of configurations where there are holes in the
middle of zones and pgdats.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
