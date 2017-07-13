Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 483E7440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 12:30:58 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q1so4977471qkb.3
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 09:30:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l128si5574379qkc.43.2017.07.13.09.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 09:30:57 -0700 (PDT)
Date: Thu, 13 Jul 2017 18:30:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
Message-ID: <20170713163054.GK22628@redhat.com>
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <20170711123642.GC11936@dhcp22.suse.cz>
 <7f14334f-81d1-7698-d694-37278f05a78e@oracle.com>
 <20170712114655.GG28912@dhcp22.suse.cz>
 <3a2cfeae-520c-b6e5-2808-cf1bcf62b067@oracle.com>
 <20170713061651.GA14492@dhcp22.suse.cz>
 <21b264e7-b879-f072-03d2-f6f4aec5c957@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <21b264e7-b879-f072-03d2-f6f4aec5c957@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Jul 13, 2017 at 09:01:54AM -0700, Mike Kravetz wrote:
> Sent a patch (in separate e-mail thread) to return EINVAL for private
> mappings.

The way old_len == 0 behaves for MAP_PRIVATE seems more sane to me
than the alternative of copying pagetables for anon pages (as behaving
the way that way avoids to break anon pages invariants), despite it's
not creating an exact mirror of what was in the original vma as it
excludes any modification done to cowed anon pages.

By nullifying move_page_tables old_len == 0 is simply duping the vma
which is equivalent to a new mmap on the file for the MAP_PRIVATE
case, it has a deterministic result. The real question is if it
anybody is using it.

So an alternative would be to start by adding a WARN_ON_ONCE deprecation
warning instead of -EINVAL right away.

The vma->vm_flags VM_ACCOUNT being wiped on the original vma as side
effect of using the old_len == 0 trick looks like a bug, I guess it
should get fixed if we intend to keep old_len and document it for the
long term.

Overall I'm more concerned about the fact an allocation failure in
do_munmap is unreported to userland and it will leave the old vma
intact like old_len == 0 would do (unless I'm misreading something
there). The VM_ACCOUNT wipe as side effect of old_len == 0 is not
major short term concern.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
