Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A24496B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 12:55:55 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so34267420wic.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:55:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q13si12845600wiv.18.2015.10.08.09.55.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Oct 2015 09:55:54 -0700 (PDT)
Date: Thu, 8 Oct 2015 09:55:39 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH -next] mm/vmacache: inline vmacache_valid_mm()
Message-ID: <20151008165539.GA2594@linux-uzut.site>
References: <1444277879-22039-1-git-send-email-dave@stgolabs.net>
 <20151008062115.GA876@swordfish>
 <20151008132331.GC3353@linux-uzut.site>
 <20151008134358.GA601@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20151008134358.GA601@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

On Thu, 08 Oct 2015, Sergey Senozhatsky wrote:

>> >+/*
>> >+ * This task may be accessing a foreign mm via (for example)
>> >+ * get_user_pages()->find_vma().  The vmacache is task-local and this
>> >+ * task's vmacache pertains to a different mm (ie, its own).  There is
>> >+ * nothing we can do here.
>> >+ *
>> >+ * Also handle the case where a kernel thread has adopted this mm via use_mm().
>> >+ * That kernel thread's vmacache is not applicable to this mm.
>> >+ */
>> >+static bool vmacache_valid_mm(struct mm_struct *mm)
>>
>> This needs (explicit) inlined, no?
>>
>
>oh, yeah. Funny how I said "both `static inline'" and made 'inline' only
>one of them.

Thinking a bit more about it, we don't want to be making vmacache_valid_mm()
visible, as users should only stick to vmacache_valid() calls. I doubt that
this would infact ever occur, but it's a bad idea regardless.

So I'd rather keep my patch as is. Yes, the compiler can already inline it for
us, but making it explicit is certainly won't harm.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
