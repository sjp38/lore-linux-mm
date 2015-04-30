Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 81C286B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 10:52:57 -0400 (EDT)
Received: by wizk4 with SMTP id k4so22801064wiz.1
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 07:52:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fb11si4379806wjc.83.2015.04.30.07.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 07:52:55 -0700 (PDT)
Date: Thu, 30 Apr 2015 16:52:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] mmap.2: clarify MAP_LOCKED semantic (was: Re: Should
 mmap MAP_LOCKED fail if mm_poppulate fails?)
Message-ID: <20150430145254.GB16964@dhcp22.suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
 <1430223111-14817-1-git-send-email-mhocko@suse.cz>
 <CA+55aFxzLXx=cC309h_tEc-Gkn_zH4ipR7PsefVcE-97Uj066g@mail.gmail.com>
 <20150428164302.GI2659@dhcp22.suse.cz>
 <CA+55aFydkG-BgZzry5DrTzueVh9VvEcVJdLV8iOyUphQk=0vpw@mail.gmail.com>
 <20150428183535.GB30918@dhcp22.suse.cz>
 <CA+55aFyajquhGhw59qNWKGK4dBV0TPmDD7-1XqPo7DZWvO_hPg@mail.gmail.com>
 <20150429113818.GC16097@dhcp22.suse.cz>
 <alpine.DEB.2.10.1504291723001.17825@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1504291723001.17825@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-mm <linux-mm@kvack.org>, Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed 29-04-15 17:28:54, David Rientjes wrote:
[...]
> The wording of this begs the question on the behavior of 
> MAP_LOCKED | MAP_POPULATE since this same man page specifies that 
> accesses to memory mapped with MAP_POPULATE will not block on page faults 
> later.

Interesting. I haven't thought of this combination. The wording of
MAP_POPULATE is too strong and it really might suggest that no future
major faults will happen. And that is simply not true.
---
diff --git a/man2/mmap.2 b/man2/mmap.2
index 1486be2e96b3..c51d3f241ff9 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -284,7 +284,7 @@ private writable mappings.
 .BR MAP_POPULATE " (since Linux 2.5.46)"
 Populate (prefault) page tables for a mapping.
 For a file mapping, this causes read-ahead on the file.
-Later accesses to the mapping will not be blocked by page faults.
+This will help to reduce blocking on the page faults later.
 .BR MAP_POPULATE
 is supported for private mappings only since Linux 2.6.23.
 .TP
 
> I think Documentation/vm/unevictable-lru.txt would benefit from an update 
> under the mmap(MAP_LOCKED) section where all this can be laid out and 
> perhaps reference it from the man page?

Sure, what about the following:
---
diff --git a/Documentation/vm/unevictable-lru.txt b/Documentation/vm/unevictable-lru.txt
index 3be0bfc4738d..9106f50781ac 100644
--- a/Documentation/vm/unevictable-lru.txt
+++ b/Documentation/vm/unevictable-lru.txt
@@ -467,7 +467,13 @@ mmap(MAP_LOCKED) SYSTEM CALL HANDLING
 
 In addition the mlock()/mlockall() system calls, an application can request
 that a region of memory be mlocked supplying the MAP_LOCKED flag to the mmap()
-call.  Furthermore, any mmap() call or brk() call that expands the heap by a
+call. There is one important and subtle difference here, though. mmap() + mlock()
+will fail if the range cannot be faulted in (e.g. because mm_populate fails)
+and returns with ENOMEM while mmap(MAP_LOCKED) will not fail. The mmaped are
+will still have properties of the locked area - aka. pages will not get
+swapped out - but major page faults to fault memory in might still happen.
+
+Furthermore, any mmap() call or brk() call that expands the heap by a
 task that has previously called mlockall() with the MCL_FUTURE flag will result
 in the newly mapped memory being mlocked.  Before the unevictable/mlock
 changes, the kernel simply called make_pages_present() to allocate pages and

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
