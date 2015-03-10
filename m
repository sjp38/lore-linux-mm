Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 357BA900020
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 07:22:35 -0400 (EDT)
Received: by wiwh11 with SMTP id h11so2008685wiw.5
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 04:22:34 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id dk4si1087744wib.95.2015.03.10.04.22.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 04:22:33 -0700 (PDT)
Date: Tue, 10 Mar 2015 12:22:20 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V3] Allow compaction of unevictable pages
Message-ID: <20150310112220.GW2896@worktop.programming.kicks-ass.net>
References: <1425934123-30591-1-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425934123-30591-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 09, 2015 at 04:48:43PM -0400, Eric B Munson wrote:
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

So mlock() is part of the POSIX real-time spec. For real-time purposes
we very much do _NOT_ want page migration to happen.

So while you might be following the letter of the spec you're very much
violating the spirit of the thing.

Also, there is another solution to your problem; you can compact
mlock'ed pages at mlock() time.

Furthermore, I would once again like to remind people of my VM_PINNED
patches. The only thing that needs happening there is someone needs to
deobfuscate the IB code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
