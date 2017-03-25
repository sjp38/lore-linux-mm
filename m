Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 721736B0038
	for <linux-mm@kvack.org>; Sat, 25 Mar 2017 17:26:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s29so14951027pfg.21
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 14:26:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 71si5227530pfh.141.2017.03.25.14.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Mar 2017 14:26:03 -0700 (PDT)
Date: Sat, 25 Mar 2017 14:25:58 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [v2 0/5] parallelized "struct page" zeroing
Message-ID: <20170325212558.GA1288@bombadil.infradead.org>
References: <1490383192-981017-1-git-send-email-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1490383192-981017-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

On Fri, Mar 24, 2017 at 03:19:47PM -0400, Pavel Tatashin wrote:
> Changelog:
> 	v1 - v2
> 	- Per request, added s390 to deferred "struct page" zeroing
> 	- Collected performance data on x86 which proofs the importance to
> 	  keep memset() as prefetch (see below).
> 
> When deferred struct page initialization feature is enabled, we get a
> performance gain of initializing vmemmap in parallel after other CPUs are
> started. However, we still zero the memory for vmemmap using one boot CPU.
> This patch-set fixes the memset-zeroing limitation by deferring it as well.
> 
> Performance gain on SPARC with 32T:
> base:	https://hastebin.com/ozanelatat.go
> fix:	https://hastebin.com/utonawukof.go
> 
> As you can see without the fix it takes: 97.89s to boot
> With the fix it takes: 46.91 to boot.
> 
> Performance gain on x86 with 1T:
> base:	https://hastebin.com/uvifasohon.pas
> fix:	https://hastebin.com/anodiqaguj.pas
> 
> On Intel we save 10.66s/T while on SPARC we save 1.59s/T. Intel has
> twice as many pages, and also fewer nodes than SPARC (sparc 32 nodes, vs.
> intel 8 nodes).
> 
> It takes one thread 11.25s to zero vmemmap on Intel for 1T, so it should
> take additional 11.25 / 8 = 1.4s  (this machine has 8 nodes) per node to
> initialize the memory, but it takes only additional 0.456s per node, which
> means on Intel we also benefit from having memset() and initializing all
> other fields in one place.

My question was how long it takes if you memset in neither place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
