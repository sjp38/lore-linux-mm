Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4EE6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:56:18 -0400 (EDT)
Received: by wibg7 with SMTP id g7so11032468wib.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 07:56:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ll20si3404033wic.111.2015.03.19.07.56.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 07:56:16 -0700 (PDT)
Message-ID: <550AE38E.7090006@suse.cz>
Date: Thu, 19 Mar 2015 15:56:14 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V6] Allow compaction of unevictable pages
References: <1426773430-31052-1-git-send-email-emunson@akamai.com>
In-Reply-To: <1426773430-31052-1-git-send-email-emunson@akamai.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-rt-users@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/19/2015 02:57 PM, Eric B Munson wrote:
> Currently, pages which are marked as unevictable are protected from
> compaction, but not from other types of migration.  The POSIX real time
> extension explicitly states that mlock() will prevent a major page
> fault, but the spirit of is is that mlock() should give a process the
> ability to control sources of latency, including minor page faults.
> However, the mlock manpage only explicitly says that a locked page will
> not be written to swap and this can cause some confusion.  The
> compaction code today, does not give a developer who wants to avoid swap
> but wants to have large contiguous areas available any method to achieve
> this state.  This patch introduces a sysctl for controlling compaction
> behavoir with respect to the unevictable lru.  Users that demand no page

  behavior

> faults after a page is present can set compact_unevictable to 0 and

                                        compact_unevictable_allowed

> users who need the large contiguous areas can enable compaction on
> locked memory by leaving the default value of 1.
> 
> To illustrate this problem I wrote a quick test program that mmaps a
> large number of 1MB files filled with random data.  These maps are
> created locked and read only.  Then every other mmap is unmapped and I
> attempt to allocate huge pages to the static huge page pool.  When the
> compact_unevictable sysctl is 0, I cannot allocate hugepages after

compact_unevictable_allowed

> fragmenting memory.  When the value is set to 1, allocations succeed.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
