Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 6F8D96B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 11:50:24 -0400 (EDT)
Date: Tue, 23 Apr 2013 11:50:19 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130423155019.GH31170@thunk.org>
References: <20130402150651.GB31577@thunk.org>
 <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
 <20130412094731.GI11656@suse.de>
 <20130421000522.GA5054@thunk.org>
 <20130423153305.GB2108@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130423153305.GB2108@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Tue, Apr 23, 2013 at 04:33:05PM +0100, Mel Gorman wrote:
> That's a pretty big drop but it gets bad again for the second worst stall --
> wait_on_page_bit as a result of generic_file_buffered_write.
> 
> Vanilla kernel  1336064 ms stalled with 109 events
> Patched kernel  2338781 ms stalled with 164 events

Do you have the stack trace for this stall?  I'm wondering if this is
caused by the waiting for stable pages in write_begin() , or something
else.

If it is blocking caused by stable page writeback that's interesting,
since it would imply that something in your workload is trying to
write to a page that has already been modified (i.e., appending to a
log file, or updating a database file).  Does that make sense given
what your workload might be running?

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
