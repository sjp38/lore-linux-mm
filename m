Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75F816B0003
	for <linux-mm@kvack.org>; Sun, 20 May 2018 21:51:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b25-v6so8329185pfn.10
        for <linux-mm@kvack.org>; Sun, 20 May 2018 18:51:55 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p7-v6si10070979pgd.96.2018.05.20.18.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 18:51:54 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, huge page: Copy to access sub-page last when copy huge page
References: <20180518030316.31019-1-ying.huang@intel.com>
	<20180518062430.GB21711@dhcp22.suse.cz>
Date: Mon, 21 May 2018 09:51:50 +0800
In-Reply-To: <20180518062430.GB21711@dhcp22.suse.cz> (Michal Hocko's message
	of "Fri, 18 May 2018 08:24:30 +0200")
Message-ID: <87fu2lkc7d.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hi, Michal,

Michal Hocko <mhocko@kernel.org> writes:

> On Fri 18-05-18 11:03:16, Huang, Ying wrote:
> [...]
>> The patch is a generic optimization which should benefit quite some
>> workloads, not for a specific use case.  To demonstrate the performance
>> benefit of the patch, we tested it with vm-scalability run on
>> transparent huge page.
>
> It is also adds quite some non-intuitive code. So is this worth? Does
> any _real_ workload benefits from the change?

I don't have any _real_ workload which benefits from this.  But I think
this is the right way to copy the huge page.  It should benefit many
workloads with heavy cache contention, as illustrated in the
micro-benchmark.  But the performance benefit may be small or
non-measurable for the _real_ workload.

The code does become not as intuitive as before.  But fortunately, all
non-intuitive code are in copy_user_huge_page(), which is a leaf
function with well defined interface and semantics.  And with the help
of the code comments, at least the intention of the code is clear.

Best Regards,
Huang, Ying

>>  include/linux/mm.h |  3 ++-
>>  mm/huge_memory.c   |  3 ++-
>>  mm/memory.c        | 43 +++++++++++++++++++++++++++++++++++++++----
>>  3 files changed, 43 insertions(+), 6 deletions(-)
