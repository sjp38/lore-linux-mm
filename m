Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id AAC7E6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 10:27:27 -0400 (EDT)
Date: Tue, 2 Apr 2013 15:27:17 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130402142717.GH32241@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-ext4@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

I'm testing a page-reclaim-related series on my laptop that is partially
aimed at fixing long stalls when doing metadata-intensive operations on
low memory such as a git checkout. I've been running 3.9-rc2 with the
series applied but found that the interactive performance was awful even
when there was plenty of free memory.

I activated a monitor from mmtests that logs when a process is stuck for
a long time in D state and found that there are a lot of stalls in ext4.
The report first states that processes have been stalled for a total of
6498 seconds on IO which seems like a lot. Here is a breakdown of the
recorded events.

Time stalled in this event:   566745 ms
Event count:                     181
git                  sleep_on_buffer        1236 ms
git                  sleep_on_buffer        1161 ms
imapd                sleep_on_buffer        3111 ms
cp                   sleep_on_buffer       10745 ms
cp                   sleep_on_buffer        5036 ms
cp                   sleep_on_buffer        4370 ms
cp                   sleep_on_buffer        1682 ms
cp                   sleep_on_buffer        8207 ms
cp                   sleep_on_buffer        5312 ms
cp                   sleep_on_buffer        1563 ms
patch                sleep_on_buffer        1172 ms
patch                sleep_on_buffer        4585 ms
patch                sleep_on_buffer        3541 ms
patch                sleep_on_buffer        4155 ms
patch                sleep_on_buffer        3120 ms
cc1                  sleep_on_buffer        1107 ms
cc1                  sleep_on_buffer        1291 ms
cc1                  sleep_on_buffer        1125 ms
cc1                  sleep_on_buffer        1257 ms
imapd                sleep_on_buffer        1424 ms
patch                sleep_on_buffer        1126 ms
mutt                 sleep_on_buffer        4804 ms
patch                sleep_on_buffer        3489 ms
patch                sleep_on_buffer        4242 ms
cp                   sleep_on_buffer        1942 ms
cp                   sleep_on_buffer        2670 ms
cp                   sleep_on_buffer        1071 ms
cp                   sleep_on_buffer        1676 ms
cp                   sleep_on_buffer        1058 ms
cp                   sleep_on_buffer        1382 ms
cp                   sleep_on_buffer        2196 ms
cp                   sleep_on_buffer        1017 ms
cp                   sleep_on_buffer        1096 ms
cp                   sleep_on_buffer        1203 ms
cp                   sleep_on_buffer        1307 ms
cp                   sleep_on_buffer        1676 ms
cp                   sleep_on_buffer        1024 ms
cp                   sleep_on_buffer        1270 ms
cp                   sleep_on_buffer        1200 ms
cp                   sleep_on_buffer        1674 ms
cp                   sleep_on_buffer        1202 ms
cp                   sleep_on_buffer        2260 ms
cp                   sleep_on_buffer        1685 ms
cp                   sleep_on_buffer        1921 ms
cp                   sleep_on_buffer        1434 ms
cp                   sleep_on_buffer        1346 ms
cp                   sleep_on_buffer        2132 ms
cp                   sleep_on_buffer        1304 ms
cp                   sleep_on_buffer        1328 ms
cp                   sleep_on_buffer        1419 ms
cp                   sleep_on_buffer        1882 ms
cp                   sleep_on_buffer        1172 ms
cp                   sleep_on_buffer        1299 ms
cp                   sleep_on_buffer        1806 ms
cp                   sleep_on_buffer        1297 ms
cp                   sleep_on_buffer        1484 ms
cp                   sleep_on_buffer        1313 ms
cp                   sleep_on_buffer        1342 ms
cp                   sleep_on_buffer        1320 ms
cp                   sleep_on_buffer        1147 ms
cp                   sleep_on_buffer        1346 ms
cp                   sleep_on_buffer        2391 ms
cp                   sleep_on_buffer        1128 ms
cp                   sleep_on_buffer        1386 ms
cp                   sleep_on_buffer        1505 ms
cp                   sleep_on_buffer        1664 ms
cp                   sleep_on_buffer        1290 ms
cp                   sleep_on_buffer        1532 ms
cp                   sleep_on_buffer        1719 ms
cp                   sleep_on_buffer        1149 ms
cp                   sleep_on_buffer        1364 ms
cp                   sleep_on_buffer        1397 ms
cp                   sleep_on_buffer        1213 ms
cp                   sleep_on_buffer        1171 ms
cp                   sleep_on_buffer        1352 ms
cp                   sleep_on_buffer        3000 ms
cp                   sleep_on_buffer        4866 ms
cp                   sleep_on_buffer        5863 ms
cp                   sleep_on_buffer        3951 ms
cp                   sleep_on_buffer        3469 ms
cp                   sleep_on_buffer        2172 ms
cp                   sleep_on_buffer       21366 ms
cp                   sleep_on_buffer       28856 ms
cp                   sleep_on_buffer        1212 ms
cp                   sleep_on_buffer        2326 ms
cp                   sleep_on_buffer        1357 ms
cp                   sleep_on_buffer        1482 ms
cp                   sleep_on_buffer        1372 ms
cp                   sleep_on_buffer        1475 ms
cp                   sleep_on_buffer        1540 ms
cp                   sleep_on_buffer        2993 ms
cp                   sleep_on_buffer        1269 ms
cp                   sleep_on_buffer        1478 ms
cp                   sleep_on_buffer        1137 ms
cp                   sleep_on_buffer        1114 ms
cp                   sleep_on_buffer        1137 ms
cp                   sleep_on_buffer        1616 ms
cp                   sleep_on_buffer        1291 ms
cp                   sleep_on_buffer        1336 ms
cp                   sleep_on_buffer        2440 ms
cp                   sleep_on_buffer        1058 ms
cp                   sleep_on_buffer        1825 ms
cp                   sleep_on_buffer        1320 ms
cp                   sleep_on_buffer        2556 ms
cp                   sleep_on_buffer        2463 ms
cp                   sleep_on_buffer        2563 ms
cp                   sleep_on_buffer        1218 ms
cp                   sleep_on_buffer        2862 ms
cp                   sleep_on_buffer        1484 ms
cp                   sleep_on_buffer        1039 ms
cp                   sleep_on_buffer        5180 ms
cp                   sleep_on_buffer        2584 ms
cp                   sleep_on_buffer        1357 ms
cp                   sleep_on_buffer        4492 ms
cp                   sleep_on_buffer        1111 ms
cp                   sleep_on_buffer        3992 ms
cp                   sleep_on_buffer        4205 ms
cp                   sleep_on_buffer        4980 ms
cp                   sleep_on_buffer        6303 ms
imapd                sleep_on_buffer        8473 ms
cp                   sleep_on_buffer        7128 ms
cp                   sleep_on_buffer        4740 ms
cp                   sleep_on_buffer       10236 ms
cp                   sleep_on_buffer        1210 ms
cp                   sleep_on_buffer        2670 ms
cp                   sleep_on_buffer       11461 ms
cp                   sleep_on_buffer        5946 ms
cp                   sleep_on_buffer        7144 ms
cp                   sleep_on_buffer        2205 ms
cp                   sleep_on_buffer       25904 ms
cp                   sleep_on_buffer        1766 ms
cp                   sleep_on_buffer        9823 ms
cp                   sleep_on_buffer        1849 ms
cp                   sleep_on_buffer        1380 ms
cp                   sleep_on_buffer        2524 ms
cp                   sleep_on_buffer        2389 ms
cp                   sleep_on_buffer        1996 ms
cp                   sleep_on_buffer       10396 ms
cp                   sleep_on_buffer        2020 ms
cp                   sleep_on_buffer        1132 ms
cc1                  sleep_on_buffer        1182 ms
cp                   sleep_on_buffer        1195 ms
cp                   sleep_on_buffer        1179 ms
cp                   sleep_on_buffer        7301 ms
cp                   sleep_on_buffer        8328 ms
cp                   sleep_on_buffer        6922 ms
cp                   sleep_on_buffer       10555 ms
Cache I/O            sleep_on_buffer       11963 ms
cp                   sleep_on_buffer        2368 ms
cp                   sleep_on_buffer        6905 ms
cp                   sleep_on_buffer        1686 ms
cp                   sleep_on_buffer        1219 ms
cp                   sleep_on_buffer        1793 ms
cp                   sleep_on_buffer        1899 ms
cp                   sleep_on_buffer        6412 ms
cp                   sleep_on_buffer        2799 ms
cp                   sleep_on_buffer        1316 ms
cp                   sleep_on_buffer        1211 ms
git                  sleep_on_buffer        1328 ms
imapd                sleep_on_buffer        4242 ms
imapd                sleep_on_buffer        2754 ms
imapd                sleep_on_buffer        4496 ms
imapd                sleep_on_buffer        4603 ms
imapd                sleep_on_buffer        7929 ms
imapd                sleep_on_buffer        8851 ms
imapd                sleep_on_buffer        2016 ms
imapd                sleep_on_buffer        1019 ms
imapd                sleep_on_buffer        1138 ms
git                  sleep_on_buffer        1510 ms
git                  sleep_on_buffer        1366 ms
git                  sleep_on_buffer        3445 ms
git                  sleep_on_buffer        2704 ms
git                  sleep_on_buffer        2057 ms
git                  sleep_on_buffer        1202 ms
git                  sleep_on_buffer        1293 ms
cat                  sleep_on_buffer        1505 ms
imapd                sleep_on_buffer        1263 ms
imapd                sleep_on_buffer        1347 ms
imapd                sleep_on_buffer        2910 ms
git                  sleep_on_buffer        1210 ms
git                  sleep_on_buffer        1199 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b789>] update_time+0x79/0xc0
[<ffffffff8118ba31>] touch_atime+0x161/0x170
[<ffffffff811105e3>] do_generic_file_read.constprop.35+0x363/0x440
[<ffffffff81111359>] generic_file_aio_read+0xd9/0x220
[<ffffffff81172b53>] do_sync_read+0xa3/0xe0
[<ffffffff8117327b>] vfs_read+0xab/0x170
[<ffffffff8117338d>] sys_read+0x4d/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Some of those stalls are awful -- 28 seconds to update atime seems
excessive. This is with relatime in use

mel@machina:~ > mount | grep sd
/dev/sda8 on / type ext4 (rw,relatime,nobarrier,data=ordered)
/dev/sda6 on /home type ext4 (rw,relatime,nobarrier,data=ordered)
/dev/sda5 on /usr/src type ext4 (rw,relatime,nobarrier,data=ordered)

/tmp is mounted as tmpfs so I doubt it's a small write problem.

Time stalled in this event:   466201 ms
Event count:                      45
git                  sleep_on_buffer        1011 ms
git                  sleep_on_buffer       29540 ms
git                  sleep_on_buffer        1485 ms
git                  sleep_on_buffer        1244 ms
git                  sleep_on_buffer       17896 ms
git                  sleep_on_buffer        1882 ms
git                  sleep_on_buffer       18249 ms
mv                   sleep_on_buffer        2107 ms
mv                   sleep_on_buffer       12655 ms
mv                   sleep_on_buffer        4290 ms
mv                   sleep_on_buffer        2640 ms
patch                sleep_on_buffer        2433 ms
patch                sleep_on_buffer        2305 ms
patch                sleep_on_buffer        3672 ms
git                  sleep_on_buffer       16663 ms
git                  sleep_on_buffer       16516 ms
git                  sleep_on_buffer       16168 ms
git                  sleep_on_buffer        1382 ms
git                  sleep_on_buffer        1695 ms
git                  sleep_on_buffer        1301 ms
git                  sleep_on_buffer       22039 ms
git                  sleep_on_buffer       19077 ms
git                  sleep_on_buffer        1208 ms
git                  sleep_on_buffer       20237 ms
git                  sleep_on_buffer        1284 ms
git                  sleep_on_buffer       19518 ms
git                  sleep_on_buffer        1959 ms
git                  sleep_on_buffer       27574 ms
git                  sleep_on_buffer        9708 ms
git                  sleep_on_buffer        1968 ms
git                  sleep_on_buffer       23600 ms
git                  sleep_on_buffer       12578 ms
git                  sleep_on_buffer       19573 ms
git                  sleep_on_buffer        2257 ms
git                  sleep_on_buffer       19068 ms
git                  sleep_on_buffer        2833 ms
git                  sleep_on_buffer        3182 ms
git                  sleep_on_buffer       22496 ms
git                  sleep_on_buffer       14030 ms
git                  sleep_on_buffer        1722 ms
git                  sleep_on_buffer       25652 ms
git                  sleep_on_buffer       15730 ms
git                  sleep_on_buffer       19096 ms
git                  sleep_on_buffer        1529 ms
git                  sleep_on_buffer        3149 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811f96f9>] ext4_lookup.part.31+0x29/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117efb2>] path_lookupat+0x222/0x780
[<ffffffff8117f53f>] filename_lookup+0x2f/0xc0
[<ffffffff81182074>] user_path_at_empty+0x54/0xa0
[<ffffffff811820cc>] user_path_at+0xc/0x10
[<ffffffff81177b39>] vfs_fstatat+0x49/0xa0
[<ffffffff81177ba9>] vfs_lstat+0x19/0x20
[<ffffffff81177d15>] sys_newlstat+0x15/0x30
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

These are directory lookups which might be a bit more reasonable to
stall on but stalls of 30 seconds seems way out of order. Unfortuantely
I do not have a comparison with older kernels but even when interactive
performance was bad on older kernels, it did not feel *this* bad.

The rest of the mail is just the remaining stalls recorded. They are a
lot of them and they are all really high. Is this a known issue? It's
not necessarily an ext4 issue and could be an IO scheduler or some other
writeback change too. I've been offline for a while so could have missed
similar bug reports and/or fixes.

Time stalled in this event:   437040 ms
Event count:                     106
git                  wait_on_page_bit       1517 ms
git                  wait_on_page_bit       2694 ms
git                  wait_on_page_bit       2829 ms
git                  wait_on_page_bit       2796 ms
git                  wait_on_page_bit       2625 ms
git                  wait_on_page_bit      14350 ms
git                  wait_on_page_bit       4529 ms
xchat                wait_on_page_bit       1928 ms
akregator            wait_on_page_bit       1116 ms
akregator            wait_on_page_bit       3556 ms
cat                  wait_on_page_bit       5311 ms
sequence-patch.      wait_on_page_bit       2555 ms
pool                 wait_on_page_bit       1485 ms
git                  wait_on_page_bit       6778 ms
git                  wait_on_page_bit       3464 ms
git                  wait_on_page_bit       2189 ms
pool                 wait_on_page_bit       3657 ms
compare-kernels      wait_on_page_bit       5729 ms
compare-kernels      wait_on_page_bit       4446 ms
git                  wait_on_page_bit       2011 ms
xchat                wait_on_page_bit       6250 ms
git                  wait_on_page_bit       2761 ms
git                  wait_on_page_bit       1157 ms
xchat                wait_on_page_bit       2670 ms
pool                 wait_on_page_bit       5964 ms
xchat                wait_on_page_bit       1805 ms
play                 wait_on_page_bit       1800 ms
xchat                wait_on_page_bit      12008 ms
cat                  wait_on_page_bit       3642 ms
sequence-patch.      wait_on_page_bit       2309 ms
sequence-patch.      wait_on_page_bit       5430 ms
cat                  wait_on_page_bit       2614 ms
sequence-patch.      wait_on_page_bit       2220 ms
git                  wait_on_page_bit       3505 ms
git                  wait_on_page_bit       4181 ms
mozStorage #2        wait_on_page_bit       1012 ms
xchat                wait_on_page_bit       1966 ms
pool                 wait_on_page_bit      14217 ms
pool                 wait_on_page_bit       3728 ms
xchat                wait_on_page_bit       1896 ms
play                 wait_on_page_bit       8731 ms
mutt                 wait_on_page_bit      14378 ms
play                 wait_on_page_bit       1208 ms
Cache I/O            wait_on_page_bit       1174 ms
xchat                wait_on_page_bit       1141 ms
mozStorage #2        wait_on_page_bit       1161 ms
mozStorage #2        wait_on_page_bit       6727 ms
Cache I/O            wait_on_page_bit       7559 ms
mozStorage #2        wait_on_page_bit       4630 ms
Cache I/O            wait_on_page_bit       4642 ms
mozStorage #2        wait_on_page_bit       1764 ms
mozStorage #2        wait_on_page_bit       2357 ms
Cache I/O            wait_on_page_bit       3694 ms
xchat                wait_on_page_bit       8484 ms
mozStorage #2        wait_on_page_bit       3958 ms
mozStorage #2        wait_on_page_bit       2067 ms
Cache I/O            wait_on_page_bit       2728 ms
xchat                wait_on_page_bit       4115 ms
Cache I/O            wait_on_page_bit       7738 ms
xchat                wait_on_page_bit       7279 ms
Cache I/O            wait_on_page_bit       4366 ms
mozStorage #2        wait_on_page_bit       2040 ms
mozStorage #2        wait_on_page_bit       1102 ms
mozStorage #2        wait_on_page_bit       4628 ms
Cache I/O            wait_on_page_bit       5127 ms
akregator            wait_on_page_bit       2897 ms
Cache I/O            wait_on_page_bit       1429 ms
mozStorage #3        wait_on_page_bit       1465 ms
git                  wait_on_page_bit       2830 ms
git                  wait_on_page_bit       2508 ms
mutt                 wait_on_page_bit       4955 ms
pool                 wait_on_page_bit       4495 ms
mutt                 wait_on_page_bit       7429 ms
akregator            wait_on_page_bit       3744 ms
mutt                 wait_on_page_bit      11632 ms
pool                 wait_on_page_bit      11632 ms
sshd                 wait_on_page_bit      16035 ms
mutt                 wait_on_page_bit      16254 ms
mutt                 wait_on_page_bit       3253 ms
mutt                 wait_on_page_bit       3254 ms
git                  wait_on_page_bit       2644 ms
git                  wait_on_page_bit       2434 ms
git                  wait_on_page_bit       8364 ms
git                  wait_on_page_bit       1618 ms
git                  wait_on_page_bit       5990 ms
git                  wait_on_page_bit       2663 ms
git                  wait_on_page_bit       1102 ms
git                  wait_on_page_bit       1160 ms
git                  wait_on_page_bit       1161 ms
git                  wait_on_page_bit       1608 ms
git                  wait_on_page_bit       2100 ms
git                  wait_on_page_bit       2215 ms
git                  wait_on_page_bit       1231 ms
git                  wait_on_page_bit       2274 ms
git                  wait_on_page_bit       6081 ms
git                  wait_on_page_bit       6877 ms
git                  wait_on_page_bit       2035 ms
git                  wait_on_page_bit       2568 ms
git                  wait_on_page_bit       4475 ms
pool                 wait_on_page_bit       1253 ms
mv                   sleep_on_buffer        1036 ms
git                  wait_on_page_bit       1876 ms
git                  wait_on_page_bit       2332 ms
git                  wait_on_page_bit       2840 ms
git                  wait_on_page_bit       1850 ms
git                  wait_on_page_bit       3943 ms
[<ffffffff8110f0e0>] wait_on_page_bit+0x70/0x80
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff8110f3aa>] generic_perform_write+0xca/0x210
[<ffffffff8110f548>] generic_file_buffered_write+0x58/0x90
[<ffffffff81110f96>] __generic_file_aio_write+0x1b6/0x3b0
[<ffffffff8111120a>] generic_file_aio_write+0x7a/0xf0
[<ffffffff811ea3a3>] ext4_file_write+0x83/0xd0
[<ffffffff81172a73>] do_sync_write+0xa3/0xe0
[<ffffffff811730fe>] vfs_write+0xae/0x180
[<ffffffff8117341d>] sys_write+0x4d/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   417840 ms
Event count:                      56
xchat                sleep_on_buffer        8571 ms
xchat                sleep_on_buffer        1772 ms
xchat                sleep_on_buffer        4063 ms
xchat                sleep_on_buffer       16290 ms
xchat                sleep_on_buffer        3201 ms
compare-kernels      sleep_on_buffer        1698 ms
xchat                sleep_on_buffer       14631 ms
xchat                sleep_on_buffer       12970 ms
xchat                sleep_on_buffer        4182 ms
xchat                sleep_on_buffer        5449 ms
Cache I/O            sleep_on_buffer        4079 ms
xchat                sleep_on_buffer        8246 ms
xchat                sleep_on_buffer        6530 ms
xchat                sleep_on_buffer        2041 ms
xchat                sleep_on_buffer       15815 ms
pool                 sleep_on_buffer        4115 ms
tee                  sleep_on_buffer        2057 ms
xchat                sleep_on_buffer        4814 ms
tee                  sleep_on_buffer       66037 ms
Cache I/O            sleep_on_buffer        6601 ms
xchat                sleep_on_buffer       10208 ms
tee                  sleep_on_buffer        6064 ms
Cache I/O            sleep_on_buffer        2008 ms
xchat                sleep_on_buffer        5257 ms
git                  sleep_on_buffer        2032 ms
xchat                sleep_on_buffer        2313 ms
tee                  sleep_on_buffer        5287 ms
Cache I/O            sleep_on_buffer        1650 ms
akregator            sleep_on_buffer        1154 ms
tee                  sleep_on_buffer       10362 ms
xchat                sleep_on_buffer        6208 ms
xchat                sleep_on_buffer        4405 ms
Cache I/O            sleep_on_buffer        8580 ms
mozStorage #2        sleep_on_buffer        6573 ms
tee                  sleep_on_buffer       10180 ms
Cache I/O            sleep_on_buffer        7691 ms
mozStorage #3        sleep_on_buffer        5502 ms
xchat                sleep_on_buffer        2339 ms
Cache I/O            sleep_on_buffer        3819 ms
sshd                 sleep_on_buffer        7252 ms
tee                  sleep_on_buffer       11422 ms
Cache I/O            sleep_on_buffer        1661 ms
bash                 sleep_on_buffer       10905 ms
git                  sleep_on_buffer        1277 ms
git                  sleep_on_buffer       18599 ms
git                  sleep_on_buffer        1189 ms
git                  sleep_on_buffer       22945 ms
pool                 sleep_on_buffer       17753 ms
git                  sleep_on_buffer        1367 ms
git                  sleep_on_buffer        2223 ms
git                  sleep_on_buffer        1280 ms
git                  sleep_on_buffer        2061 ms
git                  sleep_on_buffer        1034 ms
pool                 sleep_on_buffer       18189 ms
git                  sleep_on_buffer        1344 ms
xchat                sleep_on_buffer        2545 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b789>] update_time+0x79/0xc0
[<ffffffff8118b868>] file_update_time+0x98/0x100
[<ffffffff81110f5c>] __generic_file_aio_write+0x17c/0x3b0
[<ffffffff8111120a>] generic_file_aio_write+0x7a/0xf0
[<ffffffff811ea3a3>] ext4_file_write+0x83/0xd0
[<ffffffff81172a73>] do_sync_write+0xa3/0xe0
[<ffffffff811730fe>] vfs_write+0xae/0x180
[<ffffffff8117341d>] sys_write+0x4d/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   283964 ms
Event count:                      27
git                  sleep_on_buffer       19088 ms
git                  sleep_on_buffer        1177 ms
git                  sleep_on_buffer       30745 ms
git                  sleep_on_buffer        4782 ms
git                  sleep_on_buffer       11435 ms
git                  sleep_on_buffer        2816 ms
git                  sleep_on_buffer        5088 ms
git-merge            sleep_on_buffer       18801 ms
git                  sleep_on_buffer        1415 ms
git                  sleep_on_buffer       16005 ms
git                  sleep_on_buffer        2178 ms
git                  sleep_on_buffer       14354 ms
git                  sleep_on_buffer       12612 ms
git                  sleep_on_buffer        2785 ms
git                  sleep_on_buffer       15498 ms
git                  sleep_on_buffer       15331 ms
git                  sleep_on_buffer        1151 ms
git                  sleep_on_buffer        1320 ms
git                  sleep_on_buffer        8787 ms
git                  sleep_on_buffer        2199 ms
git                  sleep_on_buffer        1006 ms
git                  sleep_on_buffer       23644 ms
git                  sleep_on_buffer        2407 ms
git                  sleep_on_buffer        1169 ms
git                  sleep_on_buffer       25022 ms
git                  sleep_on_buffer       18651 ms
git                  sleep_on_buffer       24498 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811fb6cf>] ext4_orphan_add+0x10f/0x1f0
[<ffffffff811fc6cb>] ext4_unlink+0x32b/0x350
[<ffffffff8117daef>] vfs_unlink.part.31+0x7f/0xe0
[<ffffffff8117f9d7>] vfs_unlink+0x37/0x50
[<ffffffff8117fbff>] do_unlinkat+0x20f/0x260
[<ffffffff81182611>] sys_unlink+0x11/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   266300 ms
Event count:                      69
git                  sleep_on_buffer        2773 ms
akregator            sleep_on_buffer        1957 ms
git                  sleep_on_buffer        1417 ms
imapd                sleep_on_buffer        9532 ms
imapd                sleep_on_buffer       57801 ms
pool                 sleep_on_buffer        7761 ms
imapd                sleep_on_buffer        1444 ms
patch                sleep_on_buffer        3872 ms
imapd                sleep_on_buffer        6422 ms
imapd                sleep_on_buffer        1748 ms
pool                 sleep_on_buffer       10552 ms
imapd                sleep_on_buffer       10114 ms
imapd                sleep_on_buffer        7575 ms
mutt                 sleep_on_buffer        3901 ms
bzip2                sleep_on_buffer        1104 ms
imapd                sleep_on_buffer        4983 ms
imapd                sleep_on_buffer        1746 ms
mutt                 sleep_on_buffer        1881 ms
imapd                sleep_on_buffer        1067 ms
imapd                sleep_on_buffer        1863 ms
imapd                sleep_on_buffer        1508 ms
imapd                sleep_on_buffer        1508 ms
offlineimap          sleep_on_buffer        1385 ms
imapd                sleep_on_buffer        1653 ms
imapd                sleep_on_buffer        1179 ms
imapd                sleep_on_buffer        3473 ms
imapd                sleep_on_buffer       10130 ms
vim                  sleep_on_buffer        1690 ms
imapd                sleep_on_buffer        3102 ms
dconf-service        sleep_on_buffer        5097 ms
imapd                sleep_on_buffer        2888 ms
cp                   sleep_on_buffer        1036 ms
imapd                sleep_on_buffer       22501 ms
rsync                sleep_on_buffer        5026 ms
imapd                sleep_on_buffer        2897 ms
rsync                sleep_on_buffer        1200 ms
akregator            sleep_on_buffer        4780 ms
Cache I/O            sleep_on_buffer        1433 ms
imapd                sleep_on_buffer        2588 ms
akregator            sleep_on_buffer        1576 ms
vi                   sleep_on_buffer        2086 ms
firefox              sleep_on_buffer        4718 ms
imapd                sleep_on_buffer        1158 ms
git                  sleep_on_buffer        2073 ms
git                  sleep_on_buffer        1017 ms
git                  sleep_on_buffer        1616 ms
git                  sleep_on_buffer        1043 ms
imapd                sleep_on_buffer        1746 ms
imapd                sleep_on_buffer        1007 ms
git                  sleep_on_buffer        1146 ms
git                  sleep_on_buffer        1916 ms
git                  sleep_on_buffer        1059 ms
git                  sleep_on_buffer        1801 ms
git                  sleep_on_buffer        1208 ms
git                  sleep_on_buffer        1486 ms
git                  sleep_on_buffer        1806 ms
git                  sleep_on_buffer        1295 ms
git                  sleep_on_buffer        1461 ms
git                  sleep_on_buffer        1371 ms
git                  sleep_on_buffer        2010 ms
git                  sleep_on_buffer        1622 ms
git                  sleep_on_buffer        1453 ms
git                  sleep_on_buffer        1392 ms
git                  sleep_on_buffer        1329 ms
git                  sleep_on_buffer        1773 ms
git                  sleep_on_buffer        1750 ms
git                  sleep_on_buffer        2354 ms
imapd                sleep_on_buffer        3201 ms
imapd                sleep_on_buffer        2240 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811ebe24>] __ext4_new_inode+0x294/0x10c0
[<ffffffff811fac5b>] ext4_create+0xbb/0x190
[<ffffffff81180aa5>] vfs_create+0xb5/0x120
[<ffffffff81180c4e>] lookup_open+0x13e/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   240174 ms
Event count:                      34
systemd-journal      sleep_on_buffer        1321 ms
systemd-journal      sleep_on_buffer        4851 ms
systemd-journal      sleep_on_buffer        3341 ms
systemd-journal      sleep_on_buffer       17219 ms
systemd-journal      sleep_on_buffer        3190 ms
systemd-journal      sleep_on_buffer       13420 ms
systemd-journal      sleep_on_buffer       23421 ms
systemd-journal      sleep_on_buffer        4987 ms
systemd-journal      sleep_on_buffer       16358 ms
systemd-journal      sleep_on_buffer        2734 ms
mozStorage #2        sleep_on_buffer        1454 ms
systemd-journal      sleep_on_buffer        4524 ms
mozStorage #2        sleep_on_buffer        1211 ms
systemd-journal      sleep_on_buffer        1711 ms
systemd-journal      sleep_on_buffer        2158 ms
mkdir                wait_on_page_bit_killable   1084 ms
systemd-journal      sleep_on_buffer        5673 ms
mozStorage #2        sleep_on_buffer        1800 ms
systemd-journal      sleep_on_buffer        5586 ms
mozStorage #2        sleep_on_buffer        3199 ms
nm-dhcp-client.      wait_on_page_bit_killable   1060 ms
mozStorage #2        sleep_on_buffer        6669 ms
systemd-journal      sleep_on_buffer        3603 ms
systemd-journal      sleep_on_buffer        7666 ms
systemd-journal      sleep_on_buffer       13961 ms
systemd-journal      sleep_on_buffer        9063 ms
systemd-journal      sleep_on_buffer        4120 ms
systemd-journal      sleep_on_buffer        3328 ms
systemd-journal      sleep_on_buffer       12093 ms
systemd-journal      sleep_on_buffer        5464 ms
systemd-journal      sleep_on_buffer       12649 ms
systemd-journal      sleep_on_buffer       23460 ms
systemd-journal      sleep_on_buffer       13123 ms
systemd-journal      sleep_on_buffer        4673 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b789>] update_time+0x79/0xc0
[<ffffffff8118b868>] file_update_time+0x98/0x100
[<ffffffff811f539c>] ext4_page_mkwrite+0x5c/0x470
[<ffffffff8113740e>] do_wp_page+0x5ce/0x7d0
[<ffffffff81139598>] handle_pte_fault+0x1c8/0x200
[<ffffffff8113a731>] handle_mm_fault+0x271/0x390
[<ffffffff81597959>] __do_page_fault+0x169/0x520
[<ffffffff81597d19>] do_page_fault+0x9/0x10
[<ffffffff81594488>] page_fault+0x28/0x30
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   212304 ms
Event count:                      41
pool                 sleep_on_buffer        1216 ms
pool                 sleep_on_buffer       36361 ms
cp                   sleep_on_buffer        5034 ms
git                  sleep_on_buffer        2344 ms
gnuplot              sleep_on_buffer        1733 ms
gnuplot              sleep_on_buffer        2303 ms
gnuplot              sleep_on_buffer        1982 ms
gnuplot              sleep_on_buffer        2491 ms
gnuplot              sleep_on_buffer        1520 ms
gnuplot              sleep_on_buffer        1209 ms
gnuplot              sleep_on_buffer        1188 ms
gnuplot              sleep_on_buffer        1654 ms
gnuplot              sleep_on_buffer        1403 ms
gnuplot              sleep_on_buffer        1386 ms
gnuplot              sleep_on_buffer        1899 ms
gnuplot              sleep_on_buffer        2673 ms
gnuplot              sleep_on_buffer        2158 ms
gnuplot              sleep_on_buffer        1780 ms
gnuplot              sleep_on_buffer        1624 ms
gnuplot              sleep_on_buffer        1704 ms
gnuplot              sleep_on_buffer        2207 ms
gnuplot              sleep_on_buffer        2557 ms
gnuplot              sleep_on_buffer        1692 ms
gnuplot              sleep_on_buffer        1686 ms
gnuplot              sleep_on_buffer        1258 ms
offlineimap          sleep_on_buffer        1217 ms
pool                 sleep_on_buffer       13434 ms
offlineimap          sleep_on_buffer       30091 ms
offlineimap          sleep_on_buffer        9048 ms
offlineimap          sleep_on_buffer       13754 ms
offlineimap          sleep_on_buffer       36560 ms
offlineimap          sleep_on_buffer        1465 ms
cp                   sleep_on_buffer        1525 ms
cp                   sleep_on_buffer        2193 ms
DOM Worker           sleep_on_buffer        5563 ms
DOM Worker           sleep_on_buffer        3597 ms
cp                   sleep_on_buffer        1261 ms
git                  sleep_on_buffer        1427 ms
git                  sleep_on_buffer        1097 ms
git                  sleep_on_buffer        1232 ms
offlineimap          sleep_on_buffer        5778 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811f96f9>] ext4_lookup.part.31+0x29/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff81180bd8>] lookup_open+0xc8/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   211510 ms
Event count:                      20
flush-8:0            sleep_on_buffer       29387 ms
flush-8:0            sleep_on_buffer        2159 ms
flush-8:0            sleep_on_buffer        8593 ms
flush-8:0            sleep_on_buffer        3143 ms
flush-8:0            sleep_on_buffer        4641 ms
flush-8:0            sleep_on_buffer       17279 ms
flush-8:0            sleep_on_buffer        2210 ms
flush-8:0            sleep_on_buffer       15948 ms
flush-8:0            sleep_on_buffer        4686 ms
flush-8:0            sleep_on_buffer        7027 ms
flush-8:0            sleep_on_buffer       17871 ms
flush-8:0            sleep_on_buffer        3262 ms
flush-8:0            sleep_on_buffer        7311 ms
flush-8:0            sleep_on_buffer       11255 ms
flush-8:0            sleep_on_buffer        5693 ms
flush-8:0            sleep_on_buffer        8628 ms
flush-8:0            sleep_on_buffer       10917 ms
flush-8:0            sleep_on_buffer       17497 ms
flush-8:0            sleep_on_buffer       15750 ms
flush-8:0            sleep_on_buffer       18253 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff8121a8f2>] ext4_ext_get_access.isra.39+0x22/0x30
[<ffffffff8121d506>] ext4_split_extent_at+0xb6/0x390
[<ffffffff8121e038>] ext4_split_extent.isra.47+0x108/0x130
[<ffffffff8121e3ae>] ext4_ext_convert_to_initialized+0x15e/0x590
[<ffffffff8121ee7b>] ext4_ext_handle_uninitialized_extents+0x2fb/0x3c0
[<ffffffff8121f547>] ext4_ext_map_blocks+0x5d7/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   201192 ms
Event count:                      23
imapd                sleep_on_buffer        3770 ms
imapd                sleep_on_buffer       37050 ms
make                 sleep_on_buffer        5342 ms
compare-mmtests      sleep_on_buffer        1774 ms
scp                  sleep_on_buffer        2478 ms
scp                  sleep_on_buffer        2368 ms
imapd                sleep_on_buffer        3163 ms
pool                 sleep_on_buffer        2033 ms
imapd                sleep_on_buffer        1311 ms
imapd                sleep_on_buffer       11011 ms
imapd                sleep_on_buffer        1345 ms
imapd                sleep_on_buffer       20545 ms
imapd                sleep_on_buffer       19511 ms
imapd                sleep_on_buffer       20863 ms
imapd                sleep_on_buffer       32313 ms
imapd                sleep_on_buffer        6984 ms
imapd                sleep_on_buffer        8152 ms
imapd                sleep_on_buffer        3038 ms
imapd                sleep_on_buffer        8032 ms
imapd                sleep_on_buffer        3649 ms
imapd                sleep_on_buffer        2195 ms
imapd                sleep_on_buffer        1848 ms
mv                   sleep_on_buffer        2417 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811f96f9>] ext4_lookup.part.31+0x29/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117efb2>] path_lookupat+0x222/0x780
[<ffffffff8117f53f>] filename_lookup+0x2f/0xc0
[<ffffffff81182074>] user_path_at_empty+0x54/0xa0
[<ffffffff811820cc>] user_path_at+0xc/0x10
[<ffffffff81177b39>] vfs_fstatat+0x49/0xa0
[<ffffffff81177bc6>] vfs_stat+0x16/0x20
[<ffffffff81177ce5>] sys_newstat+0x15/0x30
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   169878 ms
Event count:                      56
git                  wait_on_page_bit       8573 ms
git                  wait_on_page_bit       2986 ms
git                  wait_on_page_bit       1811 ms
git                  wait_on_page_bit       2623 ms
git                  wait_on_page_bit       1419 ms
git                  wait_on_page_bit       1244 ms
git                  wait_on_page_bit       1134 ms
git                  wait_on_page_bit       5825 ms
git                  wait_on_page_bit       3567 ms
git                  wait_on_page_bit       1119 ms
git                  wait_on_page_bit       1375 ms
git                  wait_on_page_bit       3726 ms
git                  wait_on_page_bit       2670 ms
git                  wait_on_page_bit       4141 ms
git                  wait_on_page_bit       3858 ms
git                  wait_on_page_bit       6684 ms
git                  wait_on_page_bit       5355 ms
gen-report.sh        wait_on_page_bit       4747 ms
git                  wait_on_page_bit       6752 ms
git                  wait_on_page_bit       1229 ms
git                  wait_on_page_bit       4409 ms
git                  wait_on_page_bit       3101 ms
git                  wait_on_page_bit       1817 ms
git                  wait_on_page_bit       1687 ms
git                  wait_on_page_bit       3683 ms
git                  wait_on_page_bit       2031 ms
git                  wait_on_page_bit       2138 ms
git                  wait_on_page_bit       1513 ms
git                  wait_on_page_bit       1804 ms
git                  wait_on_page_bit       2559 ms
git                  wait_on_page_bit       7958 ms
git                  wait_on_page_bit       6265 ms
git                  wait_on_page_bit       1261 ms
git                  wait_on_page_bit       4018 ms
git                  wait_on_page_bit       1450 ms
git                  wait_on_page_bit       1821 ms
git                  wait_on_page_bit       3186 ms
git                  wait_on_page_bit       1513 ms
git                  wait_on_page_bit       3215 ms
git                  wait_on_page_bit       1262 ms
git                  wait_on_page_bit       8188 ms
git                  sleep_on_buffer        1019 ms
git                  wait_on_page_bit       5233 ms
git                  wait_on_page_bit       1842 ms
git                  wait_on_page_bit       1378 ms
git                  wait_on_page_bit       1386 ms
git                  wait_on_page_bit       2016 ms
git                  wait_on_page_bit       1901 ms
git                  wait_on_page_bit       2750 ms
git                  sleep_on_buffer        1152 ms
git                  wait_on_page_bit       1169 ms
git                  wait_on_page_bit       1371 ms
git                  wait_on_page_bit       1916 ms
git                  wait_on_page_bit       1630 ms
git                  wait_on_page_bit       8286 ms
git                  wait_on_page_bit       1112 ms
[<ffffffff8110f0e0>] wait_on_page_bit+0x70/0x80
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff8111d620>] truncate_inode_pages+0x10/0x20
[<ffffffff8111d677>] truncate_pagecache+0x47/0x70
[<ffffffff811f2f4d>] ext4_setattr+0x17d/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff8117d186>] handle_truncate+0x66/0xa0
[<ffffffff81181306>] do_last+0x626/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   167244 ms
Event count:                     118
folder-markup.s      sleep_on_buffer        2055 ms
folder-markup.s      sleep_on_buffer        3917 ms
mv                   sleep_on_buffer        1025 ms
folder-markup.s      sleep_on_buffer        1670 ms
folder-markup.s      sleep_on_buffer        1144 ms
folder-markup.s      sleep_on_buffer        1063 ms
folder-markup.s      sleep_on_buffer        1385 ms
folder-markup.s      sleep_on_buffer        1753 ms
folder-markup.s      sleep_on_buffer        1351 ms
folder-markup.s      sleep_on_buffer        1143 ms
folder-markup.s      sleep_on_buffer        1581 ms
folder-markup.s      sleep_on_buffer        1747 ms
folder-markup.s      sleep_on_buffer        1241 ms
folder-markup.s      sleep_on_buffer        1419 ms
folder-markup.s      sleep_on_buffer        1429 ms
folder-markup.s      sleep_on_buffer        1112 ms
git                  sleep_on_buffer        1190 ms
git                  sleep_on_buffer        1190 ms
git                  sleep_on_buffer        1050 ms
git                  sleep_on_buffer        1463 ms
git                  sleep_on_buffer        1376 ms
folder-markup.s      sleep_on_buffer        1481 ms
folder-markup.s      sleep_on_buffer        1424 ms
folder-markup.s      sleep_on_buffer        1633 ms
folder-markup.s      sleep_on_buffer        1012 ms
folder-markup.s      sleep_on_buffer        1706 ms
folder-markup.s      sleep_on_buffer        1246 ms
folder-markup.s      sleep_on_buffer        1275 ms
git                  sleep_on_buffer        1484 ms
git                  sleep_on_buffer        1216 ms
git                  sleep_on_buffer        1065 ms
git                  sleep_on_buffer        1455 ms
folder-markup.s      sleep_on_buffer        1063 ms
folder-markup.s      sleep_on_buffer        3059 ms
folder-markup.s      sleep_on_buffer        1140 ms
folder-markup.s      sleep_on_buffer        1353 ms
mv                   sleep_on_buffer        1050 ms
folder-markup.s      sleep_on_buffer        1209 ms
git                  sleep_on_buffer        1341 ms
scp                  sleep_on_buffer        4975 ms
folder-markup.s      sleep_on_buffer        1743 ms
folder-markup.s      sleep_on_buffer        1280 ms
folder-markup.s      sleep_on_buffer        2140 ms
folder-markup.s      sleep_on_buffer        1138 ms
folder-markup.s      sleep_on_buffer        1140 ms
folder-markup.s      sleep_on_buffer        1162 ms
folder-markup.s      sleep_on_buffer        1023 ms
git                  sleep_on_buffer        2174 ms
git                  sleep_on_buffer        1306 ms
git                  sleep_on_buffer        1224 ms
git                  sleep_on_buffer        1359 ms
git                  sleep_on_buffer        1551 ms
git                  sleep_on_buffer        1068 ms
git                  sleep_on_buffer        1367 ms
git                  sleep_on_buffer        1292 ms
git                  sleep_on_buffer        1369 ms
git                  sleep_on_buffer        1554 ms
git                  sleep_on_buffer        1273 ms
git                  sleep_on_buffer        1365 ms
mv                   sleep_on_buffer        1107 ms
folder-markup.s      sleep_on_buffer        1519 ms
folder-markup.s      sleep_on_buffer        1253 ms
folder-markup.s      sleep_on_buffer        1195 ms
mv                   sleep_on_buffer        1091 ms
git                  sleep_on_buffer        1147 ms
git                  sleep_on_buffer        1271 ms
git                  sleep_on_buffer        1056 ms
git                  sleep_on_buffer        1134 ms
git                  sleep_on_buffer        1252 ms
git                  sleep_on_buffer        1352 ms
git                  sleep_on_buffer        1449 ms
folder-markup.s      sleep_on_buffer        1732 ms
folder-markup.s      sleep_on_buffer        1332 ms
folder-markup.s      sleep_on_buffer        1450 ms
git                  sleep_on_buffer        1102 ms
git                  sleep_on_buffer        1771 ms
git                  sleep_on_buffer        1225 ms
git                  sleep_on_buffer        1089 ms
git                  sleep_on_buffer        1083 ms
folder-markup.s      sleep_on_buffer        1071 ms
folder-markup.s      sleep_on_buffer        1186 ms
folder-markup.s      sleep_on_buffer        1170 ms
git                  sleep_on_buffer        1249 ms
git                  sleep_on_buffer        1255 ms
folder-markup.s      sleep_on_buffer        1563 ms
folder-markup.s      sleep_on_buffer        1258 ms
git                  sleep_on_buffer        2066 ms
git                  sleep_on_buffer        1493 ms
git                  sleep_on_buffer        1515 ms
git                  sleep_on_buffer        1380 ms
git                  sleep_on_buffer        1238 ms
git                  sleep_on_buffer        1393 ms
git                  sleep_on_buffer        1040 ms
git                  sleep_on_buffer        1986 ms
git                  sleep_on_buffer        1293 ms
git                  sleep_on_buffer        1209 ms
git                  sleep_on_buffer        1098 ms
git                  sleep_on_buffer        1091 ms
git                  sleep_on_buffer        1701 ms
git                  sleep_on_buffer        2237 ms
git                  sleep_on_buffer        1810 ms
folder-markup.s      sleep_on_buffer        1166 ms
folder-markup.s      sleep_on_buffer        2064 ms
folder-markup.s      sleep_on_buffer        1285 ms
folder-markup.s      sleep_on_buffer        1129 ms
folder-markup.s      sleep_on_buffer        1080 ms
git                  sleep_on_buffer        1277 ms
git                  sleep_on_buffer        1280 ms
folder-markup.s      sleep_on_buffer        1298 ms
folder-markup.s      sleep_on_buffer        1355 ms
folder-markup.s      sleep_on_buffer        1043 ms
folder-markup.s      sleep_on_buffer        1204 ms
git                  sleep_on_buffer        1068 ms
git                  sleep_on_buffer        1654 ms
git                  sleep_on_buffer        1380 ms
git                  sleep_on_buffer        1289 ms
git                  sleep_on_buffer        1442 ms
git                  sleep_on_buffer        1299 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f9dd2>] ext4_dx_add_entry+0xc2/0x590
[<ffffffff811fa925>] ext4_add_entry+0x265/0x2d0
[<ffffffff811fa9b6>] ext4_add_nondir+0x26/0x80
[<ffffffff811fac9f>] ext4_create+0xff/0x190
[<ffffffff81180aa5>] vfs_create+0xb5/0x120
[<ffffffff81180c4e>] lookup_open+0x13e/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   135113 ms
Event count:                     116
flush-8:16           get_request            1274 ms
flush-8:16           get_request            1098 ms
flush-8:16           get_request            1079 ms
flush-8:16           get_request            1234 ms
flush-8:16           get_request            1229 ms
flush-8:16           get_request            1056 ms
flush-8:16           get_request            1096 ms
flush-8:16           get_request            1092 ms
flush-8:16           get_request            1099 ms
flush-8:16           get_request            1057 ms
flush-8:16           get_request            1103 ms
flush-8:16           get_request            1207 ms
flush-8:16           get_request            1087 ms
flush-8:16           get_request            1060 ms
flush-8:16           get_request            1080 ms
flush-8:16           get_request            1196 ms
flush-8:16           get_request            1453 ms
flush-8:16           get_request            1084 ms
flush-8:16           get_request            1051 ms
flush-8:16           get_request            1084 ms
flush-8:16           get_request            1132 ms
flush-8:16           get_request            1164 ms
flush-8:16           get_request            1063 ms
flush-8:16           get_request            1221 ms
flush-8:16           get_request            1074 ms
flush-8:16           get_request            1099 ms
flush-8:16           get_request            1077 ms
flush-8:16           get_request            1243 ms
flush-8:16           get_request            1080 ms
flush-8:16           get_request            1078 ms
flush-8:16           get_request            1101 ms
flush-8:16           get_request            1080 ms
flush-8:16           get_request            1056 ms
flush-8:16           get_request            1333 ms
flush-8:16           get_request            1103 ms
flush-8:16           get_request            1216 ms
flush-8:16           get_request            1108 ms
flush-8:16           get_request            1109 ms
flush-8:16           get_request            1113 ms
flush-8:16           get_request            1349 ms
flush-8:16           get_request            1086 ms
flush-8:16           get_request            1070 ms
flush-8:16           get_request            1064 ms
flush-8:16           get_request            1091 ms
flush-8:16           get_request            1064 ms
flush-8:16           get_request            1222 ms
flush-8:16           get_request            1103 ms
flush-8:16           get_request            1434 ms
flush-8:16           get_request            1124 ms
flush-8:16           get_request            1359 ms
flush-8:16           get_request            1060 ms
flush-8:16           get_request            1057 ms
flush-8:16           get_request            1066 ms
flush-8:16           get_request            1357 ms
flush-8:16           get_request            1089 ms
flush-8:16           get_request            1071 ms
flush-8:16           get_request            1196 ms
flush-8:16           get_request            1091 ms
flush-8:16           get_request            1203 ms
flush-8:16           get_request            1100 ms
flush-8:16           get_request            1208 ms
flush-8:16           get_request            1113 ms
flush-8:16           get_request            1260 ms
flush-8:16           get_request            1480 ms
flush-8:16           get_request            1054 ms
flush-8:16           get_request            1211 ms
flush-8:16           get_request            1101 ms
flush-8:16           get_request            1098 ms
flush-8:16           get_request            1190 ms
flush-8:16           get_request            1046 ms
flush-8:16           get_request            1066 ms
flush-8:16           get_request            1204 ms
flush-8:16           get_request            1076 ms
flush-8:16           get_request            1094 ms
flush-8:16           get_request            1094 ms
flush-8:16           get_request            1081 ms
flush-8:16           get_request            1080 ms
flush-8:16           get_request            1193 ms
flush-8:16           get_request            1066 ms
flush-8:16           get_request            1069 ms
flush-8:16           get_request            1081 ms
flush-8:16           get_request            1107 ms
flush-8:16           get_request            1375 ms
flush-8:16           get_request            1080 ms
flush-8:16           get_request            1068 ms
flush-8:16           get_request            1077 ms
flush-8:16           get_request            1108 ms
flush-8:16           get_request            1080 ms
flush-8:16           get_request            1098 ms
flush-8:16           get_request            1063 ms
flush-8:16           get_request            1074 ms
flush-8:16           get_request            1072 ms
flush-8:16           get_request            1038 ms
flush-8:16           get_request            1058 ms
flush-8:16           get_request            1202 ms
flush-8:16           get_request            1359 ms
flush-8:16           get_request            1190 ms
flush-8:16           get_request            1497 ms
flush-8:16           get_request            2173 ms
flush-8:16           get_request            1199 ms
flush-8:16           get_request            1358 ms
flush-8:16           get_request            1384 ms
flush-8:16           get_request            1355 ms
flush-8:16           get_request            1327 ms
flush-8:16           get_request            1312 ms
flush-8:16           get_request            1318 ms
flush-8:16           get_request            1093 ms
flush-8:16           get_request            1265 ms
flush-8:16           get_request            1155 ms
flush-8:16           get_request            1107 ms
flush-8:16           get_request            1263 ms
flush-8:16           get_request            1104 ms
flush-8:16           get_request            1122 ms
flush-8:16           get_request            1578 ms
flush-8:16           get_request            1089 ms
flush-8:16           get_request            1075 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff812a4b1f>] generic_make_request.part.59+0x6f/0xa0
[<ffffffff812a5050>] generic_make_request+0x60/0x70
[<ffffffff812a50c7>] submit_bio+0x67/0x130
[<ffffffff811f6014>] ext4_io_submit+0x24/0x60
[<ffffffff811f2265>] ext4_writepage+0x135/0x220
[<ffffffff81119292>] __writepage+0x12/0x40
[<ffffffff81119a96>] write_cache_pages+0x206/0x460
[<ffffffff81119d35>] generic_writepages+0x45/0x70
[<ffffffff8111ac15>] do_writepages+0x25/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   115939 ms
Event count:                      23
bash                 sleep_on_buffer        3076 ms
du                   sleep_on_buffer        2364 ms
du                   sleep_on_buffer        1515 ms
git                  sleep_on_buffer        1706 ms
rm                   sleep_on_buffer       10595 ms
find                 sleep_on_buffer        2048 ms
rm                   sleep_on_buffer        9146 ms
rm                   sleep_on_buffer        8220 ms
rm                   sleep_on_buffer        6080 ms
cp                   sleep_on_buffer        6302 ms
ls                   sleep_on_buffer        1225 ms
cp                   sleep_on_buffer        6279 ms
cp                   sleep_on_buffer        1164 ms
cp                   sleep_on_buffer        3365 ms
cp                   sleep_on_buffer        2191 ms
cp                   sleep_on_buffer        1367 ms
du                   sleep_on_buffer        4155 ms
cp                   sleep_on_buffer        3906 ms
cp                   sleep_on_buffer        4758 ms
rsync                sleep_on_buffer        6575 ms
git                  sleep_on_buffer        1688 ms
git                  sleep_on_buffer       26470 ms
git                  sleep_on_buffer        1744 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b789>] update_time+0x79/0xc0
[<ffffffff8118ba31>] touch_atime+0x161/0x170
[<ffffffff811849b2>] vfs_readdir+0xc2/0xe0
[<ffffffff81184ae9>] sys_getdents+0x89/0x110
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:   101122 ms
Event count:                      18
flush-8:0            sleep_on_buffer       21732 ms
flush-8:0            sleep_on_buffer        2211 ms
flush-8:0            sleep_on_buffer        1480 ms
flush-8:0            sleep_on_buffer       16292 ms
flush-8:0            sleep_on_buffer        2975 ms
flush-8:0            sleep_on_buffer        7025 ms
flush-8:0            sleep_on_buffer        5535 ms
flush-8:0            sleep_on_buffer        1885 ms
flush-8:0            sleep_on_buffer        1329 ms
flush-8:0            sleep_on_buffer        1374 ms
flush-8:0            sleep_on_buffer        1490 ms
flush-8:0            sleep_on_buffer       16341 ms
flush-8:0            sleep_on_buffer       14939 ms
flush-8:0            sleep_on_buffer        1202 ms
flush-8:0            sleep_on_buffer        1262 ms
flush-8:0            sleep_on_buffer        1121 ms
flush-8:0            sleep_on_buffer        1571 ms
flush-8:0            sleep_on_buffer        1358 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff8121a8f2>] ext4_ext_get_access.isra.39+0x22/0x30
[<ffffffff8121d506>] ext4_split_extent_at+0xb6/0x390
[<ffffffff8121e038>] ext4_split_extent.isra.47+0x108/0x130
[<ffffffff8121e3ae>] ext4_ext_convert_to_initialized+0x15e/0x590
[<ffffffff8121ee7b>] ext4_ext_handle_uninitialized_extents+0x2fb/0x3c0
[<ffffffff8121f547>] ext4_ext_map_blocks+0x5d7/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    98613 ms
Event count:                       8
git                  sleep_on_buffer       14529 ms
git                  sleep_on_buffer        4477 ms
git                  sleep_on_buffer       10045 ms
git                  sleep_on_buffer       11068 ms
git                  sleep_on_buffer       18777 ms
git                  sleep_on_buffer        9434 ms
git                  sleep_on_buffer       12262 ms
git                  sleep_on_buffer       18021 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f4e95>] ext4_evict_inode+0x1e5/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff81187248>] dentry_iput+0x98/0xe0
[<ffffffff81188ac8>] dput+0x128/0x230
[<ffffffff81182c4a>] sys_renameat+0x33a/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    94944 ms
Event count:                      11
git                  sleep_on_buffer       16110 ms
git                  sleep_on_buffer        6508 ms
git                  sleep_on_buffer       23186 ms
git                  sleep_on_buffer       25228 ms
git-merge            sleep_on_buffer        1672 ms
konqueror            sleep_on_buffer        1411 ms
git                  sleep_on_buffer        1803 ms
git                  sleep_on_buffer       15397 ms
git                  sleep_on_buffer        1276 ms
git                  sleep_on_buffer        1012 ms
git                  sleep_on_buffer        1341 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811fc3e1>] ext4_unlink+0x41/0x350
[<ffffffff8117daef>] vfs_unlink.part.31+0x7f/0xe0
[<ffffffff8117f9d7>] vfs_unlink+0x37/0x50
[<ffffffff8117fbff>] do_unlinkat+0x20f/0x260
[<ffffffff81182611>] sys_unlink+0x11/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    93658 ms
Event count:                      26
flush-8:0            sleep_on_buffer        1294 ms
flush-8:0            sleep_on_buffer        2856 ms
flush-8:0            sleep_on_buffer        3764 ms
flush-8:0            sleep_on_buffer        5086 ms
flush-8:0            sleep_on_buffer        1203 ms
flush-8:0            sleep_on_buffer        1289 ms
flush-8:0            sleep_on_buffer        1264 ms
flush-8:0            sleep_on_buffer        1252 ms
flush-8:0            sleep_on_buffer        2997 ms
flush-8:0            sleep_on_buffer        2765 ms
flush-8:0            sleep_on_buffer        4235 ms
flush-8:0            sleep_on_buffer        5205 ms
flush-8:0            sleep_on_buffer        6971 ms
flush-8:0            sleep_on_buffer        4155 ms
ps                   wait_on_page_bit_killable   1054 ms
flush-8:0            sleep_on_buffer        3719 ms
flush-8:0            sleep_on_buffer       10283 ms
flush-8:0            sleep_on_buffer        3068 ms
flush-8:0            sleep_on_buffer        2000 ms
flush-8:0            sleep_on_buffer        2264 ms
flush-8:0            sleep_on_buffer        3623 ms
flush-8:0            sleep_on_buffer       12954 ms
flush-8:0            sleep_on_buffer        6579 ms
flush-8:0            sleep_on_buffer        1245 ms
flush-8:0            sleep_on_buffer        1293 ms
flush-8:0            sleep_on_buffer        1240 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227556>] ext4_mb_mark_diskspace_used+0x76/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    92353 ms
Event count:                      11
flush-8:0            sleep_on_buffer        2192 ms
flush-8:0            sleep_on_buffer        2088 ms
flush-8:0            sleep_on_buffer        1460 ms
flush-8:0            sleep_on_buffer        1241 ms
flush-8:0            sleep_on_buffer        1986 ms
flush-8:0            sleep_on_buffer        1331 ms
flush-8:0            sleep_on_buffer        2192 ms
flush-8:0            sleep_on_buffer        3327 ms
flush-8:0            sleep_on_buffer       73408 ms
flush-8:0            sleep_on_buffer        1229 ms
flush-253:0          sleep_on_buffer        1899 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227556>] ext4_mb_mark_diskspace_used+0x76/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    91515 ms
Event count:                       7
flush-8:0            sleep_on_buffer        7128 ms
flush-8:0            sleep_on_buffer       18731 ms
flush-8:0            sleep_on_buffer       12643 ms
flush-8:0            sleep_on_buffer       28149 ms
flush-8:0            sleep_on_buffer        5728 ms
flush-8:0            sleep_on_buffer       18040 ms
git                  wait_on_page_bit       1096 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff8121a8f2>] ext4_ext_get_access.isra.39+0x22/0x30
[<ffffffff8121e658>] ext4_ext_convert_to_initialized+0x408/0x590
[<ffffffff8121ee7b>] ext4_ext_handle_uninitialized_extents+0x2fb/0x3c0
[<ffffffff8121f547>] ext4_ext_map_blocks+0x5d7/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4601>] write_cache_pages_da+0x421/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    86251 ms
Event count:                      76
imapd                wait_on_page_bit_killable   1088 ms
imapd                wait_on_page_bit_killable   1092 ms
git                  wait_on_page_bit_killable   1616 ms
git                  wait_on_page_bit_killable   1114 ms
play                 wait_on_page_bit_killable   1019 ms
play                 wait_on_page_bit_killable   1012 ms
play                 wait_on_page_bit_killable   1223 ms
play                 wait_on_page_bit_killable   1223 ms
play                 wait_on_page_bit_killable   1034 ms
play                 wait_on_page_bit_killable   1034 ms
play                 wait_on_page_bit_killable   1096 ms
play                 wait_on_page_bit_killable   1096 ms
play                 wait_on_page_bit_killable   1093 ms
play                 wait_on_page_bit_killable   1093 ms
vim                  wait_on_page_bit_killable   1084 ms
dbus-daemon-lau      wait_on_page_bit_killable   1076 ms
play                 wait_on_page_bit_killable   1097 ms
play                 wait_on_page_bit_killable   1097 ms
git                  wait_on_page_bit_killable   1005 ms
systemd-journal      wait_on_page_bit_killable   1252 ms
systemd-journal      wait_on_page_bit_killable   1158 ms
git                  wait_on_page_bit_killable   1237 ms
git                  wait_on_page_bit_killable   1043 ms
git                  wait_on_page_bit_killable   1068 ms
git                  wait_on_page_bit_killable   1070 ms
git                  wait_on_page_bit_killable   1070 ms
git                  wait_on_page_bit_killable   1097 ms
git                  wait_on_page_bit_killable   1055 ms
git                  wait_on_page_bit_killable   1252 ms
git                  wait_on_page_bit_killable   1187 ms
git                  wait_on_page_bit_killable   1069 ms
git                  wait_on_page_bit_killable   1194 ms
git                  wait_on_page_bit_killable   1035 ms
git                  wait_on_page_bit_killable   1046 ms
git                  wait_on_page_bit_killable   1024 ms
git                  wait_on_page_bit_killable   1124 ms
git                  wait_on_page_bit_killable   1293 ms
git                  wait_on_page_bit_killable   1184 ms
git                  wait_on_page_bit_killable   1269 ms
git                  wait_on_page_bit_killable   1268 ms
git                  wait_on_page_bit_killable   1088 ms
git                  wait_on_page_bit_killable   1093 ms
git                  wait_on_page_bit_killable   1013 ms
git                  wait_on_page_bit_killable   1034 ms
git                  wait_on_page_bit_killable   1018 ms
git                  wait_on_page_bit_killable   1185 ms
git                  wait_on_page_bit_killable   1258 ms
git                  wait_on_page_bit_killable   1006 ms
git                  wait_on_page_bit_killable   1061 ms
git                  wait_on_page_bit_killable   1108 ms
git                  wait_on_page_bit_killable   1006 ms
git                  wait_on_page_bit_killable   1012 ms
git                  wait_on_page_bit_killable   1210 ms
git                  wait_on_page_bit_killable   1239 ms
git                  wait_on_page_bit_killable   1146 ms
git                  wait_on_page_bit_killable   1106 ms
git                  wait_on_page_bit_killable   1063 ms
git                  wait_on_page_bit_killable   1070 ms
git                  wait_on_page_bit_killable   1041 ms
git                  wait_on_page_bit_killable   1052 ms
git                  wait_on_page_bit_killable   1237 ms
git                  wait_on_page_bit_killable   1117 ms
git                  wait_on_page_bit_killable   1086 ms
git                  wait_on_page_bit_killable   1051 ms
git                  wait_on_page_bit_killable   1029 ms
runlevel             wait_on_page_bit_killable   1019 ms
evolution            wait_on_page_bit_killable   1384 ms
evolution            wait_on_page_bit_killable   1144 ms
firefox              wait_on_page_bit_killable   1537 ms
git                  wait_on_page_bit_killable   1017 ms
evolution            wait_on_page_bit_killable   1015 ms
evolution            wait_on_page_bit_killable   1523 ms
ps                   wait_on_page_bit_killable   1394 ms
kio_http             wait_on_page_bit_killable   1010 ms
plugin-containe      wait_on_page_bit_killable   1522 ms
qmmp                 wait_on_page_bit_killable   1170 ms
[<ffffffff811115c8>] wait_on_page_bit_killable+0x78/0x80
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff81111a78>] filemap_fault+0x3d8/0x410
[<ffffffff8113599a>] __do_fault+0x6a/0x530
[<ffffffff811394be>] handle_pte_fault+0xee/0x200
[<ffffffff8113a731>] handle_mm_fault+0x271/0x390
[<ffffffff81597959>] __do_page_fault+0x169/0x520
[<ffffffff81597d19>] do_page_fault+0x9/0x10
[<ffffffff81594488>] page_fault+0x28/0x30
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    78888 ms
Event count:                      10
git                  sleep_on_buffer        1019 ms
git                  sleep_on_buffer        2031 ms
git                  sleep_on_buffer        2109 ms
git                  sleep_on_buffer        5858 ms
git                  sleep_on_buffer       15181 ms
git                  sleep_on_buffer       22771 ms
git                  sleep_on_buffer        2331 ms
git                  sleep_on_buffer        1341 ms
git                  sleep_on_buffer       24648 ms
git                  sleep_on_buffer        1599 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fb052>] ext4_delete_entry+0x62/0x120
[<ffffffff811fc495>] ext4_unlink+0xf5/0x350
[<ffffffff8117daef>] vfs_unlink.part.31+0x7f/0xe0
[<ffffffff8117f9d7>] vfs_unlink+0x37/0x50
[<ffffffff8117fbff>] do_unlinkat+0x20f/0x260
[<ffffffff81182611>] sys_unlink+0x11/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    77568 ms
Event count:                      12
git                  sleep_on_buffer        2592 ms
git                  sleep_on_buffer        1312 ms
git                  sleep_on_buffer        1974 ms
git                  sleep_on_buffer        2508 ms
git                  sleep_on_buffer        1245 ms
git                  sleep_on_buffer       20990 ms
git                  sleep_on_buffer       14782 ms
git                  sleep_on_buffer        2026 ms
git                  sleep_on_buffer        1880 ms
git                  sleep_on_buffer        2174 ms
git                  sleep_on_buffer       24451 ms
git                  sleep_on_buffer        1634 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811fc633>] ext4_unlink+0x293/0x350
[<ffffffff8117daef>] vfs_unlink.part.31+0x7f/0xe0
[<ffffffff8117f9d7>] vfs_unlink+0x37/0x50
[<ffffffff8117fbff>] do_unlinkat+0x20f/0x260
[<ffffffff81182611>] sys_unlink+0x11/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    73950 ms
Event count:                      21
pool                 wait_on_page_bit       5626 ms
git                  sleep_on_buffer        1077 ms
pool                 wait_on_page_bit       1040 ms
offlineimap          wait_on_page_bit       1083 ms
pool                 wait_on_page_bit       1044 ms
pool                 wait_on_page_bit       7268 ms
pool                 wait_on_page_bit       9900 ms
pool                 wait_on_page_bit       3530 ms
offlineimap          wait_on_page_bit      18212 ms
git                  wait_on_page_bit       1101 ms
git                  wait_on_page_bit       1402 ms
git                  sleep_on_buffer        1037 ms
pool                 wait_on_page_bit       1107 ms
git                  sleep_on_buffer        1106 ms
pool                 wait_on_page_bit      11643 ms
pool                 wait_on_page_bit       1272 ms
evolution            wait_on_page_bit       1471 ms
pool                 wait_on_page_bit       1458 ms
pool                 wait_on_page_bit       1331 ms
git                  sleep_on_buffer        1082 ms
offlineimap          wait_on_page_bit       1160 ms
[<ffffffff8110f0e0>] wait_on_page_bit+0x70/0x80
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff81110c50>] filemap_write_and_wait_range+0x60/0x70
[<ffffffff811ea54a>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    70700 ms
Event count:                      27
flush-8:0            sleep_on_buffer        1735 ms
flush-8:0            sleep_on_buffer        1720 ms
flush-8:0            sleep_on_buffer        3099 ms
flush-8:0            sleep_on_buffer        1321 ms
flush-8:0            sleep_on_buffer        3276 ms
flush-8:0            sleep_on_buffer        4215 ms
flush-8:0            sleep_on_buffer        1412 ms
flush-8:0            sleep_on_buffer        1049 ms
flush-8:0            sleep_on_buffer        2320 ms
flush-8:0            sleep_on_buffer        8076 ms
flush-8:0            sleep_on_buffer        2210 ms
flush-8:0            sleep_on_buffer        1204 ms
flush-8:0            sleep_on_buffer        1262 ms
flush-8:0            sleep_on_buffer        1995 ms
flush-8:0            sleep_on_buffer        1675 ms
flush-8:0            sleep_on_buffer        4219 ms
flush-8:0            sleep_on_buffer        4027 ms
flush-8:0            sleep_on_buffer        3452 ms
flush-8:0            sleep_on_buffer        6020 ms
flush-8:0            sleep_on_buffer        1318 ms
flush-8:0            sleep_on_buffer        1065 ms
flush-8:0            sleep_on_buffer        1148 ms
flush-8:0            sleep_on_buffer        1230 ms
flush-8:0            sleep_on_buffer        4479 ms
flush-8:0            sleep_on_buffer        1580 ms
flush-8:0            sleep_on_buffer        4551 ms
git                  sleep_on_buffer        1042 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff8121a97b>] __ext4_ext_dirty.isra.40+0x7b/0x80
[<ffffffff8121d34a>] ext4_ext_insert_extent+0x31a/0x420
[<ffffffff8121f60a>] ext4_ext_map_blocks+0x69a/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    59807 ms
Event count:                      37
mv                   sleep_on_buffer        1439 ms
mv                   sleep_on_buffer        1490 ms
mv                   sleep_on_buffer        1876 ms
mv                   sleep_on_buffer        1240 ms
mv                   sleep_on_buffer        1897 ms
mv                   sleep_on_buffer        2089 ms
mv                   sleep_on_buffer        1375 ms
mv                   sleep_on_buffer        1386 ms
mv                   sleep_on_buffer        1442 ms
mv                   sleep_on_buffer        1682 ms
mv                   sleep_on_buffer        1188 ms
offlineimap          sleep_on_buffer        2247 ms
mv                   sleep_on_buffer        1262 ms
mv                   sleep_on_buffer        8930 ms
mv                   sleep_on_buffer        1392 ms
mv                   sleep_on_buffer        1536 ms
mv                   sleep_on_buffer        1064 ms
mv                   sleep_on_buffer        1303 ms
mv                   sleep_on_buffer        1487 ms
mv                   sleep_on_buffer        1331 ms
mv                   sleep_on_buffer        1757 ms
mv                   sleep_on_buffer        1069 ms
mv                   sleep_on_buffer        1183 ms
mv                   sleep_on_buffer        1548 ms
mv                   sleep_on_buffer        1090 ms
mv                   sleep_on_buffer        1770 ms
mv                   sleep_on_buffer        1002 ms
mv                   sleep_on_buffer        1199 ms
mv                   sleep_on_buffer        1066 ms
mv                   sleep_on_buffer        1275 ms
mv                   sleep_on_buffer        1198 ms
mv                   sleep_on_buffer        1653 ms
mv                   sleep_on_buffer        1197 ms
mv                   sleep_on_buffer        1275 ms
mv                   sleep_on_buffer        1317 ms
mv                   sleep_on_buffer        1025 ms
mv                   sleep_on_buffer        1527 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fba26>] ext4_rename+0x276/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    59307 ms
Event count:                      15
git                  sleep_on_buffer        3293 ms
git                  sleep_on_buffer        1350 ms
git                  sleep_on_buffer        2132 ms
git                  sleep_on_buffer        1018 ms
git                  sleep_on_buffer       16069 ms
git                  sleep_on_buffer        5478 ms
offlineimap          sleep_on_buffer        1138 ms
imapd                sleep_on_buffer        1927 ms
imapd                sleep_on_buffer        6417 ms
offlineimap          sleep_on_buffer        6241 ms
offlineimap          sleep_on_buffer        1549 ms
rsync                sleep_on_buffer        3776 ms
rsync                sleep_on_buffer        2516 ms
git                  sleep_on_buffer        1025 ms
git                  sleep_on_buffer        5378 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff8121c4ad>] ext4_ext_tree_init+0x2d/0x40
[<ffffffff811ecc06>] __ext4_new_inode+0x1076/0x10c0
[<ffffffff811fac5b>] ext4_create+0xbb/0x190
[<ffffffff81180aa5>] vfs_create+0xb5/0x120
[<ffffffff81180c4e>] lookup_open+0x13e/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    58651 ms
Event count:                       4
git                  sleep_on_buffer       13070 ms
git                  sleep_on_buffer       18222 ms
git                  sleep_on_buffer       13508 ms
git                  sleep_on_buffer       13851 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fc898>] ext4_orphan_del+0x1a8/0x1e0
[<ffffffff811f4fbb>] ext4_evict_inode+0x30b/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff8117fbe1>] do_unlinkat+0x1f1/0x260
[<ffffffff81182611>] sys_unlink+0x11/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    56275 ms
Event count:                      14
git                  sleep_on_buffer        1116 ms
git                  sleep_on_buffer        1347 ms
git                  sleep_on_buffer        1258 ms
git                  sleep_on_buffer        3471 ms
git                  sleep_on_buffer        3348 ms
git                  sleep_on_buffer        1185 ms
git                  sleep_on_buffer        1423 ms
git                  sleep_on_buffer        2662 ms
git                  sleep_on_buffer        8693 ms
git                  sleep_on_buffer        8223 ms
git                  sleep_on_buffer        4792 ms
git                  sleep_on_buffer        2553 ms
git                  sleep_on_buffer        2550 ms
git                  sleep_on_buffer       13654 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f9c6e>] add_dirent_to_buf+0x12e/0x1d0
[<ffffffff811f9e38>] ext4_dx_add_entry+0x128/0x590
[<ffffffff811fa925>] ext4_add_entry+0x265/0x2d0
[<ffffffff811fa9b6>] ext4_add_nondir+0x26/0x80
[<ffffffff811fac9f>] ext4_create+0xff/0x190
[<ffffffff81180aa5>] vfs_create+0xb5/0x120
[<ffffffff81180c4e>] lookup_open+0x13e/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    55128 ms
Event count:                      12
dconf-service        sleep_on_buffer        1918 ms
pool                 sleep_on_buffer       10558 ms
pool                 sleep_on_buffer        1957 ms
pool                 sleep_on_buffer        1903 ms
pool                 sleep_on_buffer        1187 ms
offlineimap          sleep_on_buffer        2077 ms
URL Classifier       sleep_on_buffer        3924 ms
offlineimap          sleep_on_buffer        2573 ms
StreamT~ns #343      sleep_on_buffer       11686 ms
DOM Worker           sleep_on_buffer        2215 ms
pool                 sleep_on_buffer        4513 ms
offlineimap          sleep_on_buffer       10617 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227556>] ext4_mb_mark_diskspace_used+0x76/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81110c3a>] filemap_write_and_wait_range+0x4a/0x70
[<ffffffff811ea54a>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    53464 ms
Event count:                       4
play                 sleep_on_buffer        6853 ms
play                 sleep_on_buffer       15340 ms
play                 sleep_on_buffer       24793 ms
play                 sleep_on_buffer        6478 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff811f313c>] ext4_setattr+0x36c/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811712bd>] chown_common+0xbd/0xd0
[<ffffffff81172417>] sys_fchown+0xb7/0xd0
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    51867 ms
Event count:                       3
flush-8:0            sleep_on_buffer       42842 ms
flush-8:0            sleep_on_buffer        2026 ms
flush-8:0            sleep_on_buffer        6999 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812275bf>] ext4_mb_mark_diskspace_used+0xdf/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    49716 ms
Event count:                       8
pool                 sleep_on_buffer        4642 ms
offlineimap          sleep_on_buffer        4279 ms
evolution            sleep_on_buffer        5182 ms
rsync                sleep_on_buffer        5599 ms
git                  sleep_on_buffer        8338 ms
StreamT~ns #343      sleep_on_buffer        2216 ms
git                  sleep_on_buffer        2844 ms
git                  sleep_on_buffer       16616 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812291ba>] ext4_free_blocks+0x36a/0xc10
[<ffffffff8121bd16>] ext4_remove_blocks+0x256/0x2d0
[<ffffffff8121bf95>] ext4_ext_rm_leaf+0x205/0x520
[<ffffffff8121dcbc>] ext4_ext_remove_space+0x4dc/0x750
[<ffffffff8121fb0b>] ext4_ext_truncate+0x19b/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f513e>] ext4_evict_inode+0x48e/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff81187248>] dentry_iput+0x98/0xe0
[<ffffffff81188ac8>] dput+0x128/0x230
[<ffffffff81182c4a>] sys_renameat+0x33a/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    42396 ms
Event count:                       5
git                  sleep_on_buffer        1115 ms
git                  sleep_on_buffer       15407 ms
git                  sleep_on_buffer        9114 ms
git                  sleep_on_buffer        1076 ms
git                  sleep_on_buffer       15684 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f4e95>] ext4_evict_inode+0x1e5/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff8117fbe1>] do_unlinkat+0x1f1/0x260
[<ffffffff81182611>] sys_unlink+0x11/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    41836 ms
Event count:                      29
git                  sleep_on_buffer        1326 ms
git                  sleep_on_buffer        1017 ms
git                  sleep_on_buffer        1077 ms
git                  sleep_on_buffer        2618 ms
git                  sleep_on_buffer        1058 ms
git                  sleep_on_buffer        1321 ms
git                  sleep_on_buffer        1199 ms
git                  sleep_on_buffer        1067 ms
git                  sleep_on_buffer        1227 ms
git                  sleep_on_buffer        1101 ms
git                  sleep_on_buffer        1105 ms
git                  sleep_on_buffer        1048 ms
git                  sleep_on_buffer        1254 ms
git                  sleep_on_buffer        1866 ms
git                  sleep_on_buffer        1768 ms
git                  sleep_on_buffer        1613 ms
git                  sleep_on_buffer        1690 ms
git                  sleep_on_buffer        1189 ms
git                  sleep_on_buffer        1063 ms
git                  sleep_on_buffer        1022 ms
git                  sleep_on_buffer        2039 ms
git                  sleep_on_buffer        1898 ms
git                  sleep_on_buffer        1422 ms
git                  sleep_on_buffer        1678 ms
git                  sleep_on_buffer        1285 ms
git                  sleep_on_buffer        2058 ms
git                  sleep_on_buffer        1336 ms
git                  sleep_on_buffer        1364 ms
git                  sleep_on_buffer        2127 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f9dd2>] ext4_dx_add_entry+0xc2/0x590
[<ffffffff811fa925>] ext4_add_entry+0x265/0x2d0
[<ffffffff811fae2c>] ext4_link+0xfc/0x1b0
[<ffffffff81181e33>] vfs_link+0x113/0x1c0
[<ffffffff811828a4>] sys_linkat+0x174/0x1c0
[<ffffffff81182909>] sys_link+0x19/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    41493 ms
Event count:                       2
flush-8:0            sleep_on_buffer       28180 ms
flush-8:0            sleep_on_buffer       13313 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff8121a8f2>] ext4_ext_get_access.isra.39+0x22/0x30
[<ffffffff8121d506>] ext4_split_extent_at+0xb6/0x390
[<ffffffff8121e038>] ext4_split_extent.isra.47+0x108/0x130
[<ffffffff8121e3ae>] ext4_ext_convert_to_initialized+0x15e/0x590
[<ffffffff8121ee7b>] ext4_ext_handle_uninitialized_extents+0x2fb/0x3c0
[<ffffffff8121f547>] ext4_ext_map_blocks+0x5d7/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4601>] write_cache_pages_da+0x421/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    40644 ms
Event count:                      30
flush-8:16           get_request            1797 ms
flush-8:16           get_request            1334 ms
flush-8:16           get_request            1288 ms
flush-8:16           get_request            1741 ms
flush-8:16           get_request            2518 ms
flush-8:16           get_request            1752 ms
flush-8:16           get_request            1069 ms
flush-8:16           get_request            1487 ms
flush-8:16           get_request            1000 ms
flush-8:16           get_request            1270 ms
flush-8:16           get_request            1223 ms
flush-8:16           get_request            1384 ms
flush-8:16           get_request            1082 ms
flush-8:16           get_request            1195 ms
flush-8:16           get_request            1163 ms
flush-8:16           get_request            1605 ms
flush-8:16           get_request            1110 ms
flush-8:16           get_request            1249 ms
flush-8:16           get_request            2064 ms
flush-8:16           get_request            1073 ms
flush-8:16           get_request            1238 ms
flush-8:16           get_request            1215 ms
flush-8:16           get_request            1075 ms
flush-8:16           get_request            1532 ms
flush-8:16           get_request            1586 ms
flush-8:16           get_request            1165 ms
flush-8:16           get_request            1129 ms
flush-8:16           get_request            1098 ms
flush-8:16           get_request            1099 ms
flush-8:16           get_request            1103 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff812a4b1f>] generic_make_request.part.59+0x6f/0xa0
[<ffffffff812a5050>] generic_make_request+0x60/0x70
[<ffffffff812a50c7>] submit_bio+0x67/0x130
[<ffffffff811f6014>] ext4_io_submit+0x24/0x60
[<ffffffff811f2265>] ext4_writepage+0x135/0x220
[<ffffffff81119292>] __writepage+0x12/0x40
[<ffffffff81119a96>] write_cache_pages+0x206/0x460
[<ffffffff81119d35>] generic_writepages+0x45/0x70
[<ffffffff8111ac15>] do_writepages+0x25/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    39571 ms
Event count:                       8
kio_http             sleep_on_buffer       23133 ms
vi                   sleep_on_buffer        4288 ms
git                  sleep_on_buffer        1410 ms
mutt                 sleep_on_buffer        2302 ms
mutt                 sleep_on_buffer        2299 ms
Cache I/O            sleep_on_buffer        1283 ms
gpg                  sleep_on_buffer        3265 ms
git                  sleep_on_buffer        1591 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fb67b>] ext4_orphan_add+0xbb/0x1f0
[<ffffffff811fc6cb>] ext4_unlink+0x32b/0x350
[<ffffffff8117daef>] vfs_unlink.part.31+0x7f/0xe0
[<ffffffff8117f9d7>] vfs_unlink+0x37/0x50
[<ffffffff8117fbff>] do_unlinkat+0x20f/0x260
[<ffffffff81182611>] sys_unlink+0x11/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    38769 ms
Event count:                       6
rsync                sleep_on_buffer        3513 ms
rsync                sleep_on_buffer        3570 ms
git                  sleep_on_buffer       26211 ms
git                  sleep_on_buffer        1657 ms
git                  sleep_on_buffer        2184 ms
git                  sleep_on_buffer        1634 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811fbd0c>] ext4_rename+0x55c/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    34812 ms
Event count:                       4
acroread             wait_on_page_bit      11968 ms
acroread             wait_on_page_bit       7121 ms
acroread             wait_on_page_bit       3126 ms
acroread             wait_on_page_bit      12597 ms
[<ffffffff8110f0e0>] wait_on_page_bit+0x70/0x80
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff8111d620>] truncate_inode_pages+0x10/0x20
[<ffffffff8111d677>] truncate_pagecache+0x47/0x70
[<ffffffff811f2f4d>] ext4_setattr+0x17d/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff8117d186>] handle_truncate+0x66/0xa0
[<ffffffff81181306>] do_last+0x626/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff811c2996>] compat_sys_open+0x16/0x20
[<ffffffff8159d81c>] sysenter_dispatch+0x7/0x21
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    34740 ms
Event count:                       4
systemd-journal      sleep_on_buffer        1126 ms
systemd-journal      sleep_on_buffer       29206 ms
systemd-journal      sleep_on_buffer        1787 ms
systemd-journal      sleep_on_buffer        2621 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227556>] ext4_mb_mark_diskspace_used+0x76/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff8121fd1f>] ext4_fallocate+0x1cf/0x420
[<ffffffff81171b32>] do_fallocate+0x112/0x190
[<ffffffff81171c02>] sys_fallocate+0x52/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    33158 ms
Event count:                      32
mv                   sleep_on_buffer        1043 ms
git                  wait_on_page_bit       1150 ms
cc1                  sleep_on_buffer        1062 ms
git                  wait_on_page_bit       1055 ms
flush-8:16           get_request            1091 ms
mktexlsr             sleep_on_buffer        1152 ms
imapd                sleep_on_buffer        1004 ms
flush-8:16           get_request            1087 ms
flush-8:16           get_request            1104 ms
sleep                wait_on_page_bit_killable   1142 ms
git                  wait_on_page_bit_killable   1108 ms
git                  wait_on_page_bit_killable   1007 ms
git                  wait_on_page_bit_killable   1074 ms
git                  wait_on_page_bit_killable   1050 ms
nm-dhcp-client.      wait_on_page_bit_killable   1069 ms
uname                wait_on_page_bit_killable   1086 ms
sed                  wait_on_page_bit_killable   1101 ms
git                  wait_on_page_bit_killable   1057 ms
grep                 wait_on_page_bit_killable   1045 ms
imapd                sleep_on_buffer        1032 ms
git                  sleep_on_buffer        1015 ms
folder-markup.s      sleep_on_buffer        1048 ms
git                  wait_on_page_bit       1086 ms
git                  sleep_on_buffer        1041 ms
git                  sleep_on_buffer        1048 ms
git                  wait_on_page_bit       1063 ms
git                  sleep_on_buffer        1083 ms
series2git           sleep_on_buffer        1073 ms
git                  wait_on_page_bit       1093 ms
git                  wait_on_page_bit       1071 ms
git                  wait_on_page_bit       1018 ms

Time stalled in this event:    32109 ms
Event count:                      23
flush-8:16           get_request            1475 ms
flush-8:16           get_request            1431 ms
flush-8:16           get_request            1027 ms
flush-8:16           get_request            2019 ms
flush-8:16           get_request            1021 ms
flush-8:16           get_request            1013 ms
flush-8:16           get_request            1093 ms
flush-8:16           get_request            1178 ms
flush-8:16           get_request            1051 ms
flush-8:16           get_request            1296 ms
flush-8:16           get_request            1525 ms
flush-8:16           get_request            1083 ms
flush-8:16           get_request            1654 ms
flush-8:16           get_request            1583 ms
flush-8:16           get_request            1405 ms
flush-8:16           get_request            2004 ms
flush-8:16           get_request            2203 ms
flush-8:16           get_request            1980 ms
flush-8:16           get_request            1211 ms
flush-8:16           get_request            1116 ms
flush-8:16           get_request            1071 ms
flush-8:16           get_request            1255 ms
flush-8:16           get_request            1415 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff812a4b1f>] generic_make_request.part.59+0x6f/0xa0
[<ffffffff812a5050>] generic_make_request+0x60/0x70
[<ffffffff812a50c7>] submit_bio+0x67/0x130
[<ffffffff811a30fb>] submit_bh+0xfb/0x130
[<ffffffff811a6058>] __block_write_full_page+0x1c8/0x340
[<ffffffff811a62a3>] block_write_full_page_endio+0xd3/0x110
[<ffffffff811a62f0>] block_write_full_page+0x10/0x20
[<ffffffff811aa0c3>] blkdev_writepage+0x13/0x20
[<ffffffff81119292>] __writepage+0x12/0x40
[<ffffffff81119a96>] write_cache_pages+0x206/0x460
[<ffffffff81119d35>] generic_writepages+0x45/0x70
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    31440 ms
Event count:                       6
pool                 sleep_on_buffer       13120 ms
scp                  sleep_on_buffer        5297 ms
scp                  sleep_on_buffer        3769 ms
scp                  sleep_on_buffer        2870 ms
cp                   sleep_on_buffer        5153 ms
git                  sleep_on_buffer        1231 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811ebe24>] __ext4_new_inode+0x294/0x10c0
[<ffffffff811fb456>] ext4_mkdir+0x146/0x2b0
[<ffffffff81181b42>] vfs_mkdir+0xa2/0x120
[<ffffffff81182533>] sys_mkdirat+0xa3/0xf0
[<ffffffff81182594>] sys_mkdir+0x14/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    30241 ms
Event count:                       4
git                  sleep_on_buffer       10480 ms
evince               sleep_on_buffer        1309 ms
git                  sleep_on_buffer       17269 ms
git                  sleep_on_buffer        1183 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811eb7cf>] ext4_free_inode+0x22f/0x5f0
[<ffffffff811f4fe1>] ext4_evict_inode+0x331/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff81187248>] dentry_iput+0x98/0xe0
[<ffffffff81188ac8>] dput+0x128/0x230
[<ffffffff81182c4a>] sys_renameat+0x33a/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    28375 ms
Event count:                       4
flush-8:0            sleep_on_buffer        7042 ms
flush-8:0            sleep_on_buffer        1900 ms
flush-8:0            sleep_on_buffer        1746 ms
flush-8:0            sleep_on_buffer       17687 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff8121a8f2>] ext4_ext_get_access.isra.39+0x22/0x30
[<ffffffff8121e658>] ext4_ext_convert_to_initialized+0x408/0x590
[<ffffffff8121ee7b>] ext4_ext_handle_uninitialized_extents+0x2fb/0x3c0
[<ffffffff8121f547>] ext4_ext_map_blocks+0x5d7/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4601>] write_cache_pages_da+0x421/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    26600 ms
Event count:                       4
systemd-journal      sleep_on_buffer        2463 ms
systemd-journal      sleep_on_buffer        2988 ms
systemd-journal      sleep_on_buffer       19520 ms
systemd-journal      sleep_on_buffer        1629 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fb67b>] ext4_orphan_add+0xbb/0x1f0
[<ffffffff8121f9e1>] ext4_ext_truncate+0x71/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f2f5d>] ext4_setattr+0x18d/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff81171979>] do_sys_ftruncate.constprop.14+0x109/0x170
[<ffffffff81171a09>] sys_ftruncate+0x9/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    25557 ms
Event count:                       2
flush-253:0          sleep_on_buffer        2782 ms
flush-253:0          sleep_on_buffer       22775 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227556>] ext4_mb_mark_diskspace_used+0x76/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119ddb2>] wb_do_writeback+0xb2/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    25493 ms
Event count:                       5
git                  sleep_on_buffer       15264 ms
git                  sleep_on_buffer        2091 ms
git                  sleep_on_buffer        2507 ms
git                  sleep_on_buffer        1218 ms
git                  sleep_on_buffer        4413 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811eb7cf>] ext4_free_inode+0x22f/0x5f0
[<ffffffff811f4fe1>] ext4_evict_inode+0x331/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff8117fbe1>] do_unlinkat+0x1f1/0x260
[<ffffffff81182611>] sys_unlink+0x11/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    25420 ms
Event count:                       8
Cache I/O            sleep_on_buffer        8766 ms
pool                 sleep_on_buffer        1851 ms
rsync                sleep_on_buffer        2738 ms
imapd                sleep_on_buffer        1697 ms
evolution            sleep_on_buffer        2829 ms
pool                 sleep_on_buffer        2854 ms
firefox              sleep_on_buffer        2326 ms
imapd                sleep_on_buffer        2359 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811ec0e8>] __ext4_new_inode+0x558/0x10c0
[<ffffffff811fac5b>] ext4_create+0xbb/0x190
[<ffffffff81180aa5>] vfs_create+0xb5/0x120
[<ffffffff81180c4e>] lookup_open+0x13e/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    24833 ms
Event count:                       9
kswapd0              wait_on_page_bit       2147 ms
kswapd0              wait_on_page_bit       1483 ms
kswapd0              wait_on_page_bit       1393 ms
kswapd0              wait_on_page_bit       1844 ms
kswapd0              wait_on_page_bit       1920 ms
kswapd0              wait_on_page_bit       3606 ms
kswapd0              wait_on_page_bit       7155 ms
kswapd0              wait_on_page_bit       1189 ms
kswapd0              wait_on_page_bit       4096 ms
[<ffffffff8110f0e0>] wait_on_page_bit+0x70/0x80
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811228cf>] shrink_inactive_list+0x15f/0x4a0
[<ffffffff811230cc>] shrink_lruvec+0x13c/0x260
[<ffffffff81123256>] shrink_zone+0x66/0x180
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff8112451b>] balance_pgdat+0x33b/0x4b0
[<ffffffff811247a6>] kswapd+0x116/0x230
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    23799 ms
Event count:                      19
jbd2/sdb1-8          wait_on_page_bit       1077 ms
jbd2/sdb1-8          wait_on_page_bit       1126 ms
jbd2/sdb1-8          wait_on_page_bit       1197 ms
jbd2/sdb1-8          wait_on_page_bit       1101 ms
jbd2/sdb1-8          wait_on_page_bit       1160 ms
jbd2/sdb1-8          wait_on_page_bit       1594 ms
jbd2/sdb1-8          wait_on_page_bit       1364 ms
jbd2/sdb1-8          wait_on_page_bit       1094 ms
jbd2/sdb1-8          wait_on_page_bit       1141 ms
jbd2/sdb1-8          wait_on_page_bit       1309 ms
jbd2/sdb1-8          wait_on_page_bit       1325 ms
jbd2/sdb1-8          wait_on_page_bit       1415 ms
jbd2/sdb1-8          wait_on_page_bit       1331 ms
jbd2/sdb1-8          wait_on_page_bit       1372 ms
jbd2/sdb1-8          wait_on_page_bit       1187 ms
jbd2/sdb1-8          wait_on_page_bit       1472 ms
jbd2/sdb1-8          wait_on_page_bit       1192 ms
jbd2/sdb1-8          wait_on_page_bit       1080 ms
jbd2/sdb1-8          wait_on_page_bit       1262 ms
[<ffffffff8110f0e0>] wait_on_page_bit+0x70/0x80
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff8110f2a3>] filemap_fdatawait+0x23/0x30
[<ffffffff8123a78c>] journal_finish_inode_data_buffers+0x6c/0x170
[<ffffffff8123b376>] jbd2_journal_commit_transaction+0x706/0x13c0
[<ffffffff81240513>] kjournald2+0xb3/0x240
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    22392 ms
Event count:                       2
rsync                sleep_on_buffer        3595 ms
git                  sleep_on_buffer       18797 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227556>] ext4_mb_mark_diskspace_used+0x76/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4185>] mpage_add_bh_to_extent+0x45/0xa0
[<ffffffff811f4505>] write_cache_pages_da+0x325/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff811114b7>] filemap_flush+0x17/0x20
[<ffffffff811f0354>] ext4_alloc_da_blocks+0x44/0xa0
[<ffffffff811fb960>] ext4_rename+0x1b0/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    21612 ms
Event count:                       3
flush-8:0            sleep_on_buffer       13971 ms
flush-8:0            sleep_on_buffer        3795 ms
flush-8:0            sleep_on_buffer        3846 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff811efadd>] ext4_da_update_reserve_space+0x1cd/0x280
[<ffffffff8121f88a>] ext4_ext_map_blocks+0x91a/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    21313 ms
Event count:                       6
git                  sleep_on_buffer        1261 ms
git                  sleep_on_buffer        2135 ms
systemd-journal      sleep_on_buffer       13451 ms
git                  sleep_on_buffer        1203 ms
git                  sleep_on_buffer        1180 ms
git                  sleep_on_buffer        2083 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b789>] update_time+0x79/0xc0
[<ffffffff8118ba31>] touch_atime+0x161/0x170
[<ffffffff811e99fd>] ext4_file_mmap+0x3d/0x50
[<ffffffff81140175>] mmap_region+0x325/0x590
[<ffffffff811406f8>] do_mmap_pgoff+0x318/0x440
[<ffffffff8112ba05>] vm_mmap_pgoff+0xa5/0xd0
[<ffffffff8113ee84>] sys_mmap_pgoff+0xa4/0x180
[<ffffffff81006b8d>] sys_mmap+0x1d/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    19298 ms
Event count:                       3
flush-8:0            sleep_on_buffer       14371 ms
flush-8:0            sleep_on_buffer        1545 ms
flush-8:0            sleep_on_buffer        3382 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff8121a8f2>] ext4_ext_get_access.isra.39+0x22/0x30
[<ffffffff8121d24c>] ext4_ext_insert_extent+0x21c/0x420
[<ffffffff8121f60a>] ext4_ext_map_blocks+0x69a/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    19044 ms
Event count:                       2
akregator            sleep_on_buffer       12495 ms
imapd                sleep_on_buffer        6549 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fb67b>] ext4_orphan_add+0xbb/0x1f0
[<ffffffff8121f9e1>] ext4_ext_truncate+0x71/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f2f5d>] ext4_setattr+0x18d/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff8117d186>] handle_truncate+0x66/0xa0
[<ffffffff81181306>] do_last+0x626/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    18957 ms
Event count:                       5
flush-8:0            sleep_on_buffer        2120 ms
flush-8:0            sleep_on_buffer        1668 ms
flush-8:0            sleep_on_buffer        2679 ms
flush-8:0            sleep_on_buffer        4561 ms
flush-8:0            sleep_on_buffer        7929 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff8121a97b>] __ext4_ext_dirty.isra.40+0x7b/0x80
[<ffffffff8121d34a>] ext4_ext_insert_extent+0x31a/0x420
[<ffffffff8121f60a>] ext4_ext_map_blocks+0x69a/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    18341 ms
Event count:                       6
imapd                sleep_on_buffer        5018 ms
imapd                sleep_on_buffer        1541 ms
acroread             sleep_on_buffer        5963 ms
git                  sleep_on_buffer        3274 ms
git                  sleep_on_buffer        1387 ms
git                  sleep_on_buffer        1158 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227556>] ext4_mb_mark_diskspace_used+0x76/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff811114b7>] filemap_flush+0x17/0x20
[<ffffffff811f0354>] ext4_alloc_da_blocks+0x44/0xa0
[<ffffffff811ea201>] ext4_release_file+0x61/0xd0
[<ffffffff811742a0>] __fput+0xb0/0x240
[<ffffffff81174439>] ____fput+0x9/0x10
[<ffffffff81065dc7>] task_work_run+0x97/0xd0
[<ffffffff81002cbc>] do_notify_resume+0x9c/0xb0
[<ffffffff8159c46a>] int_signal+0x12/0x17
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    18310 ms
Event count:                      17
cp                   sleep_on_buffer        1061 ms
cp                   sleep_on_buffer        1032 ms
cp                   sleep_on_buffer        1072 ms
cp                   sleep_on_buffer        1039 ms
cp                   sleep_on_buffer        1035 ms
cp                   sleep_on_buffer        1167 ms
cp                   sleep_on_buffer        1029 ms
cp                   sleep_on_buffer        1108 ms
cp                   sleep_on_buffer        1009 ms
cp                   sleep_on_buffer        1113 ms
cp                   sleep_on_buffer        1113 ms
cp                   sleep_on_buffer        1029 ms
free                 wait_on_page_bit_killable   1067 ms
imapd                sleep_on_buffer        1103 ms
cat                  sleep_on_buffer        1180 ms
imapd                sleep_on_buffer        1005 ms
git                  sleep_on_buffer        1148 ms
[<ffffffff8110ef12>] __lock_page_killable+0x62/0x70
[<ffffffff81110507>] do_generic_file_read.constprop.35+0x287/0x440
[<ffffffff81111359>] generic_file_aio_read+0xd9/0x220
[<ffffffff81172b53>] do_sync_read+0xa3/0xe0
[<ffffffff8117327b>] vfs_read+0xab/0x170
[<ffffffff8117338d>] sys_read+0x4d/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    18275 ms
Event count:                       2
systemd-journal      sleep_on_buffer        1594 ms
systemd-journal      sleep_on_buffer       16681 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff81228bbd>] ext4_mb_new_blocks+0x1fd/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff8121fd1f>] ext4_fallocate+0x1cf/0x420
[<ffffffff81171b32>] do_fallocate+0x112/0x190
[<ffffffff81171c02>] sys_fallocate+0x52/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    17970 ms
Event count:                       2
pool                 sleep_on_buffer       12739 ms
pool                 sleep_on_buffer        5231 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f9bc4>] add_dirent_to_buf+0x84/0x1d0
[<ffffffff811fa7e4>] ext4_add_entry+0x124/0x2d0
[<ffffffff811fa9b6>] ext4_add_nondir+0x26/0x80
[<ffffffff811fac9f>] ext4_create+0xff/0x190
[<ffffffff81180aa5>] vfs_create+0xb5/0x120
[<ffffffff81180c4e>] lookup_open+0x13e/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    17925 ms
Event count:                       1
git                  sleep_on_buffer       17925 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227556>] ext4_mb_mark_diskspace_used+0x76/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f003b>] ext4_getblk+0x5b/0x1f0
[<ffffffff811f01e1>] ext4_bread+0x11/0x80
[<ffffffff811f758d>] ext4_append+0x5d/0x120
[<ffffffff811fb243>] ext4_init_new_dir+0x83/0x150
[<ffffffff811fb48d>] ext4_mkdir+0x17d/0x2b0
[<ffffffff81181b42>] vfs_mkdir+0xa2/0x120
[<ffffffff81182533>] sys_mkdirat+0xa3/0xf0
[<ffffffff81182594>] sys_mkdir+0x14/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    17421 ms
Event count:                       1
git                  sleep_on_buffer       17421 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f9c6e>] add_dirent_to_buf+0x12e/0x1d0
[<ffffffff811fa7e4>] ext4_add_entry+0x124/0x2d0
[<ffffffff811fb4bd>] ext4_mkdir+0x1ad/0x2b0
[<ffffffff81181b42>] vfs_mkdir+0xa2/0x120
[<ffffffff81182533>] sys_mkdirat+0xa3/0xf0
[<ffffffff81182594>] sys_mkdir+0x14/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    17385 ms
Event count:                       7
git                  sleep_on_buffer        1409 ms
git                  sleep_on_buffer        1128 ms
git                  sleep_on_buffer        6323 ms
rsync                sleep_on_buffer        4503 ms
git                  sleep_on_buffer        1204 ms
mv                   sleep_on_buffer        1190 ms
git                  sleep_on_buffer        1628 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227556>] ext4_mb_mark_diskspace_used+0x76/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff811114b7>] filemap_flush+0x17/0x20
[<ffffffff811f0354>] ext4_alloc_da_blocks+0x44/0xa0
[<ffffffff811fb960>] ext4_rename+0x1b0/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    13983 ms
Event count:                       3
patch                sleep_on_buffer        1511 ms
cp                   sleep_on_buffer        2096 ms
git                  sleep_on_buffer       10376 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811ec0e8>] __ext4_new_inode+0x558/0x10c0
[<ffffffff811fb456>] ext4_mkdir+0x146/0x2b0
[<ffffffff81181b42>] vfs_mkdir+0xa2/0x120
[<ffffffff81182533>] sys_mkdirat+0xa3/0xf0
[<ffffffff81182594>] sys_mkdir+0x14/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    13603 ms
Event count:                       4
git                  sleep_on_buffer        2160 ms
gen-report.sh        sleep_on_buffer        4730 ms
evolution            sleep_on_buffer        4697 ms
git                  sleep_on_buffer        2016 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811fb6cf>] ext4_orphan_add+0x10f/0x1f0
[<ffffffff811f31a4>] ext4_setattr+0x3d4/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff8117d186>] handle_truncate+0x66/0xa0
[<ffffffff81181306>] do_last+0x626/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    13264 ms
Event count:                       8
ls                   sleep_on_buffer        1116 ms
ls                   sleep_on_buffer        1756 ms
ls                   sleep_on_buffer        1901 ms
ls                   sleep_on_buffer        2033 ms
ls                   sleep_on_buffer        1373 ms
ls                   sleep_on_buffer        3046 ms
offlineimap          sleep_on_buffer        1011 ms
imapd                sleep_on_buffer        1028 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811eefee>] __ext4_get_inode_loc+0x1be/0x3f0
[<ffffffff811f0d2e>] ext4_iget+0x7e/0x940
[<ffffffff811f9796>] ext4_lookup.part.31+0xc6/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117efb2>] path_lookupat+0x222/0x780
[<ffffffff8117f53f>] filename_lookup+0x2f/0xc0
[<ffffffff81182074>] user_path_at_empty+0x54/0xa0
[<ffffffff811820cc>] user_path_at+0xc/0x10
[<ffffffff81177b39>] vfs_fstatat+0x49/0xa0
[<ffffffff81177bc6>] vfs_stat+0x16/0x20
[<ffffffff81177ce5>] sys_newstat+0x15/0x30
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    12710 ms
Event count:                       6
git                  sleep_on_buffer        1364 ms
git                  sleep_on_buffer        1612 ms
git                  sleep_on_buffer        4321 ms
git                  sleep_on_buffer        2185 ms
git                  sleep_on_buffer        2126 ms
git                  sleep_on_buffer        1102 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811e7818>] ext4_wait_block_bitmap+0xb8/0xc0
[<ffffffff8122462e>] ext4_mb_init_cache+0x1ce/0x730
[<ffffffff8122509a>] ext4_mb_load_buddy+0x26a/0x350
[<ffffffff8122676b>] ext4_mb_find_by_goal+0x9b/0x2d0
[<ffffffff81227109>] ext4_mb_regular_allocator+0x59/0x430
[<ffffffff81228db6>] ext4_mb_new_blocks+0x3f6/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4185>] mpage_add_bh_to_extent+0x45/0xa0
[<ffffffff811f4505>] write_cache_pages_da+0x325/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81110c3a>] filemap_write_and_wait_range+0x4a/0x70
[<ffffffff811ea54a>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    12397 ms
Event count:                       7
jbd2/dm-0-8          sleep_on_buffer        1516 ms
jbd2/dm-0-8          sleep_on_buffer        1153 ms
jbd2/dm-0-8          sleep_on_buffer        1307 ms
jbd2/dm-0-8          sleep_on_buffer        1518 ms
jbd2/dm-0-8          sleep_on_buffer        1513 ms
jbd2/dm-0-8          sleep_on_buffer        1516 ms
jbd2/dm-0-8          sleep_on_buffer        3874 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff8123b488>] jbd2_journal_commit_transaction+0x818/0x13c0
[<ffffffff81240513>] kjournald2+0xb3/0x240
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    12361 ms
Event count:                       4
git                  sleep_on_buffer        1076 ms
scp                  sleep_on_buffer        1517 ms
rsync                sleep_on_buffer        5018 ms
rsync                sleep_on_buffer        4750 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f9c6e>] add_dirent_to_buf+0x12e/0x1d0
[<ffffffff811fa7e4>] ext4_add_entry+0x124/0x2d0
[<ffffffff811fa9b6>] ext4_add_nondir+0x26/0x80
[<ffffffff811fac9f>] ext4_create+0xff/0x190
[<ffffffff81180aa5>] vfs_create+0xb5/0x120
[<ffffffff81180c4e>] lookup_open+0x13e/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    12175 ms
Event count:                       3
patch                sleep_on_buffer        1546 ms
patch                sleep_on_buffer        7218 ms
patch                sleep_on_buffer        3411 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f9dd2>] ext4_dx_add_entry+0xc2/0x590
[<ffffffff811fa925>] ext4_add_entry+0x265/0x2d0
[<ffffffff811fb4bd>] ext4_mkdir+0x1ad/0x2b0
[<ffffffff81181b42>] vfs_mkdir+0xa2/0x120
[<ffffffff81182533>] sys_mkdirat+0xa3/0xf0
[<ffffffff81182594>] sys_mkdir+0x14/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    11862 ms
Event count:                       4
bash                 sleep_on_buffer        5441 ms
offlineimap          sleep_on_buffer        2780 ms
pool                 sleep_on_buffer        1529 ms
pool                 sleep_on_buffer        2112 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fb67b>] ext4_orphan_add+0xbb/0x1f0
[<ffffffff811f31a4>] ext4_setattr+0x3d4/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff8117d186>] handle_truncate+0x66/0xa0
[<ffffffff81181306>] do_last+0x626/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    11695 ms
Event count:                       1
git                  sleep_on_buffer       11695 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812275bf>] ext4_mb_mark_diskspace_used+0xdf/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4185>] mpage_add_bh_to_extent+0x45/0xa0
[<ffffffff811f4505>] write_cache_pages_da+0x325/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff811114b7>] filemap_flush+0x17/0x20
[<ffffffff811f0354>] ext4_alloc_da_blocks+0x44/0xa0
[<ffffffff811fb960>] ext4_rename+0x1b0/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    11452 ms
Event count:                       8
compare-mmtests      sleep_on_buffer        1407 ms
compare-mmtests      sleep_on_buffer        1439 ms
find                 sleep_on_buffer        2063 ms
git                  sleep_on_buffer        1128 ms
cp                   sleep_on_buffer        1041 ms
rsync                sleep_on_buffer        1533 ms
rsync                sleep_on_buffer        1070 ms
FileLoader           sleep_on_buffer        1771 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f0227>] ext4_bread+0x57/0x80
[<ffffffff811f7b21>] __ext4_read_dirblock+0x41/0x1d0
[<ffffffff811f849b>] htree_dirblock_to_tree+0x3b/0x1a0
[<ffffffff811f8d7f>] ext4_htree_fill_tree+0x7f/0x220
[<ffffffff811e8d67>] ext4_dx_readdir+0x1a7/0x440
[<ffffffff811e9572>] ext4_readdir+0x422/0x4e0
[<ffffffff811849a0>] vfs_readdir+0xb0/0xe0
[<ffffffff81184ae9>] sys_getdents+0x89/0x110
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     9483 ms
Event count:                       3
offlineimap          sleep_on_buffer        1768 ms
dconf-service        sleep_on_buffer        6600 ms
git                  sleep_on_buffer        1115 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811fb8b5>] ext4_rename+0x105/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     8201 ms
Event count:                       1
systemd-journal      sleep_on_buffer        8201 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812275bf>] ext4_mb_mark_diskspace_used+0xdf/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff8121fd1f>] ext4_fallocate+0x1cf/0x420
[<ffffffff81171b32>] do_fallocate+0x112/0x190
[<ffffffff81171c02>] sys_fallocate+0x52/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     7699 ms
Event count:                       2
git                  sleep_on_buffer        3475 ms
git                  sleep_on_buffer        4224 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fc898>] ext4_orphan_del+0x1a8/0x1e0
[<ffffffff811f4fbb>] ext4_evict_inode+0x30b/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff81187248>] dentry_iput+0x98/0xe0
[<ffffffff81188ac8>] dput+0x128/0x230
[<ffffffff81182c4a>] sys_renameat+0x33a/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     7564 ms
Event count:                       2
tar                  sleep_on_buffer        1286 ms
rm                   sleep_on_buffer        6278 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811fc3e1>] ext4_unlink+0x41/0x350
[<ffffffff8117daef>] vfs_unlink.part.31+0x7f/0xe0
[<ffffffff8117f9d7>] vfs_unlink+0x37/0x50
[<ffffffff8117fbff>] do_unlinkat+0x20f/0x260
[<ffffffff811825dd>] sys_unlinkat+0x1d/0x40
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     6596 ms
Event count:                       1
acroread             sleep_on_buffer        6596 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b789>] update_time+0x79/0xc0
[<ffffffff8118ba31>] touch_atime+0x161/0x170
[<ffffffff811105e3>] do_generic_file_read.constprop.35+0x363/0x440
[<ffffffff81111359>] generic_file_aio_read+0xd9/0x220
[<ffffffff81172b53>] do_sync_read+0xa3/0xe0
[<ffffffff8117327b>] vfs_read+0xab/0x170
[<ffffffff8117338d>] sys_read+0x4d/0x90
[<ffffffff8159d81c>] sysenter_dispatch+0x7/0x21
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     6589 ms
Event count:                       1
tar                  sleep_on_buffer        6589 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f9dd2>] ext4_dx_add_entry+0xc2/0x590
[<ffffffff811fa925>] ext4_add_entry+0x265/0x2d0
[<ffffffff811fb4bd>] ext4_mkdir+0x1ad/0x2b0
[<ffffffff81181b42>] vfs_mkdir+0xa2/0x120
[<ffffffff81182533>] sys_mkdirat+0xa3/0xf0
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     6272 ms
Event count:                       6
pool                 wait_on_page_bit       1005 ms
pool                 wait_on_page_bit       1015 ms
StreamT~ns #908      sleep_on_buffer        1086 ms
Cache I/O            wait_on_page_bit       1091 ms
StreamT~ns #138      wait_on_page_bit       1046 ms
offlineimap          sleep_on_buffer        1029 ms
[<ffffffff810a04ed>] futex_wait+0x17d/0x270
[<ffffffff810a21ac>] do_futex+0x7c/0x1b0
[<ffffffff810a241d>] sys_futex+0x13d/0x190
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     6237 ms
Event count:                       1
offlineimap          sleep_on_buffer        6237 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812291ba>] ext4_free_blocks+0x36a/0xc10
[<ffffffff8121bd16>] ext4_remove_blocks+0x256/0x2d0
[<ffffffff8121bf95>] ext4_ext_rm_leaf+0x205/0x520
[<ffffffff8121dcbc>] ext4_ext_remove_space+0x4dc/0x750
[<ffffffff8121fb0b>] ext4_ext_truncate+0x19b/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f2f5d>] ext4_setattr+0x18d/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff8117d186>] handle_truncate+0x66/0xa0
[<ffffffff81181306>] do_last+0x626/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     6192 ms
Event count:                       4
ls                   sleep_on_buffer        1679 ms
ls                   sleep_on_buffer        1746 ms
ls                   sleep_on_buffer        1076 ms
ls                   sleep_on_buffer        1691 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff811ef20d>] __ext4_get_inode_loc+0x3dd/0x3f0
[<ffffffff811f0d2e>] ext4_iget+0x7e/0x940
[<ffffffff811f9796>] ext4_lookup.part.31+0xc6/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117efb2>] path_lookupat+0x222/0x780
[<ffffffff8117f53f>] filename_lookup+0x2f/0xc0
[<ffffffff81182074>] user_path_at_empty+0x54/0xa0
[<ffffffff811820cc>] user_path_at+0xc/0x10
[<ffffffff81177b39>] vfs_fstatat+0x49/0xa0
[<ffffffff81177bc6>] vfs_stat+0x16/0x20
[<ffffffff81177ce5>] sys_newstat+0x15/0x30
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     5989 ms
Event count:                       3
flush-8:0            sleep_on_buffer        1184 ms
flush-8:0            sleep_on_buffer        1548 ms
flush-8:0            sleep_on_buffer        3257 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227556>] ext4_mb_mark_diskspace_used+0x76/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4185>] mpage_add_bh_to_extent+0x45/0xa0
[<ffffffff811f4505>] write_cache_pages_da+0x325/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     5770 ms
Event count:                       1
git                  sleep_on_buffer        5770 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff8121a8f2>] ext4_ext_get_access.isra.39+0x22/0x30
[<ffffffff8121bf74>] ext4_ext_rm_leaf+0x1e4/0x520
[<ffffffff8121dcbc>] ext4_ext_remove_space+0x4dc/0x750
[<ffffffff8121fb0b>] ext4_ext_truncate+0x19b/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f513e>] ext4_evict_inode+0x48e/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff81187248>] dentry_iput+0x98/0xe0
[<ffffffff81188ac8>] dput+0x128/0x230
[<ffffffff81182c4a>] sys_renameat+0x33a/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     4477 ms
Event count:                       2
offlineimap          sleep_on_buffer        2154 ms
DOM Worker           sleep_on_buffer        2323 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811f96f9>] ext4_lookup.part.31+0x29/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff81180bd8>] lookup_open+0xc8/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     4428 ms
Event count:                       3
compare-mmtests      sleep_on_buffer        1725 ms
compare-mmtests      sleep_on_buffer        1634 ms
cp                   sleep_on_buffer        1069 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811eefee>] __ext4_get_inode_loc+0x1be/0x3f0
[<ffffffff811f0d2e>] ext4_iget+0x7e/0x940
[<ffffffff811f9796>] ext4_lookup.part.31+0xc6/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117efb2>] path_lookupat+0x222/0x780
[<ffffffff8117f53f>] filename_lookup+0x2f/0xc0
[<ffffffff81182074>] user_path_at_empty+0x54/0xa0
[<ffffffff811820cc>] user_path_at+0xc/0x10
[<ffffffff81177b39>] vfs_fstatat+0x49/0xa0
[<ffffffff81177ba9>] vfs_lstat+0x19/0x20
[<ffffffff81177d15>] sys_newlstat+0x15/0x30
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     4168 ms
Event count:                       3
git                  sleep_on_buffer        1866 ms
git                  sleep_on_buffer        1070 ms
git                  sleep_on_buffer        1232 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811e7818>] ext4_wait_block_bitmap+0xb8/0xc0
[<ffffffff8122462e>] ext4_mb_init_cache+0x1ce/0x730
[<ffffffff8122509a>] ext4_mb_load_buddy+0x26a/0x350
[<ffffffff81227247>] ext4_mb_regular_allocator+0x197/0x430
[<ffffffff81228db6>] ext4_mb_new_blocks+0x3f6/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4185>] mpage_add_bh_to_extent+0x45/0xa0
[<ffffffff811f4505>] write_cache_pages_da+0x325/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81110c3a>] filemap_write_and_wait_range+0x4a/0x70
[<ffffffff811ea54a>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     3940 ms
Event count:                       2
evolution            sleep_on_buffer        1978 ms
git                  sleep_on_buffer        1962 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812291ba>] ext4_free_blocks+0x36a/0xc10
[<ffffffff8121bd16>] ext4_remove_blocks+0x256/0x2d0
[<ffffffff8121bf95>] ext4_ext_rm_leaf+0x205/0x520
[<ffffffff8121dcbc>] ext4_ext_remove_space+0x4dc/0x750
[<ffffffff8121fb0b>] ext4_ext_truncate+0x19b/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f2f5d>] ext4_setattr+0x18d/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff8117d186>] handle_truncate+0x66/0xa0
[<ffffffff81181306>] do_last+0x626/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     3802 ms
Event count:                       2
git                  sleep_on_buffer        1933 ms
git                  sleep_on_buffer        1869 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811f96f9>] ext4_lookup.part.31+0x29/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117efb2>] path_lookupat+0x222/0x780
[<ffffffff8117f53f>] filename_lookup+0x2f/0xc0
[<ffffffff81182074>] user_path_at_empty+0x54/0xa0
[<ffffffff811820cc>] user_path_at+0xc/0x10
[<ffffffff81171cd7>] sys_faccessat+0x97/0x220
[<ffffffff81171e73>] sys_access+0x13/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     3792 ms
Event count:                       3
cc1                  sleep_on_buffer        1161 ms
compare-mmtests      sleep_on_buffer        1088 ms
cc1                  sleep_on_buffer        1543 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811f96f9>] ext4_lookup.part.31+0x29/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117e76a>] link_path_walk+0x7ca/0x8e0
[<ffffffff81181596>] path_openat+0x96/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     3783 ms
Event count:                       2
compare-mmtests      sleep_on_buffer        2237 ms
compare-mmtests      sleep_on_buffer        1546 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811eefee>] __ext4_get_inode_loc+0x1be/0x3f0
[<ffffffff811f0d2e>] ext4_iget+0x7e/0x940
[<ffffffff811f9796>] ext4_lookup.part.31+0xc6/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117e76a>] link_path_walk+0x7ca/0x8e0
[<ffffffff81181596>] path_openat+0x96/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117285f>] sys_openat+0xf/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     3692 ms
Event count:                       2
git                  sleep_on_buffer        1667 ms
git                  sleep_on_buffer        2025 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811e7818>] ext4_wait_block_bitmap+0xb8/0xc0
[<ffffffff8122462e>] ext4_mb_init_cache+0x1ce/0x730
[<ffffffff8122509a>] ext4_mb_load_buddy+0x26a/0x350
[<ffffffff8122676b>] ext4_mb_find_by_goal+0x9b/0x2d0
[<ffffffff81227109>] ext4_mb_regular_allocator+0x59/0x430
[<ffffffff81228db6>] ext4_mb_new_blocks+0x3f6/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81110c3a>] filemap_write_and_wait_range+0x4a/0x70
[<ffffffff811ea54a>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     3533 ms
Event count:                       1
pool                 sleep_on_buffer        3533 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f9dd2>] ext4_dx_add_entry+0xc2/0x590
[<ffffffff811fa925>] ext4_add_entry+0x265/0x2d0
[<ffffffff811fbf16>] ext4_rename+0x766/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     3329 ms
Event count:                       3
folder-markup.s      sleep_on_buffer        1147 ms
imapd                sleep_on_buffer        1053 ms
gnuplot              sleep_on_buffer        1129 ms
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2861 ms
Event count:                       2
chmod                sleep_on_buffer        1227 ms
chmod                sleep_on_buffer        1634 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff811f313c>] ext4_setattr+0x36c/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff8117137b>] chmod_common+0xab/0xb0
[<ffffffff811721a1>] sys_fchmodat+0x41/0xa0
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2822 ms
Event count:                       1
gnome-terminal       sleep_on_buffer        2822 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811eb856>] ext4_free_inode+0x2b6/0x5f0
[<ffffffff811f4fe1>] ext4_evict_inode+0x331/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff81187248>] dentry_iput+0x98/0xe0
[<ffffffff81188ac8>] dput+0x128/0x230
[<ffffffff81174368>] __fput+0x178/0x240
[<ffffffff81174439>] ____fput+0x9/0x10
[<ffffffff81065dc7>] task_work_run+0x97/0xd0
[<ffffffff81002cbc>] do_notify_resume+0x9c/0xb0
[<ffffffff8159c46a>] int_signal+0x12/0x17
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2769 ms
Event count:                       1
imapd                sleep_on_buffer        2769 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff811f313c>] ext4_setattr+0x36c/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff8117137b>] chmod_common+0xab/0xb0
[<ffffffff811721a1>] sys_fchmodat+0x41/0xa0
[<ffffffff81172214>] sys_chmod+0x14/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2727 ms
Event count:                       1
mv                   sleep_on_buffer        2727 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f9c6e>] add_dirent_to_buf+0x12e/0x1d0
[<ffffffff811fa7e4>] ext4_add_entry+0x124/0x2d0
[<ffffffff811fbf16>] ext4_rename+0x766/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2675 ms
Event count:                       1
flush-8:0            sleep_on_buffer        2675 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812275bf>] ext4_mb_mark_diskspace_used+0xdf/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4185>] mpage_add_bh_to_extent+0x45/0xa0
[<ffffffff811f4505>] write_cache_pages_da+0x325/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2658 ms
Event count:                       1
patch                sleep_on_buffer        2658 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff8121c4ad>] ext4_ext_tree_init+0x2d/0x40
[<ffffffff811ecc06>] __ext4_new_inode+0x1076/0x10c0
[<ffffffff811fb456>] ext4_mkdir+0x146/0x2b0
[<ffffffff81181b42>] vfs_mkdir+0xa2/0x120
[<ffffffff81182533>] sys_mkdirat+0xa3/0xf0
[<ffffffff81182594>] sys_mkdir+0x14/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2603 ms
Event count:                       2
flush-8:0            sleep_on_buffer        1162 ms
flush-8:0            sleep_on_buffer        1441 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff8121a8f2>] ext4_ext_get_access.isra.39+0x22/0x30
[<ffffffff8121d24c>] ext4_ext_insert_extent+0x21c/0x420
[<ffffffff8121f60a>] ext4_ext_map_blocks+0x69a/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2580 ms
Event count:                       2
rm                   sleep_on_buffer        1265 ms
rm                   sleep_on_buffer        1315 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811e7818>] ext4_wait_block_bitmap+0xb8/0xc0
[<ffffffff811e8265>] ext4_read_block_bitmap+0x35/0x60
[<ffffffff8122908c>] ext4_free_blocks+0x23c/0xc10
[<ffffffff8121bd16>] ext4_remove_blocks+0x256/0x2d0
[<ffffffff8121bf95>] ext4_ext_rm_leaf+0x205/0x520
[<ffffffff8121dcbc>] ext4_ext_remove_space+0x4dc/0x750
[<ffffffff8121fb0b>] ext4_ext_truncate+0x19b/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f513e>] ext4_evict_inode+0x48e/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff8117fbe1>] do_unlinkat+0x1f1/0x260
[<ffffffff811825dd>] sys_unlinkat+0x1d/0x40
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2542 ms
Event count:                       2
flush-8:16           get_request            1316 ms
flush-8:16           get_request            1226 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff812a4b1f>] generic_make_request.part.59+0x6f/0xa0
[<ffffffff812a5050>] generic_make_request+0x60/0x70
[<ffffffff812a50c7>] submit_bio+0x67/0x130
[<ffffffff811a30fb>] submit_bh+0xfb/0x130
[<ffffffff811a6058>] __block_write_full_page+0x1c8/0x340
[<ffffffff811a62a3>] block_write_full_page_endio+0xd3/0x110
[<ffffffff811a62f0>] block_write_full_page+0x10/0x20
[<ffffffff811aa0c3>] blkdev_writepage+0x13/0x20
[<ffffffff81119292>] __writepage+0x12/0x40
[<ffffffff81119a96>] write_cache_pages+0x206/0x460
[<ffffffff81119d35>] generic_writepages+0x45/0x70
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2504 ms
Event count:                       1
acroread             sleep_on_buffer        2504 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b789>] update_time+0x79/0xc0
[<ffffffff8118ba31>] touch_atime+0x161/0x170
[<ffffffff811105e3>] do_generic_file_read.constprop.35+0x363/0x440
[<ffffffff81111359>] generic_file_aio_read+0xd9/0x220
[<ffffffff81172b53>] do_sync_read+0xa3/0xe0
[<ffffffff8117327b>] vfs_read+0xab/0x170
[<ffffffff8117338d>] sys_read+0x4d/0x90
[<ffffffff8159dc79>] ia32_sysret+0x0/0x5
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2477 ms
Event count:                       2
git                  sleep_on_buffer        1200 ms
firefox              sleep_on_buffer        1277 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812291ba>] ext4_free_blocks+0x36a/0xc10
[<ffffffff8121bd16>] ext4_remove_blocks+0x256/0x2d0
[<ffffffff8121bf95>] ext4_ext_rm_leaf+0x205/0x520
[<ffffffff8121dcbc>] ext4_ext_remove_space+0x4dc/0x750
[<ffffffff8121fb0b>] ext4_ext_truncate+0x19b/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f513e>] ext4_evict_inode+0x48e/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff8117fbe1>] do_unlinkat+0x1f1/0x260
[<ffffffff81182611>] sys_unlink+0x11/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2168 ms
Event count:                       2
xchat                sleep_on_buffer        1096 ms
xchat                sleep_on_buffer        1072 ms
[<ffffffff81185476>] do_poll.isra.7+0x1c6/0x290
[<ffffffff81186331>] do_sys_poll+0x191/0x200
[<ffffffff81186466>] sys_poll+0x66/0x100
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2156 ms
Event count:                       2
git                  sleep_on_buffer        1076 ms
git                  sleep_on_buffer        1080 ms
[<ffffffff811383b2>] unmap_single_vma+0x82/0x100
[<ffffffff81138c2c>] unmap_vmas+0x4c/0xa0
[<ffffffff811408f0>] exit_mmap+0x90/0x170
[<ffffffff81043ee5>] mmput.part.27+0x45/0x110
[<ffffffff81043fcd>] mmput+0x1d/0x30
[<ffffffff8104be22>] exit_mm+0x132/0x180
[<ffffffff8104bfc5>] do_exit+0x155/0x460
[<ffffffff8104c34f>] do_group_exit+0x3f/0xa0
[<ffffffff8104c3c2>] sys_exit_group+0x12/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2141 ms
Event count:                       2
imapd                sleep_on_buffer        1057 ms
ntpd                 wait_on_page_bit_killable   1084 ms
[<ffffffff81185a99>] do_select+0x4c9/0x5d0
[<ffffffff81185d58>] core_sys_select+0x1b8/0x2f0
[<ffffffff811860d6>] sys_select+0xb6/0x100
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2130 ms
Event count:                       2
git                  sleep_on_buffer        1110 ms
git                  sleep_on_buffer        1020 ms
[<ffffffff811f4ccb>] ext4_evict_inode+0x1b/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff81187248>] dentry_iput+0x98/0xe0
[<ffffffff81188ac8>] dput+0x128/0x230
[<ffffffff81182c4a>] sys_renameat+0x33a/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2092 ms
Event count:                       1
flush-8:0            sleep_on_buffer        2092 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff8121a97b>] __ext4_ext_dirty.isra.40+0x7b/0x80
[<ffffffff8121d69b>] ext4_split_extent_at+0x24b/0x390
[<ffffffff8121e038>] ext4_split_extent.isra.47+0x108/0x130
[<ffffffff8121e3ae>] ext4_ext_convert_to_initialized+0x15e/0x590
[<ffffffff8121ee7b>] ext4_ext_handle_uninitialized_extents+0x2fb/0x3c0
[<ffffffff8121f547>] ext4_ext_map_blocks+0x5d7/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2079 ms
Event count:                       2
offlineimap          sleep_on_buffer        1030 ms
pool                 wait_on_page_bit       1049 ms
[<ffffffff811ea6e5>] ext4_sync_file+0x205/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2066 ms
Event count:                       2
folder-markup.s      sleep_on_buffer        1024 ms
tee                  sleep_on_buffer        1042 ms
[<ffffffff8117b90e>] pipe_read+0x20e/0x340
[<ffffffff81172b53>] do_sync_read+0xa3/0xe0
[<ffffffff8117327b>] vfs_read+0xab/0x170
[<ffffffff8117338d>] sys_read+0x4d/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2047 ms
Event count:                       1
Cache I/O            sleep_on_buffer        2047 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812291e1>] ext4_free_blocks+0x391/0xc10
[<ffffffff8121bd16>] ext4_remove_blocks+0x256/0x2d0
[<ffffffff8121bf95>] ext4_ext_rm_leaf+0x205/0x520
[<ffffffff8121dcbc>] ext4_ext_remove_space+0x4dc/0x750
[<ffffffff8121fb0b>] ext4_ext_truncate+0x19b/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f2f5d>] ext4_setattr+0x18d/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff81171979>] do_sys_ftruncate.constprop.14+0x109/0x170
[<ffffffff81171a09>] sys_ftruncate+0x9/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1977 ms
Event count:                       1
patch                sleep_on_buffer        1977 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811f96f9>] ext4_lookup.part.31+0x29/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117e76a>] link_path_walk+0x7ca/0x8e0
[<ffffffff8117ede3>] path_lookupat+0x53/0x780
[<ffffffff8117f53f>] filename_lookup+0x2f/0xc0
[<ffffffff81182074>] user_path_at_empty+0x54/0xa0
[<ffffffff811820cc>] user_path_at+0xc/0x10
[<ffffffff81177b39>] vfs_fstatat+0x49/0xa0
[<ffffffff81177ba9>] vfs_lstat+0x19/0x20
[<ffffffff81177d15>] sys_newlstat+0x15/0x30
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1839 ms
Event count:                       1
compare-mmtests      sleep_on_buffer        1839 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811eefee>] __ext4_get_inode_loc+0x1be/0x3f0
[<ffffffff811f0d2e>] ext4_iget+0x7e/0x940
[<ffffffff811f9796>] ext4_lookup.part.31+0xc6/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117e76a>] link_path_walk+0x7ca/0x8e0
[<ffffffff81181596>] path_openat+0x96/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1819 ms
Event count:                       1
cp                   sleep_on_buffer        1819 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff811a4bc7>] write_dirty_buffer+0x67/0x70
[<ffffffff8123d035>] __flush_batch+0x45/0xa0
[<ffffffff8123dad6>] jbd2_log_do_checkpoint+0x1d6/0x220
[<ffffffff8123dba1>] __jbd2_log_wait_for_space+0x81/0x190
[<ffffffff812382d0>] start_this_handle+0x2e0/0x3e0
[<ffffffff81238590>] jbd2__journal_start.part.8+0x90/0x190
[<ffffffff812386d5>] jbd2__journal_start+0x45/0x50
[<ffffffff812205d1>] __ext4_journal_start_sb+0x81/0x170
[<ffffffff811ebf61>] __ext4_new_inode+0x3d1/0x10c0
[<ffffffff811fac5b>] ext4_create+0xbb/0x190
[<ffffffff81180aa5>] vfs_create+0xb5/0x120
[<ffffffff81180c4e>] lookup_open+0x13e/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1664 ms
Event count:                       1
flush-8:0            sleep_on_buffer        1664 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff8121a8f2>] ext4_ext_get_access.isra.39+0x22/0x30
[<ffffffff8121d125>] ext4_ext_insert_extent+0xf5/0x420
[<ffffffff8121f60a>] ext4_ext_map_blocks+0x69a/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1635 ms
Event count:                       1
flush-8:0            sleep_on_buffer        1635 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812275bf>] ext4_mb_mark_diskspace_used+0xdf/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4185>] mpage_add_bh_to_extent+0x45/0xa0
[<ffffffff811f4505>] write_cache_pages_da+0x325/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1591 ms
Event count:                       1
imapd                sleep_on_buffer        1591 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811f96f9>] ext4_lookup.part.31+0x29/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8117ca84>] lookup_hash+0x14/0x20
[<ffffffff8117fae3>] do_unlinkat+0xf3/0x260
[<ffffffff81182611>] sys_unlink+0x11/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1529 ms
Event count:                       1
ls                   sleep_on_buffer        1529 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f0227>] ext4_bread+0x57/0x80
[<ffffffff811f7b21>] __ext4_read_dirblock+0x41/0x1d0
[<ffffffff811f7f3d>] dx_probe+0x3d/0x410
[<ffffffff811f8dce>] ext4_htree_fill_tree+0xce/0x220
[<ffffffff811e8d67>] ext4_dx_readdir+0x1a7/0x440
[<ffffffff811e9572>] ext4_readdir+0x422/0x4e0
[<ffffffff811849a0>] vfs_readdir+0xb0/0xe0
[<ffffffff81184ae9>] sys_getdents+0x89/0x110
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1523 ms
Event count:                       1
gnuplot              sleep_on_buffer        1523 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff8121fad7>] ext4_ext_truncate+0x167/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f2f5d>] ext4_setattr+0x18d/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff8117d186>] handle_truncate+0x66/0xa0
[<ffffffff81181306>] do_last+0x626/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1519 ms
Event count:                       1
find                 sleep_on_buffer        1519 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f0227>] ext4_bread+0x57/0x80
[<ffffffff811f7b21>] __ext4_read_dirblock+0x41/0x1d0
[<ffffffff811f849b>] htree_dirblock_to_tree+0x3b/0x1a0
[<ffffffff811f8e42>] ext4_htree_fill_tree+0x142/0x220
[<ffffffff811e8d67>] ext4_dx_readdir+0x1a7/0x440
[<ffffffff811e9572>] ext4_readdir+0x422/0x4e0
[<ffffffff811849a0>] vfs_readdir+0xb0/0xe0
[<ffffffff81184ae9>] sys_getdents+0x89/0x110
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1509 ms
Event count:                       1
git                  sleep_on_buffer        1509 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811e7818>] ext4_wait_block_bitmap+0xb8/0xc0
[<ffffffff811e8265>] ext4_read_block_bitmap+0x35/0x60
[<ffffffff81227533>] ext4_mb_mark_diskspace_used+0x53/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81110c3a>] filemap_write_and_wait_range+0x4a/0x70
[<ffffffff811ea54a>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1470 ms
Event count:                       1
rm                   sleep_on_buffer        1470 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811eb4d0>] ext4_read_inode_bitmap+0x400/0x4d0
[<ffffffff811eb7ab>] ext4_free_inode+0x20b/0x5f0
[<ffffffff811f4fe1>] ext4_evict_inode+0x331/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff8117fbe1>] do_unlinkat+0x1f1/0x260
[<ffffffff811825dd>] sys_unlinkat+0x1d/0x40
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1462 ms
Event count:                       1
imapd                sleep_on_buffer        1462 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811fbb37>] ext4_rename+0x387/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1457 ms
Event count:                       1
git                  sleep_on_buffer        1457 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811e7818>] ext4_wait_block_bitmap+0xb8/0xc0
[<ffffffff811e8265>] ext4_read_block_bitmap+0x35/0x60
[<ffffffff81227533>] ext4_mb_mark_diskspace_used+0x53/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4185>] mpage_add_bh_to_extent+0x45/0xa0
[<ffffffff811f4505>] write_cache_pages_da+0x325/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81110c3a>] filemap_write_and_wait_range+0x4a/0x70
[<ffffffff811ea54a>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1395 ms
Event count:                       1
flush-8:0            sleep_on_buffer        1395 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812275bf>] ext4_mb_mark_diskspace_used+0xdf/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1387 ms
Event count:                       1
git                  sleep_on_buffer        1387 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812275bf>] ext4_mb_mark_diskspace_used+0xdf/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81110c3a>] filemap_write_and_wait_range+0x4a/0x70
[<ffffffff811ea54a>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1378 ms
Event count:                       1
gnuplot              sleep_on_buffer        1378 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812275bf>] ext4_mb_mark_diskspace_used+0xdf/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff811114b7>] filemap_flush+0x17/0x20
[<ffffffff811f0354>] ext4_alloc_da_blocks+0x44/0xa0
[<ffffffff811ea201>] ext4_release_file+0x61/0xd0
[<ffffffff811742a0>] __fput+0xb0/0x240
[<ffffffff81174439>] ____fput+0x9/0x10
[<ffffffff81065de4>] task_work_run+0xb4/0xd0
[<ffffffff8104bffa>] do_exit+0x18a/0x460
[<ffffffff8104c34f>] do_group_exit+0x3f/0xa0
[<ffffffff8104c3c2>] sys_exit_group+0x12/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1337 ms
Event count:                       1
git                  sleep_on_buffer        1337 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811e7818>] ext4_wait_block_bitmap+0xb8/0xc0
[<ffffffff8122462e>] ext4_mb_init_cache+0x1ce/0x730
[<ffffffff81224c2e>] ext4_mb_init_group+0x9e/0x100
[<ffffffff81224d97>] ext4_mb_good_group+0x107/0x1a0
[<ffffffff81227233>] ext4_mb_regular_allocator+0x183/0x430
[<ffffffff81228db6>] ext4_mb_new_blocks+0x3f6/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4185>] mpage_add_bh_to_extent+0x45/0xa0
[<ffffffff811f4505>] write_cache_pages_da+0x325/0x4b0
[<ffffffff811f49e5>] ext4_da_writepages+0x355/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81110c3a>] filemap_write_and_wait_range+0x4a/0x70
[<ffffffff811ea54a>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1309 ms
Event count:                       1
flush-8:0            sleep_on_buffer        1309 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff8121a97b>] __ext4_ext_dirty.isra.40+0x7b/0x80
[<ffffffff8121d69b>] ext4_split_extent_at+0x24b/0x390
[<ffffffff8121e038>] ext4_split_extent.isra.47+0x108/0x130
[<ffffffff8121e3ae>] ext4_ext_convert_to_initialized+0x15e/0x590
[<ffffffff8121ee7b>] ext4_ext_handle_uninitialized_extents+0x2fb/0x3c0
[<ffffffff8121f547>] ext4_ext_map_blocks+0x5d7/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119c5d7>] wb_check_old_data_flush+0x97/0xa0
[<ffffffff8119de49>] wb_do_writeback+0x149/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1284 ms
Event count:                       1
cp                   sleep_on_buffer        1284 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b789>] update_time+0x79/0xc0
[<ffffffff8118ba31>] touch_atime+0x161/0x170
[<ffffffff81177e71>] sys_readlinkat+0xe1/0x120
[<ffffffff81177ec6>] sys_readlink+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1277 ms
Event count:                       1
git                  sleep_on_buffer        1277 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811e7818>] ext4_wait_block_bitmap+0xb8/0xc0
[<ffffffff8122462e>] ext4_mb_init_cache+0x1ce/0x730
[<ffffffff81224c2e>] ext4_mb_init_group+0x9e/0x100
[<ffffffff81224d97>] ext4_mb_good_group+0x107/0x1a0
[<ffffffff81227233>] ext4_mb_regular_allocator+0x183/0x430
[<ffffffff81228db6>] ext4_mb_new_blocks+0x3f6/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81110c3a>] filemap_write_and_wait_range+0x4a/0x70
[<ffffffff811ea54a>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1758>] do_fsync+0x58/0x80
[<ffffffff811a1abb>] sys_fsync+0xb/0x10
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1235 ms
Event count:                       1
cp                   sleep_on_buffer        1235 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812275bf>] ext4_mb_mark_diskspace_used+0xdf/0x4d0
[<ffffffff81228c6f>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8122d7d0>] ext4_alloc_blocks+0x140/0x2b0
[<ffffffff8122d995>] ext4_alloc_branch+0x55/0x2c0
[<ffffffff8122ecb9>] ext4_ind_map_blocks+0x299/0x500
[<ffffffff811efd43>] ext4_map_blocks+0x1b3/0x450
[<ffffffff811f23e7>] _ext4_get_block+0x87/0x170
[<ffffffff811f2501>] ext4_get_block+0x11/0x20
[<ffffffff811a65bf>] __block_write_begin+0x1af/0x4d0
[<ffffffff811f1969>] ext4_write_begin+0x159/0x410
[<ffffffff8110f3aa>] generic_perform_write+0xca/0x210
[<ffffffff8110f548>] generic_file_buffered_write+0x58/0x90
[<ffffffff81110f96>] __generic_file_aio_write+0x1b6/0x3b0
[<ffffffff8111120a>] generic_file_aio_write+0x7a/0xf0
[<ffffffff811ea3a3>] ext4_file_write+0x83/0xd0
[<ffffffff81172a73>] do_sync_write+0xa3/0xe0
[<ffffffff811730fe>] vfs_write+0xae/0x180
[<ffffffff8117341d>] sys_write+0x4d/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1182 ms
Event count:                       1
imapd                sleep_on_buffer        1182 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fb052>] ext4_delete_entry+0x62/0x120
[<ffffffff811fbfea>] ext4_rename+0x83a/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1181 ms
Event count:                       1
systemd-journal      sleep_on_buffer        1181 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff8121a8f2>] ext4_ext_get_access.isra.39+0x22/0x30
[<ffffffff8121d125>] ext4_ext_insert_extent+0xf5/0x420
[<ffffffff8121f60a>] ext4_ext_map_blocks+0x69a/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff8121fd1f>] ext4_fallocate+0x1cf/0x420
[<ffffffff81171b32>] do_fallocate+0x112/0x190
[<ffffffff81171c02>] sys_fallocate+0x52/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1160 ms
Event count:                       1
rm                   sleep_on_buffer        1160 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9505>] ext4_find_entry+0x325/0x4f0
[<ffffffff811fc169>] ext4_rmdir+0x39/0x270
[<ffffffff8117dbf8>] vfs_rmdir.part.32+0xa8/0xf0
[<ffffffff8117fc8a>] vfs_rmdir+0x3a/0x50
[<ffffffff8117fe63>] do_rmdir+0x1c3/0x1e0
[<ffffffff811825ed>] sys_unlinkat+0x2d/0x40
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1108 ms
Event count:                       1
mutt                 sleep_on_buffer        1108 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811eb7cf>] ext4_free_inode+0x22f/0x5f0
[<ffffffff811f4fe1>] ext4_evict_inode+0x331/0x4c0
[<ffffffff8118bcbf>] evict+0xaf/0x1b0
[<ffffffff8118c543>] iput_final+0xd3/0x160
[<ffffffff8118c609>] iput+0x39/0x50
[<ffffffff81187248>] dentry_iput+0x98/0xe0
[<ffffffff81188ac8>] dput+0x128/0x230
[<ffffffff81174368>] __fput+0x178/0x240
[<ffffffff81174439>] ____fput+0x9/0x10
[<ffffffff81065dc7>] task_work_run+0x97/0xd0
[<ffffffff81002cbc>] do_notify_resume+0x9c/0xb0
[<ffffffff8159c46a>] int_signal+0x12/0x17
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1106 ms
Event count:                       1
flush-8:0            sleep_on_buffer        1106 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f51b1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119a84e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff811efadd>] ext4_da_update_reserve_space+0x1cd/0x280
[<ffffffff8121f88a>] ext4_ext_map_blocks+0x91a/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff811998f0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119bf9a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c1e6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c48b>] wb_writeback+0x27b/0x330
[<ffffffff8119de90>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119df53>] bdi_writeback_thread+0x83/0x280
[<ffffffff810690eb>] kthread+0xbb/0xc0
[<ffffffff8159c0fc>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1081 ms
Event count:                       1
imapd                sleep_on_buffer        1081 ms
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fb67b>] ext4_orphan_add+0xbb/0x1f0
[<ffffffff8121f9e1>] ext4_ext_truncate+0x71/0x1e0
[<ffffffff811ef535>] ext4_truncate.part.59+0xd5/0xf0
[<ffffffff811f0614>] ext4_truncate+0x34/0x90
[<ffffffff811f2f5d>] ext4_setattr+0x18d/0x640
[<ffffffff8118d132>] notify_change+0x1f2/0x3c0
[<ffffffff811715d9>] do_truncate+0x59/0xa0
[<ffffffff8117d186>] handle_truncate+0x66/0xa0
[<ffffffff81181306>] do_last+0x626/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1079 ms
Event count:                       1
git                  sleep_on_buffer        1079 ms
[<ffffffff812a5050>] generic_make_request+0x60/0x70
[<ffffffff812a50c7>] submit_bio+0x67/0x130
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1074 ms
Event count:                       1
cp                   sleep_on_buffer        1074 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a35ae>] __lock_buffer+0x2e/0x30
[<ffffffff81239def>] do_get_write_access+0x43f/0x4b0
[<ffffffff81239fab>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220839>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f2b88>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f2bf9>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811ec749>] __ext4_new_inode+0xbb9/0x10c0
[<ffffffff811fac5b>] ext4_create+0xbb/0x190
[<ffffffff81180aa5>] vfs_create+0xb5/0x120
[<ffffffff81180c4e>] lookup_open+0x13e/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff811815b3>] path_openat+0xb3/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff8117284c>] sys_open+0x1c/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1072 ms
Event count:                       1
du                   sleep_on_buffer        1072 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811eefee>] __ext4_get_inode_loc+0x1be/0x3f0
[<ffffffff811f0d2e>] ext4_iget+0x7e/0x940
[<ffffffff811f9796>] ext4_lookup.part.31+0xc6/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff8117ca63>] __lookup_hash+0x33/0x40
[<ffffffff8158464f>] lookup_slow+0x40/0xa4
[<ffffffff8117efb2>] path_lookupat+0x222/0x780
[<ffffffff8117f53f>] filename_lookup+0x2f/0xc0
[<ffffffff81182074>] user_path_at_empty+0x54/0xa0
[<ffffffff811820cc>] user_path_at+0xc/0x10
[<ffffffff81177b39>] vfs_fstatat+0x49/0xa0
[<ffffffff81177d45>] sys_newfstatat+0x15/0x30
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1034 ms
Event count:                       1
git                  sleep_on_buffer        1034 ms
[<ffffffff8110ef82>] __lock_page+0x62/0x70
[<ffffffff8110fe71>] find_lock_page+0x51/0x80
[<ffffffff8110ff04>] grab_cache_page_write_begin+0x64/0xd0
[<ffffffff811f1ca4>] ext4_da_write_begin+0x84/0x2e0
[<ffffffff8110f3aa>] generic_perform_write+0xca/0x210
[<ffffffff8110f548>] generic_file_buffered_write+0x58/0x90
[<ffffffff81110f96>] __generic_file_aio_write+0x1b6/0x3b0
[<ffffffff8111120a>] generic_file_aio_write+0x7a/0xf0
[<ffffffff811ea3a3>] ext4_file_write+0x83/0xd0
[<ffffffff81172a73>] do_sync_write+0xa3/0xe0
[<ffffffff811730fe>] vfs_write+0xae/0x180
[<ffffffff8117341d>] sys_write+0x4d/0x90
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1031 ms
Event count:                       1
git                  sleep_on_buffer        1031 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811e7818>] ext4_wait_block_bitmap+0xb8/0xc0
[<ffffffff8122462e>] ext4_mb_init_cache+0x1ce/0x730
[<ffffffff8122509a>] ext4_mb_load_buddy+0x26a/0x350
[<ffffffff81227247>] ext4_mb_regular_allocator+0x197/0x430
[<ffffffff81228db6>] ext4_mb_new_blocks+0x3f6/0x490
[<ffffffff8121f471>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811efe65>] ext4_map_blocks+0x2d5/0x450
[<ffffffff811f3f0a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f4a10>] ext4_da_writepages+0x380/0x620
[<ffffffff8111ac0b>] do_writepages+0x1b/0x30
[<ffffffff81110be9>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff811114b7>] filemap_flush+0x17/0x20
[<ffffffff811f0354>] ext4_alloc_da_blocks+0x44/0xa0
[<ffffffff811fb960>] ext4_rename+0x1b0/0x980
[<ffffffff8117d4ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180126>] vfs_rename+0xb6/0x240
[<ffffffff81182c96>] sys_renameat+0x386/0x3d0
[<ffffffff81182cf6>] sys_rename+0x16/0x20
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1029 ms
Event count:                       1
git                  wait_on_page_bit_killable   1029 ms
[<ffffffff815966d9>] kretprobe_trampoline+0x25/0x4c
[<ffffffff81111728>] filemap_fault+0x88/0x410
[<ffffffff81135d69>] __do_fault+0x439/0x530
[<ffffffff811394be>] handle_pte_fault+0xee/0x200
[<ffffffff8113a731>] handle_mm_fault+0x271/0x390
[<ffffffff81597a20>] __do_page_fault+0x230/0x520
[<ffffffff81594ec5>] do_device_not_available+0x15/0x20
[<ffffffff8159d50e>] device_not_available+0x1e/0x30
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1017 ms
Event count:                       1
npviewer.bin         sleep_on_buffer        1017 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff811eefee>] __ext4_get_inode_loc+0x1be/0x3f0
[<ffffffff811f0d2e>] ext4_iget+0x7e/0x940
[<ffffffff811f9796>] ext4_lookup.part.31+0xc6/0x140
[<ffffffff811f9835>] ext4_lookup+0x25/0x30
[<ffffffff8117c628>] lookup_real+0x18/0x50
[<ffffffff81180bd8>] lookup_open+0xc8/0x1d0
[<ffffffff81180fe7>] do_last+0x307/0x820
[<ffffffff8118182a>] path_openat+0x32a/0x4a0
[<ffffffff8118210d>] do_filp_open+0x3d/0xa0
[<ffffffff81172749>] do_sys_open+0xf9/0x1e0
[<ffffffff811c2996>] compat_sys_open+0x16/0x20
[<ffffffff8159dc79>] ia32_sysret+0x0/0x5
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1016 ms
Event count:                       1
rm                   sleep_on_buffer        1016 ms
[<ffffffff815966b4>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3566>] __wait_on_buffer+0x26/0x30
[<ffffffff8123d8f0>] __wait_cp_io+0xd0/0xe0
[<ffffffff8123da23>] jbd2_log_do_checkpoint+0x123/0x220
[<ffffffff8123dba1>] __jbd2_log_wait_for_space+0x81/0x190
[<ffffffff812382d0>] start_this_handle+0x2e0/0x3e0
[<ffffffff81238590>] jbd2__journal_start.part.8+0x90/0x190
[<ffffffff812386d5>] jbd2__journal_start+0x45/0x50
[<ffffffff812205d1>] __ext4_journal_start_sb+0x81/0x170
[<ffffffff811fc44c>] ext4_unlink+0xac/0x350
[<ffffffff8117daef>] vfs_unlink.part.31+0x7f/0xe0
[<ffffffff8117f9d7>] vfs_unlink+0x37/0x50
[<ffffffff8117fbff>] do_unlinkat+0x20f/0x260
[<ffffffff811825dd>] sys_unlinkat+0x1d/0x40
[<ffffffff8159c1ad>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
