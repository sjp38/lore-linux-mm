Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 04F396B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 13:37:03 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id ia10so1236213vcb.20
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 10:37:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130809075523.GA14574@quack.suse.cz>
References: <cover.1375729665.git.luto@amacapital.net> <20130807134058.GC12843@quack.suse.cz>
 <520286A4.1020101@intel.com> <CALCETrXAz1fc7y07LhmxNh6zA_KZB4yv57NY2MrhUwKdkypB9w@mail.gmail.com>
 <20130808101807.GB4325@quack.suse.cz> <CALCETrX1GXr58ujqAVT5_DtOx+8GEiyb9svK-SGH9d+7SXiNqQ@mail.gmail.com>
 <20130808185340.GA13926@quack.suse.cz> <CALCETrVXTXzXAmUsmmWxwr6vK+Vux7_pUzWPYyHjxEbn3ObABg@mail.gmail.com>
 <5204229F.8000507@intel.com> <20130809075523.GA14574@quack.suse.cz>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 9 Aug 2013 10:36:41 -0700
Message-ID: <CALCETrU6j=X0KcuiNQxcsBiwD-o+PcDVbA2usV+fr+8M-1zm9Q@mail.gmail.com>
Subject: Re: [RFC 0/3] Add madvise(..., MADV_WILLWRITE)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Aug 9, 2013 at 12:55 AM, Jan Kara <jack@suse.cz> wrote:
> On Thu 08-08-13 15:58:39, Dave Hansen wrote:
>> I was coincidentally tracking down what I thought was a scalability
>> problem (turned out to be full disks :).  I noticed, though, that ext4
>> is about 20% slower than ext2/3 at doing write page faults (x-axis is
>> number of tasks):
>>
>> http://www.sr71.net/~dave/intel/page-fault-exts/cmp.html?1=ext3&2=ext4&hide=linear,threads,threads_idle,processes_idle&rollPeriod=5
>>
>> The test case is:
>>
>>       https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault3.c
>   The reason is that ext2/ext3 do almost nothing in their write fault
> handler - they are about as fast as it can get. ext4 OTOH needs to reserve
> blocks for delayed allocation, setup buffers under a page etc. This is
> necessary if you want to make sure that if data are written via mmap, they
> also have space available on disk to be written to (ext2 / ext3 do not care
> and will just drop the data on the floor if you happen to hit ENOSPC during
> writeback).

Out of curiosity, why does ext4 need to set up buffers?  That is, as
long as the fs can guarantee that there is reserved space to write out
the page, why isn't it sufficient to just mark the page dirty and let
the writeback code set up the buffers?

>
> I'm not saying ext4 write fault path cannot possibly be optimized (noone
> seriously looked into that AFAIK so there may well be some low hanging
> fruit) but it will always be slower than ext2/3. A more meaningful
> comparison would be with filesystems like XFS which make similar guarantees
> regarding data safety.

FWIW, back when I actually tested this stuff, I had awful performance
on XFS, btrfs, and ext4.  But I'm really only interested in the
whether IO (or waiting for contended locks) happens on faults or not
-- a handful of microseconds while the fs allocates something from a
slab doesn't really bother me.


--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
