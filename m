Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 6B3B26B0005
	for <linux-mm@kvack.org>; Sat, 20 Apr 2013 20:05:28 -0400 (EDT)
Date: Sat, 20 Apr 2013 20:05:22 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130421000522.GA5054@thunk.org>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
 <20130412094731.GI11656@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130412094731.GI11656@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

As an update to this thread, we brought up this issue at LSF/MM, and
there is a thought that we should be able to solve this problem by
having lock_buffer() check to see if the buffer is locked due to a
write being queued, to have the priority of the write bumped up in the
write queues to resolve the priority inversion.  I believe Jeff Moyer
was going to look into this, if I remember correctly.

An alternate solution which I've been playing around adds buffer_head
flags so we can indicate that a buffer contains metadata and/or should
have I/O submitted with the REQ_PRIO flag set.

Adding a buffer_head flag for at least BH_Meta is probably a good
thing, since that way the blktrace will be properly annotated.
Whether we should keep the BH_Prio flag or rely on lock_buffer()
automatically raising the priority is, my feeling is that if
lock_buffer() can do the right thing, we should probably do it via
lock_buffer().  I have a feeling this might be decidedly non-trivial,
though, so perhaps we should just doing via BH flags?

	   	      	     	  	- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
