Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4784F6B0037
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 11:48:28 -0500 (EST)
Received: by mail-vc0-f179.google.com with SMTP id ia6so3612284vcb.24
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 08:48:28 -0800 (PST)
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
        by mx.google.com with ESMTPS id x7si2407301vel.0.2014.01.21.08.48.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 08:48:27 -0800 (PST)
Received: by mail-vc0-f181.google.com with SMTP id ie18so3609834vcb.40
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 08:48:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140121111727.GB13997@dastard>
References: <CALCETrUaotUuzn60-bSt1oUb8+94do2QgiCq_TXhqEHj79DePQ@mail.gmail.com>
 <52D8AEBF.3090803@symas.com> <52D982EB.6010507@amacapital.net>
 <52DE23E8.9010608@symas.com> <20140121111727.GB13997@dastard>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 21 Jan 2014 08:48:06 -0800
Message-ID: <CALCETrUWhWDSJNHT5OEmNSyBuGx4-AxqeS3YBcKL0nejZ6kQ4w@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] [ATTEND] Persistent memory
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Howard Chu <hyc@symas.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jan 21, 2014 at 3:17 AM, Dave Chinner <david@fromorbit.com> wrote:
> On Mon, Jan 20, 2014 at 11:38:16PM -0800, Howard Chu wrote:
>> Andy Lutomirski wrote:
>> >On 01/16/2014 08:17 PM, Howard Chu wrote:
>> >>Andy Lutomirski wrote:
>> >>>I'm interested in a persistent memory track.  There seems to be plenty
>> >>>of other emails about this, but here's my take:
>> >>
>> >>I'm also interested in this track. I'm not up on FS development these
>> >>days, the last time I wrote filesystem code was nearly 20 years ago. But
>> >>persistent memory is a topic near and dear to my heart, and of great
>> >>relevance to my current pet project, the LMDB memory-mapped database.
>> >>
>> >>In a previous era I also developed block device drivers for
>> >>battery-backed external DRAM disks. (My ideal would have been systems
>> >>where all of RAM was persistent. I suppose we can just about get there
>> >>with mobile phones and tablets these days.)
>> >>
>> >>In the context of database engines, I'm interested in leveraging
>> >>persistent memory for write-back caching and how user level code can be
>> >>made aware of it. (If all your cache is persistent and guaranteed to
>> >>eventually reach stable store then you never need to fsync() a
>> >>transaction.)
>
> I don't think that is true -  your still going to need fsync to get
> the CPU to flush it's caches and filesystem metadata into the
> persistent domain....

I think that this depends on the technology in question.

I suspect (I don't know for sure) that, if the mapping is WT or UC,
that it would be possible to get the data fully flushed to persistent
storage by doing something like a UC read from any appropriate type of
I/O space (someone from Intel would have to confirm).  There's a
chipset register you're probably supposed to frob (it's well buried in
the public chipset docs), but I don't know how necessary it is.  In
any event, that type of flush is systemwide (or at least
package-wide), so fsyncing a file should be overkill.

Even if caching is on, clflush may be faster than a syscall.  (It's
sad that x86 doesn't have writeback-but-don't-invalidate.  PPC FTW.)

All of this suggests to me that a vsyscall "sync persistent memory"
might be better than a real syscall.

For what it's worth, some of the NV-DIMM systems are supposed to be
configured in such a way that, if power fails, an NMI, SMI, or even
(not really sure) a hardwired thing in the memory controller will
trigger the requisite flush.  I don't personally believe in this if
L2/L3 cache are involved (they're too big), but for the little write
buffers and memory controller things, this seems entirely plausible.

--Andy

>
>> >Hmm.  Presumably that would work by actually allocating cache pages in
>> >persistent memory.  I don't think that anything like the current XIP
>> >interfaces can do that, but it's certainly an interesting thought for
>> >(complicated) future work.
>> >
>> >This might not be pretty in conjunction with something like my
>> >writethrough mapping idea -- read(2) and write(2) would be fine (well,
>> >write(2) might need to use streaming loads), but mmap users who weren't
>> >expecting it might have truly awful performance.  That especially
>> >includes things like databases that aren't expecting this behavior.
>>
>> At the moment all I can suggest is a new mmap() flag, e.g.
>> MAP_PERSISTENT. Not sure how a user or app should discover that it's
>> supported though.
>
> The point of using the XIP interface with filesystems that are
> backed by persistent memory is that mmap() gives userspace
> applications direct acess to the persistent memory directly without
> needing any modifications.  It's just a really, really fast file...
>

I think this was talking about using persistent memory as a
limited-size cache.  In that case, XIP (as currently designed) has no
provision for removing cache pages, so the kernel isn't ready for
this.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
