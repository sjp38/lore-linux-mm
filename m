Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9E1F6B0333
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 12:12:46 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id d67so188063644qkc.0
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 09:12:46 -0800 (PST)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id 19si1555202otu.23.2016.11.17.09.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 09:12:46 -0800 (PST)
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
	<87twb6avk8.fsf_-_@xmission.com>
Date: Thu, 17 Nov 2016 11:08:22 -0600
In-Reply-To: <87twb6avk8.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Thu, 17 Nov 2016 11:02:47 -0600")
Message-ID: <87inrmavax.fsf_-_@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: [REVIEW][PATCH 2/3] exec: Don't allow ptracing an exec of an unreadable file
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Containers <containers@lists.linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Willy Tarreau <w@1wt.eu>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>


It is the reasonable expectation that if an executable file is not
readable there will be no way for a user without special privileges to
read the file.  This is enforced in ptrace_attach but if we are
already attached there is no enforcement if a readonly executable
is exec'd.

Therefore do the simple thing and if there is a non-dumpable
executable that we are tracing without privilege fail to exec it.

Fixes: v1.0
Cc: stable@vger.kernel.org
Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 fs/exec.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/exec.c b/fs/exec.c
index fdec760bfac3..de107f74e055 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1230,6 +1230,11 @@ int flush_old_exec(struct linux_binprm * bprm)
 {
 	int retval;
 
+	/* Fail if the tracer can't read the executable */
+	if ((bprm->interp_flags & BINPRM_FLAGS_ENFORCE_NONDUMP) &&
+	    !ptracer_capable(current, bprm->mm->user_ns))
+		return -EPERM;
+
 	/*
 	 * Make sure we have a private signal table and that
 	 * we are unassociated from the previous thread group.
@@ -1301,7 +1306,6 @@ void setup_new_exec(struct linux_binprm * bprm)
 	    !gid_eq(bprm->cred->gid, current_egid())) {
 		current->pdeath_signal = 0;
 	} else {
-		would_dump(bprm, bprm->file);
 		if (bprm->interp_flags & BINPRM_FLAGS_ENFORCE_NONDUMP)
 			set_dumpable(current->mm, suid_dumpable);
 	}
@@ -1736,6 +1740,8 @@ static int do_execveat_common(int fd, struct filename *filename,
 	if (retval < 0)
 		goto out;
 
+	would_dump(bprm, bprm->file);
+
 	retval = exec_binprm(bprm);
 	if (retval < 0)
 		goto out;
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
