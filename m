Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 821EC6B0284
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:15:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l66so6064562pfl.7
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:15:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g16si4653812pfj.150.2016.11.02.12.15.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Nov 2016 12:15:53 -0700 (PDT)
From: Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [PATCH] mm: only enable sys_pkey* when ARCH_HAS_PKEYS
References: <1477958904-9903-1-git-send-email-mark.rutland@arm.com>
Message-ID: <c716d515-409f-4092-73d2-1a81db6c1ba3@linux.intel.com>
Date: Wed, 2 Nov 2016 12:15:50 -0700
MIME-Version: 1.0
In-Reply-To: <1477958904-9903-1-git-send-email-mark.rutland@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Russell King <rmk+kernel@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On 10/31/2016 05:08 PM, Mark Rutland wrote:
> When an architecture does not select CONFIG_ARCH_HAS_PKEYS, the pkey_alloc
> syscall will return -ENOSPC for all (otherwise well-formed) requests, as the
> generic implementation of mm_pkey_alloc() returns -1. The other pkey syscalls
> perform some work before always failing, in a similar fashion.
> 
> This implies the absence of keys, but otherwise functional pkey support. This
> is odd, since the architecture provides no such support. Instead, it would be
> preferable to indicate that the syscall is not implemented, since this is
> effectively the case.

This makes the behavior of an x86 cpu without pkeys and an arm cpu
without pkeys differ.  Is that what we want?  An application that
_wants_ to use protection keys but can't needs to handle -ENOSPC anyway.

On an architecture that will never support pkeys, it makes sense to do
-ENOSYS, but that's not the case for arm, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
