Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 98E376B00C9
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 16:17:28 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id k14so5156116wgh.10
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 13:17:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7si10613966wjy.45.2014.03.17.13.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 13:17:25 -0700 (PDT)
Date: Mon, 17 Mar 2014 21:17:21 +0100
From: Jan Kara <jack@suse.cz>
Subject: [LSF/MM TOPIC] Page fault locking
Message-ID: <20140317201721.GA8743@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

  Hello,

  so this is a continuation of the topic we spoke about at last LSF/MM
(http://lwn.net/Articles/548098/) about problems filesystems have with
mmap_sem held over page fault. Over the year I have slowly worked through
get_user_pages() users and was converting them to hide mmap_sem locking
inside helpers. Some of the patches were merged, some patches still just
sit in my queue (but most of them is luckily trivial), I've sent out
probably the most complex part - conversion of video4linux2 core - today.

What I'm interested in is:
1) Some feedback regarding the proposed get_vaddr_pfn() helper function.
2) Discuss changes of get_user_pages() function - my idea is that all users
   that need non-trivial locking should use __get_user_pages() (so far
   there are about 8 such callers after my series). get_user_pages() call
   will now grab mmap_sem on its own.
3) Overview remaining call sites of get_user_pages() with non-trivial
   locking - at some places I think we could change the locking so that
   they could use get_user_pages() variant which takes care of grabbing
   mmap_sem. Also I have one place (yes, the only place in the whole
   kernel) in kernel/events/uprobes.c where it's not clear to me how to
   handle situation if fault handler would drop mmap_sem. So I'd like to
   bounce that off the people in the room in case someone comes up with
   anything clever.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
