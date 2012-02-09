Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 15C426B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 08:22:07 -0500 (EST)
Date: Thu, 9 Feb 2012 14:21:55 +0100
From: Johannes Stezenbach <js@sig21.net>
Subject: Re: swap storm since kernel 3.2.x
Message-ID: <20120209132155.GA15147@sig21.net>
References: <201202041109.53003.toralf.foerster@gmx.de>
 <201202051107.26634.toralf.foerster@gmx.de>
 <CAJd=RBCvvVgWqfSkoEaWVG=2mwKhyXarDOthHt9uwOb2fuDE9g@mail.gmail.com>
 <201202080956.18727.toralf.foerster@gmx.de>
 <20120208115244.GA24959@sig21.net>
 <CAJd=RBDbYA4xZRikGtHJvKESdiSE-B4OucZ6vQ+tHCi+hG2+aw@mail.gmail.com>
 <20120209113606.GA8054@sig21.net>
 <CAJd=RBDzUpUgZLVU+WSfb8grzMAbi3fcyyZkpX8qpaxu6zYe1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJd=RBDzUpUgZLVU+WSfb8grzMAbi3fcyyZkpX8qpaxu6zYe1g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Thu, Feb 09, 2012 at 08:02:20PM +0800, Hillf Danton wrote:
> On Thu, Feb 9, 2012 at 7:36 PM, Johannes Stezenbach <js@sig21.net> wrote:
> > On Wed, Feb 08, 2012 at 08:34:14PM +0800, Hillf Danton wrote:
> >> And I want to ask kswapd to do less work, the attached diff is
> >> based on 3.2.5, mind to test it with CONFIG_DEBUG_OBJECTS enabled?
> >
> > Sorry, for slow reply.  The patch does not apply to 3.2.4
> > (3.2.5 only has the ASPM change which I don't want to
> > try atm).  Is the patch below correct?
> >
> 
> It is fine;)

Hm, with 3.2.4 + patch +

CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
CONFIG_DEBUG_OBJECTS_WORK=y
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1

it looks good.  Neither do I get the huge debug_objects_cache
nor does it swap, after running a crosstool-ng toolchain build.
Well, last time I also had one kvm -m 1G instance running.  I'll
try if that triggers the issue.  So far:

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
  689249 689235  99%    0.36K  31334       22    250672K debug_objects_cache
  625185 609295  97%    0.42K  34735       18    277880K buffer_head
  103834 103393  99%    1.74K   7245       18    231840K ext3_inode_cache
   84348  82351  97%    0.58K   3124       27     49984K dentry

MemTotal:        3938800 kB
MemFree:           77136 kB
Buffers:           68892 kB
Cached:          2686376 kB
SwapCached:            8 kB
Active:          1343464 kB
Inactive:        1584476 kB
Active(anon):      78712 kB
Inactive(anon):   145220 kB
Active(file):    1264752 kB
Inactive(file):  1439256 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       3903484 kB
SwapFree:        3903248 kB
Dirty:                64 kB
Writeback:             0 kB
AnonPages:        172676 kB
Mapped:            41868 kB
Shmem:             51260 kB
Slab:             872400 kB
SReclaimable:     549904 kB
SUnreclaim:       322496 kB
KernelStack:        1432 kB
PageTables:         3172 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     5872884 kB
Committed_AS:     474604 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      345800 kB
VmallocChunk:   34359386531 kB
DirectMap4k:       12288 kB
DirectMap2M:     4098048 kB


Thanks,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
