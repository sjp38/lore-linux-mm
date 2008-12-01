Received: by gv-out-0910.google.com with SMTP id l14so308500gvf.19
        for <linux-mm@kvack.org>; Mon, 01 Dec 2008 03:37:33 -0800 (PST)
Message-ID: <4933CC78.2030707@gmail.com>
Date: Mon, 01 Dec 2008 13:37:28 +0200
From: =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
References: <20081127120330.GM28285@wotan.suse.de> <492E90BC.1090208@gmail.com> <20081127123926.GN28285@wotan.suse.de> <492E97FA.5000804@gmail.com> <20081127130525.GO28285@wotan.suse.de> <492E9C3C.9050507@gmail.com> <20081127131215.GQ28285@wotan.suse.de> <492E9F42.6010808@gmail.com> <20081128121015.GC13786@wotan.suse.de> <4932EBAA.60808@gmail.com> <20081201111301.GB13903@wotan.suse.de>
In-Reply-To: <20081201111301.GB13903@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Mike Waychison <mikew@google.com>, Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On 2008-12-01 13:13, Nick Piggin wrote:
> BTW. I think your source code (I see you updated it since last posting)
> should be very easy to give good hints to the kernel about the IO. I
> will try a few simple tricks and we can see if they help. (this pattern
> of touching memory corresponds well to how your app works?)

It corresponds well to the latencies involved, but only part of the
behaviour:

- in some cases mmap is used to sequentially read a file (PROT_READ,
MAP_PRIVATE), and does operations like
memchr, memcpy on it, my testcase models this
- in some cases it is used to mmap archives, and containers, that have
the index at the end (like zip), so it jumps back and forth between the
end of the file, and the offset indicated there (using pread here may be
better, but using mmap simplified the code a lot)
- there are multiple threads, each processing a different file, the only
data shared between threads is the signature database, so once a thread
started working on a file,
no other thread touches it
- the goal is to process as many files as possible, which works on some
files very well (PE files mostly), but not on others (where I can't load
all cores to 400%)

In either case it pagefaults a lot, and calls mmap() often, which is
what my testcase attempted to model.

You can completely disable mmap usage in clamav, but last I tried that
slowed things down (it falls back to using fread, and reading the entire
file in memory in case of zip).
Perhaps I should try turning off mmap for just portions.

If you find something that improves my testcase, I can try on the real
application and let you know if it improved or not (and perhaps create a
new testcase).

If you want, you can test on the original application (its open source
after all!) too.
I found that scanning my local copy of my Gmail inbox is  a good
testcase. I can walk you through how to configure/setup clamav to test.

Best regards,
--Edwin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
