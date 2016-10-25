Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0C46B027C
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 19:46:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 140so8973870wmv.12
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 16:46:35 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id r140si119151wme.5.2016.10.25.16.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 16:46:34 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id b80so192770861wme.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 16:46:34 -0700 (PDT)
Date: Wed, 26 Oct 2016 00:46:31 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH] mm: remove unnecessary __get_user_pages_unlocked() calls
Message-ID: <20161025234631.GA5946@lucifer>
References: <20161025233609.5601-1-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025233609.5601-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

The holdout for unexporting __get_user_pages_unlocked() is its invocation in
mm/process_vm_access.c: process_vm_rw_single_vec(), as this definitely _does_
seem to invoke VM_FAULT_RETRY behaviour which get_user_pages_remote() will not
trigger if we were to replace it with the latter.

I'm not sure how to proceed in this case - get_user_pages_remote() invocations
assume mmap_sem is held so can't offer VM_FAULT_RETRY behaviour as the lock
can't be assumed to be safe to release, and get_user_pages_unlocked() assumes
tsk, mm are set to current, current->mm respectively so we can't use that here
either.

Is it important to retain VM_FAULT_RETRY behaviour here, does it matter? If it
isn't so important then we can just go ahead and replace with
get_user_pages_remote() and unexport away.

Of course the whole idea of unexporting __get_user_pages_unlocked() might be
bogus so let me know in that case also :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
