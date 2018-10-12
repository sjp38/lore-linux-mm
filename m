Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E50E86B000C
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:58:03 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 4-v6so12062439qtt.22
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 10:58:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z12-v6si1606886qkl.152.2018.10.12.10.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 10:58:03 -0700 (PDT)
Date: Fri, 12 Oct 2018 13:58:00 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/thp: fix call to mmu_notifier in
 set_pmd_migration_entry()
Message-ID: <20181012175800.GD7395@redhat.com>
References: <20181012160953.5841-1-jglisse@redhat.com>
 <DB07F115-B404-4AB0-9D54-BC20C3A3F2B0@cs.rutgers.edu>
 <20181012172422.GA7395@redhat.com>
 <20181012173518.GD6593@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181012173518.GD6593@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, David Nellans <dnellans@nvidia.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

On Fri, Oct 12, 2018 at 01:35:19PM -0400, Jerome Glisse wrote:
> On Fri, Oct 12, 2018 at 01:24:22PM -0400, Andrea Arcangeli wrote:
> > Hello,
> > 
> > On Fri, Oct 12, 2018 at 12:20:54PM -0400, Zi Yan wrote:
> > > On 12 Oct 2018, at 12:09, jglisse@redhat.com wrote:
> > > 
> > > > From: Jerome Glisse <jglisse@redhat.com>
> > > >
> > > > Inside set_pmd_migration_entry() we are holding page table locks and
> > > > thus we can not sleep so we can not call invalidate_range_start/end()
> > > >
> > > > So remove call to mmu_notifier_invalidate_range_start/end() and add
> > > > call to mmu_notifier_invalidate_range(). Note that we are already
> > 
> > Why the call to mmu_notifier_invalidate_range if we're under
> > range_start and followed by range_end? (it's not _range_only_end, if
> > it was _range_only_end the above would be needed)
> 
> I wanted to be extra safe and accept to over invalidate. You are right
> that it is not strictly necessary. I am fine with removing it.

If it's superfluous, I'd generally prefer strict code unless there's a
very explicit comment about it that says it's actually superfluous.
Otherwise after a while we don't know why it was added there.

> We can remove it. Should i post a v2 without it ?

That's fine with me yes.

Thanks,
Andrea
