Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA30195
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 13:46:18 -0500
Subject: Re: Results: 2.2.0-pre5 vs arcavm10 vs arcavm9 vs arcavm7
References: <Pine.LNX.3.95.990107093240.4270F-100000@penguin.transmeta.com>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 07 Jan 1999 19:44:18 +0100
In-Reply-To: Linus Torvalds's message of "Thu, 7 Jan 1999 09:35:41 -0800 (PST)"
Message-ID: <87iueiudml.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

This is a MIME multipart message.  If you are reading
this, you shouldn't.

--=-=-=

Linus Torvalds <torvalds@transmeta.com> writes:

> On Wed, 6 Jan 1999, Steve Bergman wrote:
> > 
> > Here are my latest numbers.  This is timing a complete kernel compile  (make
> > clean;make depend;make;make modules;make modules_install)  in 16MB memory with
> > netscape, kde, and various daemons running.  I unknowningly had two more daemons
> > running in the background this time than last so the numbers can't be compared
> > directly with my last test (Which I think I only sent to Andrea).  But all of
> > these numbers are consistent with *each other*.
> > 
> > 
> > kernel		Time	Maj pf	Min pf  Swaps
> > ----------	-----	------	------	-----
> > 2.2.0-pre5		18:19	522333	493803	27984
> > arcavm10		19:57	556299	494163	12035
> > arcavm9		19:55	553783	494444	12077
> > arcavm7		18:39	538520	493287	11526
> 
> Don't look too closely at the "swaps" number - I think pre-5 just changed
> accounting a bit. A lot of the "swaps" are really just dropping a virtual
> mapping (that is later picked up again from the page cache or the swap
> cache). 
> 
> Basically, pre-5 uses the page cache and the swap cache more actively as a
> "victim cache", and that inflates the "swaps" number simply due to the
> accounting issues. 
> 
> I guess I shouldn't count the simple "drop_pte" operation as a swap at
> all, because it doesn't involve any IO.
> 

2.2.0-pre5 works very good, indeed, but it still has some not
sufficiently explored nuisances:

1) Swap performance in pre-5 is much worse compared to pre-4 in
*certain* circumstances. I'm using quite stupid and unintelligent
program to check for raw swap speed (attached below). With 64 MB of
RAM I usually run it as 'hogmem 100 3' and watch for result which is
recently around 6 MB/sec. But when I lately decided to start two
instances of it like "hogmem 50 3 & hogmem 50 3 &" in pre-4 I got 2 x
2.5 MB/sec and in pre-5 it is only 2 x 1 MB/sec and disk is making
very weird and frightening sounds. My conclusion is that now (pre-5)
system behaves much poorer when we have more than one thrashing
task. *Please*, check this, it is a quite serious problem.

2) In pre-5, under heavy load, free memory is hovering around
freepages.min instead of being somewhere between freepages.low &
freepages.max. This could make trouble for bursts of atomic
allocations (networking!).

3) Nitpick #1: /proc/swapstats exist but is only filled with
zeros. Probably it should go away. I believe Stephen added it
recently, but only part of his patch got actually applied.

4) Nitpick #2": "Swap cache:" line in report of Alt-SysRq-M is not
useful as it is laid now. People have repeatedly sent patches (Rik,
Andrea...) to fix this but it is still not fixed, as of pre-5.

5) There is lots of #if 0 constructs in MM code, and also lots of
structures are not anymore used but still take precious memory in
compiled kernel and uncover itself under /proc (/proc/sys/vm/swapctl
for instance). Do you want a patch to remove this cruft?

6) Finally one suggestion of mine. In swapfile.c there is comment:

         * We try to cluster swap pages by allocating them
         * sequentially in swap.  Once we've allocated
         * SWAP_CLUSTER_MAX pages this way, however, we resort to
         * first-free allocation, starting a new cluster.  This
         * prevents us from scattering swap pages all over the entire
         * swap partition, so that we reduce overall disk seek times

This is good, but clustering of only 32 (SWAP_CLUSTER_MAX) * 4KB =
128KB is too small for today's disk and swap sizes. I tried to enlarge
this value to something like 2 MB and got much much better results.
This is very important now that we have swapin readahead to keep pages
as adjacent as possible to each other so hit rate is big. It is
trivial (one liner) and completely safe to make this constant much
bigger, so I'm not even attaching a patch. 512 works very well and
swapping is much faster than with default valuein place. Maybe this
should even be sysctl controllable. If you agree with the last idea,
I'll send you a patch, just confirm.

I promised memory hogger:


--=-=-=
Content-Type: application/octet-stream
Content-Disposition: attachment
Content-Description: Hogmem.c
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KI2luY2x1ZGUgPHN0ZGxp
Yi5oPgojaW5jbHVkZSA8bGltaXRzLmg+CiNpbmNsdWRlIDxzaWduYWwuaD4KI2luY2x1ZGUg
PHRpbWUuaD4KI2luY2x1ZGUgPHN5cy90aW1lcy5oPgoKI2RlZmluZSBNQiAoMTAyNCAqIDEw
MjQpCgppbnQgbnIsIGludHNpemUsIGksIHQ7CmNsb2NrX3Qgc3Q7CnN0cnVjdCB0bXMgZHVt
bXk7Cgp2b2lkIGludHIoaW50IGludG51bSkKewogICAgY2xvY2tfdCBldCA9IHRpbWVzKCZk
dW1teSk7CgogICAgcHJpbnRmKCJcbk1lbW9yeSBzcGVlZDogJS4yZiBNQi9zZWNcbiIsICgy
ICogdCAqIENMS19UQ0sgKiBuciArIChkb3VibGUpIGkgKiBDTEtfVENLICogaW50c2l6ZSAv
IE1CKSAvIChldCAtIHN0KSk7CiAgICBleGl0KEVYSVRfU1VDQ0VTUyk7Cn0KCmludCBtYWlu
KGludCBhcmdjLCBjaGFyICoqYXJndikKewogICAgaW50IG1heCwgbnJfdGltZXMsICphcmVh
LCBjOwoKICAgIHNldGJ1ZihzdGRvdXQsIDApOwogICAgc2lnbmFsKFNJR0lOVCwgaW50cik7
CiAgICBzaWduYWwoU0lHVEVSTSwgaW50cik7CiAgICBpbnRzaXplID0gc2l6ZW9mKGludCk7
CiAgICBpZiAoYXJnYyA8IDIgfHwgYXJnYyA+IDMpIHsKCWZwcmludGYoc3RkZXJyLCAiVXNh
Z2U6IGhvZ21lbSA8TUI+IFt0aW1lc11cbiIpOwoJZXhpdChFWElUX0ZBSUxVUkUpOwogICAg
fQogICAgbnIgPSBhdG9pKGFyZ3ZbMV0pOwogICAgaWYgKGFyZ2MgPT0gMykKCW5yX3RpbWVz
ID0gYXRvaShhcmd2WzJdKTsKICAgIGVsc2UKCW5yX3RpbWVzID0gSU5UX01BWDsKICAgIGFy
ZWEgPSBtYWxsb2MobnIgKiBNQik7CiAgICBtYXggPSBuciAqIE1CIC8gaW50c2l6ZTsKICAg
IHN0ID0gdGltZXMoJmR1bW15KTsKICAgIGZvciAoYyA9IDA7IGMgPCBucl90aW1lczsgYysr
KQogICAgewoJZm9yIChpID0gMDsgaSA8IG1heDsgaSsrKQoJICAgIGFyZWFbaV0rKzsKCXQr
KzsKCXB1dGNoYXIoJy4nKTsKICAgIH0KICAgIGkgPSAwOwogICAgaW50cigwKTsKICAgIC8q
IG5vdHJlYWNoZWQgKi8KICAgIGV4aXQoRVhJVF9TVUNDRVNTKTsKfQo=

--=-=-=


OK, that's it for today. Don't bang heads too hard and enjoy!
-- 
Zlatko

--=-=-=--
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
