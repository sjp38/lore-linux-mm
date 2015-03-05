Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id D1A3E6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 05:35:37 -0500 (EST)
Received: by wevl61 with SMTP id l61so52055176wev.2
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 02:35:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y7si13243924wiv.25.2015.03.05.02.35.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 02:35:36 -0800 (PST)
Date: Thu, 5 Mar 2015 11:35:29 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/3 v2] dax: use pfn_mkwrite to update c/mtime + freeze
 protection
Message-ID: <20150305103529.GA2836@quack.suse.cz>
References: <54F733BD.7060807@plexistor.com>
 <54F73746.5020300@plexistor.com>
 <20150304171935.GA5443@quack.suse.cz>
 <54F820E2.9060109@plexistor.com>
 <54F822A9.7090707@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F822A9.7090707@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu 05-03-15 11:32:25, Boaz Harrosh wrote:
> On 03/05/2015 11:24 AM, Boaz Harrosh wrote:
> > 
> > [v1]
> > Without this patch, c/mtime is not updated correctly when mmap'ed page is
> > first read from and then written to.
> > 
> > A new xfstest is submitted for testing this (generic/080)
> > 
> > [v2]
> > Jan Kara has pointed out that if we add the
> > sb_start/end_pagefault pair in the new pfn_mkwrite we
> > are then fixing another bug where: A user could start
> > writing to the page while filesystem is frozen.
> > 
> 
> Thanks Jan.
> 
> Just as curiosity, does the freezing code goes and turns all mappings
> into read-only, Also for pfn mapping?
  Hum, that's a good question. Probably we don't end up doing that. For
normal filesystems we sync all inodes which also writeprotects all pages
(in clear_page_dirty_for_io() - for normal filesystems we know that if page
is writeably mapped it is dirty). However this won't happen for pfn
mapping as we don't have dirty pages. So we probably need dax_freeze()
implementation that will walk through all inodes with writeable mappings and
writeprotect them.

> Do you think there is already an xfstest freezing test that should now
> fail, and will succeed after this patch (v2). Something like:
>   * mmap-read/write before the freeze
>   * freeze the fs
>   * Another thread tries to mmap-write, should get stuck
>   * unfreeze the fs
>   * Now mmap-writer continues
  I don't remember there would be any test to specifically test this.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
