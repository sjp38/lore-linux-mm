Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 90B056B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:39:59 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so8192249pbc.8
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:39:59 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xf4si20273197pab.162.2014.02.11.13.39.58
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 13:39:58 -0800 (PST)
Date: Tue, 11 Feb 2014 13:39:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC, PATCH 0/2] mm: map few pages around fault address if they
 are in page cache
Message-Id: <20140211133956.ef8b9417ed09651fbcf6d3a9@linux-foundation.org>
In-Reply-To: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org

On Tue, 11 Feb 2014 05:05:55 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Okay, it's RFC only. I haven't stabilize it yet. And it's 5 AM...
> 
> It kind of work on small test-cases in kvm, but hung my laptop shortly
> after boot. So no benchmark data.
> 
> The patches are on top of mine __do_fault() cleanup.
> 
> The idea is to minimize number of minor page faults by mapping pages around
> the fault address if they are already in page cache.
> 
> With the patches we try to map up to 32 pages (subject to change) on read
> page fault. Later can extended to write page faults to shared mappings if
> works well.
> 
> The pages must be on the same page table so we can change all ptes under
> one lock.
> 
> I tried to avoid additional latency, so we don't wait page to get ready,
> just skip to the next one.
> 
> The only place where we can get stuck for relatively long time is
> do_async_mmap_readahead(): it allocates pages and submits IO. We can't
> just skip readahead, otherwise it will stop working and we will get miss
> all the time. On other hand keeping do_async_mmap_readahead() there will
> probably break readahead heuristics: interleaving access looks as
> sequential.
> 

hm, we tried that a couple of times, many years ago.  Try
https://www.google.com/#q="faultahead" then spend a frustrating hour
trying to work out what went wrong.

Of course, the implementation might have been poor and perhaps we can
get this to work.

It would seem to make most sense to tie the faultahead into linear
reads of mmapped files.  The disk readahead code already tries to
recognise and optimise such read patterns, but tying faultahead into
readahead won't work well because the pages will often already be in
pagecache.

A starting point for this work would be to get all the tracepoints in
place and then perform some analysis of what the access patterns really
look like.  Based on that (statistical) analysis we can then design a
feature to optimise it and make some predictions about how effective it
might be.


I have vague memories of writing code which, within the first fault
would read the entire file into pagecache and then mapped everything. 
It was really fast (mainly from linearising the read of executables and
libraries) but was wasteful and unserious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
