Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6C16B02C4
	for <linux-mm@kvack.org>; Tue, 16 May 2017 18:37:08 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l39so62245985qtb.9
        for <linux-mm@kvack.org>; Tue, 16 May 2017 15:37:08 -0700 (PDT)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com. [209.85.220.178])
        by mx.google.com with ESMTPS id e19si204450qka.19.2017.05.16.15.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 15:37:07 -0700 (PDT)
Received: by mail-qk0-f178.google.com with SMTP id u75so142375375qka.3
        for <linux-mm@kvack.org>; Tue, 16 May 2017 15:37:06 -0700 (PDT)
Subject: Re: Low memory killer problem
References: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A004D@CN-MBX05.HTC.COM.TW>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06@CN-MBX03.HTC.COM.TW>
 <20170515080535.GA22076@kroah.com>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F84@CN-MBX03.HTC.COM.TW>
 <20170515090027.GA18167@kroah.com>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A52C9@CN-MBX03.HTC.COM.TW>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <1f0815e5-5cb7-81a4-24c8-b0608ef2684a@redhat.com>
Date: Tue, 16 May 2017 15:37:03 -0700
MIME-Version: 1.0
In-Reply-To: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A52C9@CN-MBX03.HTC.COM.TW>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhiyuan_zhu@htc.com, gregkh@linuxfoundation.org
Cc: vinmenon@codeaurora.org, linux-mm@kvack.org, skhiani@codeaurora.org, torvalds@linux-foundation.org, Jet_Li@htc.com

On 05/15/2017 08:41 PM, zhiyuan_zhu@htc.com wrote:
> Thanks for your remind,
> I found lowmemorykiller.c have been removed, and ION module still exist since v4.12-rc1.
> I will pay attention to ION module.
> 
> But I still have 3 questions,
> Is there any substitute for low-memory-killer after kernel v4.12-rc1 ?
> Can I accounted the ION free to free memory?
> Is there any different from ION free and the normal system memory free?
> 
> ION free means:   IonTotal - IonInUse  - ION reserved memory.
> Thanks a lot.
> 

Issues like this are exactly why the LMK was deleted. The problem
is the LMK is hooked up as a shrinker so it runs in parallel to
any other shrinker. The short answer is yes if you want the LMK
to do anything reasonable you probably need to tweak it to account
for other memory that may be held in the system (Ion, zswap etc.).
There never seemed to be one universal heuristic that worked for
everyone which was part of the reason why most changes exist downstream.
Using some combination of the Ion variables above would work if
you experiment. If this sounds like a non-answer, that's because it is.

Thanks,
Laura

> -----Original Message-----
> From: Greg KH [mailto:gregkh@linuxfoundation.org] 
> Sent: Monday, May 15, 2017 5:00 PM
> To: Zhiyuan Zhu(ae?+-a??e? )
> Cc: vinmenon@codeaurora.org; linux-mm@kvack.org; skhiani@codeaurora.org; torvalds@linux-foundation.org; Jet Li(ae??c? 1/4 a??)
> Subject: Re: Low memory killer problem
> 
> On Mon, May 15, 2017 at 08:22:38AM +0000, zhiyuan_zhu@htc.com wrote:
>> Dear Greg,
>>
>> Very sorry my mail history is lost.
>>
>> I found a part of ION memory will be return to system in android 
>> platform, But these memorys  cana??t accounted in low-memory-killer strategy.
>> a?|
>> And I also found ION memory comes from,  kmalloc/vmalloc/alloc pages/reserved memory.
>> I understand reserved memory shouldn't accounted to free memory.
>> But the memory which alloced by kmalloc/vmalloc/alloc pages, can be reclaimed.
>>
>> But the low-memory killer can't accounted this part, Many thanks.
>>
>> Code location, 
>>    ---> drivers/staging/android/lowmemorykiller.c   -> lowmem_scan
> 
> That file is gone from the latest kernel release, sorry.  So there's not much we can do about this code anymore.
> 
> See the mailing list archives for what should be used instead of this code, there is a plan for what to do.
> 
> Also note that the ION code has had a lot of reworks lately as well.
> 
> good luck!
> 
> greg k-h
> 
> Ni? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 ri? 1/2 i? 1/2 zC?ui? 1/2 i? 1/2 i? 1/2 AE {i? 1/2 i? 1/2 i? 1/2 i1>>i? 1/2 &TH?)i? 1/2 i? 1/2 ii? 1/2 i? 1/2 i? 1/2 ^ni? 1/2 ri? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 Ycj$i? 1/2 i? 1/2 $i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 ~i? 1/2 '.)i? 1/2 i? 1/2 i? 1/2 ,yi? 1/2 mi? 1/2 i? 1/2 i? 1/2 i? 1/2 %i? 1/2 {i? 1/2 i? 1/2 j+i? 1/2 i? 1/2 i? 1/2 x|j)Zi? 1/2 i? 1/2 i? 1/2 fi? 1/2 i? 1/2 i? 1/2 {di? 1/2 i? 1/2 $i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 /a==
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
