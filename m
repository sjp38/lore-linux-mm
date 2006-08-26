From: Andi Kleen <ak@suse.de>
Subject: Re: [Ext2-devel] ext3 fsync being starved for a long time by cp and cronjob
Date: Sat, 26 Aug 2006 12:04:17 +0200
References: <200608251353.51748.ak@suse.de> <200608251430.56655.ak@suse.de> <20060826041422.GA2397@thunk.org>
In-Reply-To: <20060826041422.GA2397@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608261204.17944.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Jens Axboe <axboe@kernel.dk>, akpm@osdl.org, linux-mm@kvack.org, ext2-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Saturday 26 August 2006 06:14, Theodore Tso wrote:

> >Background load is a large cp from the same fs to a tmpfs and a cron job
> >doing random cron job stuff. All on a single sata disk with a 28G partition.
> 
> That doesn't sound like you are doing anything that would result in a
> lot of ext3 journal activity (unless there's something strange running
> out of your cron scripts).

(looking through the process list again)

kmail was doing some write IO, not sure how much.

So yes.

> So if you're focused on allocating blame :-), 

I would be mostly interested in a solution.

(sorry "assigning blame" is a SUSE tongue-in-cheek and just means the 
first step in debugging when you try to figure out which subsystem
to look at. It wasn't meant as in to blame some person of 
wrong-doing.) 

> it's probably both ext3 
> and the elevator code equally at fault.  I suspect what we need is a
> way of informing the elevator that when ext3 is writing commit records
> or other writes that block filesystem I/O, that these synchronous
> writes should be prioritized about other (asynchronous) write traffic.
> This hint would have to be passed through the buffer cache layer,
> since the jbd layer is still using buffer heads.

Hmm, I thought CFQ currently only looked at processes for priority,
but maybe it's possible to add temporary boosts. Jens? 

Or maybe just run kjournald always with a high io priority? I assume
it mostly does journal IO and not much else, right?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
