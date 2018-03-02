Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86C216B0008
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 12:43:47 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id w23so5599837otj.6
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 09:43:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 62si1981060oih.104.2018.03.02.09.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 09:43:46 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/1] FOLL_NOWAIT and get_user_pages_unlocked
Date: Fri,  2 Mar 2018 18:43:42 +0100
Message-Id: <20180302174343.5421-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, qemu-devel@nongnu.org, linux-mm@kvack.org

Hello,

KVM is hanging on postcopy live migration.

David tracked it down to commit
ce53053ce378c21e7ffc45241fd67d6ee79daa2b and the problem is pretty
obvious then.

Either we teach get_user_pages_locked/unlocked to handle FOLL_NOWAIT
(so faultin_nopage works right even when the nonblocking pointer is
not NULL) or we need to revert part of commit
ce53053ce378c21e7ffc45241fd67d6ee79daa2b and keep using FOLL_NOWAIT
only as parameter to get_user_pages (which won't ever set nonblocking
pointer to non-NULL). I suppose the former approach is preferred to be
more robust.

Thanks,
Andrea

Andrea Arcangeli (1):
  mm: gup: teach get_user_pages_unlocked to handle FOLL_NOWAIT

 mm/gup.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
