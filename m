Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 37EAC4402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 14:11:36 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id mv3so19253016igc.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 11:11:36 -0800 (PST)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id op7si5432676igb.73.2015.12.17.11.11.34
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 Dec 2015 11:11:35 -0800 (PST)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH v2 0/8] fs: don't use module helpers in non-modular code
Date: Thu, 17 Dec 2015 14:10:58 -0500
Message-ID: <1450379466-23115-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, David Howells <dhowells@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Eric Paris <eparis@parisplace.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@poochiereds.net>, Josh Triplett <josh@joshtriplett.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Peter Hurley <peter@hurleysoftware.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This series of commits is a slice of a larger project to ensure
people don't needlessly use modular support functions in non-modular
code.  Overall there was roughly 5k lines of unused _exit code and
".remove" functions in the kernel due to this.  So far we've fixed
several areas, like tty, x86, net, etc. and we continue here in fs/

There are several reasons to not use module helpers for code that can
never be built as a module, but the big ones are:

 (1) it is easy to accidentally code up an unused module_exit function
 (2) it can be misleading when reading the source, thinking it can be
      modular when the Makefile and/or Kconfig prohibit it
 (3) it requires the include of the module.h header file which in turn
     includes nearly everything else, thus increasing CPP overhead.

Fortunately the code here is core fs code and not strictly a driver
in the sense that a UART or GPIO driver is.  So we don't have a lot
of unused code to remove, and mainly gain in avoiding #2 and #3 above.

Here we convert some module_init() calls into fs_initcall().  In doing
so we must note that this changes the init ordering slightly, since
module_init() becomes device_initcall() in the non-modular case, and
that comes after fs_initcall().

We could have used device_initcall here to strictly preserve the old
ordering, and that largely makes sense for drivers/* dirs.  But using
device_initcall in the fs/ dir just seems wrong when we have the staged
initcall system and a fs_initcall bucket in that tiered system.

The hugetlb patch warrants special mention.  It has code in both the
fs dir and the mm dir, with initcalls in each.  There is an implicit
requirement that the mm one be executed prior to the fs one, else
the runtime will splat.  Currently we achieve that only by luck of the
link order.  With the changes made here, we use our existing initcall
buckets properly to guarantee that ordering.

Since I have a large queue, I'm hoping to get as many of these as
possible in via maintainers, so that I'm not left someday asking
Linus to pull a giant series.

[v1 --> v2: drop 2 patches merged elsewhere, combine mm & fs chunks
 of hugetlb patch into one & update log accordingly.]

---

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: David Rientjes <rientjes@google.com>
Cc: Eric Paris <eparis@parisplace.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: Josh Triplett <josh@joshtriplett.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Peter Hurley <peter@hurleysoftware.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org

The following changes since commit 9f9499ae8e6415cefc4fe0a96ad0e27864353c89:

  Linux 4.4-rc5 (2015-12-13 17:42:58 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git fs_initcall

for you to fetch changes up to 7763d3b42ca62dc967cc56218df8007401e63cd0:

  fs: make binfmt_elf.c explicitly non-modular (2015-12-17 12:11:19 -0500)

----------------------------------------------------------------

Paul Gortmaker (8):
  hugetlb: make mm and fs code explicitly non-modular
  fs: make notify dnotify.c explicitly non-modular
  fs: make fcntl.c explicitly non-modular
  fs: make filesystems.c explicitly non-modular
  fs: make locks.c explicitly non-modular
  fs: make direct-io.c explicitly non-modular
  fs: make devpts/inode.c explicitly non-modular
  fs: make binfmt_elf.c explicitly non-modular

 fs/binfmt_elf.c             | 11 +----------
 fs/devpts/inode.c           |  3 +--
 fs/direct-io.c              |  4 ++--
 fs/fcntl.c                  |  4 +---
 fs/filesystems.c            |  2 +-
 fs/hugetlbfs/inode.c        | 27 ++-------------------------
 fs/locks.c                  |  3 +--
 fs/notify/dnotify/dnotify.c |  4 +---
 mm/hugetlb.c                | 39 +--------------------------------------
 9 files changed, 11 insertions(+), 86 deletions(-)

-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
