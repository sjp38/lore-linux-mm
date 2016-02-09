Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7203E6B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 12:24:02 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id c200so70450003wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 09:24:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g133si18068472wma.66.2016.02.09.09.24.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 09:24:01 -0800 (PST)
Date: Tue, 9 Feb 2016 18:24:16 +0100
From: Jan Kara <jack@suse.cz>
Subject: Another proposal for DAX fault locking
Message-ID: <20160209172416.GB12245@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, mgorman@suse.de, Matthew Wilcox <willy@linux.intel.com>

Hello,

I was thinking about current issues with DAX fault locking [1] (data
corruption due to racing faults allocating blocks) and also races which
currently don't allow us to clear dirty tags in the radix tree due to races
between faults and cache flushing [2]. Both of these exist because we don't
have an equivalent of page lock available for DAX. While we have a
reasonable solution available for problem [1], so far I'm not aware of a
decent solution for [2]. After briefly discussing the issue with Mel he had
a bright idea that we could used hashed locks to deal with [2] (and I think
we can solve [1] with them as well). So my proposal looks as follows:

DAX will have an array of mutexes (the array can be made per device but
initially a global one should be OK). We will use mutexes in the array as a
replacement for page lock - we will use hashfn(mapping, index) to get
particular mutex protecting our offset in the mapping. On fault / page
mkwrite, we'll grab the mutex similarly to page lock and release it once we
are done updating page tables. This deals with races in [1]. When flushing
caches we grab the mutex before clearing writeable bit in page tables
and clearing dirty bit in the radix tree and drop it after we have flushed
caches for the pfn. This deals with races in [2].

Thoughts?

								Honza

[1] http://oss.sgi.com/archives/xfs/2016-01/msg00575.html
[2] https://lists.01.org/pipermail/linux-nvdimm/2016-January/004057.html

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
