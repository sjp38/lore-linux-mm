Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.2 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4DD9C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:14:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAEDF21743
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:14:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAEDF21743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kvack.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 430DF6B000D; Thu,  8 Aug 2019 12:14:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AC176B000C; Thu,  8 Aug 2019 12:14:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 224956B000E; Thu,  8 Aug 2019 12:14:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C6B66B000A; Thu,  8 Aug 2019 12:14:57 -0400 (EDT)
Date: Thu, 8 Aug 2019 12:14:57 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
To: linux-aio@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@kvack.org
Subject: summary of current pending changes in aio-next.git
Message-ID: <20190808161457.GP28371@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.4.2.2i
X-IMAPbase: 1406838451 0000000033
X-UID: 1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The first 10 of Kent's AIO optimization series have been pulled into my 
tree as summarised below.  I had to rework some of the patches to correctly 
apply after Gu Zheng's polishing of the AIO ringbuffer migration support, 
so any extra eyes on those changes would be helpful.  I also fixed a couple 
of bugs in the table lookup patch, as well as eliminating a BUG_ON() Kent 
added in order to be a bit more defensive.

These changes should show up in linux-next, so please give them a beating.  
I plan to post a few more changes against this tree in the next couple of 
weeks.

		-ben
---
The following changes since commit 47188d39b5deeebf41f87a02af1b3935866364cf:

  Merge tag 'ext4_for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4 (2013-07-14 21:47:51 -0700)

are available in the git repository at:


  git://git.kvack.org/~bcrl/aio-next.git master

for you to fetch changes up to 6878ea72a5d1aa6caae86449975a50b7fe9abed5:

  aio: be defensive to ensure request batching is non-zero instead of BUG_ON() (2013-07-31 10:34:18 -0400)

----------------------------------------------------------------
Benjamin LaHaise (4):
      aio: fix build when migration is disabled
      aio: double aio_max_nr in calculations
      aio: convert the ioctx list to table lookup v3
      aio: be defensive to ensure request batching is non-zero instead of BUG_ON()

Gu Zheng (2):
      fs/anon_inode: Introduce a new lib function anon_inode_getfile_private()
      fs/aio: Add support to aio ring pages migration

Kent Overstreet (9):
      aio: reqs_active -> reqs_available
      aio: percpu reqs_available
      aio: percpu ioctx refcount
      aio: io_cancel() no longer returns the io_event
      aio: Don't use ctx->tail unnecessarily
      aio: Kill aio_rw_vect_retry()
      aio: Kill unneeded kiocb members
      aio: Kill ki_users
      aio: Kill ki_dtor

 drivers/staging/android/logger.c |   2 +-
 drivers/usb/gadget/inode.c       |   9 +-
 fs/aio.c                         | 717 +++++++++++++++++++++++++--------------
 fs/anon_inodes.c                 |  66 ++++
 fs/block_dev.c                   |   2 +-
 fs/nfs/direct.c                  |   1 -
 fs/ocfs2/file.c                  |   6 +-
 fs/read_write.c                  |   3 -
 fs/udf/file.c                    |   2 +-
 include/linux/aio.h              |  21 +-
 include/linux/anon_inodes.h      |   3 +
 include/linux/migrate.h          |   3 +
 include/linux/mm_types.h         |   5 +-
 kernel/fork.c                    |   2 +-
 mm/migrate.c                     |   2 +-
 mm/page_io.c                     |   1 -
 net/socket.c                     |  15 +-
 17 files changed, 549 insertions(+), 311 deletions(-)
-- 
"Thought is the essence of where you are now."

