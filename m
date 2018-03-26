Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33A976B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:26:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c65so4020035pfa.5
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 12:26:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k8si10683097pgs.555.2018.03.26.12.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 12:26:13 -0700 (PDT)
Date: Mon, 26 Mar 2018 12:26:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: kmemleak: wait for scan completion before disabling
 free
Message-Id: <20180326122611.acbfe1bfe6f7c1792b42a3a7@linux-foundation.org>
In-Reply-To: <20180326154421.obk7ikx3h5ko62o5@armageddon.cambridge.arm.com>
References: <1522063429-18992-1-git-send-email-vinmenon@codeaurora.org>
	<20180326154421.obk7ikx3h5ko62o5@armageddon.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org

On Mon, 26 Mar 2018 16:44:21 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:

> On Mon, Mar 26, 2018 at 04:53:49PM +0530, Vinayak Menon wrote:
> > A crash is observed when kmemleak_scan accesses the
> > object->pointer, likely due to the following race.
> > 
> > TASK A             TASK B                     TASK C
> > kmemleak_write
> >  (with "scan" and
> >  NOT "scan=on")
> > kmemleak_scan()
> >                    create_object
> >                    kmem_cache_alloc fails
> >                    kmemleak_disable
> >                    kmemleak_do_cleanup
> >                    kmemleak_free_enabled = 0
> >                                               kfree
> >                                               kmemleak_free bails out
> >                                                (kmemleak_free_enabled is 0)
> >                                               slub frees object->pointer
> > update_checksum
> > crash - object->pointer
> >  freed (DEBUG_PAGEALLOC)
> > 
> > kmemleak_do_cleanup waits for the scan thread to complete, but not for
> > direct call to kmemleak_scan via kmemleak_write. So add a wait for
> > kmemleak_scan completion before disabling kmemleak_free.
> > 
> > Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> 
> It looks fine to me. Maybe Andrew can pick it up.
> 
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Well, the comment says:

/*
 * Stop the automatic memory scanning thread. This function must be called
 * with the scan_mutex held.
 */
static void stop_scan_thread(void)


So shouldn't we do it this way?

--- a/mm/kmemleak.c~mm-kmemleak-wait-for-scan-completion-before-disabling-free-fix
+++ a/mm/kmemleak.c
@@ -1919,9 +1919,9 @@ static void __kmemleak_do_cleanup(void)
  */
 static void kmemleak_do_cleanup(struct work_struct *work)
 {
+	mutex_lock(&scan_mutex);
 	stop_scan_thread();
 
-	mutex_lock(&scan_mutex);
 	/*
 	 * Once it is made sure that kmemleak_scan has stopped, it is safe to no
 	 * longer track object freeing. Ordering of the scan thread stopping and
_
