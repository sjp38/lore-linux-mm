Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECD316B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 17:40:36 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id c5so760740oib.10
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 14:40:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s188si2630693oib.82.2018.01.25.14.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 14:40:36 -0800 (PST)
Date: Thu, 25 Jan 2018 23:40:29 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2] mm: Reduce memory bloat with THP
Message-ID: <20180125224029.GB4454@redhat.com>
References: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
 <20180119124957.GA6584@dhcp22.suse.cz>
 <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
 <20180125095832.GN28465@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180125095832.GN28465@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nitin Gupta <nitin.m.gupta@oracle.com>, Nitin Gupta <nitingupta910@gmail.com>, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 25, 2018 at 10:58:32AM +0100, Michal Hocko wrote:
> Ohh, absolutely. And that is why we have changed the default in upstream
> 444eb2a449ef ("mm: thp: set THP defrag by default to madvise and add a
> stall-free defrag option")

Agreed, that direct compaction change should already address the cases
quoted in the other URLs.

One of the URL is about using fork() to snapshot a nosql db state,
that one can't be helped by the above commit but it's still unrelated
to MADV_DONTNEED or memory bloat.

It would be possible to fully fix the use of fork() for snapshotting
without userfaultfd WP mode, by just adding an madvise that forces 4k
CoWs on top of 2M THP and to call it in the parent that keeps writing
to memory while the child is writing the readonly copy to disk, but I
believe userfaultfd WP will be way more optimal as it provides so many
other advantages (i.e. avoid fork() in the first place and use
pthread_create and be able to throttle on I/O and limit the max memory
usage to something less than x2 RAM without the risk of triggering the
OOM killer and have a ring that is written immediately to keep the mem
utilization low etc..).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
