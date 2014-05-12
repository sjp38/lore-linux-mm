Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 875356B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 13:05:47 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so4858226eek.21
        for <linux-mm@kvack.org>; Mon, 12 May 2014 10:05:46 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id d5si11029606eei.88.2014.05.12.10.05.45
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 10:05:46 -0700 (PDT)
Date: Mon, 12 May 2014 20:05:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm: replace remap_file_pages() syscall with emulation
Message-ID: <20140512170514.GA28227@node.dhcp.inet.fi>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1399552888-11024-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20140508145729.3d82d2c989cfc483c94eb324@linux-foundation.org>
 <5370E4B4.1060802@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5370E4B4.1060802@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

On Mon, May 12, 2014 at 11:11:48AM -0400, Sasha Levin wrote:
> On 05/08/2014 05:57 PM, Andrew Morton wrote:
> > On Thu,  8 May 2014 15:41:28 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> >> > remap_file_pages(2) was invented to be able efficiently map parts of
> >> > huge file into limited 32-bit virtual address space such as in database
> >> > workloads.
> >> > 
> >> > Nonlinear mappings are pain to support and it seems there's no
> >> > legitimate use-cases nowadays since 64-bit systems are widely available.
> >> > 
> >> > Let's drop it and get rid of all these special-cased code.
> >> > 
> >> > The patch replaces the syscall with emulation which creates new VMA on
> >> > each remap_file_pages(), unless they it can be merged with an adjacent
> >> > one.
> >> > 
> >> > I didn't find *any* real code that uses remap_file_pages(2) to test
> >> > emulation impact on. I've checked Debian code search and source of all
> >> > packages in ALT Linux. No real users: libc wrappers, mentions in strace,
> >> > gdb, valgrind and this kind of stuff.
> >> > 
> >> > There are few basic tests in LTP for the syscall. They work just fine
> >> > with emulation.
> >> > 
> >> > To test performance impact, I've written small test case which
> >> > demonstrate pretty much worst case scenario: map 4G shmfs file, write to
> >> > begin of every page pgoff of the page, remap pages in reverse order,
> >> > read every page.
> >> > 
> >> > The test creates 1 million of VMAs if emulation is in use, so I had to
> >> > set vm.max_map_count to 1100000 to avoid -ENOMEM.
> >> > 
> >> > Before:		23.3 ( +-  4.31% ) seconds
> >> > After:		43.9 ( +-  0.85% ) seconds
> >> > Slowdown:	1.88x
> >> > 
> >> > I believe we can live with that.
> >> > 
> > There's still all the special-case goop around the place to be cleaned
> > up - VM_NONLINEAR is a decent search term.  As is "grep nonlinear
> > mm/*.c".  And although this cleanup is the main reason for the
> > patchset, let's not do it now - we can do all that if/after this patch
> > get merged.
> > 
> > I'll queue the patches for some linux-next exposure and shall send
> > [1/2] Linuswards for 3.16 if nothing terrible happens.  Once we've
> > sorted out the too-many-vmas issue we'll need to work out when to merge
> > [2/2].
> 
> It seems that since no one is really using it, it's also impossible to
> properly test it. I've sent a fix that deals with panics in error paths
> that are very easy to trigger, but I'm worried that there are a lot more
> of those hiding over there.

Sorry for that.

> Since we can't find any actual users, testing suites are very incomplete
> w.r.t this syscall, and the amount of work required to "remove" it is
> non-trivial, can we just kill this syscall off?
> 
> It sounds to me like a better option than to ship a new, buggy and possibly
> security dangerous version which we can't even test.

Taking into account your employment, is it possible to check how the RDBMS
(old but it still supported 32-bit versions) would react on -ENOSYS here?

I would like to get rid of it completely, but I thought it's not an option
for compatibility reason.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
