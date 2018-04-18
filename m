Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 356E76B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 23:55:25 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 35-v6so283140pla.18
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 20:55:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d2-v6si371229pln.533.2018.04.17.20.55.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 20:55:23 -0700 (PDT)
Message-Id: <201804180355.w3I3tM6T001187@www262.sakura.ne.jp>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 18 Apr 2018 12:55:22 +0900
References: <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com> <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

David Rientjes wrote:
> Fix this by reusing MMF_UNSTABLE to specify that an mm should not be
> reaped.  This prevents the concurrent munlock_vma_pages_range() and
> unmap_page_range().  The oom reaper will simply not operate on an mm that
> has the bit set and leave the unmapping to exit_mmap().

This change assumes that munlock_vma_pages_all()/unmap_vmas()/free_pgtables()
are never blocked for memory allocation. Is that guaranteed? For example,
i_mmap_lock_write() from unmap_single_vma() from unmap_vmas() is never blocked
for memory allocation? Commit 97b1255cb27c551d ("mm,oom_reaper: check for
MMF_OOM_SKIP before complaining") was waiting for i_mmap_lock_write() from
unlink_file_vma() from free_pgtables(). Is it really guaranteed that somebody
else who is holding that lock is never waiting for memory allocation?
