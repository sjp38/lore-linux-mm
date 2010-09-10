Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1906B00B5
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 12:01:55 -0400 (EDT)
Date: Fri, 10 Sep 2010 18:02:48 +0200
From: Johannes Stezenbach <js@sig21.net>
Subject: Re: block cache replacement strategy?
Message-ID: <20100910160247.GA637@sig21.net>
References: <20100907133429.GB3430@sig21.net>
 <20100909120044.GA27765@sig21.net>
 <20100910120235.455962c4@schatten.dmk.lab>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100910120235.455962c4@schatten.dmk.lab>
Sender: owner-linux-mm@kvack.org
To: Florian Mickler <florian@mickler.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 10, 2010 at 12:02:35PM +0200, Florian Mickler wrote:
> > On Tue, Sep 07, 2010 at 03:34:29PM +0200, Johannes Stezenbach wrote:
> > > 
> > > during some simple disk read throughput testing I observed
> > > caching behaviour that doesn't seem right.  The machine
> > > has 2G of RAM and AMD Athlon 4850e, x86_64 kernel but 32bit
> > > userspace, Linux 2.6.35.4.  It seems that contents of the
> > > block cache are not evicted to make room for other blocks.
> > > (Or something like that, I have no real clue about this.)
> > > 
> > > Since this is a rather artificial test I'm not too worried,
> > > but it looks strange to me so I thought I better report it.
> 
> Well I personally have  no clue about the block caching, but perhaps
> that is an heuristic to prevent the cache from fluctuating too much?
> Some minimum time a block is hold... in a big linear read the cache is
> useless anyway most of the time, so it could make some sense...
> 
> You could try accessing random files after filling up the cache and
> check if those evict the the cache.  That should rule out any
> linear-read-detection heuristic. 

OK, here is another run with simple files (using two kvm images
I had lying around).
Note how the cache used by /dev/sda2 apparently prevents the
kvm image from being cached, but also how the cache used by test.img
prevents test2.img from being cached.

Linear read heuristic might be a good guess, but it would
be nice to hear a comment from a vm/fs expert which
confirms this works as intended.


Thanks
Johannes

zzz:~# echo 3 >/proc/sys/vm/drop_caches
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.9516 s, 75.2 MB/s
zzz:~# dd if=/dev/sda2 of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 0.957778 s, 1.1 GB/s

zzz:~# dd if=~js/qemu/test.img of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 18.4247 s, 56.9 MB/s
zzz:~# dd if=~js/qemu/test.img of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 18.3675 s, 57.1 MB/s
zzz:~# dd if=~js/qemu/test.img of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 18.3925 s, 57.0 MB/s

zzz:~# echo 3 >/proc/sys/vm/drop_caches
zzz:~# dd if=~js/qemu/test.img of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 18.5455 s, 56.5 MB/s
zzz:~# dd if=~js/qemu/test.img of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 0.950387 s, 1.1 GB/s

zzz:~# dd if=~js/qemu/test2.img of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 18.085 s, 58.0 MB/s
zzz:~# dd if=~js/qemu/test2.img of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 17.7351 s, 59.1 MB/s

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
