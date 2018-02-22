Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 79E7B6B0008
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 14:01:58 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id t2so2696333plr.15
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 11:01:58 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 33-v6si452451plt.429.2018.02.22.11.01.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 11:01:57 -0800 (PST)
Received: from mail-it0-f52.google.com (mail-it0-f52.google.com [209.85.214.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CDB53217A0
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 19:01:56 +0000 (UTC)
Received: by mail-it0-f52.google.com with SMTP id w63so222268ita.3
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 11:01:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180222133643.GJ30681@dhcp22.suse.cz>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
 <151670493255.658225.2881484505285363395.stgit@buzz> <20180221154214.GA4167@bombadil.infradead.org>
 <fff58819-d39d-3a8a-f314-690bcb2f95d7@intel.com> <20180221170129.GB27687@bombadil.infradead.org>
 <20180222065943.GA30681@dhcp22.suse.cz> <20180222122254.GA22703@bombadil.infradead.org>
 <20180222133643.GJ30681@dhcp22.suse.cz>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 22 Feb 2018 19:01:35 +0000
Message-ID: <CALCETrU2c=SzWJCwuqqFuBVkC=nN27_ce4GxweCQXEwPAqnz7A@mail.gmail.com>
Subject: Re: Use higher-order pages in vmalloc
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu, Feb 22, 2018 at 1:36 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 22-02-18 04:22:54, Matthew Wilcox wrote:
>> On Thu, Feb 22, 2018 at 07:59:43AM +0100, Michal Hocko wrote:
>> > On Wed 21-02-18 09:01:29, Matthew Wilcox wrote:
>> > > Right.  It helps with fragmentation if we can keep higher-order
>> > > allocations together.
>> >
>> > Hmm, wouldn't it help if we made vmalloc pages migrateable instead? That
>> > would help the compaction and get us to a lower fragmentation longterm
>> > without playing tricks in the allocation path.
>>
>> I was wondering about that possibility.  If we want to migrate a page
>> then we have to shoot down the PTE across all CPUs, copy the data to the
>> new page, and insert the new PTE.  Copying 4kB doesn't take long; if you
>> have 12GB/s (current example on Wikipedia: dual-channel memory and one
>> DDR2-800 module per channel gives a theoretical bandwidth of 12.8GB/s)
>> then we should be able to copy a page in 666ns).  So there's no problem
>> holding a spinlock for it.
>>
>> But we can't handle a fault in vmalloc space today.  It's handled in
>> arch-specific code, see vmalloc_fault() in arch/x86/mm/fault.c
>> If we're going to do this, it'll have to be something arches opt into
>> because I'm not taking on the job of fixing every architecture!
>
> yes.

On x86, if you shoot down the PTE for the current stack, you're dead.
vmalloc_fault() might not even be called.  Instead we hit
do_double_fault(), and the manual warns extremely strongly against
trying to recover, and, in this case, I agree with the SDM.  If you
actually want this to work, there needs to be a special IPI broadcast
to the task in question (with appropriate synchronization) that calls
magic arch code that does the switcheroo.

Didn't someone (Christoph?) have a patch to teach the page allocator
to give high-order allocations if available and otherwise fall back to
low order?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
