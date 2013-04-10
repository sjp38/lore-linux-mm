Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 94F9F6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 09:12:50 -0400 (EDT)
Date: Wed, 10 Apr 2013 09:12:45 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130410131245.GC4862@thunk.org>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130410105608.GC1910@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130410105608.GC1910@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Wed, Apr 10, 2013 at 11:56:08AM +0100, Mel Gorman wrote:
> During major activity there is likely to be "good" behaviour
> with stalls roughly every 30 seconds roughly corresponding to
> dirty_expire_centiseconds. As you'd expect, the flusher thread is stuck
> when this happens.
> 
>   237 ?        00:00:00 flush-8:0
> [<ffffffff811a35b9>] sleep_on_buffer+0x9/0x10
> [<ffffffff811a35ee>] __lock_buffer+0x2e/0x30
> [<ffffffff8123a21f>] do_get_write_access+0x43f/0x4b0

If we're stalling on lock_buffer(), that implies that buffer was being
written, and for some reason it was taking a very long time to
complete.

It might be worthwhile to put a timestamp in struct dm_crypt_io, and
record the time when a particular I/O encryption/decryption is getting
queued to the kcryptd workqueues, and when they finally squirt out.

Something else that might be worth trying is to add WQ_HIGHPRI to the
workqueue flags and see if that makes a difference.

	  	    	   	- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
