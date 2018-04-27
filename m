Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEE16B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 08:48:31 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 88-v6so1233586wrc.21
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 05:48:31 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id i7-v6si1642165edg.65.2018.04.27.05.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 05:48:29 -0700 (PDT)
Date: Fri, 27 Apr 2018 14:48:29 +0200
From: "joro@8bytes.org" <joro@8bytes.org>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Message-ID: <20180427124828.GW15462@8bytes.org>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
 <20180314180155.19492-3-toshi.kani@hpe.com>
 <20180426141926.GN15462@8bytes.org>
 <1524759629.2693.465.camel@hpe.com>
 <20180426172327.GQ15462@8bytes.org>
 <1524764948.2693.478.camel@hpe.com>
 <20180426200737.GS15462@8bytes.org>
 <1524781764.2693.503.camel@hpe.com>
 <20180427073719.GT15462@8bytes.org>
 <5b237058-6617-6af3-8499-8836d95f538d@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b237058-6617-6af3-8499-8836d95f538d@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: "Kani, Toshi" <toshi.kani@hpe.com>, "Hocko, Michal" <MHocko@suse.com>, "hpa@zytor.com" <hpa@zytor.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "x86@kernel.org" <x86@kernel.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mingo@redhat.com" <mingo@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "bp@suse.de" <bp@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Apr 27, 2018 at 05:22:28PM +0530, Chintan Pandya wrote:
> I'm bit confused here. Are you pointing to race within ioremap/vmalloc
> framework while updating the page table or race during tlb ops. Since
> later is arch dependent, I would not comment. But if the race being
> discussed here while altering page tables, I'm not on the same page.

The race condition is between hardware and software. It is not
sufficient to just remove the software references to the page that is
about to be freed (by clearing the PMD/PUD), also the hardware
references in the page-walk cache need to be removed with a TLB flush.
Otherwise the hardware can use the freed (and possibly reused) page to
establish new TLB entries.



	Joerg
