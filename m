Date: Tue, 6 Mar 2001 19:36:23 +0000 (GMT)
From: Matthew Kirkwood <matthew@hairy.beasts.org>
Subject: Linux 2.2 vs 2.4 for PostgreSQL
Message-ID: <Pine.LNX.4.10.10103061626070.20708-100000@sphinx.mythic-beasts.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mike Galbraith <mikeg@wen-online.de>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

I have been collecting some postgres benchmark numbers
on various kernels, which may be of interest to this
list.

The test was to run "pgbench" with various numbers of
clients against postgresql 7.1beta4.  The benchmark
looks rather like a fairly minimal TPC/B, with lots of
small transactions, all committed.  It's not very
complex, but does produce pretty stable numbers, and
appears capable of showing up performance improvements
or deteriorations.

Postgres is fairly fsync-happy.  Version 7.1 uses write-
ahead logging, in (as far as I can see) pretty much
exactly the same way as journally filesystems do, so
this is likely to be a fairly common access-pattern.
Oracle works in a similar manner, though it's rather
cleverer.

Details:
 * dual P3-450
 * 384Mb RAM
 * 3 x 9Gb 10KRPM Quantum Atlas disks on aic7xxx
 * postgres data and journal files on the same 2Gb
   partition on the third disk (will try splitting
   the two to see how that affects things).

Postgres:
 * 7.1beta4 RPMs from ftp.postgresql.org/pub/dev/test-rpms
 * max_connections = 128
 * shared_buffers = 10240
 * wal_buffers = 128, wal_files = 10
 * fsync = {true,false} -- different tables
 * pgbench args:
   + -s 10 (scale factor 10 - aka 1 million accounts)
   + -t 1000 (1000 transactions per client)
   + -c {1,2,4,8,16,32,64,128} (number of concurrent
     clients)
 * pgbench's multi-client mode uses multiple connections
   from a single process via their async API.  I have
   been told that there is not evidence for that being a
   bottleneck, but haven't proved that to myself yet.

Kernels:
 * Built with:
   + gcc version egcs-2.91.66 19990314/Linux (egcs-1.1.2
     release)
 * 2.2.19pre16 + RAID + dc395 driver
 * 2.4.2pre2 + dc395 driver
 * 2.4.2ac11 + dc395
 * 2.4.2ac11 + dc395 + Mike Galbraith's tiny patch from
   Sunday evening
 * sysctl -w kernel.shmmax=268435456
 * sysctl -w fs.inode-max=102400
 * (on 2.2) sysctl -w fs.file-max=10240
 * .config's available, but I did turn off the debugging
   options in the 2.4ac configs
 * No kernel has gone more than a few hundred Kb into
   swap

Results:
 * Numbers are transactions per second
 * The numbers I get are fairly stable across different
   runs (to within one TPS or so).  I umounted, mkfs'ed,
   mounted and initdb'ed the filesystem between each run.
 * As you can see by comparing the results without fsync,
   disk access is something of a bottleneck.  I will
   redo this with logs and datafiles on separate spindles
   to see how that affects things.

Conclusions:
Draw your own, but:
 * 2.4's IO scheduling doesn't seem as good as 2.2's yet
 * But it's getting better
 * Mike's patch was about 3-5% worse on this workload
   with fsync on and 3% better with it off (except on
   one run, which I think may be an anomaly)
 * Even with multiple clients and light I/O (no-fsync)
   on a 2-way box, 2.4 seems not to help postgres.  2.4
   degrades a bit better, but the sweet spot seems lower.

Invitations:
 * Anyone care to suggest any patches/configuration tweaks/
   &c, which might prove an interesting test?  Are there
   significant elevator/VM differences between 2.4.2ac and
   2.4.3pre?

And now, the numbers (the xx.xxxxxx one is still running :):

fsync on

#c	2.2.19p16	2.4.2p2		2.4.2-ac11	2.4.2-ac11+fix
1	37.252046	29.274617	34.157451	32.875597
2	46.871538	38.203153	42.366190	41.138971
4	66.080711	57.555436	61.593403	60.142452
8	91.921916	81.564555	87.356349	84.971314
16	63.828916	62.447728	71.734160	67.892885
32	48.731521	51.852875	55.244382	53.663921
64	33.582506	34.908383	35.883570	35.794966
128	20.323637	20.402136	20.838813	20.972550


fsync off

#c	2.2.19p16	2.4.2p2		2.4.2-ac11	2.4.2-ac11+fix
1	196.225716	197.193853	197.315522	199.199378
2	279.804417	263.167071	265.132293	257.112338
4	256.049932	246.218893	248.105236	255.663816
8	202.133422	205.652017	207.631981	210.701314
16	137.565201	144.262640	144.649113	144.941244
32	78.388172	86.006355	85.393162	85.069347
64	46.164090	47.408836	47.643161	47.646383
128	xx.xxxxxx	24.721486	25.016129       24.997236

Matthew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
