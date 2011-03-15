Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80F928D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 19:16:57 -0400 (EDT)
Date: Tue, 15 Mar 2011 16:16:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Resend] Cross Memory Attach v3 [PATCH]
Message-Id: <20110315161623.4099664b.akpm@linux-foundation.org>
In-Reply-To: <20110315143547.1b233cd4@lilo>
References: <20110315143547.1b233cd4@lilo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 15 Mar 2011 14:35:47 +1030
Christopher Yeoh <cyeoh@au1.ibm.com> wrote:

> Hi Andrew,
> 
> I was wondering if you thought the cross memory attach patch is in
> suitable shape to go into your tree with view of getting it into
> mainline sometime in the not too distant future.

It looks reasonable to me, but I might have missed something and would
ask that some of the other guys take a close look, please.

It's regrettable that vmsplice() won't serve the purpose but I can see
that the blocking problems are there.

Minor thing: mm/memory.c is huge, and I think this new code would live
happily in a new mm/process_vm_access.c.

> There are some cases of MPI collectives where even a single copy
> interface does not get us the performance gain we could.  For example
> in an MPI_Reduce rather than copy the data from the source we would
> like to instead use it directly in a mathops (say the reduce is doing a
> sum) as this would save us doing a copy.  We don't need to keep a copy
> of the data from the source.  I haven't implemented this, but I think
> this interface could in the future do all this through the use of the
> flags - eg could specify the math operation and type and the kernel
> rather than just copying the data would apply the specified operation
> between the source and destination and store it in the destination.  

Well yes.  This smells like MAP_SHARED.

Thinking out loud: if we had a way in which a process can add and
remove a local anonymous page into pagecache then other processes could
access that page via mmap.  If both processes map the file with a
nonlinear vma they they can happily sit there flipping pages into and
out of the shared mmap at arbitrary file offsets.  The details might
get hairy ;) We wouldn't want all the regular mmap semantics of making
pages dirty, writing them back, etc so make that mmap be backed by a
new special device rather than by a regular file, perhaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
