Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id AC7166B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 17:51:18 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id lj1so3250856pab.29
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 14:51:18 -0800 (PST)
Received: from psmtp.com ([74.125.245.204])
        by mx.google.com with SMTP id rw4si12634532pac.178.2013.11.19.14.51.16
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 14:51:17 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id bj1so927423pad.2
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 14:51:15 -0800 (PST)
Message-ID: <528BEB60.7040402@amacapital.net>
Date: Tue, 19 Nov 2013 14:51:12 -0800
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 0/3] Add dirty-tracking infrastructure for non-page-backed
 address spaces
References: <1384891576-7851-1-git-send-email-thellstrom@vmware.com>
In-Reply-To: <1384891576-7851-1-git-send-email-thellstrom@vmware.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Hellstrom <thellstrom@vmware.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linux-graphics-maintainer@vmware.com

On 11/19/2013 12:06 PM, Thomas Hellstrom wrote:
> Hi!
> 
> Before going any further with this I'd like to check whether this is an
> acceptable way to go.
> Background:
> GPU buffer objects in general and vmware svga GPU buffers in
> particular are mapped by user-space using MIXEDMAP or PFNMAP. Sometimes the
> address space is backed by a set of pages, sometimes it's backed by PCI memory.
> In the latter case in particular, there is no way to track dirty regions
> using page_mkwrite() and page_mkclean(), other than allocating a bounce
> buffer and perform dirty tracking on it, and then copy data to the real GPU
> buffer. This comes with a big memory- and performance overhead.
> 
> So I'd like to add the following infrastructure with a callback pfn_mkwrite()
> and a function mkclean_mapping_range(). Typically we will be cleaning a range
> of ptes rather than random ptes in a vma.
> This comes with the extra benefit of being usable when the backing memory of
> the GPU buffer is not coherent with the GPU itself, and where we either need
> to flush caches or move data to synchronize.
> 
> So this is a RFC for
> 1) The API. Is it acceptable? Any other suggestions if not?
> 2) Modifying apply_to_page_range(). Better to make a standalone
> non-populating version?
> 3) tlb- mmu- and cache-flushing calls. I've looked at unmap_mapping_range()
> and page_mkclean_one() to try to get it right, but still unsure.

Most (all?) architectures have real dirty tracking -- you can mark a pte
as "clean" and the hardware (or arch code) will mark it dirty when
written, *without* a page fault.

I'm not convinced that it works completely correctly right now (I
suspect that there are some TLB flushing issues on the dirty->clean
transition), and it's likely prone to bit-rot, since the page cache
doesn't rely on it.

That being said, using hardware dirty tracking should be *much* faster
and less latency-inducing than doing it in software like this.  It may
be worth trying to get HW dirty tracking working before adding more page
fault-based tracking.

(I think there's also some oddity on S/390.  I don't know what that
oddity is or whether you should care.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
