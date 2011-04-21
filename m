Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9023A8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 02:06:02 -0400 (EDT)
Date: Thu, 21 Apr 2011 14:05:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
 was written
Message-ID: <20110421060556.GA24232@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.778889102@intel.com>
 <20110419102016.GD5257@quack.suse.cz>
 <20110419111601.GA18961@localhost>
 <20110419211008.GD9556@quack.suse.cz>
 <20110420075053.GB30672@localhost>
 <20110420152211.GC4991@quack.suse.cz>
 <20110421033325.GA13764@localhost>
 <20110421043940.GC22423@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421043940.GC22423@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Apr 21, 2011 at 12:39:40PM +0800, Christoph Hellwig wrote:
> On Thu, Apr 21, 2011 at 11:33:25AM +0800, Wu Fengguang wrote:
> > I collected the writeback_single_inode() traces (patch attached for
> > your reference) each for several test runs, and find much more
> > I_DIRTY_PAGES after patchset. Dave, do you know why there are so many
> > I_DIRTY_PAGES (or radix tag) remained after the XFS ->writepages() call,
> > even for small files?
> 
> What is your defintion of a small file?  As soon as it has multiple
> extents or holes there's absolutely no way to clean it with a single
> writepage call.

It's writing a kernel source tree to XFS. You can find in the below
trace that it often leaves more dirty pages behind (indicated by the
I_DIRTY_PAGES flag) after writing as less as 1 page (indicated by the
wrote=1 field).

> Also XFS tries to operate as non-blocking as possible
> if the non-blocking flag is set in the wbc, but that flag actually
> seems to be dead these days.

Yeah.

Thanks,
Fengguang
---
wfg /tmp% head -300 trace-dt7-moving-expire-xfs
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
            init-1     [004]  5291.655631: writeback_single_inode: bdi 0:15: ino=1574069 state= age=6 wrote=2 to_write=9223372036854775805 index=179837
            init-1     [004]  5291.657137: writeback_single_inode: bdi 0:15: ino=1574069 state= age=7 wrote=0 to_write=9223372036854775807 index=0
            init-1     [004]  5291.657141: writeback_single_inode: bdi 0:15: ino=1574069 state= age=7 wrote=0 to_write=9223372036854775807 index=0
            init-1     [004]  5291.659716: writeback_single_inode: bdi 0:15: ino=1574069 state= age=3 wrote=1 to_write=9223372036854775806 index=179837
##### CPU 6 buffer started ####
           getty-3417  [006]  5291.661265: writeback_single_inode: bdi 0:15: ino=1574069 state= age=4 wrote=0 to_write=9223372036854775807 index=0
           getty-3417  [006]  5291.661269: writeback_single_inode: bdi 0:15: ino=1574069 state= age=4 wrote=0 to_write=9223372036854775807 index=0
           getty-3417  [006]  5291.663963: writeback_single_inode: bdi 0:15: ino=1574069 state= age=3 wrote=1 to_write=9223372036854775806 index=179837
       flush-8:0-3402  [006]  5291.903857: writeback_single_inode: bdi 8:0: ino=131 state=I_DIRTY_SYNC|I_DIRTY_DATASYNC|I_DIRTY_PAGES age=323 wrote=4097 to_write=-1 index=0
       flush-8:0-3402  [006]  5291.919833: writeback_single_inode: bdi 8:0: ino=133 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4095 index=0
       flush-8:0-3402  [006]  5291.919876: writeback_single_inode: bdi 8:0: ino=134 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=4093 index=1
       flush-8:0-3402  [006]  5291.919913: writeback_single_inode: bdi 8:0: ino=135 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=5 to_write=4088 index=4
       flush-8:0-3402  [006]  5291.919969: writeback_single_inode: bdi 8:0: ino=136 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=23 to_write=4065 index=13
       flush-8:0-3402  [006]  5291.920008: writeback_single_inode: bdi 8:0: ino=134217857 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4064 index=0
       flush-8:0-3402  [006]  5291.920049: writeback_single_inode: bdi 8:0: ino=134217858 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=4060 index=3
       flush-8:0-3402  [006]  5291.920087: writeback_single_inode: bdi 8:0: ino=268628417 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4059 index=0
       flush-8:0-3402  [006]  5291.920128: writeback_single_inode: bdi 8:0: ino=402653313 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4058 index=0
       flush-8:0-3402  [006]  5291.920160: writeback_single_inode: bdi 8:0: ino=402653314 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4057 index=0
       flush-8:0-3402  [006]  5291.920194: writeback_single_inode: bdi 8:0: ino=402653315 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4056 index=0
       flush-8:0-3402  [006]  5291.920225: writeback_single_inode: bdi 8:0: ino=402653316 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4055 index=0
       flush-8:0-3402  [006]  5291.920260: writeback_single_inode: bdi 8:0: ino=138 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4054 index=0
       flush-8:0-3402  [006]  5291.920291: writeback_single_inode: bdi 8:0: ino=139 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4053 index=0
       flush-8:0-3402  [006]  5291.920325: writeback_single_inode: bdi 8:0: ino=140 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4052 index=0
       flush-8:0-3402  [006]  5291.920356: writeback_single_inode: bdi 8:0: ino=141 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4051 index=0
       flush-8:0-3402  [006]  5291.920393: writeback_single_inode: bdi 8:0: ino=134217860 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4050 index=0
       flush-8:0-3402  [006]  5291.920425: writeback_single_inode: bdi 8:0: ino=134217861 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4049 index=0
       flush-8:0-3402  [006]  5291.920458: writeback_single_inode: bdi 8:0: ino=134217862 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4048 index=0
       flush-8:0-3402  [006]  5291.920489: writeback_single_inode: bdi 8:0: ino=134217863 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4047 index=0
       flush-8:0-3402  [006]  5291.920524: writeback_single_inode: bdi 8:0: ino=134217864 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=4045 index=1
       flush-8:0-3402  [006]  5291.920556: writeback_single_inode: bdi 8:0: ino=134217865 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4044 index=0
       flush-8:0-3402  [006]  5291.920589: writeback_single_inode: bdi 8:0: ino=134217866 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4043 index=0
       flush-8:0-3402  [006]  5291.920620: writeback_single_inode: bdi 8:0: ino=134217867 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4042 index=0
       flush-8:0-3402  [006]  5291.920653: writeback_single_inode: bdi 8:0: ino=134217868 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4041 index=0
       flush-8:0-3402  [006]  5291.920718: writeback_single_inode: bdi 8:0: ino=134217869 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4040 index=0
       flush-8:0-3402  [006]  5291.920758: writeback_single_inode: bdi 8:0: ino=268628419 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4039 index=0
       flush-8:0-3402  [006]  5291.920790: writeback_single_inode: bdi 8:0: ino=268628420 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4038 index=0
       flush-8:0-3402  [006]  5291.920823: writeback_single_inode: bdi 8:0: ino=268628421 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4037 index=0
       flush-8:0-3402  [006]  5291.920855: writeback_single_inode: bdi 8:0: ino=268628422 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4036 index=0
       flush-8:0-3402  [006]  5291.920890: writeback_single_inode: bdi 8:0: ino=268628423 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4035 index=0
       flush-8:0-3402  [006]  5291.920924: writeback_single_inode: bdi 8:0: ino=268628424 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=4033 index=1
       flush-8:0-3402  [006]  5291.920957: writeback_single_inode: bdi 8:0: ino=268628425 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4032 index=0
       flush-8:0-3402  [006]  5291.920988: writeback_single_inode: bdi 8:0: ino=268628426 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4031 index=0
       flush-8:0-3402  [006]  5291.921021: writeback_single_inode: bdi 8:0: ino=268628427 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4030 index=0
       flush-8:0-3402  [006]  5291.921054: writeback_single_inode: bdi 8:0: ino=268628428 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=4028 index=1
       flush-8:0-3402  [006]  5291.921091: writeback_single_inode: bdi 8:0: ino=268628429 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4027 index=0
       flush-8:0-3402  [006]  5291.921122: writeback_single_inode: bdi 8:0: ino=268628430 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4026 index=0
       flush-8:0-3402  [006]  5291.921155: writeback_single_inode: bdi 8:0: ino=268628431 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4025 index=0
       flush-8:0-3402  [006]  5291.921188: writeback_single_inode: bdi 8:0: ino=268628432 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=4023 index=1
       flush-8:0-3402  [006]  5291.921224: writeback_single_inode: bdi 8:0: ino=268628433 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4022 index=0
       flush-8:0-3402  [006]  5291.921256: writeback_single_inode: bdi 8:0: ino=268628434 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4021 index=0
       flush-8:0-3402  [006]  5291.921289: writeback_single_inode: bdi 8:0: ino=268628435 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4020 index=0
       flush-8:0-3402  [006]  5291.921320: writeback_single_inode: bdi 8:0: ino=268628436 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4019 index=0
       flush-8:0-3402  [006]  5291.921354: writeback_single_inode: bdi 8:0: ino=268628437 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4018 index=0
       flush-8:0-3402  [006]  5291.921385: writeback_single_inode: bdi 8:0: ino=268628438 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4017 index=0
       flush-8:0-3402  [006]  5291.921421: writeback_single_inode: bdi 8:0: ino=268628439 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4016 index=0
       flush-8:0-3402  [006]  5291.921453: writeback_single_inode: bdi 8:0: ino=268628440 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4015 index=0
       flush-8:0-3402  [006]  5291.921487: writeback_single_inode: bdi 8:0: ino=268628441 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4014 index=0
       flush-8:0-3402  [006]  5291.921518: writeback_single_inode: bdi 8:0: ino=268628442 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4013 index=0
       flush-8:0-3402  [006]  5291.921552: writeback_single_inode: bdi 8:0: ino=268628443 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4012 index=0
       flush-8:0-3402  [006]  5291.921586: writeback_single_inode: bdi 8:0: ino=268628444 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=4009 index=2
       flush-8:0-3402  [006]  5291.921622: writeback_single_inode: bdi 8:0: ino=268628445 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=4007 index=1
       flush-8:0-3402  [006]  5291.921653: writeback_single_inode: bdi 8:0: ino=268628446 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4006 index=0
       flush-8:0-3402  [006]  5291.921709: writeback_single_inode: bdi 8:0: ino=268628447 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4005 index=0
       flush-8:0-3402  [006]  5291.921742: writeback_single_inode: bdi 8:0: ino=268628448 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4004 index=0
       flush-8:0-3402  [006]  5291.921775: writeback_single_inode: bdi 8:0: ino=268628449 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4003 index=0
       flush-8:0-3402  [006]  5291.921807: writeback_single_inode: bdi 8:0: ino=268628450 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4002 index=0
       flush-8:0-3402  [006]  5291.921840: writeback_single_inode: bdi 8:0: ino=268628451 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=4001 index=0
       flush-8:0-3402  [006]  5291.921874: writeback_single_inode: bdi 8:0: ino=268628452 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3999 index=1
       flush-8:0-3402  [006]  5291.921909: writeback_single_inode: bdi 8:0: ino=268628453 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3997 index=1
       flush-8:0-3402  [006]  5291.921940: writeback_single_inode: bdi 8:0: ino=268628454 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3996 index=0
       flush-8:0-3402  [006]  5291.921974: writeback_single_inode: bdi 8:0: ino=268628455 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3995 index=0
       flush-8:0-3402  [006]  5291.922005: writeback_single_inode: bdi 8:0: ino=268628456 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3994 index=0
       flush-8:0-3402  [006]  5291.922044: writeback_single_inode: bdi 8:0: ino=268628457 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3992 index=1
       flush-8:0-3402  [006]  5291.922077: writeback_single_inode: bdi 8:0: ino=268628458 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3990 index=1
       flush-8:0-3402  [006]  5291.922116: writeback_single_inode: bdi 8:0: ino=268628459 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3988 index=1
       flush-8:0-3402  [006]  5291.922149: writeback_single_inode: bdi 8:0: ino=268628460 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3986 index=1
       flush-8:0-3402  [006]  5291.922182: writeback_single_inode: bdi 8:0: ino=268628461 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3985 index=0
       flush-8:0-3402  [006]  5291.922213: writeback_single_inode: bdi 8:0: ino=268628462 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3984 index=0
       flush-8:0-3402  [006]  5291.922246: writeback_single_inode: bdi 8:0: ino=268628463 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3983 index=0
       flush-8:0-3402  [006]  5291.922277: writeback_single_inode: bdi 8:0: ino=268628464 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3982 index=0
       flush-8:0-3402  [006]  5291.922310: writeback_single_inode: bdi 8:0: ino=268628465 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3981 index=0
       flush-8:0-3402  [006]  5291.922341: writeback_single_inode: bdi 8:0: ino=268628466 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3980 index=0
       flush-8:0-3402  [006]  5291.922375: writeback_single_inode: bdi 8:0: ino=268628467 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3979 index=0
       flush-8:0-3402  [006]  5291.922406: writeback_single_inode: bdi 8:0: ino=268628468 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3978 index=0
       flush-8:0-3402  [006]  5291.922439: writeback_single_inode: bdi 8:0: ino=268628469 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3977 index=0
       flush-8:0-3402  [006]  5291.922474: writeback_single_inode: bdi 8:0: ino=268628470 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=5 to_write=3972 index=4
       flush-8:0-3402  [006]  5291.922508: writeback_single_inode: bdi 8:0: ino=268628471 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3971 index=0
       flush-8:0-3402  [006]  5291.922539: writeback_single_inode: bdi 8:0: ino=268628472 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3970 index=0
       flush-8:0-3402  [006]  5291.922572: writeback_single_inode: bdi 8:0: ino=268628473 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3969 index=0
       flush-8:0-3402  [006]  5291.922603: writeback_single_inode: bdi 8:0: ino=268628474 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3968 index=0
       flush-8:0-3402  [006]  5291.922636: writeback_single_inode: bdi 8:0: ino=268628475 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3967 index=0
       flush-8:0-3402  [006]  5291.922673: writeback_single_inode: bdi 8:0: ino=268628476 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3966 index=0
       flush-8:0-3402  [006]  5291.922709: writeback_single_inode: bdi 8:0: ino=268628477 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3965 index=0
       flush-8:0-3402  [006]  5291.922741: writeback_single_inode: bdi 8:0: ino=268628478 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3964 index=0
       flush-8:0-3402  [006]  5291.922777: writeback_single_inode: bdi 8:0: ino=268628479 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3963 index=0
       flush-8:0-3402  [006]  5291.922810: writeback_single_inode: bdi 8:0: ino=268628480 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3961 index=1
       flush-8:0-3402  [006]  5291.922850: writeback_single_inode: bdi 8:0: ino=268628481 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3960 index=0
       flush-8:0-3402  [006]  5291.922882: writeback_single_inode: bdi 8:0: ino=268628482 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3959 index=0
       flush-8:0-3402  [006]  5291.922915: writeback_single_inode: bdi 8:0: ino=268628483 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3958 index=0
       flush-8:0-3402  [006]  5291.922946: writeback_single_inode: bdi 8:0: ino=268628484 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3957 index=0
       flush-8:0-3402  [006]  5291.922980: writeback_single_inode: bdi 8:0: ino=268628485 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3956 index=0
       flush-8:0-3402  [006]  5291.923015: writeback_single_inode: bdi 8:0: ino=134217870 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3953 index=2
       flush-8:0-3402  [006]  5291.923052: writeback_single_inode: bdi 8:0: ino=134217871 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3949 index=3
       flush-8:0-3402  [006]  5291.923090: writeback_single_inode: bdi 8:0: ino=134217872 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=8 to_write=3941 index=7
       flush-8:0-3402  [006]  5291.923129: writeback_single_inode: bdi 8:0: ino=134217873 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=7 to_write=3934 index=6
       flush-8:0-3402  [006]  5291.923167: writeback_single_inode: bdi 8:0: ino=134217874 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=7 to_write=3927 index=6
       flush-8:0-3402  [006]  5291.923202: writeback_single_inode: bdi 8:0: ino=134217875 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3925 index=1
       flush-8:0-3402  [006]  5291.923234: writeback_single_inode: bdi 8:0: ino=134217876 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3924 index=0
       flush-8:0-3402  [006]  5291.923268: writeback_single_inode: bdi 8:0: ino=402653318 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3923 index=0
       flush-8:0-3402  [006]  5291.923305: writeback_single_inode: bdi 8:0: ino=402653319 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=6 to_write=3917 index=5
       flush-8:0-3402  [006]  5291.923341: writeback_single_inode: bdi 8:0: ino=402653320 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3915 index=1
       flush-8:0-3402  [006]  5291.923372: writeback_single_inode: bdi 8:0: ino=402653321 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3914 index=0
       flush-8:0-3402  [006]  5291.923410: writeback_single_inode: bdi 8:0: ino=402653322 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3910 index=3
       flush-8:0-3402  [006]  5291.923444: writeback_single_inode: bdi 8:0: ino=402653323 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3906 index=3
       flush-8:0-3402  [006]  5291.923483: writeback_single_inode: bdi 8:0: ino=402653324 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3903 index=2
       flush-8:0-3402  [006]  5291.923521: writeback_single_inode: bdi 8:0: ino=402653325 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=8 to_write=3895 index=7
       flush-8:0-3402  [006]  5291.923556: writeback_single_inode: bdi 8:0: ino=143 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3894 index=0
       flush-8:0-3402  [006]  5291.923595: writeback_single_inode: bdi 8:0: ino=144 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=10 to_write=3884 index=9
       flush-8:0-3402  [006]  5291.923630: writeback_single_inode: bdi 8:0: ino=145 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3882 index=1
       flush-8:0-3402  [006]  5291.923673: writeback_single_inode: bdi 8:0: ino=146 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=7 to_write=3875 index=6
       flush-8:0-3402  [006]  5291.923711: writeback_single_inode: bdi 8:0: ino=147 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3874 index=0
       flush-8:0-3402  [006]  5291.923746: writeback_single_inode: bdi 8:0: ino=148 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3870 index=3
       flush-8:0-3402  [006]  5291.923780: writeback_single_inode: bdi 8:0: ino=149 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3869 index=0
       flush-8:0-3402  [006]  5291.923817: writeback_single_inode: bdi 8:0: ino=150 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=6 to_write=3863 index=5
       flush-8:0-3402  [006]  5291.923852: writeback_single_inode: bdi 8:0: ino=151 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3860 index=2
       flush-8:0-3402  [006]  5291.923887: writeback_single_inode: bdi 8:0: ino=152 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3856 index=3
       flush-8:0-3402  [006]  5291.923931: writeback_single_inode: bdi 8:0: ino=153 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=13 to_write=3843 index=12
       flush-8:0-3402  [006]  5291.923964: writeback_single_inode: bdi 8:0: ino=154 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3841 index=1
       flush-8:0-3402  [006]  5291.924014: writeback_single_inode: bdi 8:0: ino=155 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=18 to_write=3823 index=13
       flush-8:0-3402  [006]  5291.924045: writeback_single_inode: bdi 8:0: ino=156 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3822 index=0
       flush-8:0-3402  [006]  5291.924092: writeback_single_inode: bdi 8:0: ino=157 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=13 to_write=3809 index=12
       flush-8:0-3402  [006]  5291.924127: writeback_single_inode: bdi 8:0: ino=402653326 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3805 index=3
       flush-8:0-3402  [006]  5291.924167: writeback_single_inode: bdi 8:0: ino=402653327 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=8 to_write=3797 index=7
       flush-8:0-3402  [006]  5291.924203: writeback_single_inode: bdi 8:0: ino=402653328 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=5 to_write=3792 index=4
       flush-8:0-3402  [006]  5291.924242: writeback_single_inode: bdi 8:0: ino=402653329 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3789 index=2
       flush-8:0-3402  [006]  5291.924282: writeback_single_inode: bdi 8:0: ino=402653330 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=11 to_write=3778 index=10
       flush-8:0-3402  [006]  5291.924330: writeback_single_inode: bdi 8:0: ino=402653331 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=17 to_write=3761 index=13
       flush-8:0-3402  [006]  5291.924370: writeback_single_inode: bdi 8:0: ino=402653332 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=11 to_write=3750 index=10
       flush-8:0-3402  [006]  5291.924413: writeback_single_inode: bdi 8:0: ino=402653333 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=12 to_write=3738 index=11
       flush-8:0-3402  [006]  5291.924446: writeback_single_inode: bdi 8:0: ino=402653334 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3735 index=2
       flush-8:0-3402  [006]  5291.924483: writeback_single_inode: bdi 8:0: ino=402653335 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3731 index=3
       flush-8:0-3402  [006]  5291.924513: writeback_single_inode: bdi 8:0: ino=402653336 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3730 index=0
       flush-8:0-3402  [006]  5291.924554: writeback_single_inode: bdi 8:0: ino=402653337 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=8 to_write=3722 index=7
       flush-8:0-3402  [006]  5291.924588: writeback_single_inode: bdi 8:0: ino=402653338 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3719 index=2
       flush-8:0-3402  [006]  5291.924626: writeback_single_inode: bdi 8:0: ino=402653339 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3717 index=1
       flush-8:0-3402  [006]  5291.924679: writeback_single_inode: bdi 8:0: ino=402653340 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=12 to_write=3705 index=11
       flush-8:0-3402  [006]  5291.924719: writeback_single_inode: bdi 8:0: ino=402653341 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3704 index=0
       flush-8:0-3402  [006]  5291.924751: writeback_single_inode: bdi 8:0: ino=402653342 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3702 index=1
       flush-8:0-3402  [006]  5291.924787: writeback_single_inode: bdi 8:0: ino=402653343 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3699 index=2
       flush-8:0-3402  [006]  5291.924820: writeback_single_inode: bdi 8:0: ino=402653344 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3697 index=1
       flush-8:0-3402  [006]  5291.924856: writeback_single_inode: bdi 8:0: ino=402653345 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3693 index=3
       flush-8:0-3402  [006]  5291.924888: writeback_single_inode: bdi 8:0: ino=402653346 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3692 index=0
       flush-8:0-3402  [006]  5291.924921: writeback_single_inode: bdi 8:0: ino=402653347 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3691 index=0
       flush-8:0-3402  [006]  5291.924952: writeback_single_inode: bdi 8:0: ino=402653348 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3690 index=0
       flush-8:0-3402  [006]  5291.924995: writeback_single_inode: bdi 8:0: ino=402653349 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=9 to_write=3681 index=8
       flush-8:0-3402  [006]  5291.925035: writeback_single_inode: bdi 8:0: ino=402653350 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=10 to_write=3671 index=9
       flush-8:0-3402  [006]  5291.925070: writeback_single_inode: bdi 8:0: ino=134217878 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3670 index=0
       flush-8:0-3402  [006]  5291.925103: writeback_single_inode: bdi 8:0: ino=134217879 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3668 index=1
       flush-8:0-3402  [006]  5291.925140: writeback_single_inode: bdi 8:0: ino=134217880 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=5 to_write=3663 index=4
       flush-8:0-3402  [006]  5291.925181: writeback_single_inode: bdi 8:0: ino=134217881 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=12 to_write=3651 index=11
       flush-8:0-3402  [006]  5291.925235: writeback_single_inode: bdi 8:0: ino=134217882 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=24 to_write=3627 index=13
       flush-8:0-3402  [006]  5291.925283: writeback_single_inode: bdi 8:0: ino=134217883 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=20 to_write=3607 index=13
       flush-8:0-3402  [006]  5291.925319: writeback_single_inode: bdi 8:0: ino=134217884 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3605 index=1
       flush-8:0-3402  [006]  5291.925351: writeback_single_inode: bdi 8:0: ino=134217885 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3603 index=1
       flush-8:0-3402  [006]  5291.925386: writeback_single_inode: bdi 8:0: ino=134217886 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3601 index=1
       flush-8:0-3402  [006]  5291.925417: writeback_single_inode: bdi 8:0: ino=134217887 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3600 index=0
       flush-8:0-3402  [006]  5291.925450: writeback_single_inode: bdi 8:0: ino=134217888 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3599 index=0
       flush-8:0-3402  [006]  5291.925481: writeback_single_inode: bdi 8:0: ino=134217889 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3598 index=0
       flush-8:0-3402  [006]  5291.925519: writeback_single_inode: bdi 8:0: ino=134217890 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3596 index=1
       flush-8:0-3402  [006]  5291.925552: writeback_single_inode: bdi 8:0: ino=134217891 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3594 index=1
       flush-8:0-3402  [006]  5291.925594: writeback_single_inode: bdi 8:0: ino=134217892 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=5 to_write=3589 index=4
       flush-8:0-3402  [006]  5291.925626: writeback_single_inode: bdi 8:0: ino=134217893 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3588 index=0
       flush-8:0-3402  [006]  5291.925669: writeback_single_inode: bdi 8:0: ino=134217894 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3584 index=3
       flush-8:0-3402  [006]  5291.925703: writeback_single_inode: bdi 8:0: ino=134217895 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3582 index=1
       flush-8:0-3402  [006]  5291.925746: writeback_single_inode: bdi 8:0: ino=134217896 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=8 to_write=3574 index=7
       flush-8:0-3402  [006]  5291.925777: writeback_single_inode: bdi 8:0: ino=134217897 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3573 index=0
       flush-8:0-3402  [006]  5291.925813: writeback_single_inode: bdi 8:0: ino=134217898 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3571 index=1
       flush-8:0-3402  [006]  5291.925850: writeback_single_inode: bdi 8:0: ino=134217899 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=7 to_write=3564 index=6
       flush-8:0-3402  [006]  5291.925891: writeback_single_inode: bdi 8:0: ino=134217900 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=7 to_write=3557 index=6
       flush-8:0-3402  [006]  5291.925925: writeback_single_inode: bdi 8:0: ino=134217901 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3554 index=2
       flush-8:0-3402  [006]  5291.925965: writeback_single_inode: bdi 8:0: ino=134217902 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=7 to_write=3547 index=6
       flush-8:0-3402  [006]  5291.925999: writeback_single_inode: bdi 8:0: ino=134217903 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3544 index=2
       flush-8:0-3402  [006]  5291.926033: writeback_single_inode: bdi 8:0: ino=134217904 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3543 index=0
       flush-8:0-3402  [006]  5291.926065: writeback_single_inode: bdi 8:0: ino=134217905 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3541 index=1
       flush-8:0-3402  [006]  5291.926100: writeback_single_inode: bdi 8:0: ino=134217906 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3539 index=1
       flush-8:0-3402  [006]  5291.926131: writeback_single_inode: bdi 8:0: ino=134217907 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3538 index=0
       flush-8:0-3402  [006]  5291.926164: writeback_single_inode: bdi 8:0: ino=134217908 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3537 index=0
       flush-8:0-3402  [006]  5291.926197: writeback_single_inode: bdi 8:0: ino=134217909 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3535 index=1
       flush-8:0-3402  [006]  5291.926232: writeback_single_inode: bdi 8:0: ino=134217910 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3533 index=1
       flush-8:0-3402  [006]  5291.926264: writeback_single_inode: bdi 8:0: ino=134217911 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3531 index=1
       flush-8:0-3402  [006]  5291.926298: writeback_single_inode: bdi 8:0: ino=134217912 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3530 index=0
       flush-8:0-3402  [006]  5291.926338: writeback_single_inode: bdi 8:0: ino=134217913 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=11 to_write=3519 index=10
       flush-8:0-3402  [006]  5291.926376: writeback_single_inode: bdi 8:0: ino=134217914 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3517 index=1
       flush-8:0-3402  [006]  5291.926411: writeback_single_inode: bdi 8:0: ino=134217915 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3514 index=2
       flush-8:0-3402  [006]  5291.926450: writeback_single_inode: bdi 8:0: ino=134217916 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3511 index=2
       flush-8:0-3402  [006]  5291.926482: writeback_single_inode: bdi 8:0: ino=134217917 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3510 index=0
       flush-8:0-3402  [006]  5291.926516: writeback_single_inode: bdi 8:0: ino=134217918 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3508 index=1
       flush-8:0-3402  [006]  5291.926549: writeback_single_inode: bdi 8:0: ino=134217919 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3506 index=1
       flush-8:0-3402  [006]  5291.926594: writeback_single_inode: bdi 8:0: ino=134217984 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=9 to_write=3497 index=8
       flush-8:0-3402  [006]  5291.926627: writeback_single_inode: bdi 8:0: ino=134217985 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3494 index=2
       flush-8:0-3402  [006]  5291.926667: writeback_single_inode: bdi 8:0: ino=134217986 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3493 index=0
       flush-8:0-3402  [006]  5291.926699: writeback_single_inode: bdi 8:0: ino=134217987 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3492 index=0
       flush-8:0-3402  [006]  5291.926732: writeback_single_inode: bdi 8:0: ino=134217988 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3491 index=0
       flush-8:0-3402  [006]  5291.926763: writeback_single_inode: bdi 8:0: ino=134217989 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3490 index=0
       flush-8:0-3402  [006]  5291.926796: writeback_single_inode: bdi 8:0: ino=134217990 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3489 index=0
       flush-8:0-3402  [006]  5291.926827: writeback_single_inode: bdi 8:0: ino=134217991 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3488 index=0
       flush-8:0-3402  [006]  5291.926862: writeback_single_inode: bdi 8:0: ino=134217992 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3486 index=1
       flush-8:0-3402  [006]  5291.926895: writeback_single_inode: bdi 8:0: ino=134217993 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3484 index=1
       flush-8:0-3402  [006]  5291.926928: writeback_single_inode: bdi 8:0: ino=134217994 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3483 index=0
       flush-8:0-3402  [006]  5291.926961: writeback_single_inode: bdi 8:0: ino=134217995 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3482 index=0
       flush-8:0-3402  [006]  5291.926996: writeback_single_inode: bdi 8:0: ino=134217996 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3480 index=1
       flush-8:0-3402  [006]  5291.927029: writeback_single_inode: bdi 8:0: ino=134217997 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3478 index=1
       flush-8:0-3402  [006]  5291.927064: writeback_single_inode: bdi 8:0: ino=134217998 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3476 index=1
       flush-8:0-3402  [006]  5291.927096: writeback_single_inode: bdi 8:0: ino=134217999 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3474 index=1
       flush-8:0-3402  [006]  5291.927135: writeback_single_inode: bdi 8:0: ino=134218000 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3472 index=1
       flush-8:0-3402  [006]  5291.927168: writeback_single_inode: bdi 8:0: ino=134218001 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3470 index=1
       flush-8:0-3402  [006]  5291.927205: writeback_single_inode: bdi 8:0: ino=134218002 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3468 index=1
       flush-8:0-3402  [006]  5291.927247: writeback_single_inode: bdi 8:0: ino=134218003 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=8 to_write=3460 index=7
       flush-8:0-3402  [006]  5291.927285: writeback_single_inode: bdi 8:0: ino=134218004 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3456 index=3
       flush-8:0-3402  [006]  5291.927320: writeback_single_inode: bdi 8:0: ino=134218005 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3452 index=3
       flush-8:0-3402  [006]  5291.927355: writeback_single_inode: bdi 8:0: ino=134218006 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3450 index=1
       flush-8:0-3402  [006]  5291.927388: writeback_single_inode: bdi 8:0: ino=134218007 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3448 index=1
       flush-8:0-3402  [006]  5291.927421: writeback_single_inode: bdi 8:0: ino=134218008 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3447 index=0
       flush-8:0-3402  [006]  5291.927454: writeback_single_inode: bdi 8:0: ino=134218009 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3445 index=1
       flush-8:0-3402  [006]  5291.927487: writeback_single_inode: bdi 8:0: ino=134218010 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3444 index=0
       flush-8:0-3402  [006]  5291.927518: writeback_single_inode: bdi 8:0: ino=134218011 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3443 index=0
       flush-8:0-3402  [006]  5291.927555: writeback_single_inode: bdi 8:0: ino=134218012 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3441 index=1
       flush-8:0-3402  [006]  5291.927604: writeback_single_inode: bdi 8:0: ino=134218013 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=22 to_write=3419 index=13
       flush-8:0-3402  [006]  5291.927639: writeback_single_inode: bdi 8:0: ino=134218014 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3417 index=1
       flush-8:0-3402  [006]  5291.927681: writeback_single_inode: bdi 8:0: ino=134218015 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3414 index=2
       flush-8:0-3402  [006]  5291.927717: writeback_single_inode: bdi 8:0: ino=134218016 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3411 index=2
       flush-8:0-3402  [006]  5291.927747: writeback_single_inode: bdi 8:0: ino=134218017 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3410 index=0
       flush-8:0-3402  [006]  5291.927782: writeback_single_inode: bdi 8:0: ino=134218018 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3408 index=1
       flush-8:0-3402  [006]  5291.927815: writeback_single_inode: bdi 8:0: ino=134218019 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3406 index=1
       flush-8:0-3402  [006]  5291.927852: writeback_single_inode: bdi 8:0: ino=134218020 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3404 index=1
       flush-8:0-3402  [006]  5291.927885: writeback_single_inode: bdi 8:0: ino=134218021 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3401 index=2
       flush-8:0-3402  [006]  5291.927921: writeback_single_inode: bdi 8:0: ino=134218022 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3398 index=2
       flush-8:0-3402  [006]  5291.927952: writeback_single_inode: bdi 8:0: ino=134218023 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3397 index=0
       flush-8:0-3402  [006]  5291.927986: writeback_single_inode: bdi 8:0: ino=134218024 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3396 index=0
       flush-8:0-3402  [006]  5291.928020: writeback_single_inode: bdi 8:0: ino=134218025 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3393 index=2
       flush-8:0-3402  [006]  5291.928058: writeback_single_inode: bdi 8:0: ino=134218026 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3391 index=1
       flush-8:0-3402  [006]  5291.928093: writeback_single_inode: bdi 8:0: ino=134218027 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3387 index=3
       flush-8:0-3402  [006]  5291.928130: writeback_single_inode: bdi 8:0: ino=134218028 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3385 index=1
       flush-8:0-3402  [006]  5291.928162: writeback_single_inode: bdi 8:0: ino=134218029 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3383 index=1
       flush-8:0-3402  [006]  5291.928197: writeback_single_inode: bdi 8:0: ino=134218030 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3381 index=1
       flush-8:0-3402  [006]  5291.928228: writeback_single_inode: bdi 8:0: ino=134218031 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3380 index=0
       flush-8:0-3402  [006]  5291.928262: writeback_single_inode: bdi 8:0: ino=134218032 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3379 index=0
       flush-8:0-3402  [006]  5291.928294: writeback_single_inode: bdi 8:0: ino=134218033 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3377 index=1
       flush-8:0-3402  [006]  5291.928333: writeback_single_inode: bdi 8:0: ino=134218034 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3375 index=1
       flush-8:0-3402  [006]  5291.928367: writeback_single_inode: bdi 8:0: ino=134218035 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3372 index=2
       flush-8:0-3402  [006]  5291.928408: writeback_single_inode: bdi 8:0: ino=134218036 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=5 to_write=3367 index=4
       flush-8:0-3402  [006]  5291.928441: writeback_single_inode: bdi 8:0: ino=134218037 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3365 index=1
       flush-8:0-3402  [006]  5291.928476: writeback_single_inode: bdi 8:0: ino=134218038 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3363 index=1
       flush-8:0-3402  [006]  5291.928507: writeback_single_inode: bdi 8:0: ino=134218039 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3362 index=0
       flush-8:0-3402  [006]  5291.928545: writeback_single_inode: bdi 8:0: ino=134218040 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3360 index=1
       flush-8:0-3402  [006]  5291.928579: writeback_single_inode: bdi 8:0: ino=134218041 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3357 index=2
       flush-8:0-3402  [006]  5291.928613: writeback_single_inode: bdi 8:0: ino=134218042 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3356 index=0
       flush-8:0-3402  [006]  5291.928653: writeback_single_inode: bdi 8:0: ino=134218043 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3353 index=2
       flush-8:0-3402  [006]  5291.928690: writeback_single_inode: bdi 8:0: ino=134218044 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3351 index=1
       flush-8:0-3402  [006]  5291.928724: writeback_single_inode: bdi 8:0: ino=134218045 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3348 index=2
       flush-8:0-3402  [006]  5291.928758: writeback_single_inode: bdi 8:0: ino=134218046 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3347 index=0
       flush-8:0-3402  [006]  5291.928793: writeback_single_inode: bdi 8:0: ino=134218047 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=5 to_write=3342 index=4
       flush-8:0-3402  [006]  5291.928826: writeback_single_inode: bdi 8:0: ino=134218048 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3341 index=0
       flush-8:0-3402  [006]  5291.928858: writeback_single_inode: bdi 8:0: ino=134218049 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3340 index=0
       flush-8:0-3402  [006]  5291.928902: writeback_single_inode: bdi 8:0: ino=134218050 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3338 index=1
       flush-8:0-3402  [006]  5291.928934: writeback_single_inode: bdi 8:0: ino=134218051 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3337 index=0
       flush-8:0-3402  [006]  5291.928967: writeback_single_inode: bdi 8:0: ino=134218052 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3336 index=0
       flush-8:0-3402  [006]  5291.929001: writeback_single_inode: bdi 8:0: ino=134218053 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3333 index=2
       flush-8:0-3402  [006]  5291.929039: writeback_single_inode: bdi 8:0: ino=134218054 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=5 to_write=3328 index=4
       flush-8:0-3402  [006]  5291.929070: writeback_single_inode: bdi 8:0: ino=134218055 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3327 index=0
       flush-8:0-3402  [006]  5291.929105: writeback_single_inode: bdi 8:0: ino=134218056 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3325 index=1
       flush-8:0-3402  [006]  5291.929137: writeback_single_inode: bdi 8:0: ino=134218057 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3324 index=0
       flush-8:0-3402  [006]  5291.929170: writeback_single_inode: bdi 8:0: ino=134218058 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3323 index=0
       flush-8:0-3402  [006]  5291.929201: writeback_single_inode: bdi 8:0: ino=134218059 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3322 index=0
       flush-8:0-3402  [006]  5291.929279: writeback_single_inode: bdi 8:0: ino=402653351 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=51 to_write=3271 index=13
       flush-8:0-3402  [006]  5291.929314: writeback_single_inode: bdi 8:0: ino=402653352 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=5 to_write=3266 index=4
       flush-8:0-3402  [006]  5291.929352: writeback_single_inode: bdi 8:0: ino=402653353 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3262 index=3
       flush-8:0-3402  [006]  5291.929389: writeback_single_inode: bdi 8:0: ino=134218060 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=7 to_write=3255 index=6
       flush-8:0-3402  [006]  5291.929430: writeback_single_inode: bdi 8:0: ino=134218061 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=8 to_write=3247 index=7
       flush-8:0-3402  [006]  5291.929461: writeback_single_inode: bdi 8:0: ino=134218062 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3246 index=0
       flush-8:0-3402  [006]  5291.929495: writeback_single_inode: bdi 8:0: ino=134218063 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3245 index=0
       flush-8:0-3402  [006]  5291.929526: writeback_single_inode: bdi 8:0: ino=134218064 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3244 index=0
       flush-8:0-3402  [006]  5291.929559: writeback_single_inode: bdi 8:0: ino=134218065 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3243 index=0
       flush-8:0-3402  [006]  5291.929594: writeback_single_inode: bdi 8:0: ino=134218066 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3239 index=3
       flush-8:0-3402  [006]  5291.929629: writeback_single_inode: bdi 8:0: ino=268628487 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3238 index=0
       flush-8:0-3402  [006]  5291.929671: writeback_single_inode: bdi 8:0: ino=268628488 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=4 to_write=3234 index=3
       flush-8:0-3402  [006]  5291.929709: writeback_single_inode: bdi 8:0: ino=268628489 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3231 index=2
       flush-8:0-3402  [006]  5291.929744: writeback_single_inode: bdi 8:0: ino=268628490 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=5 to_write=3226 index=4
       flush-8:0-3402  [006]  5291.929780: writeback_single_inode: bdi 8:0: ino=268628491 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3225 index=0
       flush-8:0-3402  [006]  5291.929817: writeback_single_inode: bdi 8:0: ino=268628492 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=7 to_write=3218 index=6
       flush-8:0-3402  [006]  5291.929853: writeback_single_inode: bdi 8:0: ino=268628493 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=3 to_write=3215 index=2
       flush-8:0-3402  [006]  5291.929885: writeback_single_inode: bdi 8:0: ino=402653355 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=1 to_write=3214 index=0
       flush-8:0-3402  [006]  5291.929919: writeback_single_inode: bdi 8:0: ino=402653356 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3212 index=1
       flush-8:0-3402  [006]  5291.929956: writeback_single_inode: bdi 8:0: ino=402653357 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=7 to_write=3205 index=6
       flush-8:0-3402  [006]  5291.929994: writeback_single_inode: bdi 8:0: ino=402653358 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3203 index=1
       flush-8:0-3402  [006]  5291.930027: writeback_single_inode: bdi 8:0: ino=402653359 state=I_DIRTY_SYNC|I_DIRTY_PAGES age=0 wrote=2 to_write=3201 index=1
wfg /tmp%

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
