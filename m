Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id C1B006B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 12:24:51 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id v8so8270095otd.4
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 09:24:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m139si3789718oig.93.2017.12.03.09.24.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Dec 2017 09:24:50 -0800 (PST)
Date: Sun, 3 Dec 2017 18:24:47 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] TESTING! KVM: x86: add invalidate_range mmu notifier
Message-ID: <20171203172447.GQ8063@redhat.com>
References: <20171130161933.GB1606@flask>
 <20171130180546.4331-1-rkrcmar@redhat.com>
 <20171130180546.4331-2-rkrcmar@redhat.com>
 <4e0b6e81-b987-487e-b582-4d61aec9252d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4e0b6e81-b987-487e-b582-4d61aec9252d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Fabian =?iso-8859-1?Q?Gr=FCnbichler?= <f.gruenbichler@proxmox.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Fri, Dec 01, 2017 at 04:15:37PM +0100, Paolo Bonzini wrote:
> On 30/11/2017 19:05, Radim KrA?mA!A? wrote:
> > Does roughly what kvm_mmu_notifier_invalidate_page did before.
> > 
> > I am not certain why this would be needed.  It might mean that we have
> > another bug with start/end or just that I missed something.
> 
> I don't think this is needed, because we don't have shared page tables.
> My understanding is that without shared page tables, you can assume that
> all page modifications go through invalidate_range_start/end.  With
> shared page tables, there are additional TLB flushes to take care of,
> which require invalidate_range.

Agreed, invalidate_range only is ever needed if you the secondary MMU
(i.e. KVM) shares the same pagetables of the primary MMU in the
host. Only in such case we need a special secondary MMU invalidate in
the tlb gather before the page is freed because there's no way to
block the secondary MMU from walking the host pagetables in
invalidate_range_start.

In KVM case the secondary MMU always go through the shadow pagetables,
so all shadow pagetable invalidates can happen in
invalidate_range_start and patch 2/2 is not needed here.

Note that the host kernel could have always decided to call
invalidate_range_start/end and never to call invalidate_page even
before invalidate_page was removed.

So the problem in practice could only be noticed after the removal of
invalidate_page of course, but in more theoretical terms 1/2 is
actually fixing a longstanding bug. The removal of invalidate_page
made the lack of kvm_arch_mmu_notifier_invalidate_page call in
invalidate_range_start more apparent.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
