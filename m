Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF0F6B0032
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 07:59:33 -0500 (EST)
Received: by mail-oi0-f43.google.com with SMTP id z81so38572269oif.2
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 04:59:33 -0800 (PST)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id mn5si653061obb.33.2015.01.31.04.59.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 31 Jan 2015 04:59:32 -0800 (PST)
Received: by mail-oi0-f49.google.com with SMTP id a3so38411380oib.8
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 04:59:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150131110743.GA2299@swordfish>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
	<1422432945-6764-2-git-send-email-minchan@kernel.org>
	<CADAEsF9tejvCL3gqGuYKsnv_wsfpsESsAg=Hm3r_ZfbpftE4-w@mail.gmail.com>
	<20150129151227.GA936@swordfish>
	<CADAEsF-1Y7_JM_1cq6+O3XASz8FAZoazjOF=x+oXFXuXUxK5Ng@mail.gmail.com>
	<20150130080808.GA782@swordfish>
	<CADAEsF-BztDePzMFAQ7zncXBTtS+iey79xf3sGzYeAjak0k-QQ@mail.gmail.com>
	<20150131110743.GA2299@swordfish>
Date: Sat, 31 Jan 2015 20:59:31 +0800
Message-ID: <CADAEsF_7vJrYf09s4DZ7AOvXrAwJeoCCZ0EKxwHeHHURBVQ6Bw@mail.gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>

Hello, Sergey

2015-01-31 19:07 GMT+08:00 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>:
> On (01/31/15 16:50), Ganesh Mahendran wrote:
>> >> > after umount we still have init device. so, *theoretically*, we
>> >> > can see something like
>> >> >
>> >> >         CPU0                            CPU1
>> >> > umount
>> >> > reset_store
>> >> > bdev->bd_holders == 0                   mount
>> >> > ...                                     zram_make_request()
>> >> > zram_reset_device()
> [..]
>
>
>>
>> Maybe I did not explain clearly. I send a patch about this issue:
>>
>> https://patchwork.kernel.org/patch/5754041/
>
>
> excuse me? explain to me clearly what? my finding and my analysis?

Sorry, I missed this mail
https://lkml.org/lkml/2015/1/27/1029

That's why I ask questions in this
https://lkml.org/lkml/2015/1/29/580
after Minchan's description.

>
>
> this is the second time in a week that you hijack someone's work
> and you don't even bother to give any credit to people.
>
>
> Minchan moved zram_meta_free(meta) out of init_lock here
> https://lkml.org/lkml/2015/1/21/29
>
> I proposed to also move zs_free() of meta->handles here
> https://lkml.org/lkml/2015/1/21/384

I thought you wanted move the code block after
       up_write(&zram->init_lock);

And I found the code block can be even encapsulated in
zram_meta_free().

That's why I sent:
https://lkml.org/lkml/2015/1/24/50

>
>
> ... so what happened then -- you jumped in and sent a patch.
> https://lkml.org/lkml/2015/1/24/50
>
>
> Minchan sent you a hint https://lkml.org/lkml/2015/1/26/471
>
>>   but it seems the patch is based on my recent work "zram: free meta out of init_lock".
>
>
>
>  "the patch is based on my work"!
>
>
>
> now, for the last few days we were discussing init_lock and I first
> expressed my concerns and spoke about 'free' vs. 'use' problem
> here (but still didn't have enough spare to submit, besides we are in
> the middle of reset/init/write rework)
>
> https://lkml.org/lkml/2015/1/27/1029
>
>>
>>bdev->bd_holders protects from resetting device which has read/write
>>operation ongoing on the onther CPU.
>>
>>I need to refresh on how ->bd_holders actually incremented/decremented.
>>can the following race condition take a place?
>>
>>        CPU0                                    CPU1
>>reset_store()
>>bdev->bd_holders == false
>>                                        zram_make_request
>>                                                -rm- down_read(&zram->init_lock);
>>                                        init_done(zram) == true
>>zram_reset_device()                     valid_io_request()
>>                                        __zram_make_request
>>down_write(&zram->init_lock);           zram_bvec_rw
>>[..]
>>set_capacity(zram->disk, 0);
>>zram->init_done = false;
>>kick_all_cpus_sync();                   zram_bvec_write or zram_bvec_read()
>>zram_meta_free(zram->meta);
>>zcomp_destroy(zram->comp);              zcomp_compress() or zcomp_decompress()

Sorry, I did not check this mail.

>>
>
>
> and later here https://lkml.org/lkml/2015/1/29/645
>
>>
>>after umount we still have init device. so, *theoretically*, we
>>can see something like
>>
>>
>>        CPU0                            CPU1
>>umount
>>reset_store
>>bdev->bd_holders == 0                   mount
>>...                                     zram_make_request()
>>zram_reset_device()
>>
>
>
>
> so what happened next? your patch happened next.
> with quite familiar problem description
>
>>
>>      CPU0                    CPU1
>> t1:  bdput
>> t2:                          mount /dev/zram0 /mnt
>> t3:  zram_reset_device
>>
>
> and now you say that I don't understant something in "your analysis"?
>
>
>
> stop doing this. this is not how it works.
>
>
>         -ss
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
