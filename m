Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9JLMOB4023045
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 17:22:24 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9JLNH6k545500
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 15:23:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9JLMN7U031304
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 15:22:23 -0600
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051019183202.GA8120@localhost.localdomain>
References: <1129570219.23632.34.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>
	 <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>
	 <1129651502.23632.63.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com>
	 <20051019183202.GA8120@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 19 Oct 2005 14:21:48 -0700
Message-Id: <1129756908.8716.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-19 at 14:32 -0400, Jeff Dike wrote:
> On Wed, Oct 19, 2005 at 06:56:59PM +0100, Hugh Dickins wrote:
> > To achieve the effect you want, along these lines, there needs to be
> > a way to truncate pages out of the middle of the shm object: I believe
> > "punch holes" is the phrase that's been used when this kind of behaviour
> > has been discussed (not particularly in relation to tmpfs) before.
> > Some have proposed a sys_punch syscall to the VFS.
> > 
> > Jeff Dike had a patch for like functionality for UML, via a /dev/anon
> > to tmpfs, nearly two years ago.  I've kept his mail in my TODO folder
> > ever since, ambivalent about it, and never got around to giving it the
> > review needed.  I've a feeling time has moved on so far that Jeff may
> > now be achieving the effect he needs by other means (remap_file_pages?).
> > 
> > Is /dev/anon still of interest to you, Jeff?  Not that I'm any closer
> > to the point of thinking about it now than then, just want to factor
> > your idea in with what Badari is thinking of.
> 
> Yes, either sys_punch or something like /dev/anon is still needed.  I need to
> be able to dirty file-backed pages and tell the host to drop them as though
> they were clean.  Punching a hole in the middle of the file, effectively
> sparsing it, or having a special driver that drops pages when their map count
> goes to zero will both work for me.  This will avoid having the host swap out
> pages that are clean from the UML point of view (but dirty from the host's
> point of view).  It will also allow me to free memory back to the host, 
> allowing memory to be added and removed dynamically from UML instances.

My requirement is a simple subset of yours. All I want is ability to
completely drop range of pages in a shared memory segment (as if they
are clean). madvise(MADV_DISCARD) would be good enough for me. In fact,
I have another weird requirement that - it should be able to drop these
pages even when map count is NOT zero. I am still thinking about this
one. Our database folks, map these regions into different db2 processes
and they want this to work from any given process (even if other
processes have it mapped). I am not sure what would happen, some
other process touches it after we dropped it - may be a zero page ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
