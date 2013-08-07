Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id BD5076B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 14:01:13 -0400 (EDT)
Received: by mail-vb0-f49.google.com with SMTP id w16so2163560vbb.36
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 11:01:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <520286A4.1020101@intel.com>
References: <cover.1375729665.git.luto@amacapital.net> <20130807134058.GC12843@quack.suse.cz>
 <520286A4.1020101@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 7 Aug 2013 11:00:52 -0700
Message-ID: <CALCETrXAz1fc7y07LhmxNh6zA_KZB4yv57NY2MrhUwKdkypB9w@mail.gmail.com>
Subject: Re: [RFC 0/3] Add madvise(..., MADV_WILLWRITE)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Aug 7, 2013 at 10:40 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 08/07/2013 06:40 AM, Jan Kara wrote:
>>   One question before I look at the patches: Why don't you use fallocate()
>> in your application? The functionality you require seems to be pretty
>> similar to it - writing to an already allocated block is usually quick.
>
> One problem I've seen is that it still costs you a fault per-page to get
> the PTEs in to a state where you can write to the memory.  MADV_WILLNEED
> will do readahead to get the page cache filled, but it still leaves the
> pages unmapped.  Those faults get expensive when you're trying to do a
> couple hundred million of them all at once.

I have grand plans to teach the kernel to use hardware dirty tracking
so that (some?) pages can be left clean and writable for long periods
of time.  This will be hard.

Even so, the second write fault to a page tends to take only a few
microseconds, while the first one often blocks in fs code.

(mmap_sem is a different story, but I see it as a separate issue.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
