Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3226B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:48:51 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e70so912004wmc.6
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 01:48:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l6si11534241wrg.340.2017.12.19.01.48.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 01:48:49 -0800 (PST)
Date: Tue, 19 Dec 2017 10:48:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: shmctl(SHM_STAT) vs. /proc/sysvipc/shm permissions discrepancies
Message-ID: <20171219094848.GE2787@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-api@vger.kernel.org
Cc: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Waychison <mikew@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi,
we have been contacted by our partner about the following permission
discrepancy
1. Create a shared memory segment with permissions 600 with user A using
   shmget(key, 1024, 0600 | IPC_CREAT)
2. ipcs -m should return an output as follows:

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x58b74326 759562241  A          600        1024       0

3. Try to read the metadata with shmctl(0, SHM_STAT,...) as user B.
4. shmctl will return -EACCES

The supper set information provided by shmctl can be retrieved by
reading /proc/sysvipc/shm which does not require read permissions
because it is 444.

It seems that the discrepancy is there since ae7817745eef ("[PATCH] ipc:
add generic struct ipc_ids seq_file iteration") when the proc interface
has been introduced. The changelog is really modest on information or
intention but I suspect this just got overlooked during review. SHM_STAT
has always been about read permission and it is explicitly documented
that way.

I am not a security expert to judge whether this leak can have some
interesting consequences but I am really interested whether this is
something we want to keep that way. Do we want to filter and dump only
shmids the caller has access to? This would break the delegation AFAICS.
Do we want to make the file root only? That would probably break an
existing userspace as well.

Or should we simply allow SHM_STAT for processes without a read permission
because the same information can be read by other means already?

Any other ideas?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
