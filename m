Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1256F6B0009
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 13:23:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a127so2015602wmh.6
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:23:31 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id g35si1317276eda.74.2018.04.26.10.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 10:23:28 -0700 (PDT)
Date: Thu, 26 Apr 2018 19:23:28 +0200
From: "joro@8bytes.org" <joro@8bytes.org>
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
Message-ID: <20180426172327.GQ15462@8bytes.org>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
 <20180314180155.19492-3-toshi.kani@hpe.com>
 <20180426141926.GN15462@8bytes.org>
 <1524759629.2693.465.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1524759629.2693.465.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "willy@infradead.org" <willy@infradead.org>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Thu, Apr 26, 2018 at 04:21:19PM +0000, Kani, Toshi wrote:
> All pages under the pmd had been unmapped and then lazy TLB purged with
> INVLPG before coming to this code path.  Speculation is not allowed to
> pages without mapping.

CPUs have not only TLBs, but also page-walk caches which cache
intermediary results of page-table walks and which is flushed together
with the TLB.

So the PMD entry you clear can still be in a page-walk cache and this
needs to be flushed too before you can free the PTE page. Otherwise
page-walks might still go to the page you just freed. That is especially
bad when the page is already reallocated and filled with other data.

> > Further this needs synchronization with other page-tables in the system
> > when the kernel PMDs are not shared between processes. In x86-32 with
> > PAE this causes a BUG_ON() being triggered at arch/x86/mm/fault.c:268
> > because the page-tables are not correctly synchronized.
> 
> I think this is an issue with pmd mapping support on x86-32-PAE, not
> with this patch.  I think the code needed to be updated to sync at the
> pud level.

It is an issue with this patch, because this patch is for x86 and on x86
every change to the kernel page-tables potentially needs to by
synchronized to the other page-tables. And this patch doesn't implement
it, which triggers a BUG_ON() under certain conditions.


Regards,

	Joerg
