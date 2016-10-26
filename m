Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 500836B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 03:59:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y138so11651460wme.7
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:59:59 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id c199si1692811wmd.119.2016.10.26.00.59.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 00:59:57 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id b80so209443985wme.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:59:57 -0700 (PDT)
Date: Wed, 26 Oct 2016 08:59:52 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH] mm: remove unnecessary __get_user_pages_unlocked() calls
Message-ID: <20161026075952.GA30977@lucifer>
References: <20161025233609.5601-1-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025233609.5601-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 26, 2016 at 12:36:09AM +0100, Lorenzo Stoakes wrote:
> In hva_to_pfn_slow() we are able to replace __get_user_pages_unlocked() with
> get_user_pages_unlocked() since we can now pass gup_flags.
>
> In async_pf_execute() we need to pass different tsk, mm arguments so
> get_user_pages_remote() is the sane replacement here (having added manual
> acquisition and release of mmap_sem.)
>
> Since we pass a NULL pages parameter the subsequent call to
> __get_user_pages_locked() will have previously bailed any attempt at
> VM_FAULT_RETRY, so we do not change this behaviour by using
> get_user_pages_remote() which does not invoke VM_FAULT_RETRY logic at all.
>
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

Note that the use of get_user_pages_remote() in async_pf_execute() reintroduces
the use of the FOLL_TOUCH flag - I don't think this is a problem as this flag
was dropped by 1e987790 ("mm/gup: Introduce get_user_pages_remote()") which
states 'Without protection keys, this patch should not change any behavior', so
I don't think this was intentional.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
