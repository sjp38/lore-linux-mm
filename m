Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA04228089F
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 09:00:50 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d66so12334141wmi.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 06:00:50 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id b70si14726597wmd.99.2017.03.06.06.00.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 06:00:49 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id 196so18549493wmm.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 06:00:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170221124217.GB13174@node.shutemov.name>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
 <CALCETrVKKU_eJVH3scF=89z98dba8iHwuNfdUPE9Hx=-3b_+Pg@mail.gmail.com>
 <CAJwJo6ajrum1AkMS4Mu7nXBzAui_9+fjARBN8NpsFEdA+ZeN7A@mail.gmail.com> <20170221124217.GB13174@node.shutemov.name>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Mon, 6 Mar 2017 17:00:28 +0300
Message-ID: <CAJwJo6YUA0i8AsQ+sKJZcJSsUGwGFuNxOWB71_n4KJ2dDyKbCQ@mail.gmail.com>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andy Lutomirski <luto@amacapital.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

2017-02-21 15:42 GMT+03:00 Kirill A. Shutemov <kirill@shutemov.name>:
> On Tue, Feb 21, 2017 at 02:54:20PM +0300, Dmitry Safonov wrote:
>> 2017-02-17 19:50 GMT+03:00 Andy Lutomirski <luto@amacapital.net>:
>> > On Fri, Feb 17, 2017 at 6:13 AM, Kirill A. Shutemov
>> > <kirill.shutemov@linux.intel.com> wrote:
>> >> This patch introduces two new prctl(2) handles to manage maximum virtual
>> >> address available to userspace to map.
>> ...
>> > Anyway, can you and Dmitry try to reconcile your patches?
>>
>> So, how can I help that?
>> Is there the patch's version, on which I could rebase?
>> Here are BTW the last patches, which I will resend with trivial ifdef-fixup
>> after the merge window:
>> http://marc.info/?i=20170214183621.2537-1-dsafonov%20()%20virtuozzo%20!%20com
>
> Could you check if this patch collides with anything you do:
>
> http://lkml.kernel.org/r/20170220131515.GA9502@node.shutemov.name

Ok, sorry for the late reply - it was the merge window anyway and I've got
urgent work to do.

Let's see:

I'll need minor merge fixup here:
>-#define TASK_UNMAPPED_BASE (PAGE_ALIGN(TASK_SIZE / 3))
>+#define TASK_UNMAPPED_BASE (PAGE_ALIGN(DEFAULT_MAP_WINDOW / 3))
while in my patches:
>+#define __TASK_UNMAPPED_BASE(task_size)        (PAGE_ALIGN(task_size / 3))
>+#define TASK_UNMAPPED_BASE             __TASK_UNMAPPED_BASE(TASK_SIZE)

This should be just fine with my changes:
>- info.high_limit = end;
>+ info.high_limit = min(end, DEFAULT_MAP_WINDOW);

This will need another minor fixup:
>-#define MAX_GAP (TASK_SIZE/6*5)
>+#define MAX_GAP (DEFAULT_MAP_WINDOW/6*5)
I've moved it from macro to mmap_base() as local var,
which depends on task_size parameter.

That's all, as far as I can see at this moment.
Does not seems hard to fix. So I suggest sending patches sets
in parallel, the second accepted will rebase the set.
Is it convenient for you?
If you have/will have some questions about my patches, I'll be
open to answer.

-- 
             Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
