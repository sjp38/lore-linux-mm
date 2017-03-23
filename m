Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 87EFB6B0333
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 19:26:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p189so334758528pfp.5
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 16:26:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i1si321224pgn.203.2017.03.23.16.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 16:26:40 -0700 (PDT)
Date: Thu, 23 Mar 2017 16:26:38 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [v1 0/5] parallelized "struct page" zeroing
Message-ID: <20170323232638.GB29134@bombadil.infradead.org>
References: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.or

On Thu, Mar 23, 2017 at 07:01:48PM -0400, Pavel Tatashin wrote:
> When deferred struct page initialization feature is enabled, we get a
> performance gain of initializing vmemmap in parallel after other CPUs are
> started. However, we still zero the memory for vmemmap using one boot CPU.
> This patch-set fixes the memset-zeroing limitation by deferring it as well.
> 
> Here is example performance gain on SPARC with 32T:
> base
> https://hastebin.com/ozanelatat.go
> 
> fix
> https://hastebin.com/utonawukof.go
> 
> As you can see without the fix it takes: 97.89s to boot
> With the fix it takes: 46.91 to boot.

How long does it take if we just don't zero this memory at all?  We seem
to be initialising most of struct page in __init_single_page(), so it
seems like a lot of additional complexity to conditionally zero the rest
of struct page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
