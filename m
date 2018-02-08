Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B80036B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 14:00:42 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q13so2066083pgt.17
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 11:00:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w6si378975pfj.311.2018.02.08.11.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 11:00:41 -0800 (PST)
Date: Thu, 8 Feb 2018 11:00:18 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC] x86: KASAN: Sanitize unauthorized irq stack access
Message-ID: <20180208190016.GC9524@bombadil.infradead.org>
References: <151802005995.4570.824586713429099710.stgit@localhost.localdomain>
 <6638b09b-30b0-861e-9c00-c294889a3791@linux.intel.com>
 <d1b8c22c-79bf-55a1-37a1-2ce508881f3d@virtuozzo.com>
 <20180208163041.zy7dbz4tlbit4i2h@treble>
 <CACT4Y+bZ2JtwTK+a2=wuTm3891Zu1qksreyO63i6whKqFv66Cw@mail.gmail.com>
 <20180208172026.6kqimndwyekyzzvl@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180208172026.6kqimndwyekyzzvl@treble>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Juergen Gross <jgross@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kees Cook <keescook@chromium.org>, Mathias Krause <minipli@googlemail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Thu, Feb 08, 2018 at 11:20:26AM -0600, Josh Poimboeuf wrote:
> The patch description is confusing.  It talks about "crappy drivers irq
> handlers when they access wrong memory on the stack".  But if I
> understand correctly, the patch doesn't actually protect against that
> case, because irq handlers run on the irq stack, and this patch only
> affects code which *isn't* running on the irq stack.

This would catch a crappy driver which allocates some memory on the
irq stack, squirrels the pointer to it away in a data structure, then
returns to process (or softirq) context and dereferences the pointer.

I have no idea if that's the case that Kirill is tracking down, but it's
something I can imagine someone doing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
