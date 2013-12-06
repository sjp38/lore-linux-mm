Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id ED9BC6B009E
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 15:33:01 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id e16so881779qcx.31
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 12:33:01 -0800 (PST)
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTP id k3si50579058qao.58.2013.12.06.12.32.57
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 12:33:00 -0800 (PST)
Date: Fri, 6 Dec 2013 20:32:56 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 14/15] mm: fix TLB flush race between migration, and
 change_protection_range
In-Reply-To: <20131206141331.10880d2b@annuminas.surriel.com>
Message-ID: <00000142c99cf5b0-69cc9987-aa36-4889-af6a-1a45032d0d13-000000@email.amazonses.com>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de> <1386060721-3794-15-git-send-email-mgorman@suse.de> <529E641A.7040804@redhat.com> <20131203234637.GS11295@suse.de> <529F3D51.1090203@redhat.com> <20131204160741.GC11295@suse.de>
 <20131206141331.10880d2b@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 6 Dec 2013, Rik van Riel wrote:
>
> The basic race looks like this:
>
> CPU A			CPU B			CPU C
>
> 						load TLB entry
> make entry PTE/PMD_NUMA
> 			fault on entry
> 						read/write old page
> 			start migrating page

When you start migrating a page a special page migration entry is
created that will trap all accesses to the page. You can safely flush when
the migration entry is there. Only allow a new PTE/PMD to be put there
*after* the tlb flush.


> 			change PTE/PMD to new page

Dont do that. We have migration entries for a reason.

> 						read/write old page [*]

Should cause a page fault which should put the process to sleep. Process
will safely read the page after the migration entry is removed.

> flush TLB

Establish the new PTE/PMD after the flush removing the migration pte
entry and thereby avoiding the race.

> 						reload TLB from new entry
> 						read/write new page
> 						lose data
>
> [*] the old page may belong to a new user at this point!
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
