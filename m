Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 65A886B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 03:38:32 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h18so215244igc.8
        for <linux-mm@kvack.org>; Thu, 01 May 2014 00:38:32 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id kb6si1410042igb.9.2014.05.01.00.38.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 00:38:31 -0700 (PDT)
Received: by mail-ig0-f170.google.com with SMTP id r10so109807igi.5
        for <linux-mm@kvack.org>; Thu, 01 May 2014 00:38:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140430141924.8d84f7fdcac3ac3996802aa9@linux-foundation.org>
References: <20140429025310.GA5913@devel>
	<20140430141924.8d84f7fdcac3ac3996802aa9@linux-foundation.org>
Date: Thu, 1 May 2014 16:38:31 +0900
Message-ID: <CAHb8M2DSRmKDNq4faBg6OUza6auUfXAJLNmUMMqbQxJQG4e6Cw@mail.gmail.com>
Subject: Re: [PATCH] dmapool: remove redundant NULL check for dev in dma_pool_create()
From: DaeSeok Youn <daeseok.youn@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

2014-05-01 6:19 GMT+09:00, Andrew Morton <akpm@linux-foundation.org>:
> On Tue, 29 Apr 2014 11:53:10 +0900 Daeseok Youn <daeseok.youn@gmail.com>
> wrote:
>
>> "dev" cannot be NULL because it is already checked before
>> calling dma_pool_create().
>>
>> Signed-off-by: Daeseok Youn <daeseok.youn@gmail.com>
>> ---
>> If dev can be NULL, it has NULL deferencing when kmalloc_node()
>> is called after enabling CONFIG_NUMA.
>
> hm, this is unclear.
>
> The code which handles the dev==NULL case was obviously put there
> deliberately, presumably with the intention of permitting drivers to
> call dma_pool_create() without a device*.  This code is very old.
>
> A lot of drivers call dma_pool_create() (I doubt if you audited all of
> them!) and perhaps there are some which use this feature and have never
> been run on NUMA hardware.
Yes.. I didn't check all of callers.. sorry about that. Some drivers
are checked.
>
> I think I'll apply the patch anyway because such drivers (if they
> exist) probably need some attending to.
>
> I rewrote the changelog thusly:
>
>
> : "dev" cannot be NULL because it is already checked before calling
> : dma_pool_create().
> :
> : If dev ever was NULL, the code would oops in dev_to_node() after enabling
> : CONFIG_NUMA.
> :
> : It is possible that some driver is using dev==NULL and has never been run
> : on a NUMA machine.  Such a driver is probably outdated, possibly buggy
> and
> : will need some attention if it starts triggering NULL derefs.
>
>
Ok. Thanks for kind explanation.
Regards,
Daeseok Youn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
