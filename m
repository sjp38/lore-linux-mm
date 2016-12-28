Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C28216B025E
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 03:48:28 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id hb5so88788022wjc.2
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 00:48:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k141si49406014wmd.133.2016.12.28.00.48.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 00:48:27 -0800 (PST)
Date: Wed, 28 Dec 2016 09:48:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161228084823.GB11470@dhcp22.suse.cz>
References: <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
 <20161223085150.GA23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com>
 <20161223111817.GC23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612231428030.88276@chino.kir.corp.google.com>
 <20161226090211.GA11455@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612261639550.99744@chino.kir.corp.google.com>
 <20161227094008.GC1308@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612271324300.67790@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1612271324300.67790@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 27-12-16 13:36:54, David Rientjes wrote:
[...]
> All madvised VMAs stall now because THEY WANT TO STALL.  It is 
> unbelievable that you would claim otherwise or think that you know better 
> than the application writer about their application.

I do care more about _users_ and their _experience_ than what
application _writers_ think is the best. This is the whole point
of giving the defrag tunable. madvise(MADV_HUGEPAGE) is just a hint to
the system that using transparent hugepages is _preferable_, not
mandatory. We have an option to allow stalls for those vmas to increase
the allocation success rate. We also have tunable to completely ignore
it. And we should also have an option to not stall.

Your interpretation of what is the expected stalling behavior of
MADV_HUGEPAGE doesn't match what the man page says:

: MADV_HUGEPAGE (since Linux 2.6.38)
: Enable Transparent Huge Pages (THP) for pages in the range specified
: by addr and length.  Currently, Transparent Huge Pages work only with
: private anonymous pages (see mmap(2)).  The kernel will regularly
: scan the areas marked as huge page candidates to replace them with
: huge pages.  The kernel will also allocate huge pages directly
: when the region is naturally aligned to the huge page size (see
: posix_memalign(2)).
: 
: This feature is primarily aimed at applications that use large mappings
: of data and access large regions of that memory at a time (e.g.,
: virtualization systems such as QEMU).  It can very easily waste memory
: (e.g., a 2MB mapping that only ever accesses 1 byte will result in 2MB
: of wired memory instead of one 4KB page).  See the Linux kernel source
: file Documentation/vm/transhuge.txt for more details.
: 
: The MADV_HUGEPAGE and MADV_NOHUGEPAGE operations are available only if
: the kernel was configured with CONFIG_TRANSPARENT_HUGEPAGE.

while it clearly contradicts what "defer" option is documented to
provide in  Documentation/vm/transhuge.txt:

: "defer" means that an application will wake kswapd in the background
: to reclaim pages and wake kcompact to compact memory so that THP is
: available in the near future. It's the responsibility of khugepaged
: to then install the THP pages later.

I am not going to reply to other your claims because I would just repeat
myself.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
