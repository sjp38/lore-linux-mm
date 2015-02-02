Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A083F6B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 17:22:39 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so87684636pab.6
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 14:22:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id km8si111518pbc.254.2015.02.02.14.22.38
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 14:22:38 -0800 (PST)
Message-ID: <54CFF8AC.6010102@intel.com>
Date: Mon, 02 Feb 2015 14:22:36 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: madvise: Ignore repeated MADV_DONTNEED hints
References: <20150202165525.GM2395@suse.de>
In-Reply-To: <20150202165525.GM2395@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org
Cc: Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 02/02/2015 08:55 AM, Mel Gorman wrote:
> This patch identifies when a thread is frequently calling MADV_DONTNEED
> on the same region of memory and starts ignoring the hint. On an 8-core
> single-socket machine this was the impact on ebizzy using glibc 2.19.

The manpage, at least, claims that we zero-fill after MADV_DONTNEED is
called:

>      MADV_DONTNEED
>               Do  not  expect  access in the near future.  (For the time being, the application is finished with the given range, so the kernel can free resources
>               associated with it.)  Subsequent accesses of pages in this range will succeed, but will result either in reloading of the memory contents  from  the
>               underlying mapped file (see mmap(2)) or zero-fill-on-demand pages for mappings without an underlying file.

So if we have anything depending on the behavior that it's _always_
zero-filled after an MADV_DONTNEED, this will break it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
