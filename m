Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8006B0038
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 19:36:59 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id b82so105336698iod.10
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 16:36:59 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q2si7966152plh.271.2017.04.20.16.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 16:36:58 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 4/4] Change mmap_sem to range lock
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
	<1492698500-24219-1-git-send-email-ldufour@linux.vnet.ibm.com>
Date: Thu, 20 Apr 2017 16:36:57 -0700
In-Reply-To: <1492698500-24219-1-git-send-email-ldufour@linux.vnet.ibm.com>
	(Laurent Dufour's message of "Thu, 20 Apr 2017 16:28:20 +0200")
Message-ID: <8737d2d52e.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:

> [resent this patch which seems to have not reached the mailing lists]
>
> Change the mmap_sem to a range lock to allow finer grain locking on
> the memory layout of a task.
>
> This patch rename mmap_sem into mmap_rw_tree to avoid confusion and
> replace any locking (read or write) by complete range locking.  So
> there is no functional change except in the way the underlying locking
> is achieved.
>
> Currently, this patch only supports x86 and PowerPc architectures,
> furthermore it should break the build of any others.

Thanks for working on this.

However as commented before I think the first step to make progress here
is a description of everything mmap_sem protects.

Surely the init full case could be done shorter with some wrapper
that combines the init_full and lock operation?

Then it would be likely a simple search'n'replace to move the
whole tree in one atomic step to the new wrappers.
Initially they could be just defined to use rwsems too to
not change anything at all.

It would be a good idea to merge such a patch as quickly
as possible beause it will be a nightmare to maintain
longer term.

Then you could add a config to use a range lock through
the wrappers.

Then after that you could add real ranges step by step,
after doing the proper analysis.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
