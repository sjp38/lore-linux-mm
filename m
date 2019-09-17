Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PULL_REQUEST,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AC17C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 15:06:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8E3021897
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 15:06:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="L4MGQ8vd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8E3021897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 801386B0003; Tue, 17 Sep 2019 11:06:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78C616B0005; Tue, 17 Sep 2019 11:06:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67A396B0006; Tue, 17 Sep 2019 11:06:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0019.hostedemail.com [216.40.44.19])
	by kanga.kvack.org (Postfix) with ESMTP id 42FD26B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 11:06:12 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C828555F88
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 15:06:11 +0000 (UTC)
X-FDA: 75944738142.22.veil16_702f96080e72a
X-HE-Tag: veil16_702f96080e72a
X-Filterd-Recvd-Size: 2916
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 15:06:10 +0000 (UTC)
Received: from localhost (c-67-169-218-210.hsd1.or.comcast.net [67.169.218.210])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5BA7D20665;
	Tue, 17 Sep 2019 15:06:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1568732769;
	bh=SDG5YpF85LDl7cxtILkzcLro5V+SIvuaeeWO/xetNPc=;
	h=Date:From:To:Cc:Subject:From;
	b=L4MGQ8vdegQAMJWZvefCan9LNmZ58YKbkSOalMHxvO0HWyV0pmFh1Ux7JqwFOW68O
	 mCGBhYjjy1+ryMK52xSHfJQua12b18hMCxbKZNbPuOyslbAj0VL4Avpn+vFS73QMQF
	 zChusAZY9pyCaARcI1IJL6QMmjaAJ3A8JgTG6/KI=
Date: Tue, 17 Sep 2019 08:06:09 -0700
From: "Darrick J. Wong" <djwong@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Darrick J. Wong" <djwong@kernel.org>, linux-fsdevel@vger.kernel.org,
	linux-xfs@vger.kernel.org, hch@infradead.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk, linux-mm@kvack.org,
	Theodore Ts'o <tytso@mit.edu>
Subject: [GIT PULL] vfs: prohibit writes to active swap devices
Message-ID: <20190917150608.GT2229799@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

Please pull this short series that prevents writes to active swap files
and swap devices.  There's no non-malicious use case for allowing
userspace to scribble on storage that the kernel thinks it owns.

The branch merges cleanly against this morning's HEAD and survived an
overnight run of xfstests.  The merge was completely straightforward, so
please let me know if you run into anything weird.

--D

The following changes since commit 609488bc979f99f805f34e9a32c1e3b71179d10b:

  Linux 5.3-rc2 (2019-07-28 12:47:02 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/fs/xfs/xfs-linux.git tags/vfs-5.4-merge-1

for you to fetch changes up to dc617f29dbe5ef0c8ced65ce62c464af1daaab3d:

  vfs: don't allow writes to swap files (2019-08-20 07:55:16 -0700)

----------------------------------------------------------------
Changes for 5.4:
- Prohibit writing to active swap files and swap partitions.

----------------------------------------------------------------
Darrick J. Wong (2):
      mm: set S_SWAPFILE on blockdev swap devices
      vfs: don't allow writes to swap files

 fs/block_dev.c     |  3 +++
 include/linux/fs.h | 11 +++++++++++
 mm/filemap.c       |  3 +++
 mm/memory.c        |  4 ++++
 mm/mmap.c          |  8 ++++++--
 mm/swapfile.c      | 41 +++++++++++++++++++++++++----------------
 6 files changed, 52 insertions(+), 18 deletions(-)

