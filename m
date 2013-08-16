Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 790C36B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 14:41:28 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Fri, 16 Aug 2013 12:41:27 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 59EB93E4004E
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 12:40:58 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7GIf5QH071982
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 12:41:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7GIf4Ft011158
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 12:41:05 -0600
Date: Fri, 16 Aug 2013 13:41:00 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
Message-ID: <20130816184100.GA7265@variantweb.net>
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <5959614.447qgH8r7c@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5959614.447qgH8r7c@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 15, 2013 at 02:01:09AM +0200, Rafael J. Wysocki wrote:
> On Wednesday, August 14, 2013 02:31:45 PM Seth Jennings wrote:
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
> I wonder how this is going to work with the ACPI device object binding to
> memory blocks that's in 3.11-rc.

Thanks for pointing this out.  Yes the walking of the memory blocks in
this code will present a problem for the dynamic creation of memory
blocks :/  Sounds like there are some other challenges (backward
compatibility, no boot paramater) that I'll have to look at as well.

Seth

> 
> That stuff will only work if the memory blocks are already there when
> acpi_memory_enable_device() runs and that is called from the ACPI namespace
> scanning code executed (1) during boot and (2) during hotplug.  So I don't
> think you can just create them on the fly at run time as a result of a
> sysfs write.
> 
> Thanks,
> Rafael
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
