Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 257CC6B006E
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 09:00:15 -0400 (EDT)
Received: by wizo1 with SMTP id o1so103958993wiz.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 06:00:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si18527350wix.110.2015.06.01.06.00.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 06:00:09 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 0/2] mapping_gfp_mask from the page fault path
Date: Mon,  1 Jun 2015 15:00:01 +0200
Message-Id: <1433163603-13229-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org

Hi,
I somehow forgot about these patches. The previous version was
posted here: http://marc.info/?l=linux-mm&m=142668784122763&w=2. The
first attempt was broken but even when fixed it seems like ignoring
mapping_gfp_mask in page_cache_read is too fragile because
filesystems might use locks in their filemap_fault handlers
which could trigger recursion problems as pointed out by Dave
http://marc.info/?l=linux-mm&m=142682332032293&w=2.

The first patch should be straightforward fix to obey mapping_gfp_mask
when allocating for mapping. It can be applied even without the second
one.

The second patch is an attempt to handle mapping_gfp_mask from the
page fault path properly. GFP_IOFS should be safe from he page fault
path in general (we would be quite broken otherwise because there
are places where GFP_KERNEL is used - e.g. pte allocation). MM will
communicate this to the fs layer via struct vm_fault::gfp_mask.
If fs needs to change this allocation context in a fs callback it can
overwrite this mask. If the code flow gets back to MM we will obey this
gfp_mask (e.g. in page_cache_read). This should be more appropriate than
following mapping_gfp_mask blindly. See the patch description for more
details.

I am still not sure this is the right way to go so I am sending this as
an RFC so any comments are highly appreciated.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
