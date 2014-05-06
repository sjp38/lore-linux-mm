Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7BA6B005A
	for <linux-mm@kvack.org>; Tue,  6 May 2014 13:06:32 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so6190869pab.17
        for <linux-mm@kvack.org>; Tue, 06 May 2014 10:06:31 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id qa3si400927pbb.149.2014.05.06.10.06.30
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 10:06:31 -0700 (PDT)
Date: Tue, 6 May 2014 18:05:49 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 6/6] mm: Postpone the disabling of kmemleak early logging
Message-ID: <20140506170549.GM23957@arm.com>
References: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
 <1399038070-1540-7-git-send-email-catalin.marinas@arm.com>
 <5368FDBB.8070106@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5368FDBB.8070106@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 06, 2014 at 04:20:27PM +0100, Sasha Levin wrote:
> On 05/02/2014 09:41 AM, Catalin Marinas wrote:
> > Currently, kmemleak_early_log is disabled at the beginning of the
> > kmemleak_init() function, before the full kmemleak tracing is actually
> > enabled. In this small window, kmem_cache_create() is called by kmemleak
> > which triggers additional memory allocation that are not traced. This
> > patch moves the kmemleak_early_log disabling further down and at the
> > same time with full kmemleak enabling.
> > 
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> This patch makes the kernel die during the boot process:
> 
> [   24.471801] BUG: unable to handle kernel paging request at ffffffff922f2b93
> [   24.472496] IP: [<ffffffff922f2b93>] log_early+0x0/0xcd

Thanks for reporting this. I assume you run with
CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF enabled and kmemleak_early_log remains
set even though kmemleak is not in use.

Does the patch below fix it?

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 0cd6aabd45a0..e7f74091c024 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1811,6 +1811,7 @@ void __init kmemleak_init(void)
 
 #ifdef CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF
 	if (!kmemleak_skip_disable) {
+		kmemleak_early_log = 0;
 		kmemleak_disable();
 		return;
 	}

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
