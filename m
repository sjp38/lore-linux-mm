Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id E42BD6B0033
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 15:25:56 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id ha11so408455vcb.35
        for <linux-mm@kvack.org>; Thu, 08 Aug 2013 12:25:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130808185340.GA13926@quack.suse.cz>
References: <cover.1375729665.git.luto@amacapital.net> <20130807134058.GC12843@quack.suse.cz>
 <520286A4.1020101@intel.com> <CALCETrXAz1fc7y07LhmxNh6zA_KZB4yv57NY2MrhUwKdkypB9w@mail.gmail.com>
 <20130808101807.GB4325@quack.suse.cz> <CALCETrX1GXr58ujqAVT5_DtOx+8GEiyb9svK-SGH9d+7SXiNqQ@mail.gmail.com>
 <20130808185340.GA13926@quack.suse.cz>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 8 Aug 2013 12:25:35 -0700
Message-ID: <CALCETrVXTXzXAmUsmmWxwr6vK+Vux7_pUzWPYyHjxEbn3ObABg@mail.gmail.com>
Subject: Re: [RFC 0/3] Add madvise(..., MADV_WILLWRITE)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Aug 8, 2013 at 11:53 AM, Jan Kara <jack@suse.cz> wrote:
> On Thu 08-08-13 08:56:28, Andy Lutomirski wrote:
>> On Thu, Aug 8, 2013 at 3:18 AM, Jan Kara <jack@suse.cz> wrote:
>> > On Wed 07-08-13 11:00:52, Andy Lutomirski wrote:
>> >> On Wed, Aug 7, 2013 at 10:40 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>> >> > On 08/07/2013 06:40 AM, Jan Kara wrote:
>> >> >>   One question before I look at the patches: Why don't you use fallocate()
>> >> >> in your application? The functionality you require seems to be pretty
>> >> >> similar to it - writing to an already allocated block is usually quick.
>> >> >
>> >> > One problem I've seen is that it still costs you a fault per-page to get
>> >> > the PTEs in to a state where you can write to the memory.  MADV_WILLNEED
>> >> > will do readahead to get the page cache filled, but it still leaves the
>> >> > pages unmapped.  Those faults get expensive when you're trying to do a
>> >> > couple hundred million of them all at once.
>> >>
>> >> I have grand plans to teach the kernel to use hardware dirty tracking
>> >> so that (some?) pages can be left clean and writable for long periods
>> >> of time.  This will be hard.
>> >   Right that will be tough... Although with your application you could
>> > require such pages to be mlocked and then I could imagine we would get away
>> > at least from problems with dirty page accounting.
>>
>> True.  The nasty part will be all the code that assumes that the acts
>> of un-write-protecting and dirtying are the same thing, for example
>> __block_write_begin, which is why I don't really believe in my
>> willwrite patches...
>>
>> >
>> >> Even so, the second write fault to a page tends to take only a few
>> >> microseconds, while the first one often blocks in fs code.
>> >   So you wrote blocks are already preallocated with fallocate(). If you
>> > also preload pages in memory with MADV_WILLNEED is there still big
>> > difference between the first and subsequent write fault?
>>
>> I haven't measured it yet, because I suspect that my patches are
>> rather buggy in their current form.
>   I think you're mistaking MADV_WILLNEED with your MADV_WILLWRITE.
> MADV_WILLNEED will just trigger readahead for the range - thus you should
> have all pages with their block mappings set up in memory. Now the first
> writeable fault will still have to do some work, namely converting
> unwritten extents in extent tree to written ones. So there is going to be
> some difference between the first and subsequent writeable faults. But I'd
> like to see whether the difference is really worth the effort with new
> MADV_... call.
>

Whoops -- I read your email too quickly.  I haven't tried
MADV_WILLNEED, but I think I tried reading each page to fault them in.
 Is there any reason to expect MADV_WILLNEED to do any better?  I'll
try to do some new tests to see how well this all works.

(I imagine that freshly fallocated files are somehow different when
read, since there aren't zeros on the disk backing them until they get
written.)

--Andy

>                                                                 Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
