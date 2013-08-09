Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 92A466B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 03:55:31 -0400 (EDT)
Date: Fri, 9 Aug 2013 09:55:23 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 0/3] Add madvise(..., MADV_WILLWRITE)
Message-ID: <20130809075523.GA14574@quack.suse.cz>
References: <cover.1375729665.git.luto@amacapital.net>
 <20130807134058.GC12843@quack.suse.cz>
 <520286A4.1020101@intel.com>
 <CALCETrXAz1fc7y07LhmxNh6zA_KZB4yv57NY2MrhUwKdkypB9w@mail.gmail.com>
 <20130808101807.GB4325@quack.suse.cz>
 <CALCETrX1GXr58ujqAVT5_DtOx+8GEiyb9svK-SGH9d+7SXiNqQ@mail.gmail.com>
 <20130808185340.GA13926@quack.suse.cz>
 <CALCETrVXTXzXAmUsmmWxwr6vK+Vux7_pUzWPYyHjxEbn3ObABg@mail.gmail.com>
 <5204229F.8000507@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5204229F.8000507@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 08-08-13 15:58:39, Dave Hansen wrote:
> I was coincidentally tracking down what I thought was a scalability
> problem (turned out to be full disks :).  I noticed, though, that ext4
> is about 20% slower than ext2/3 at doing write page faults (x-axis is
> number of tasks):
> 
> http://www.sr71.net/~dave/intel/page-fault-exts/cmp.html?1=ext3&2=ext4&hide=linear,threads,threads_idle,processes_idle&rollPeriod=5
> 
> The test case is:
> 
> 	https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault3.c
  The reason is that ext2/ext3 do almost nothing in their write fault
handler - they are about as fast as it can get. ext4 OTOH needs to reserve
blocks for delayed allocation, setup buffers under a page etc. This is
necessary if you want to make sure that if data are written via mmap, they
also have space available on disk to be written to (ext2 / ext3 do not care
and will just drop the data on the floor if you happen to hit ENOSPC during
writeback).

I'm not saying ext4 write fault path cannot possibly be optimized (noone
seriously looked into that AFAIK so there may well be some low hanging
fruit) but it will always be slower than ext2/3. A more meaningful
comparison would be with filesystems like XFS which make similar guarantees
regarding data safety.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
