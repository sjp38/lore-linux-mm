Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 3CD2F6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 13:45:01 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id g17so4326647vbg.28
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 10:45:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <520529FD.2080407@intel.com>
References: <cover.1375729665.git.luto@amacapital.net> <20130807134058.GC12843@quack.suse.cz>
 <520286A4.1020101@intel.com> <CALCETrXAz1fc7y07LhmxNh6zA_KZB4yv57NY2MrhUwKdkypB9w@mail.gmail.com>
 <20130808101807.GB4325@quack.suse.cz> <CALCETrX1GXr58ujqAVT5_DtOx+8GEiyb9svK-SGH9d+7SXiNqQ@mail.gmail.com>
 <20130808185340.GA13926@quack.suse.cz> <CALCETrVXTXzXAmUsmmWxwr6vK+Vux7_pUzWPYyHjxEbn3ObABg@mail.gmail.com>
 <5204229F.8000507@intel.com> <20130809075523.GA14574@quack.suse.cz> <520529FD.2080407@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 9 Aug 2013 10:44:40 -0700
Message-ID: <CALCETrU5+Rh9Ujw2tKdWb_fZ=idUKWNrj3qc+tOxmDh_5xCDZg@mail.gmail.com>
Subject: Re: [RFC 0/3] Add madvise(..., MADV_WILLWRITE)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Aug 9, 2013 at 10:42 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 08/09/2013 12:55 AM, Jan Kara wrote:
>> On Thu 08-08-13 15:58:39, Dave Hansen wrote:
>>> > I was coincidentally tracking down what I thought was a scalability
>>> > problem (turned out to be full disks :).  I noticed, though, that ext4
>>> > is about 20% slower than ext2/3 at doing write page faults (x-axis is
>>> > number of tasks):
>>> >
>>> > http://www.sr71.net/~dave/intel/page-fault-exts/cmp.html?1=ext3&2=ext4&hide=linear,threads,threads_idle,processes_idle&rollPeriod=5
>>> >
>>> > The test case is:
>>> >
>>> >    https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault3.c
>>   The reason is that ext2/ext3 do almost nothing in their write fault
>> handler - they are about as fast as it can get. ext4 OTOH needs to reserve
>> blocks for delayed allocation, setup buffers under a page etc. This is
>> necessary if you want to make sure that if data are written via mmap, they
>> also have space available on disk to be written to (ext2 / ext3 do not care
>> and will just drop the data on the floor if you happen to hit ENOSPC during
>> writeback).
>
> I did try throwing a fallocate() in there to see if it helped.  It
> didn't appear to help.  Should it have?


Try reading all the pages after mmap (and keep the fallocate).

In theory, MAP_POPULATE should help some, but until Linux 3.9
MAP_POPULATE was a disaster, and I'm still a bit afraid of it.

--Andy


-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
