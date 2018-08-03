Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6857C6B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 06:31:17 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y130-v6so4906958qka.1
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 03:31:17 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u3-v6si4362112qku.184.2018.08.03.03.31.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 03:31:15 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <47c34fad-5d11-53b0-4386-61be890163c5@virtuozzo.com>
References: <47c34fad-5d11-53b0-4386-61be890163c5@virtuozzo.com> <153320759911.18959.8842396230157677671.stgit@localhost.localdomain> <20180802134723.ecdd540c7c9338f98ee1a2c6@linux-foundation.org>
Subject: Re: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to do_shrink_slab()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8346.1533292272.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Fri, 03 Aug 2018 11:31:12 +0100
Message-ID: <8347.1533292272@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, willy@infradead.org, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org

The reproducer can be reduced to:

	#define _GNU_SOURCE
	#include <endian.h>
	#include <stdint.h>
	#include <string.h>
	#include <stdio.h>
	#include <sys/syscall.h>
	#include <sys/stat.h>
	#include <sys/mount.h>
	#include <unistd.h>
	#include <fcntl.h>

	const char path[] =3D "./file0";

	int main()
	{
		mkdir(path, 0);
		mount(path, path, "cgroup2", 0, 0);
		chroot(path);
		umount2(path, 0);
		return 0;
	}

and I've found two bugs (see attached patch).  The issue is that
do_remount_sb() is called with fc =3D=3D NULL from umount(), but both
cgroup_reconfigure() and do_remount_sb() dereference fc unconditionally.

But!  I'm not sure why the reproducer works at all because the umount2() c=
all
is *after* the chroot, so should fail on ENOENT before it even gets that f=
ar.
In fact, umount2() can be called multiple times, apparently successfully, =
and
doesn't actually unmount anything.

David
---
diff --git a/fs/super.c b/fs/super.c
index 3fe5d12b7697..321fbc244570 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -978,7 +978,10 @@ int do_remount_sb(struct super_block *sb, int sb_flag=
s, void *data,
 	    sb->s_op->remount_fs) {
 		if (sb->s_op->reconfigure) {
 			retval =3D sb->s_op->reconfigure(sb, fc);
-			sb_flags =3D fc->sb_flags;
+			if (fc)
+				sb_flags =3D fc->sb_flags;
+			else
+				sb_flags =3D sb->s_flags;
 			if (retval =3D=3D 0)
 				security_sb_reconfigure(fc);
 		} else {
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index f3238f38d152..48275fdce053 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -1796,9 +1796,11 @@ static void apply_cgroup_root_flags(unsigned int ro=
ot_flags)
 =

 static int cgroup_reconfigure(struct kernfs_root *kf_root, struct fs_cont=
ext *fc)
 {
-	struct cgroup_fs_context *ctx =3D cgroup_fc2context(fc);
+	if (fc) {
+		struct cgroup_fs_context *ctx =3D cgroup_fc2context(fc);
 =

-	apply_cgroup_root_flags(ctx->flags);
+		apply_cgroup_root_flags(ctx->flags);
+	}
 	return 0;
 }
 =
