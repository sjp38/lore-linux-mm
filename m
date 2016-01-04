Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 546406B0003
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 12:09:01 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id 1so114569200ion.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 09:09:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 23si21685198ioc.165.2016.01.04.09.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 09:09:00 -0800 (PST)
Date: Mon, 4 Jan 2016 18:08:57 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v3 0/2] Allow gmap fault to retry
Message-ID: <20160104170857.GA3702@redhat.com>
References: <1451906395-80878-1-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1451906395-80878-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, linux-kernel@vger.kernel.org

On Mon, Jan 04, 2016 at 12:19:53PM +0100, Dominik Dingel wrote:
> Hello,
> 
> sorry for the delay since the last version.
> 
> During Jasons work with postcopy migration support for s390 a problem regarding
> gmap faults was discovered.
> 
> The gmap code will call fixup_user_fault which will end up always in
> handle_mm_fault. Till now we never cared about retries, but as the userfaultfd
> code kind of relies on it. this needs some fix.
> 
> This patchset does not take care of the futex code. I will now look closer at
> this.
> 
> Thanks,
>     Dominik
> 
> v2 -> v3:
> - In case of retrying check vma again
> - Do the accounting of major/minor faults once

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>


> 
> v1 -> v2:
> - Instread of passing the VM_FAULT_RETRY from fixup_user_fault we do retries
>   within fixup_user_fault, like get_user_pages_locked do.
> - gmap code will now take retry if fixup_user_fault drops the lock.
> 
> Dominik Dingel (2):
>   mm: bring in additional flag for fixup_user_fault to signal unlock
>   s390/mm: enable fixup_user_fault retrying
> 
>  arch/s390/mm/pgtable.c | 31 ++++++++++++++++++++++++++++---
>  include/linux/mm.h     |  5 +++--
>  kernel/futex.c         |  2 +-
>  mm/gup.c               | 30 +++++++++++++++++++++++++-----
>  4 files changed, 57 insertions(+), 11 deletions(-)
> 
> -- 
> 2.3.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
