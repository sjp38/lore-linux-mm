Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C8E6E6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 22:54:31 -0400 (EDT)
Date: Tue, 28 Sep 2010 19:50:35 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/8] v2 De-Couple sysfs memory directories from memory
	sections
Message-ID: <20100929025035.GA13096@kroah.com>
References: <4CA0EBEB.1030204@austin.ibm.com> <4CA1E338.6070201@redhat.com> <20100928151218.GJ14068@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100928151218.GJ14068@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Avi Kivity <avi@redhat.com>, Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 28, 2010 at 10:12:18AM -0500, Robin Holt wrote:
> On Tue, Sep 28, 2010 at 02:44:40PM +0200, Avi Kivity wrote:
> >  On 09/27/2010 09:09 PM, Nathan Fontenot wrote:
> > >This set of patches decouples the concept that a single memory
> > >section corresponds to a single directory in
> > >/sys/devices/system/memory/.  On systems
> > >with large amounts of memory (1+ TB) there are perfomance issues
> > >related to creating the large number of sysfs directories.  For
> > >a powerpc machine with 1 TB of memory we are creating 63,000+
> > >directories.  This is resulting in boot times of around 45-50
> > >minutes for systems with 1 TB of memory and 8 hours for systems
> > >with 2 TB of memory.  With this patch set applied I am now seeing
> > >boot times of 5 minutes or less.
> > >
> > >The root of this issue is in sysfs directory creation. Every time
> > >a directory is created a string compare is done against all sibling
> > >directories to ensure we do not create duplicates.  The list of
> > >directory nodes in sysfs is kept as an unsorted list which results
> > >in this being an exponentially longer operation as the number of
> > >directories are created.
> > >
> > >The solution solved by this patch set is to allow a single
> > >directory in sysfs to span multiple memory sections.  This is
> > >controlled by an optional architecturally defined function
> > >memory_block_size_bytes().  The default definition of this
> > >routine returns a memory block size equal to the memory section
> > >size. This maintains the current layout of sysfs memory
> > >directories as it appears to userspace to remain the same as it
> > >is today.
> > >
> > 
> > Why not update sysfs directory creation to be fast, for example by
> > using an rbtree instead of a linked list.  This fixes an
> > implementation problem in the kernel instead of working around it
> > and creating a new ABI.
> 
> Because the old ABI creates 129,000+ entries inside
> /sys/devices/system/memory with their associated links from
> /sys/devices/system/node/node*/ back to those directory entries.
> 
> Thankfully things like rpm, hald, and other miscellaneous commands scan
> that information.

Really?  Why?  Why would rpm care about this?  hald is dead now so we
don't need to worry about that anymore, but what other commands/programs
read this information?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
