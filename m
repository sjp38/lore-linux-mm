Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8213D6B0038
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 09:40:58 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id j127so110718194qke.2
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 06:40:58 -0800 (PST)
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com. [209.85.220.180])
        by mx.google.com with ESMTPS id f4si13555995qke.184.2017.03.05.06.40.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Mar 2017 06:40:57 -0800 (PST)
Received: by mail-qk0-f180.google.com with SMTP id p64so1149716qke.1
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 06:40:57 -0800 (PST)
Message-ID: <1488724854.2925.6.camel@redhat.com>
Subject: Re: [PATCH 0/3] mm/fs: get PG_error out of the writeback reporting
 business
From: Jeff Layton <jlayton@redhat.com>
Date: Sun, 05 Mar 2017 09:40:54 -0500
In-Reply-To: <20170305133535.6516-1-jlayton@redhat.com>
References: <20170305133535.6516-1-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, konishi.ryusuke@lab.ntt.co.jp
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, NeilBrown <neilb@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sun, 2017-03-05 at 08:35 -0500, Jeff Layton wrote:
> I recently did some work to wire up -ENOSPC handling in ceph, and found
> I could get back -EIO errors in some cases when I should have instead
> gotten -ENOSPC. The problem was that the ceph writeback code would set
> PG_error on a writeback error, and that error would clobber the mapping
> error.
> 

I should also note that relying on PG_error to report writeback errors
is inherently unreliable as well. If someone calls sync() before your
fsync gets in there, then you'll likely lose it anyway.

filemap_fdatawait_keep_errors will preserve the error in the mapping,
but not the individual PG_error flags, so I think we do want to ensure
that the mapping error is set when there is a writeback error and not
rely on PG_error bit for that.

> While I fixed that problem by simply not setting that bit on errors,
> that led me down a rabbit hole of looking at how PG_error is being
> handled in the kernel.
> 
> This patch series is a few fixes for things that I 100% noticed by
> inspection. I don't have a great way to test these since they involve
> error handling. I can certainly doctor up a kernel to inject errors
> in this code and test by hand however if these look plausible up front.
> 
> Jeff Layton (3):
>   nilfs2: set the mapping error when calling SetPageError on writeback
>   mm: don't TestClearPageError in __filemap_fdatawait_range
>   mm: set mapping error when launder_pages fails
> 
>  fs/nilfs2/segment.c |  1 +
>  mm/filemap.c        | 19 ++++---------------
>  mm/truncate.c       |  6 +++++-
>  3 files changed, 10 insertions(+), 16 deletions(-)
> 

(cc'ing Ross...)

Just when I thought that only NILFS2 needed a little work here, I see
another spot...

I think that we should also need to fix dax_writeback_mapping_range to
set a mapping error on writeback as well. It looks like that's not
happening today. Something like the patch below (obviously untested).

I'll also plan to follow up with a patch to vfs.txt to outline how
writeback errors should be handled by filesystems, assuming that this
patchset isn't completely off base.

-------------------8<-----------------------

[PATCH] dax: set error in mapping when writeback fails

In order to get proper error codes from fsync, we must set an error in
the mapping range when writeback fails.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/dax.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index c45598b912e1..9005d90deeda 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -888,8 +888,10 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 
 			ret = dax_writeback_one(bdev, mapping, indices[i],
 					pvec.pages[i]);
-			if (ret < 0)
+			if (ret < 0) {
+				mapping_set_error(mapping, ret);
 				return ret;
+			}
 		}
 	}
 	return 0;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
