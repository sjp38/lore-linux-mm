Date: Tue, 20 Mar 2007 18:47:51 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [RFC][PATCH 0/6] per device dirty throttling
Message-ID: <20070320074751.GP32602149@melbourne.sgi.com>
References: <20070319155737.653325176@programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070319155737.653325176@programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

On Mon, Mar 19, 2007 at 04:57:37PM +0100, Peter Zijlstra wrote:
> This patch-set implements per device dirty page throttling. Which should solve
> the problem we currently have with one device hogging the dirty limit.
> 
> Preliminary testing shows good results:

I just ran some higher throughput number on this patchset.

Identical 4-disk dm stripes, XFS, 4p x86_64, 16GB RAM, dirty_ratio = 5:

One dm stripe: 320MB/s
two dm stripes: 310+315MB/s
three dm stripes: 254+253+253MB/s (pci-x bus bound)

The three stripe test was for 100GB of data to each
filesystem - all the writes finished with 1s of each other
at 7m4s. Interestingly, the amount of memory in cache for
each of these devices was almost exactly the same - about
5.2GB each. Looks good so far....

Hmmm - small problem - root disk (XFS) got stuck in
balance_dirty_pages_ratelimited_nr() after the above write test
attempting to unmount the filesystems (i.e. umount trying
to modify /etc/mtab got stuck and the root fs locked up)

(reboot)

None-identical dm stripes, XFS, run alone:

Single disk: 80MB/s
2 disk dm stripe: 155MB/s
4 disk dm stripe: 310MB/s

Combined, after some runtime:

# ls -sh /mnt/dm*/test
10G /mnt/dm0/test	19G /mnt/dm1/test	41G /mnt/dm2/test
15G /mnt/dm0/test	27G /mnt/dm1/test	52G /mnt/dm2/test
18G /mnt/dm0/test	32G /mnt/dm1/test	64G /mnt/dm2/test
24G /mnt/dm0/test	45G /mnt/dm1/test	86G /mnt/dm2/test
27G /mnt/dm0/test	51G /mnt/dm1/test	95G /mnt/dm2/test
29G /mnt/dm0/test	52G /mnt/dm1/test	97G /mnt/dm2/test
29G /mnt/dm0/test	54G /mnt/dm1/test	101G /mnt/dm2/test [done]
35G /mnt/dm0/test	65G /mnt/dm1/test	101G /mnt/dm2/test
38G /mnt/dm0/test	70G /mnt/dm1/test	101G /mnt/dm2/test

And so on. Final number:

Single disk: 70MB/s
2 disk dm stripe: 130MB/s
4 disk dm stripe: 260MB/s

So overall we've lost about 15-20% of the theoretical aggregate
perfomrance, but we haven't starved any of the devices over a
long period of time.

However, looking at vmstat for total throughput, there are periods
of time where it appears that the fastest disk goes idle. That is,
we drop from an aggregate of about 550MB/s to below 300MB/s for
several seconds at a time. You can sort of see this from the file
size output above - long term the ratios remain the same, but in the
short term we see quite a bit of variability.

When the fast disk completed, I saw almost the same thing, but
this time it seems like the slow disk (i.e. ~230MB/s to ~150MB/s)
stopped for several seconds.

I haven't really digested what the patches do, but it's almost
like it is throttling a device completely while it allows another
to finish writing it's quota (underestimating bandwidth?).

(umount after writes hung again. Same root disk thing as before....)

This is looking promising, Peter. When it is more stable I'll run
some more tests....

Cheers,

Dave.
--
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
