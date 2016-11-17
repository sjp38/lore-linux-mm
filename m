Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDEEF6B032E
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 12:07:35 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id 41so83841451qtn.7
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 09:07:35 -0800 (PST)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id s194si1531888oih.181.2016.11.17.09.07.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 09:07:35 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net> <87r37dnz74.fsf@xmission.com>
	<87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
Date: Thu, 17 Nov 2016 11:02:47 -0600
In-Reply-To: <CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	(Andy Lutomirski's message of "Wed, 19 Oct 2016 16:17:30 -0700")
Message-ID: <87twb6avk8.fsf_-_@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: [REVIEW][PATCH 0/3] Fixing ptrace vs exec vs userns interactions
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Containers <containers@lists.linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Willy Tarreau <w@1wt.eu>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>


With everyone heading to Kernel Summit and Plumbers I put this set of
patches down temporarily.   Now is the time to take it back up and to
make certain I am not missing something stupid in this set of patches.

There are other issues in this area as well, but these are the pieces
that I can see clearly, and have tested fixes for.

Andy as to your criticism about using strace sudo I can't possibly see
how that is effective or useful.  Under strace sudo won't run as root
today, and will immediately exit because it is not root.  Furthermore
the only place I can find non-readable executables is people hardening
suid root executables so they are more difficult to trace.  So I
definitely think we should honor the unix permissions and people's
expressed wishes.

Eric W. Biederman (3):
      ptrace: Capture the ptracer's creds not PT_PTRACE_CAP
      exec: Don't allow ptracing an exec of an unreadable file
      exec: Ensure mm->user_ns contains the execed files

 fs/exec.c                  | 26 +++++++++++++++++++++++---
 include/linux/capability.h |  2 ++
 include/linux/ptrace.h     |  1 -
 include/linux/sched.h      |  1 +
 kernel/capability.c        | 36 ++++++++++++++++++++++++++++++++++--
 kernel/ptrace.c            | 12 +++++++-----
 6 files changed, 67 insertions(+), 11 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
