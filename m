Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 272C56B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 18:23:15 -0500 (EST)
Date: Fri, 19 Nov 2010 18:22:54 -0500
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
Message-ID: <20101119232254.GA28151@thunk.org>
References: <1289996638-21439-1-git-send-email-walken@google.com>
 <1289996638-21439-4-git-send-email-walken@google.com>
 <20101117125756.GA5576@amd>
 <1290007734.2109.941.camel@laptop>
 <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
 <20101117231143.GQ22876@dastard>
 <20101118133702.GA18834@infradead.org>
 <alpine.LSU.2.00.1011180934400.3210@tigran.mtv.corp.google.com>
 <20101119072316.GA14388@google.com>
 <20101119145442.ddf0c0e8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101119145442.ddf0c0e8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>, Dustin Kirkland <kirkland@canonical.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 02:54:42PM -0800, Andrew Morton wrote:
> 
> Dirtying all that memory at mlock() time is pretty obnoxious.
> ...
> So all that leaves me thinking that we merge your patches as-is.  Then
> work out why users can fairly trivially use mlock to hang the kernel on
> ext2 and ext3 (and others?) 

So at least on RHEL 4 and 5 systems, pam_limits was configured so that
unprivileged processes could only mlock() at most 16k.  This was
deemed enough so that programs could protect crypto keys.  The
thinking when we added the mlock() ulimit setting was that
unprivileged users could very easily make a nuisance of themselves,
and grab way too much system resources, by using mlock() in obnoxious
ways.

I was just checking to see if my memory was correct, and to my
surprise, I've just found that Ubuntu deliberately sets the memlock
ulimit to be unlimited.  Which means that Ubuntu systems are
completely wide open for this particular DOS attack.  So if you
administer an Ubuntu-based server, it might be a good idea to make a
tiny little change to /etc/security/limits.conf....

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
