Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id EEB544403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:20:10 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id f206so257034259wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:20:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15si142357912wjr.53.2016.01.12.07.20.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Jan 2016 07:20:09 -0800 (PST)
Date: Tue, 12 Jan 2016 16:20:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix locking order in mm_take_all_locks()
Message-ID: <20160112152008.GN25337@dhcp22.suse.cz>
References: <1452510328-93955-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160112144521.GL25337@dhcp22.suse.cz>
 <20160112145219.GA11419@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160112145219.GA11419@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>

On Tue 12-01-16 16:52:19, Kirill A. Shutemov wrote:
> On Tue, Jan 12, 2016 at 03:45:21PM +0100, Michal Hocko wrote:
> > On Mon 11-01-16 14:05:28, Kirill A. Shutemov wrote:
> > > Dmitry Vyukov has reported[1] possible deadlock (triggered by his syzkaller
> > > fuzzer):
> > > 
> > >  Possible unsafe locking scenario:
> > > 
> > >        CPU0                    CPU1
> > >        ----                    ----
> > >   lock(&hugetlbfs_i_mmap_rwsem_key);
> > >                                lock(&mapping->i_mmap_rwsem);
> > >                                lock(&hugetlbfs_i_mmap_rwsem_key);
> > >   lock(&mapping->i_mmap_rwsem);
> > > 
> > > Both traces points to mm_take_all_locks() as a source of the problem.
> > > It doesn't take care about ordering or hugetlbfs_i_mmap_rwsem_key (aka
> > > mapping->i_mmap_rwsem for hugetlb mapping) vs. i_mmap_rwsem.
> > 
> > Hmm, but huge_pmd_share is called with mmap_sem held no?
> 
> Why does it matter?
> 
> Both mappings can be mapped to different processes, so mmap_sem is no good
> here.

You are right! Then it really makes a differencec.
Feel free to add
Reviewed-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
