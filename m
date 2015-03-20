Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 979866B006C
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 10:47:43 -0400 (EDT)
Received: by qcbkw5 with SMTP id kw5so95009737qcb.2
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 07:47:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b79si4439476qge.107.2015.03.20.07.47.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 07:47:42 -0700 (PDT)
Message-ID: <550C32E8.6030103@redhat.com>
Date: Fri, 20 Mar 2015 10:47:04 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V7] Allow compaction of unevictable pages
References: <1426859390-10974-1-git-send-email-emunson@akamai.com>
In-Reply-To: <1426859390-10974-1-git-send-email-emunson@akamai.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, linux-doc@vger.kernel.org, linux-rt-users@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/20/2015 09:49 AM, Eric B Munson wrote:
> Currently, pages which are marked as unevictable are protected from
> compaction, but not from other types of migration.  The POSIX real time
> extension explicitly states that mlock() will prevent a major page
> fault, but the spirit of this is that mlock() should give a process the
> ability to control sources of latency, including minor page faults.
> However, the mlock manpage only explicitly says that a locked page will
> not be written to swap and this can cause some confusion.  The
> compaction code today does not give a developer who wants to avoid swap
> but wants to have large contiguous areas available any method to achieve
> this state.  This patch introduces a sysctl for controlling compaction
> behavior with respect to the unevictable lru.  Users that demand no page
> faults after a page is present can set compact_unevictable_allowed to 0
> and users who need the large contiguous areas can enable compaction on
> locked memory by leaving the default value of 1.
> 
> To illustrate this problem I wrote a quick test program that mmaps a
> large number of 1MB files filled with random data.  These maps are
> created locked and read only.  Then every other mmap is unmapped and I
> attempt to allocate huge pages to the static huge page pool.  When the
> compact_unevictable_allowed sysctl is 0, I cannot allocate hugepages
> after fragmenting memory.  When the value is set to 1, allocations
> succeed.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Christoph Lameter <cl@linux.com>
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
