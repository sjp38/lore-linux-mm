Subject: Linux I/O performance in 2.3.99pre
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 22 May 2000 14:26:40 +0200
Message-ID: <dn4s7qpy7z.fsf@magla.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: andrea@suse.de
List-ID: <linux-mm.kvack.org>

This is just to report that I/O performance in the pre kernels is very
bad. System is so sluggish that you don't need any benchmarks to
quantify it, but I did some anyway. :)

This is bonnie output on pre9-3 virgin:


              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU
pre9-3    400 15032 64.4 12843 13.8  6202  7.1 11421 38.1 13005 11.6 118.1  1.2
                         ^^^^^                            ^^^^^

It looks like a slightly slower/older 5400 disk, is it?

But in fact it is a quite fast (and expensive) 7200rpm disk, which is
capable of this:

              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU
9-3-nswap 400 21222 89.7 22244 19.7  7343  8.0 17863 57.3 21030 18.0 118.8  1.1
                         ^^^^^                            ^^^^^

This second numbers are generated on the same kernel version, but with
disabled swap_out() function.

Memory balancing is killing I/O. It is very common to see system
swapping loads of pages in/out with only one I/O intensive process
running and plenty (~100MB) free memory (page cache). Swapping kills
I/O performance because of needless disk head seeks, and thus all
recent kernels have very slow I/O (~60% of possible speed).

While at benchmarking, I have also tested 2.3.42 which is the last
kernel before elevator rewrite (Hi Andrea! :))

              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU
2.3.42    400 20978 97.2 22519 22.2  9302 12.7 18860 61.5 21020 20.4 114.8  1.3
                                     ^^^^

Numbers for read/write are almost same as in my experiment (which is
to say that VM subsytem worked OK in 2.3.42, at least for common
memory configurations :)), but there is a measurable difference in a
rewrite case. Old elevator allowed ~9.5MB/s rewriting speed, while
with new code it drops to ~7.5MB/s.

Question for Andrea: is it possible to get back to the old speeds with
tha new elevator code, or is the speed drop unfortunate effect of the
"non-starvation" logic, and thus can't be cured?

Doing that same rewrite test under old and new kernels reveals that in
2.3.42 disk is completely quiet while rewriting, while in the 99-pre
series it makes very loud and scary noise. Could that still be a bug
somewhere in the elevator?

Regards,
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
