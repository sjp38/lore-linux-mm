Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 617826B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 00:59:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k18-v6so14039515wrm.6
        for <linux-mm@kvack.org>; Tue, 29 May 2018 21:59:31 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id w39-v6si31613eda.109.2018.05.29.21.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 21:59:28 -0700 (PDT)
Date: Wed, 30 May 2018 06:59:27 +0200
From: "joro@8bytes.org" <joro@8bytes.org>
Subject: Re: [PATCH v3 3/3] x86/mm: add TLB purge to free pmd/pte page
 interfaces
Message-ID: <20180530045927.GP18595@8bytes.org>
References: <20180516233207.1580-1-toshi.kani@hpe.com>
 <20180516233207.1580-4-toshi.kani@hpe.com>
 <20180529144438.GM18595@8bytes.org>
 <1527610139.14039.58.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1527610139.14039.58.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>

On Tue, May 29, 2018 at 04:10:24PM +0000, Kani, Toshi wrote:
> Can you explain why you think allocating a page here is a major problem?

Because a larger allocation is more likely to fail. And if you fail the
allocation, you also fail to free more pages, which _is_ a problem. So
better avoid any allocations in code paths that are about freeing
memory.

> If we just revert, please apply patch 1/3 first.  This patch address the
> BUG_ON issue on PAE.  This is a real issue that needs a fix ASAP.

It does not address the problem of dirty page-walk caches on x86-64.

> The page-directory cache issue on x64, which is addressed by patch 3/3,
> is a theoretical issue that I could not hit by putting ioremap() calls
> into a loop for a whole day.  Nobody hit this issue, either.

How do you know you didn't hit that issue? It might cause silent data
corruption, which might not be easily detected.

> The simple revert patch Joerg posted a while ago causes
> pmd_free_pte_page() to fail on x64.  This causes multiple pmd mappings
> to fall into pte mappings on my test systems.  This can be seen as a
> degradation, and I am afraid that it is more harmful than good.

The plain revert just removes all the issues with the dirty TLB that the
original patch introduced and prevents huge mappings from being
established when there have been smaller mappings before. This is not
ideal, but at least its is consistent and does not leak pages and leaves
no dirty TLBs. So this is the easiest and most reliable fix for this
stage in the release process.


Regards,

	Joerg
