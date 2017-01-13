Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 043C06B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 13:40:52 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t18so2646465wmt.7
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 10:40:51 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id 80si3021159wmy.107.2017.01.13.10.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 10:40:47 -0800 (PST)
Date: Fri, 13 Jan 2017 18:40:36 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170113184036.GN1555@ZenIV.linux.org.uk>
References: <20170110160224.GC6179@noname.redhat.com>
 <87k2a2ig2c.fsf@notabene.neil.brown.name>
 <20170113110959.GA4981@noname.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113110959.GA4981@noname.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Wolf <kwolf@redhat.com>
Cc: NeilBrown <neilb@suse.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Ric Wheeler <rwheeler@redhat.com>, Rik van Riel <riel@redhat.com>

On Fri, Jan 13, 2017 at 12:09:59PM +0100, Kevin Wolf wrote:

> I had assumed that there is a way to get back from the file to all file
> descriptors that are open for it, but looking at the code I don't see
> one indeed. Is this an intentional design decision or is it just that
> nobody needed it?

The locking required for that would be horrible.  Ditto for the memory
*and* dirty cache footprint.  Besides, what kind of locking would the
callers need, simply to keep the answer from going stale by the time
they see it?  System-wide exclusion of operations that might affect
descriptors (including fork and exit, BTW)?

And that's aside of the fact that an opened file might have no descriptors
whatsoever - e.g. stuff it into SCM_RIGHTS, send to another process (or
to yourself) and close the descriptor you've used.  recvmsg() will reattach
it to descriptor table nicely...

If you are not actually talking about the descriptors and want all
struct file associated with given... inode, presumably?  That one is
merely a nasty headache from dirty cache footprint on a bunch of
hot paths.  That, and the same "how do you keep the results valid by the
time they are returned to caller" problem - e.g. how do you know that
another process has not opened the same thing just as you'd been examining
the set of opened files with that inode?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
