Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26DC72808A7
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 23:28:46 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e5so93290115pgk.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 20:28:46 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id b6si5234308pfg.209.2017.03.08.20.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 20:28:45 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id o126so23580450pfb.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 20:28:45 -0800 (PST)
Date: Thu, 9 Mar 2017 13:29:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: "mm: fix lazyfree BUG_ON check in try_to_unmap_one()" build error
Message-ID: <20170309042908.GA26702@jagdpanzerIV.localdomain>
Reply-To: 20170307055551.GC29458@bbox.kvack.org
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Minchan,

/* I can't https://marc.info/?l=linux-kernel&m=148886631303107 thread
   in my mail box for some reason so the Reply-To message-id may be wrong. */



commit "mm: fix lazyfree BUG_ON check in try_to_unmap_one()"
(mmotm fd07630cbf59bead90046dd3e5cfd891e58e6987)


	if (VM_WARN_ON_ONCE(PageSwapBacked(page) !=
			PageSwapCache(page))) {
	...
	}


does not compile on !CONFIG_DEBUG_VM configs, because VM_WARN_ONCE() is

	#define BUILD_BUG_ON_INVALID(e) ((void)(sizeof((__force long)(e))))



In file included from ./include/linux/mmdebug.h:4:0,
                 from ./include/linux/mm.h:8,
                 from mm/rmap.c:48:
mm/rmap.c: In function a??try_to_unmap_onea??:
./include/linux/bug.h:45:33: error: void value not ignored as it ought to be
 #define BUILD_BUG_ON_INVALID(e) ((void)(sizeof((__force long)(e))))
                                 ^
./include/linux/mmdebug.h:49:31: note: in expansion of macro a??BUILD_BUG_ON_INVALIDa??
 #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
                               ^~~~~~~~~~~~~~~~~~~~
mm/rmap.c:1416:8: note: in expansion of macro a??VM_WARN_ON_ONCEa??
    if (VM_WARN_ON_ONCE(PageSwapBacked(page) !=
        ^~~~~~~~~~~~~~~

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
