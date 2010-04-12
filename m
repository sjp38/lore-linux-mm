Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0CC226B01F2
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 00:50:33 -0400 (EDT)
Date: Mon, 12 Apr 2010 12:50:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Downsides to madvise/fadvise(willneed) for application startup
Message-ID: <20100412045029.GA18099@localhost>
References: <20100412022704.GB5151@localhost> <g7wssj9j6ukus9yti3UYAxe124vaj_firegpg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <g7wssj9j6ukus9yti3UYAxe124vaj_firegpg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: "drepper@gmail.com" <drepper@gmail.com>
Cc: Taras Glek <tglek@mozilla.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 12:43:00PM +0800, drepper@gmail.com wrote:
> On Sun, Apr 11, 2010 at 19:27, Wu Fengguang <fengguang.wu@intel.com> wrote:
>> Yes, every binary/library starts with this 512b read. A It is requested
>> by ld.so/ld-linux.so, and will trigger a 4-page readahead. This is not
>> good readahead. I wonder if ld.so can switch to mmap read for the
>> first read, in order to trigger a larger 128kb readahead.
>
> We first need to know the sizes of the segments and their location
> in the binary.  The binaries we use now are somewhat well laid out.
> The read-only segment starts at offset 0 etc.  But this doesn't have
> to be the case.  The dynamic linker has to be generic.  Also, even
> if we start mapping at offset zero, now much to map?  The file might
> contain debug info which must not be mapped.  Therefore the first
> read loads enough of the headers to make all of the decisions.  Yes,

I once read the ld code, it's more complex than I expected.

> we could do a mmap of one page instead of the read.  But that's more
> expansive in general, isn't it?

Right. Without considering IO, a simple read(512) is more efficient than
mmap()+read+munmap().

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
