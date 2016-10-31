Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCA06B0290
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 06:21:11 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m83so66990852wmc.1
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 03:21:11 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id wx6si28718709wjb.37.2016.10.31.03.21.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Oct 2016 03:21:10 -0700 (PDT)
Date: Mon, 31 Oct 2016 10:20:57 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [net-next PATCH RFC 04/26] arch/arm: Add option to skip sync on
 DMA map and unmap
Message-ID: <20161031102057.GZ1041@n2100.armlinux.org.uk>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024120447.16276.50401.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024120447.16276.50401.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, davem@davemloft.net

On Mon, Oct 24, 2016 at 08:04:47AM -0400, Alexander Duyck wrote:
> The use of DMA_ATTR_SKIP_CPU_SYNC was not consistent across all of the DMA
> APIs in the arch/arm folder.  This change is meant to correct that so that
> we get consistent behavior.

I'm really not convinced that this is anywhere close to correct behaviour.

If we're DMA-ing to a buffer, and we unmap it or sync_for_cpu, then we
will want to access the DMA'd data - especially in the sync_for_cpu case,
it's pointless to call sync_for_cpu if we're not going to access the
data.

So the idea of skipping the CPU copy when DMA_ATTR_SKIP_CPU_SYNC is set
seems to be completely wrong - it means we end up reading the stale data
that was in the buffer, completely ignoring whatever was DMA'd to it.

What's the use case for DMA_ATTR_SKIP_CPU_SYNC ?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
