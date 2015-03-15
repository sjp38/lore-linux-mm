Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 22077900017
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 22:13:13 -0400 (EDT)
Received: by wgra20 with SMTP id a20so14753052wgr.3
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 19:13:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gs6si10231446wib.101.2015.03.14.19.13.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 14 Mar 2015 19:13:11 -0700 (PDT)
Message-ID: <1426385580.28068.74.camel@stgolabs.net>
Subject: Re: [PATCH 3/4] prctl: move MMF_EXE_FILE_CHANGED into exe_file
 struct
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Sat, 14 Mar 2015 19:13:00 -0700
In-Reply-To: <1426372766-3029-4-git-send-email-dave@stgolabs.net>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
	 <1426372766-3029-4-git-send-email-dave@stgolabs.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: viro@zeniv.linux.org.uk, gorcunov@openvz.org, oleg@redhat.com, koct9i@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 2015-03-14 at 15:39 -0700, Davidlohr Bueso wrote:
> +	if (test_and_set_mm_exe_file(mm, exefd.file))
> +		return 0;
> +	return -EPERM;

Bah, this is obviously bogus. We'd need the following folded in:

diff --git a/kernel/sys.c b/kernel/sys.c
index a82d0c4..41b27bd 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1694,8 +1694,8 @@ set_file:
         * This grabs a reference to exefd.file.
         */
        if (test_and_set_mm_exe_file(mm, exefd.file))
-               return 0;
-       return -EPERM;
+               return -EPERM;
+       return 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
