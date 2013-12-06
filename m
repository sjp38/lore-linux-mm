Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f53.google.com (mail-qe0-f53.google.com [209.85.128.53])
	by kanga.kvack.org (Postfix) with ESMTP id 20EC86B00A8
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 16:21:29 -0500 (EST)
Received: by mail-qe0-f53.google.com with SMTP id nc12so955765qeb.40
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 13:21:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v4si37499347qeb.140.2013.12.06.13.21.27
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 13:21:28 -0800 (PST)
Message-ID: <52A23FD1.3040102@redhat.com>
Date: Fri, 06 Dec 2013 16:21:21 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/15] mm: fix TLB flush race between migration, and change_protection_range
References: <1386060721-3794-1-git-send-email-mgorman@suse.de> <1386060721-3794-15-git-send-email-mgorman@suse.de> <529E641A.7040804@redhat.com> <20131203234637.GS11295@suse.de> <529F3D51.1090203@redhat.com> <20131204160741.GC11295@suse.de> <20131206141331.10880d2b@annuminas.surriel.com> <00000142c99cf5b0-69cc9987-aa36-4889-af6a-1a45032d0d13-000000@email.amazonses.com>
In-Reply-To: <00000142c99cf5b0-69cc9987-aa36-4889-af6a-1a45032d0d13-000000@email.amazonses.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/06/2013 03:32 PM, Christoph Lameter wrote:
> On Fri, 6 Dec 2013, Rik van Riel wrote:
>>
>> The basic race looks like this:
>>
>> CPU A			CPU B			CPU C
>>
>> 						load TLB entry
>> make entry PTE/PMD_NUMA
>> 			fault on entry
>> 						read/write old page
>> 			start migrating page
> 
> When you start migrating a page a special page migration entry is
> created that will trap all accesses to the page. You can safely flush when
> the migration entry is there. Only allow a new PTE/PMD to be put there
> *after* the tlb flush.

A PROT_NONE or NUMA pte is just as effective as a migration pte.
The only problem is, the TLB flush was not always done...

> 
>> 			change PTE/PMD to new page
> 
> Dont do that. We have migration entries for a reason.

We do not have migration entries for hugepages, do we?

>> 						read/write old page [*]
> 
> Should cause a page fault which should put the process to sleep. Process
> will safely read the page after the migration entry is removed.
> 
>> flush TLB
> 
> Establish the new PTE/PMD after the flush removing the migration pte
> entry and thereby avoiding the race.

That is what this patch does.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
