Date: Wed, 3 Nov 1999 17:46:59 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: Why don't we make mmap MAP_SHARED with /dev/zero possible?
In-Reply-To: <m1r9i7y6gt.fsf@flinx.hidden>
Message-ID: <Pine.LNX.4.10.9911031736450.7408-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, fxzhang@chpc.ict.ac.cn, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 3 Nov 1999, Eric W. Biederman wrote:

> Not really.  I played with the idea, and the only really tricky aspect I saw
> was how to write a version of copy_to/from_user that would handle the bigmem
> case.   Because kmap ... copy .. kunmap  isn't safe as you can sleep due
> to a page fault.

yes, i implemented a new 'kaddr = kmap_permanent(page)'
'kunmap_permanent(kaddr)' interface which is schedulable. This is now
getting used in exec.c (argument pages can be significantly big) and the
page cache.

> And I played with putting a wrapper around ll_rw_block calls in
> buffer.c that would allocate bounce buffers from the buffer cache as
> needed.

that is a much more problematic issue, especially if you consider future
64-bit PCI DMAing. What i did was to change bh->b_data to bh->b_page,
which b_page is a 32-bit value describing the physical address of the
buffer, in 512-byte units. This also ment changing bazillion places where
b_data was used (lowlevel fs, buffer-cache and block layer, device
drivers) ... But it's working just fine on my box:

        moon:~> cat /proc/meminfo

        MemTotal:   8249708 kB
        MemFree:    7760256 kB
        MemShared:        0 kB
        Buffers:      20292 kB
        Cached:      432052 kB <=== 432M pagecache
        HighTotal:  7471104 kB
        HighFree:   7035928 kB <=== 444M high memory allocated
        LowTotal:    778604 kB
        LowFree:     724328 kB <===  50M normal memory allocated
        SwapTotal:        0 kB
        SwapFree:         0 kB


> I'll probably get back to shmfs in a kernel version or two.

looking forward to test it, i believe we could get some spectacular
benchmark numbers with that thing and 2.4 ...

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
