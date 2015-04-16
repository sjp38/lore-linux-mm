Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7666B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 03:19:39 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so82120647pdb.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 00:19:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ht8si10850115pdb.99.2015.04.16.00.19.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 00:19:38 -0700 (PDT)
Date: Thu, 16 Apr 2015 00:25:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
Message-Id: <20150416002501.e9615db6.akpm@linux-foundation.org>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, 13 Apr 2015 11:16:52 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Memory initialisation

I wish we didn't call this "memory initialization".  Because memory
initialization is memset(), and that isn't what we're doing here.

Installation?  Bringup?

> had been identified as one of the reasons why large
> machines take a long time to boot. Patches were posted a long time ago
> that attempted to move deferred initialisation into the page allocator
> paths. This was rejected on the grounds it should not be necessary to hurt
> the fast paths to parallelise initialisation. This series reuses much of
> the work from that time but defers the initialisation of memory to kswapd
> so that one thread per node initialises memory local to that node. The
> issue is that on the machines I tested with, memory initialisation was not
> a major contributor to boot times. I'm posting the RFC to both review the
> series and see if it actually helps users of very large machines.
> 
> ...
>
>  15 files changed, 507 insertions(+), 98 deletions(-)

Sadface at how large and complex this is.  I'd hoped the way we were
going to do this was by bringing up a bit of memory to get booted up,
then later on we just fake a bunch of memory hot-add operations.  So
the new code would be pretty small and quite high-level.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
