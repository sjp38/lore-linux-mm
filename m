Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.59-mm5
Date: Sat, 25 Jan 2003 20:43:09 -0500
References: <20030123195044.47c51d39.akpm@digeo.com> <200301251534.32447.tomlins@cam.org> <20030125143343.2c505c93.akpm@digeo.com>
In-Reply-To: <20030125143343.2c505c93.akpm@digeo.com>
MIME-Version: 1.0
Message-Id: <200301252043.09642.tomlins@cam.org>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, Oleg Drokin <green@namesys.com>
List-ID: <linux-mm.kvack.org>

On January 25, 2003 05:33 pm, Andrew Morton wrote:
> Ed Tomlinson <tomlins@cam.org> wrote:
> > On January 25, 2003 12:41 pm, Andrew Morton wrote:
> > > Ed Tomlinson <tomlins@cam.org> wrote:
> > > > Hi Andrew,
> > > >
> > > > I am seeing a strange problem with mm5.  This occurs both with and
> > > > without the anticipatory scheduler changes.  What happens is I see
> > > > very high system times and X responds very very slowly.  I first
> > > > noticed this when switching between folders in kmail and have seen it
> > > > rebuilding db files for squidguard. Here is what happened during the
> > > > db rebuild (no anticipatory ioscheduler):
> > >
> > > Could you please try reverting the reiserfs changes?
> > >
> > > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm5/broken-
> > >out/ reiserfs-readpages.patch
> > >
> > > and
> > >
> > > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm5/broken-
> > >out/ reiserfs_file_write.patch
> >
> > Reverting reiserfs_file_write.patch seems to cure the interactivity
> > problems. I still see the high system times but they in themselves are
> > not a problem. Reverting the second patch does not change the situation. 
> > I am currently running with reiserfs_file_write.patch removed - so far so
> > good.
>
> Well, high system time _is_ a problem, isn't it?  Do you always see that?
>
> Or perhaps userspace monitoring tools are confusing I/O wait with CPU
> busyness. Does a revert of
>
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm5/broken-out/
>buffer-io-accounting.patch
>
> make the numbers look different?  If so, then it's a procps bug...
>
> WRT the excessive copy_foo_user() times: I shall forward your initial email
> to Oleg, thanks.

The excessive copy_foo_user times are still there with Oleg (and Chris's) patch
removed.  Here is what I see doing:

"apt-get install --reinstall squidguard chastity-list"

(with file_write from my first message)
 55091 default_idle                             1377.2750
 62640 __copy_from_user_ll                      1204.6154
 33595 __copy_to_user_ll                        646.0577

(without file_write)
 40259 __copy_from_user_ll                      774.2115
 18735 default_idle                             468.3750
 21524 __copy_to_user_ll                        413.9231 
   386 system_call                                8.0417
   428 current_kernel_time                        7.1333
   988 established_get_next                       6.8611
    60 ide_outb                                   5.0000
   509 reiserfs_prepare_write                     4.2417
   100 get_offset_tsc                             4.1667
    38 syscall_call                               3.4545
   159 fget                                       2.4844
   279 radix_tree_lookup                          2.2500
    61 init_journal_hash                          1.9062
    68 task_vsize                                 1.8889
   105 mark_page_accessed                         1.7500
   366 find_lock_page                             1.7264
    48 delay_tsc                                  1.7143
    89 block_prepare_write                        1.7115
   237 update_atime                               1.6458
    32 fput                                       1.6000
    90 unlock_page                                1.5000
   210 inode_update_time                          1.3816
   108 sys_pwrite64                               1.3500
    16 ide_inb                                    1.3333
    78 mark_buffer_dirty                          1.3000
   192 reiserfs_wait_on_write_block               1.2632
    93 handle_IRQ_event                           1.2237
    76 fault_in_pages_readable                    1.1875
     4 reiserfs_check_lock_depth                  1.0000

So removing file_read seems to have reduced the copy_foo_user() issue but
has not removed it.

Using a vmstat hacked to show iowait with the above running...

oscar% vmstat -a 5

   procs             memory (mB)      swap          io     system         cpu
 r  b  w  swpd  free inact   act   si   so    bi    bo   in    cs us sy io id
 3  0  0    42     6    13   434    0    3    36    69 1061    61 25  3  1 71
 5  0  0    42     4    15   434    0    0  1189   893 1184 18253 28 11 10 51
 4  0  0    42     5     8   440    0   66   353   274 1070  7874 74  7 10  9
 6  0  0    42     6     9   438    0    0   468   343 1081  2936 93  7  0  0
 5  0  0    46     4     5   444    0  714  1453   976 1147  8891 87 13  0  0
 4  0  0    51     5     1   447    0 1086   626  1877 1279 23445 57 43  0  0
 4  1  1    52     4     3   446    0  290   615  1206 1219 22018 68 32  0  0
 6  0  0    53     8    10   434    0   82   690  1020 1141 14962 59 41  0  0
10  0  0    53    36    14   403    0    0     2   599 1206  1988 85 15  0  0
 5  0  0    53    27     9   417    0    0    35    94 1072  1269 94  6  0  0
 5  0  0    53    31    11   411    0    0   188   761 1089  2401 88 12  0  0
 8  0  0    53    26    11   416    0    0     1   298 1052  9013 42 28  3 27
 7  0  0    53    25    11   417    0    0     0    22 1021   574 38 62  0  0
10  0  0    53    24    11   418    0    0     0    34 1014   546 53 47  0  0
11  0  0    53    23    11   419    0    0     0  1814 1142   634 43 57  0  0
 9  0  0    53    22    11   421    0    0     2    39 1019   556 40 60  0  0
13  0  0    53    20    10   423    0    0     0    32 1031  1183 51 47  0  2
 9  0  0    53    18    10   425    0    0     0  1946 1083   560 36 64  0  0
 9  0  0    53    17    10   426    0    0     0    28 1016   575 38 62  0  0
10  0  0    53    16    10   427    0    0     0    47 1022   560 52 48  0  0
 9  0  0    53    15    10   428    0    0     0    36 1015   540 28 72  0  0
 9  0  0    53    14    10   429    0    0     0    27 1023   603 48 52  0  0
 8  0  0    53    13    10   430    0    0     0    36 1019   536 48 52  0  0
 9  0  0    53    12    10   431    0    0     0   367 1029   539 36 64  0  0
11  0  0    53    11    10   432    0    0     0  1785 1112   587 32 68  0  0
10  0  0    53    11    10   433    0    0     0    58 1030   610 75 25  0  0
10  0  0    53    10    10   433    0    0     0    38 1037   599 67 33  0  0
12  0  0    53    10    10   434    0    0     0    34 1056   679 81 19  0  0
14  0  0    53    10    10   434   26    0    26    44 1059   647 42 58  0  0
13  0  0    53     9    10   435    0    0     0    45 1050   686 56 44  0  0
10  0  0    53     9    10   435    0    0     0   585 1083   678 59 41  0  0
   procs             memory (mB)      swap          io     system         cpu
 r  b  w  swpd  free inact   act   si   so    bi    bo   in    cs us sy io id
 9  0  1    53     8    10   435    0    0     0  2518 1200   727 48 52  0  0
10  0  0    53     8    10   436    0    0     0    43 1065   660 38 62  0  0
11  0  0    53     7    10   437    0    0     0    39 1044   661 29 71  0  0
 9  0  0    53     6     9   438    0    0     0   196 1063   676 44 56  0  0
 9  0  0    53     5    10   438    0    0     0   732 1169   681 27 73  0  0
 6  4  0    53     4    10   440    0    0     0   633 1121  1987 52 48  0  0
10  0  0    53    10    12   431    0    0     2  3294 1203  8145 54 46  0  0
11  0  0    53    24    17   412    0    0     0   806 1133   686 60 40  0  0

Unless its an accounting error, its not iowait (confirmed on a nonbusy system
too).  There is no change with or with out the io_schedule() changed back to 
schedule().

Ed Tomlinson









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
