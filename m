Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k12GlY12011050
	for <linux-mm@kvack.org>; Thu, 2 Feb 2006 11:47:34 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k12GlYxP203438
	for <linux-mm@kvack.org>; Thu, 2 Feb 2006 11:47:34 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k12GlY03024494
	for <linux-mm@kvack.org>; Thu, 2 Feb 2006 11:47:34 -0500
Subject: Re: [PATCH] Dynamically allocated pageflags
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200602021431.30194.ak@suse.de>
References: <200602022111.32930.ncunningham@cyclades.com>
	 <200602021431.30194.ak@suse.de>
Content-Type: text/plain
Date: Thu, 02 Feb 2006 08:47:06 -0800
Message-Id: <1138898826.29030.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nigel Cunningham <ncunningham@cyclades.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-02-02 at 14:31 +0100, Andi Kleen wrote:
> On Thursday 02 February 2006 12:11, Nigel Cunningham wrote:
> > This is my latest revision of the dynamically allocated pageflags patch.
> > 
> > The patch is useful for kernel space applications that sometimes need to flag
> > pages for some purpose, but don't otherwise need the retain the state. A prime
> > example is suspend-to-disk, which needs to flag pages as unsaveable, allocated
> > by suspend-to-disk and the like while it is working, but doesn't need to
> > retain any of this state between cycles.
> 
> It looks like total overkill for a simple problem to me. And is there really
> any other user of this other than swsusp?

We'll probably end up needing a similar mechanism for memory hotplug.
What I need is a mechanism that is exceedingly quick during normal
runtime, any maybe marginally slower during a memory remove operation.

We basically put three or so hooks into some crucial parts of the page
allocator to grab out pages which we want to remove so that they never
make it back into the allocator or out to the system.

Those hooks have to be _really_ fast at runtime, obviously.  In my
testing code, I always just added a page flag, but that's only because I
was being lazy when I coded it up.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
