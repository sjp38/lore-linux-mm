Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 76BA96B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 04:32:30 -0500 (EST)
Received: by wevm14 with SMTP id m14so51678327wev.8
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 01:32:30 -0800 (PST)
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id fb8si16283537wid.20.2015.03.05.01.32.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 01:32:28 -0800 (PST)
Received: by wggx12 with SMTP id x12so52130463wgg.6
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 01:32:28 -0800 (PST)
Message-ID: <54F822A9.7090707@plexistor.com>
Date: Thu, 05 Mar 2015 11:32:25 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3 v2] dax: use pfn_mkwrite to update c/mtime + freeze
 protection
References: <54F733BD.7060807@plexistor.com> <54F73746.5020300@plexistor.com> <20150304171935.GA5443@quack.suse.cz> <54F820E2.9060109@plexistor.com>
In-Reply-To: <54F820E2.9060109@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 03/05/2015 11:24 AM, Boaz Harrosh wrote:
> 
> [v1]
> Without this patch, c/mtime is not updated correctly when mmap'ed page is
> first read from and then written to.
> 
> A new xfstest is submitted for testing this (generic/080)
> 
> [v2]
> Jan Kara has pointed out that if we add the
> sb_start/end_pagefault pair in the new pfn_mkwrite we
> are then fixing another bug where: A user could start
> writing to the page while filesystem is frozen.
> 

Thanks Jan.

Just as curiosity, does the freezing code goes and turns all mappings
into read-only, Also for pfn mapping?

Do you think there is already an xfstest freezing test that should now
fail, and will succeed after this patch (v2). Something like:
  * mmap-read/write before the freeze
  * freeze the fs
  * Another thread tries to mmap-write, should get stuck
  * unfreeze the fs
  * Now mmap-writer continues

Thanks again
Boaz

> CC: Jan Kara <jack@suse.cz>
> Signed-off-by: Yigal Korman <yigal@plexistor.com>
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
<>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
