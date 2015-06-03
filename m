Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7902B900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 19:29:38 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so16690379pad.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 16:29:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l14si3040401pdn.60.2015.06.03.16.29.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 16:29:37 -0700 (PDT)
Date: Wed, 3 Jun 2015 16:29:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: kmemleak: Fix crashing during kmemleak disabling
Message-Id: <20150603162936.9132276820819001436585b3@linux-foundation.org>
In-Reply-To: <1433346176-912-1-git-send-email-catalin.marinas@arm.com>
References: <1433346176-912-1-git-send-email-catalin.marinas@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vignesh Radhakrishnan <vigneshr@codeaurora.org>

On Wed,  3 Jun 2015 16:42:56 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:

> With the current implementation, if kmemleak is disabled because of an
> error condition (e.g. fails to allocate metadata), alloc/free calls are
> no longer tracked. Usually this is not a problem since the kmemleak
> metadata is being removed via kmemleak_do_cleanup(). However, if the
> scanning thread is running at the time of disabling, kmemleak would no
> longer notice a potential vfree() call and the freed/unmapped object may
> still be accessed, causing a fault.
> 
> This patch separates the kmemleak_free() enabling/disabling from the
> overall kmemleak_enabled nob so that we can defer the disabling of the
> object freeing tracking until the scanning thread completed. The
> kmemleak_free_part() is deliberately ignored by this patch since this is
> only called during boot before the scanning thread started.

I'm having trouble with this.  afacit, kmemleak_free() can still be
called while kmemleak_scan() is running on another CPU. 
kmemleak_free_enabled hasn't been cleared yet so the races remain.

However your statement "if the scanning thread is running at the time
of disabling" implies that the race is between kmemleak_scan() and
kmemleak_disable().  Yet the race avoidance code is placed in
kmemleak_free().

All confused.  A more detailed description of the race would help.

Also, the words "kmemleak would no longer notice a potential vfree()
call" aren't sufficiently specific.  kmemleak is a big place - what
*part* of kmemleak are you referring to here?

Finally, I'm concerned that a bare

	kmemleak_free_enabled = 0;

lacks sufficient synchronization with respect to the
kmemleak_free_enabled readers from a locking/reordering point of view. 
What's the story here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
