Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED9146B0005
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 14:36:16 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 67so2964805pfg.0
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 11:36:16 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m11si405288pgc.671.2018.02.22.11.36.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 11:36:15 -0800 (PST)
Subject: Re: Use higher-order pages in vmalloc
References: <151670492223.658225.4605377710524021456.stgit@buzz>
 <151670493255.658225.2881484505285363395.stgit@buzz>
 <20180221154214.GA4167@bombadil.infradead.org>
 <fff58819-d39d-3a8a-f314-690bcb2f95d7@intel.com>
 <20180221170129.GB27687@bombadil.infradead.org>
 <20180222065943.GA30681@dhcp22.suse.cz>
 <20180222122254.GA22703@bombadil.infradead.org>
 <20180222133643.GJ30681@dhcp22.suse.cz>
 <CALCETrU2c=SzWJCwuqqFuBVkC=nN27_ce4GxweCQXEwPAqnz7A@mail.gmail.com>
 <ab926942-92a2-de72-68a0-c250e72739f9@intel.com>
 <CALCETrUeSgVmjgNsUg+0sAacq_VeHsEPqOkRfHkij4xmADM_5A@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cf07fba1-a787-9af3-682f-309ac52c9345@intel.com>
Date: Thu, 22 Feb 2018 11:36:13 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrUeSgVmjgNsUg+0sAacq_VeHsEPqOkRfHkij4xmADM_5A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On 02/22/2018 11:27 AM, Andy Lutomirski wrote:
> On Thu, Feb 22, 2018 at 7:19 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>> On 02/22/2018 11:01 AM, Andy Lutomirski wrote:
>>> On x86, if you shoot down the PTE for the current stack, you're dead.
>>
>> *If* we were to go do this insanity for vmalloc()'d memory, we could
>> probably limit it to kswapd, and also make sure that kernel threads
>> don't get vmalloc()'d stacks or that we mark them in a way to say we
>> never muck with them.
> 
> How does that help?  We need to make sure that the task whose stack
> we're migrating is (a) not running and (b) is not being switched in or
> out.  And we have to make sure that there isn't some *other* mm that
> has the task's stack in ASID's TLB space.
> 
> Maybe we take some lock so the task can't run, then flush the world,
> then release the lock.

Oh, I was thinking only of the case where you try to muck with your
*own* stack.  But, I see what you are saying about doing it to another
task on another CPU that is actively using the stack.

I think what you're saying is that we do not want to handle faults that
are caused by %esp being unusable.  Whatever we do, we've got to make
sure that no CPU has a stack in %esp that we are messing with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
