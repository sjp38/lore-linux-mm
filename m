Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52AEF6B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 13:25:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l188so63253348pfc.7
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:25:15 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e127si9660934pfc.168.2017.10.10.10.25.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 10:25:14 -0700 (PDT)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 0/7 v1] Speed up page cache truncation
References: <20171010151937.26984-1-jack@suse.cz>
Date: Tue, 10 Oct 2017 10:25:13 -0700
In-Reply-To: <20171010151937.26984-1-jack@suse.cz> (Jan Kara's message of
	"Tue, 10 Oct 2017 17:19:30 +0200")
Message-ID: <878tgisyo6.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

Jan Kara <jack@suse.cz> writes:

> when rebasing our enterprise distro to a newer kernel (from 4.4 to 4.12) we
> have noticed a regression in bonnie++ benchmark when deleting files.
> Eventually we have tracked this down to a fact that page cache truncation got
> slower by about 10%. There were both gains and losses in the above interval of
> kernels but we have been able to identify that commit 83929372f629 "filemap:
> prepare find and delete operations for huge pages" caused about 10% regression
> on its own.

It's odd that just checking if some pages are huge should be that
expensive, but ok ..
>
> Patch 1 is an easy speedup of cancel_dirty_page(). Patches 2-6 refactor page
> cache truncation code so that it is easier to batch radix tree operations.
> Patch 7 implements batching of deletes from the radix tree which more than
> makes up for the original regression.
>
> What do people think about this series?

Batching locks is always a good idea. You'll likely see far more benefits
under lock contention on larger systems.

>From a quick read it looks good to me.

Reviewed-by: Andi Kleen <ak@linux.intel.com>


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
