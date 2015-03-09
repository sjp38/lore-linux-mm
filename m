Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id DA9EE6B0074
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 16:52:22 -0400 (EDT)
Received: by qcwr17 with SMTP id r17so17980370qcw.2
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 13:52:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w33si1907705qgw.43.2015.03.09.13.52.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 13:52:22 -0700 (PDT)
Message-ID: <54FE07E8.4000802@redhat.com>
Date: Mon, 09 Mar 2015 16:51:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3] Allow compaction of unevictable pages
References: <1425934123-30591-1-git-send-email-emunson@akamai.com>
In-Reply-To: <1425934123-30591-1-git-send-email-emunson@akamai.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/09/2015 04:48 PM, Eric B Munson wrote:
> Currently, pages which are marked as unevictable are protected from
> compaction, but not from other types of migration.  The mlock
> desctription does not promise that all page faults will be avoided, only
> major ones so this protection is not necessary.  This extra protection
> can cause problems for applications that are using mlock to avoid
> swapping pages out, but require order > 0 allocations to continue to
> succeed in a fragmented environment.  This patch removes the
> ISOLATE_UNEVICTABLE mode and the check for it in __isolate_lru_page().
> Removing this check allows the removal of the isolate_mode argument from
> isolate_migratepages_block() because it can compute the required mode
> from the compact_control structure.
>
> To illustrate this problem I wrote a quick test program that mmaps a
> large number of 1MB files filled with random data.  These maps are
> created locked and read only.  Then every other mmap is unmapped and I
> attempt to allocate huge pages to the static huge page pool.  Without
> this patch I am unable to allocate any huge pages after  fragmenting
> memory.  With it, I can allocate almost all the space freed by unmapping
> as huge pages.
>
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: David Rientjes <rientjes@google.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
