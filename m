Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 99A5D6B005A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 04:08:56 -0400 (EDT)
Date: Tue, 9 Oct 2012 10:07:35 +0200
From: Mike Hommey <mh@glandium.org>
Subject: Re: [PATCH 0/3] Volatile Ranges (v7) & Lots of words
Message-ID: <20121009080735.GA24375@glandium.org>
References: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Sep 28, 2012 at 11:16:30PM -0400, John Stultz wrote:
> fd based interfaces vs madvise:
> 	In talking with Taras Glek, he pointed out that for his
> 	needs, the fd based interface is a little annoying, as it
> 	requires having to get access to tmpfs file and mmap it in,
> 	then instead of just referencing a pointer to the data he
> 	wants to mark volatile, he has to calculate the offset from
> 	start of the mmap and pass those file offsets to the interface.
> 	Instead he mentioned that using something like madvise would be
> 	much nicer, since they could just pass a pointer to the object
> 	in memory they want to make volatile and avoid the extra work.
> 
> 	I'm not opposed to adding an madvise interface for this as
> 	well, but since we have a existing use case with Android's
> 	ashmem, I want to make sure we support this existing behavior.
> 	Specifically as with ashmem  applications can be sharing
> 	these tmpfs fds, and so file-relative volatile ranges make
> 	more sense if you need to coordinate what data is volatile
> 	between two applications.
> 
> 	Also, while I agree that having an madvise interface for
> 	volatile ranges would be nice, it does open up some more
> 	complex implementation issues, since with files, there is a
> 	fixed relationship between pages and the files' address_space
> 	mapping, where you can't have pages shared between different
> 	mappings. This makes it easy to hang the volatile-range tree
> 	off of the mapping (well, indirectly via a hash table). With
> 	general anonymous memory, pages can be shared between multiple
> 	processes, and as far as I understand, don't have any grouping
> 	structure we could use to determine if the page is in a
> 	volatile range or not. We would also need to determine more
> 	complex questions like: What are the semantics of volatility
> 	with copy-on-write pages?  I'm hoping to investigate this
> 	idea more deeply soon so I can be sure whatever is pushed has
> 	a clear plan of how to address this idea. Further thoughts
> 	here would be appreciated.

Note it doesn't have to be a vs. situation. madvise could be an
additional way to interface with volatile ranges on a given fd.

That is, madvise doesn't have to mean anonymous memory. As a matter of
fact, MADV_WILLNEED/MADV_DONTNEED are usually used on mmaped files.
Similarly, there could be a way to use madvise to mark volatile ranges,
without the application having to track what memory ranges are
associated to what part of what file, which the kernel already tracks.

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
