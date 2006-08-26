Date: Sat, 26 Aug 2006 00:14:22 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [Ext2-devel] ext3 fsync being starved for a long time by cp and cronjob
Message-ID: <20060826041422.GA2397@thunk.org>
References: <200608251353.51748.ak@suse.de> <200608251422.48287.ak@suse.de> <20060825122615.GB24258@kernel.dk> <200608251430.56655.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200608251430.56655.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Jens Axboe <axboe@kernel.dk>, akpm@osdl.org, linux-mm@kvack.org, ext2-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Fri, Aug 25, 2006 at 02:30:56PM +0200, Andi Kleen wrote:
> So you think it's the elevator? I was about to blame JBD.

Earlier in the thread, you said:

>Background load is a large cp from the same fs to a tmpfs and a cron job
>doing random cron job stuff. All on a single sata disk with a 28G partition.

That doesn't sound like you are doing anything that would result in a
lot of ext3 journal activity (unless there's something strange running
out of your cron scripts).

As such, it's hard to see how this would be an JBD issue.  Ext3 might
have been in the middle of doing a synchronous write of a commit
block, which might have been getting starved by an elevator which
prioritizes read traffic ahead of write traffic, but it doesn't sound
like it's due to the excessive journal traffic.

So if you're focused on allocating blame :-), it's probably both ext3
and the elevator code equally at fault.  I suspect what we need is a
way of informing the elevator that when ext3 is writing commit records
or other writes that block filesystem I/O, that these synchronous
writes should be prioritized about other (asynchronous) write traffic.
This hint would have to be passed through the buffer cache layer,
since the jbd layer is still using buffer heads.

Regards,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
