Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB9B6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 15:42:47 -0400 (EDT)
Received: by igcau2 with SMTP id au2so104202536igc.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 12:42:47 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id d19si2700796icc.71.2015.03.19.12.42.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 12:42:46 -0700 (PDT)
Received: by ignm3 with SMTP id m3so17127258ign.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 12:42:46 -0700 (PDT)
Date: Thu, 19 Mar 2015 12:42:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V6] Allow compaction of unevictable pages
In-Reply-To: <1426773430-31052-1-git-send-email-emunson@akamai.com>
Message-ID: <alpine.DEB.2.10.1503191242150.20092@chino.kir.corp.google.com>
References: <1426773430-31052-1-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-rt-users@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 19 Mar 2015, Eric B Munson wrote:

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
> faults after a page is present can set compact_unevictable to 0 and
> users who need the large contiguous areas can enable compaction on
> locked memory by leaving the default value of 1.
> 
> To illustrate this problem I wrote a quick test program that mmaps a
> large number of 1MB files filled with random data.  These maps are
> created locked and read only.  Then every other mmap is unmapped and I
> attempt to allocate huge pages to the static huge page pool.  When the
> compact_unevictable sysctl is 0, I cannot allocate hugepages after
> fragmenting memory.  When the value is set to 1, allocations succeed.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: linux-rt-users@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-api@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
