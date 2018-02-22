Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD516B0008
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 14:27:40 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id m6so2724583plt.14
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 11:27:40 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k6-v6si480194pla.333.2018.02.22.11.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 11:27:39 -0800 (PST)
Received: from mail-it0-f46.google.com (mail-it0-f46.google.com [209.85.214.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BD2BB217A5
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 19:27:38 +0000 (UTC)
Received: by mail-it0-f46.google.com with SMTP id o13so310259ito.2
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 11:27:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ab926942-92a2-de72-68a0-c250e72739f9@intel.com>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
 <151670493255.658225.2881484505285363395.stgit@buzz> <20180221154214.GA4167@bombadil.infradead.org>
 <fff58819-d39d-3a8a-f314-690bcb2f95d7@intel.com> <20180221170129.GB27687@bombadil.infradead.org>
 <20180222065943.GA30681@dhcp22.suse.cz> <20180222122254.GA22703@bombadil.infradead.org>
 <20180222133643.GJ30681@dhcp22.suse.cz> <CALCETrU2c=SzWJCwuqqFuBVkC=nN27_ce4GxweCQXEwPAqnz7A@mail.gmail.com>
 <ab926942-92a2-de72-68a0-c250e72739f9@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 22 Feb 2018 19:27:16 +0000
Message-ID: <CALCETrUeSgVmjgNsUg+0sAacq_VeHsEPqOkRfHkij4xmADM_5A@mail.gmail.com>
Subject: Re: Use higher-order pages in vmalloc
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu, Feb 22, 2018 at 7:19 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 02/22/2018 11:01 AM, Andy Lutomirski wrote:
>> On x86, if you shoot down the PTE for the current stack, you're dead.
>
> *If* we were to go do this insanity for vmalloc()'d memory, we could
> probably limit it to kswapd, and also make sure that kernel threads
> don't get vmalloc()'d stacks or that we mark them in a way to say we
> never muck with them.

How does that help?  We need to make sure that the task whose stack
we're migrating is (a) not running and (b) is not being switched in or
out.  And we have to make sure that there isn't some *other* mm that
has the task's stack in ASID's TLB space.

Maybe we take some lock so the task can't run, then flush the world,
then release the lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
