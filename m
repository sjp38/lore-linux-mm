Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 36C734403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 09:52:23 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id f206so257177165wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 06:52:23 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id 134si28668001wmr.40.2016.01.12.06.52.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 06:52:22 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id f206so324283431wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 06:52:21 -0800 (PST)
Date: Tue, 12 Jan 2016 16:52:19 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: fix locking order in mm_take_all_locks()
Message-ID: <20160112145219.GA11419@node.shutemov.name>
References: <1452510328-93955-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160112144521.GL25337@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160112144521.GL25337@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Jan 12, 2016 at 03:45:21PM +0100, Michal Hocko wrote:
> On Mon 11-01-16 14:05:28, Kirill A. Shutemov wrote:
> > Dmitry Vyukov has reported[1] possible deadlock (triggered by his syzkaller
> > fuzzer):
> > 
> >  Possible unsafe locking scenario:
> > 
> >        CPU0                    CPU1
> >        ----                    ----
> >   lock(&hugetlbfs_i_mmap_rwsem_key);
> >                                lock(&mapping->i_mmap_rwsem);
> >                                lock(&hugetlbfs_i_mmap_rwsem_key);
> >   lock(&mapping->i_mmap_rwsem);
> > 
> > Both traces points to mm_take_all_locks() as a source of the problem.
> > It doesn't take care about ordering or hugetlbfs_i_mmap_rwsem_key (aka
> > mapping->i_mmap_rwsem for hugetlb mapping) vs. i_mmap_rwsem.
> 
> Hmm, but huge_pmd_share is called with mmap_sem held no?

Why does it matter?

Both mappings can be mapped to different processes, so mmap_sem is no good
here.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
