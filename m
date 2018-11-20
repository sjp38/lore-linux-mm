Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CED876B2101
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 12:04:10 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so3944745qka.7
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:04:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 16si2223376qtc.18.2018.11.20.09.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 09:04:09 -0800 (PST)
Date: Tue, 20 Nov 2018 12:04:07 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
Message-ID: <20181120170407.GM29258@redhat.com>
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
 <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
 <20181109195150.GA24747@redhat.com>
 <20181110132249.GH23260@techsingularity.net>
 <20181110164412.GB22642@redhat.com>
 <20181120091122.3dxlgff3vivwilrg@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120091122.3dxlgff3vivwilrg@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@techsingularity.net>, Anthony Yznaga <anthony.yznaga@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com

On Tue, Nov 20, 2018 at 12:11:22PM +0300, Kirill A. Shutemov wrote:
> On Sat, Nov 10, 2018 at 11:44:12AM -0500, Andrea Arcangeli wrote:
> > I would prefer to add intelligence to detect when COWs after fork
> > should be done at 2m or 4k granularity (in the latter case by
> > splitting the pmd before the actual COW while leaving the transhuge
> > pmd intact in the other mm), because that would save CPU (and it'd
> > automatically optimize redis). The snapshot process especially would
> > run faster as it will read with THP performance.
> 
> I would argue we should switch to 4k COW everywhere. But it requires some

We could do that if MADV_HUGEPAGE is not set for example. So there
would still be a way to force the 2M cows if something benefits from
them.

For example with binaries executed in tmpfs one could want 2M cows on
MAP_PRIVATE to keep all the executable in 2MB tlbs despite the memory
loss (but then there are those libs that apparently aren't released to
load the binaries into THP anon too for the same reason and with even
higher memory waste risk as unlike tmpfs nothing can be shared if you
run multiple copies of a go large binary or something).

Certainly it would help whenever fork() is used for snapshotting
purposes, but then fork() used for snapshotting purposes doesn't look
the best mechanism possible for atomic snapshots.

It would be interesting to know which other common workloads will
benefit, for workloads that unlike fork()-for-snapshot, are already as
optimal as it can get.

> work on khugepaged side to be able to recover THP back after multiple 4k
> COW in the range. Currently khugepaged is not able to collapse PTE entires
> backed by compound page back to PMD.

Yes this is also answering Anthony question about what shall happen
after to the 4k cows on the doublemap.

The thing is, by the time khugepaged comes around, the child will
hopefully already have quit, so it would be ideal if it can understand
the anon page isn't even shared anymore, it's fully private to the
process after holding the mmap_sem for writing, so if it's not-shared
anymore and mapcount is 1, khugepaged doesn't need to do the 2M cow of
the doublemap THP at all, it just needs to flush the 4k fragment back
to the THP and drop the doublemap and convert the readonly pte entries
to a writable pmd_trans_huge (if VM_WRITE is still set).

> I have this on my todo list for long time, but...

We're also slowly making progress on the uffd-wp to offer a hopefully
way more efficient way to do the snapshot than using fork(), then the
whole fork thing won't be an issue because there will be no fork.
