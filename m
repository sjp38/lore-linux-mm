Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2673C6B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 03:53:29 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id f4so1760945plr.14
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 00:53:29 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30135.outbound.protection.outlook.com. [40.107.3.135])
        by mx.google.com with ESMTPS id d12si1119204pgv.538.2018.02.09.00.53.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 09 Feb 2018 00:53:27 -0800 (PST)
Subject: Re: [PATCH RFC] x86: KASAN: Sanitize unauthorized irq stack access
References: <151802005995.4570.824586713429099710.stgit@localhost.localdomain>
 <6638b09b-30b0-861e-9c00-c294889a3791@linux.intel.com>
 <d1b8c22c-79bf-55a1-37a1-2ce508881f3d@virtuozzo.com>
 <20180208163041.zy7dbz4tlbit4i2h@treble>
 <CACT4Y+bZ2JtwTK+a2=wuTm3891Zu1qksreyO63i6whKqFv66Cw@mail.gmail.com>
 <20180208172026.6kqimndwyekyzzvl@treble>
 <20180208190016.GC9524@bombadil.infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <e74919c7-6b32-f55c-ff88-c3abd851476f@virtuozzo.com>
Date: Fri, 9 Feb 2018 11:53:19 +0300
MIME-Version: 1.0
In-Reply-To: <20180208190016.GC9524@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Juergen Gross <jgross@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kees Cook <keescook@chromium.org>, Mathias Krause <minipli@googlemail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On 08.02.2018 22:00, Matthew Wilcox wrote:
> On Thu, Feb 08, 2018 at 11:20:26AM -0600, Josh Poimboeuf wrote:
>> The patch description is confusing.  It talks about "crappy drivers irq
>> handlers when they access wrong memory on the stack".  But if I
>> understand correctly, the patch doesn't actually protect against that
>> case, because irq handlers run on the irq stack, and this patch only
>> affects code which *isn't* running on the irq stack.
> 
> This would catch a crappy driver which allocates some memory on the
> irq stack, squirrels the pointer to it away in a data structure, then
> returns to process (or softirq) context and dereferences the pointer.

Yes, this is exactly what I mean. The patch allows stack modifications
for interrupt time, and catches wrong accesses from another contexts/cpus
(when there is no interrupt executing in parallel).

It's possible to catch wrong accesses in interrupt time also, but we need
to unmap irq stacks on another cpus to do that, which is not KASAN thing.

But, I hope we may be lucky and catch such situations even if we only check
for accesses, which are going not in interrupt time.

> I have no idea if that's the case that Kirill is tracking down, but it's
> something I can imagine someone doing.

Kirill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
