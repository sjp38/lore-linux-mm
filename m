Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 024B36B0005
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 00:35:56 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r28so6206410pgu.1
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 21:35:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i78si5808873pfi.150.2018.01.25.21.35.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Jan 2018 21:35:54 -0800 (PST)
Date: Thu, 25 Jan 2018 21:35:42 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
Message-ID: <20180126053542.GA30189@bombadil.infradead.org>
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com>
 <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, jglisse@redhat.com, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Jan 24, 2018 at 08:10:53PM +0100, Jann Horn wrote:
> I'm not entirely convinced by the approach of marking small parts of
> kernel memory as readonly for hardening.

It depends how significant the data stored in there are.  For example,
storing function pointers in read-only memory provides significant
hardening.

> You're allocating with vmalloc(), which, as far as I know, establishes
> a second mapping in the vmalloc area for pages that are already mapped
> as RW through the physmap. AFAICS, later, when you're trying to make
> pages readonly, you're only changing the protections on the second
> mapping in the vmalloc area, therefore leaving the memory writable
> through the physmap. Is that correct? If so, please either document
> the reasoning why this is okay or change it.

Yes, this is still vulnerable to attacks through the physmap.  That's also
true for marking structs as const.  We should probably fix that at some
point, but at least they're not vulnerable to heap overruns by small
amounts ... you have to be able to overrun some other array by terabytes.

It's worth having a discussion about whether we want the pmalloc API
or whether we want a slab-based API.  We can have a separate discussion
about an API to remove pages from the physmap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
