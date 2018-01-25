Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A8172800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 06:57:31 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 66so4687332pgh.2
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 03:57:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15-v6si1913110plk.245.2018.01.25.03.57.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 03:57:30 -0800 (PST)
Date: Thu, 25 Jan 2018 12:57:27 +0100
From: Jan Kara <jack@suse.cz>
Subject: [LSF/MM TOPIC] get_user_pages() and filesystems
Message-ID: <20180125115727.slf6zj4zzevcskkn@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org

Hello,

this is about a problem I have identified last month and for which I still
don't have good solution. Some discussion of the problem happened here [1]
where also technical details are posted but culprit of the problem is
relatively simple: Lots of places in kernel (fs code, writeback logic,
stable-pages framework for DIF/DIX) assume that file pages in page cache
can be modified either via write(2), truncate(2), fallocate(2) or similar
code paths explicitely manipulating with file space or via a writeable
mapping into page tables. In particular we assume that if we block all the
above paths by taking proper locks, block page faults, and unmap (/ map
read-only) the page, it cannot be modified. But this assumption is violated
by get_user_pages() users (such as direct IO or RDMA drivers - and we've
got reports from such users of weird things happening).

The problem with GUP users is that they acquire page reference (at that
point page is writeably mapped into page tables) and some time in future
(which can be quite far in case of RDMA) page contents gets modified and
page marked dirty.

The question is how to properly solve this problem. One obvious way is to
indicate page has a GUP reference and block its unmapping / remapping RO
until that is dropped. But this has a technical problem (how to find space
in struct page for such tracking) and a design problem (blocking e.g.
writeback for hours because some RDMA app used a file mapping as a buffer
simply is not acceptable). There are also various modifications to this
solution like refuse to use file pages for RDMA
(get_user_pages_longterm()) and block waiting for users like direct IO, or
require that RDMA users provide a way to revoke access from GUPed pages.

Another obvious solution is to try to remove the assumption from all those
places - i.e., use bounce buffers for DIF/DIX, make sure filesystems are
prepared for dirty pages suddenly appearing in files and handle that as
good as they can. They really need to sensibly handle only a case when
underlying storage is already allocated / reserved, in all other cases I
believe they are fine in just discarding the data. This would be very
tedious but I believe it could be done. But overall long-term maintenance
burden of this solution just doesn't seem worth it to me.

Another possible solution might be that GUP users (at least the long term
ones) won't get references directly to page cache pages but only to some
bounce pages (something like cow on private file mappings) and data would
be just copied to the page cache pages at set_page_dirty_lock() time (we
would probably have to move these users to a completely new API to keep our
sanity). This would have userspace visible impacts (data won't be visible
in the file until GUP user is done with it) but maybe it would be
acceptable. Also how to keep association to the original pagecache page
(and how it should be handled when underlying file just goes away) is
unclear.

So clever ideas are needed and possibly some input from FS / MM / RDMA
folks about what might be acceptable.

								Honza

[1] https://www.spinics.net/lists/linux-xfs/msg14468.html

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
