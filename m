Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CAA07828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 02:21:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so103624584wme.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:21:22 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id l64si1954661wml.10.2016.07.05.23.21.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 23:21:21 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id r201so33240526wme.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:21:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160706024830.GG13566@bbox>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-7-git-send-email-opensource.ganesh@gmail.com>
 <20160704084347.GG898@swordfish> <CADAEsF91-j-DDXt63-dtG77Q5uowb8hdvT2Zk54B74XwDxFCxQ@mail.gmail.com>
 <20160705010028.GA459@swordfish> <20160706024830.GG13566@bbox>
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Date: Wed, 6 Jul 2016 14:21:20 +0800
Message-ID: <CADAEsF9=ev8Mvdz6Pm=FCwH-Cd8dw8maPUG=NfmSgOsRMHYnHg@mail.gmail.com>
Subject: Re: [PATCH v2 7/8] mm/zsmalloc: add __init,__exit attribute
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, rostedt@goodmis.org, mingo@redhat.com

2016-07-06 10:48 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> On Tue, Jul 05, 2016 at 10:00:28AM +0900, Sergey Senozhatsky wrote:
>> Hello Ganesh,
>>
>> On (07/04/16 17:21), Ganesh Mahendran wrote:
>> > > On (07/04/16 14:49), Ganesh Mahendran wrote:
>> > > [..]
>> > >> -static void zs_unregister_cpu_notifier(void)
>> > >> +static void __exit zs_unregister_cpu_notifier(void)
>> > >>  {
>> > >
>> > > this __exit symbol is called from `__init zs_init()' and thus is
>> > > free to crash.
>> >
>> > I change code to force the code goto notifier_fail where the
>> > zs_unregister_cpu_notifier will be called.
>> > I tested with zsmalloc module buildin and built as a module.
>>
>> sorry, not sure I understand what do you mean by this.
>
> It seems he tested it both builtin and module with simulating to fail
> zs_register_cpu_notifier so that finally called zs_unergister_cpu_notifier.
> With that, he cannot find any problem.

Yes, This is what I mean.

>>
>
>>
>> > Please correct me, if I miss something.
>>
>> you have an __exit section function being called from
>> __init section:
>>
>> static void __exit zs_unregister_cpu_notifier(void)
>> {
>> }
>>
>> static int __init zs_init(void)
>> {
>>       zs_unregister_cpu_notifier();
>> }
>>
>> it's no good.
>
> Agree.
>
> I didn't look at linker script how to handle it. Although it works well,
> it would be not desirable to mark __exit to the function we already
> know it would be called from non-exit functions.

I will revert change in this patch.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
