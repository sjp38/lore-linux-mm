Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44E816B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 15:28:31 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id a6so11372207lfa.1
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 12:28:31 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id f2si1552471ljb.73.2017.02.28.12.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 12:28:29 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id z127so1823768lfa.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 12:28:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170228193539.GT29622@ZenIV.linux.org.uk>
References: <20170227215008.21457-1-lstoakes@gmail.com> <20170228090110.m4pxtjlbgaft7oet@phenom.ffwll.local>
 <20170228193539.GT29622@ZenIV.linux.org.uk>
From: Lorenzo Stoakes <lstoakes@gmail.com>
Date: Tue, 28 Feb 2017 20:28:08 +0000
Message-ID: <CAA5enKa4Asp4qSHkeV3saLZrhOMf2DJ9vuiwTDo1t5t54z4sTQ@mail.gmail.com>
Subject: Re: [PATCH RESEND] drm/via: use get_user_pages_unlocked()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org, linux-mm <linux-mm@kvack.org>

On 28 February 2017 at 19:35, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Tue, Feb 28, 2017 at 10:01:10AM +0100, Daniel Vetter wrote:
>
>> > +   ret = get_user_pages_unlocked((unsigned long)xfer->mem_addr,
>> > +                   vsg->num_pages, vsg->pages,
>> > +                   (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0);
>
> Umm...  Why not
>         ret = get_user_pages_fast((unsigned long)xfer->mem_addr,
>                         vsg->num_pages,
>                         vsg->direction == DMA_FROM_DEVICE,
>                         vsg->pages);
>
> IOW, do you really need a warranty that ->mmap_sem will be grabbed and
> released?

Daniel will be better placed to answer in this specific case, but more
generally is there any reason why we can't just use
get_user_pages_fast() in all such cases? These patches were simply a
mechanical/cautious replacement for code that is more or less exactly
equivalent but if this would make sense perhaps it'd be worth using
gup_fast() where possible?

-- 
Lorenzo Stoakes
https://ljs.io

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
