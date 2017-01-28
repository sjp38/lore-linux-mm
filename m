Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 738576B0038
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 21:49:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 14so374459732pgg.4
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 18:49:43 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id q61si6119391plb.25.2017.01.27.18.49.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 18:49:42 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 0/2] setgid hardening
Date: Fri, 27 Jan 2017 18:49:30 -0800
Message-Id: <cover.1485571668.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: security@kernel.org
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Frank Filz <ffilzlnx@mindspring.com>, Andy Lutomirski <luto@kernel.org>

The kernel has some dangerous behavior involving the creation and
modification of setgid executables.  These issues aren't kernel
security bugs per se, but they have been used to turn various
filesystem permission oddities into reliably privilege escalation
exploits.

See http://www.halfdog.net/Security/2015/SetgidDirectoryPrivilegeEscalation/
for a nice writeup.

Let's fix them for real.

Changes from v1:
 - Fix uninitialized variable issue (Willy, Ben)
 - Also check current creds in should_remove_suid() (Ben)

Andy Lutomirski (2):
  fs: Check f_cred as well as of current's creds in should_remove_suid()
  fs: Harden against open(..., O_CREAT, 02777) in a setgid directory

 fs/inode.c         | 61 ++++++++++++++++++++++++++++++++++++++++++++++--------
 fs/internal.h      |  2 +-
 fs/ocfs2/file.c    |  4 ++--
 fs/open.c          |  2 +-
 include/linux/fs.h |  2 +-
 5 files changed, 57 insertions(+), 14 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
