Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 07F306B0034
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 15:07:43 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Fri, 16 Aug 2013 15:07:42 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 0F659C9004A
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 15:07:39 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7GJ7ecZ206618
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 15:07:40 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7GJ7dtR016693
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 13:07:40 -0600
Date: Fri, 16 Aug 2013 14:07:37 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
Message-ID: <20130816190737.GC7265@variantweb.net>
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130814194043.GA10469@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814194043.GA10469@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 14, 2013 at 12:40:43PM -0700, Greg Kroah-Hartman wrote:
> On Wed, Aug 14, 2013 at 02:31:45PM -0500, Seth Jennings wrote:
> > Large memory systems (~1TB or more) experience boot delays on the order
> > of minutes due to the initializing the memory configuration part of
> > sysfs at /sys/devices/system/memory/.
> > 
> > ppc64 has a normal memory block size of 256M (however sometimes as low
> > as 16M depending on the system LMB size), and (I think) x86 is 128M.  With
> > 1TB of RAM and a 256M block size, that's 4k memory blocks with 20 sysfs
> > entries per block that's around 80k items that need be created at boot
> > time in sysfs.  Some systems go up to 16TB where the issue is even more
> > severe.
> > 
> > This patch provides a means by which users can prevent the creation of
> > the memory block attributes at boot time, yet still dynamically create
> > them if they are needed.
> > 
> > This patch creates a new boot parameter, "largememory" that will prevent
> > memory_dev_init() from creating all of the memory block sysfs attributes
> > at boot time.  Instead, a new root attribute "show" will allow
> > the dynamic creation of the memory block devices.
> > Another new root attribute "present" shows the memory blocks present in
> > the system; the valid inputs for the "show" attribute.
> 
> Ick, no new boot parameters please, that's just a mess for distros and
> users.

Yes, I agreed it isn't the best.  The reason for it is backward
compatibility; or rather the user saying "I knowingly forfeit backward
compatibility in favor of fast boot time and all my userspace tools are
aware of the new requirement to show memory blocks before trying to use
them".

The only suggestion I heard that would make full backward compatibility
possible is one from Dave to create a new filesystem for memory blocks
(not sysfs) where the memory block directories would be dynamically
created as programs tried to access/open them. But you'd still have the
issue of requiring user intervention to mount that "memoryfs" at
/sys/devices/system/memory (or whatever your sysfs mount point was).

So it's tricky.

> 
> How about tying this into the work that has been happening on lkml with
> booting large-memory systems faster?  The work there should solve the
> problems you are seeing here (i.e. add memory after booting).  It looks
> like this is the same issue you are having here, just in a different
> part of the kernel.

I assume you are referring to the "[RFC v3 0/5] Transparent on-demand
struct page initialization embedded in the buddy allocator" thread.  I
think that trying to solve a different problem than I am trying to solve
though.  IIUC, that patch series is deferring the initialization of the
actually memory pages.

I'm working on breaking out just the refactoring patches (no functional
change) into a reviewable patch series.  Thanks for your time looking at
this!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
