Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C5DB282997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 09:26:27 -0400 (EDT)
Received: by paza2 with SMTP id a2so10515175paz.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 06:26:27 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ct3si3450606pbc.99.2015.05.22.06.26.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 06:26:27 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOR007B76NYMA50@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 22 May 2015 14:26:22 +0100 (BST)
Message-id: <555F2E7C.4090707@samsung.com>
Date: Fri, 22 May 2015 15:26:20 +0200
From: Marcin Jabrzyk <m.jabrzyk@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] zram: check compressor name before setting it
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish> <555EF30C.60108@samsung.com>
 <20150522124411.GA3793@swordfish>
In-reply-to: <20150522124411.GA3793@swordfish>
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com



On 22/05/15 14:44, Sergey Senozhatsky wrote:
> On (05/22/15 11:12), Marcin Jabrzyk wrote:
>>>
>>> no.
>>>
>>> zram already complains about failed comp backend creation.
>>> it's in dmesg (or syslog, etc.):
>>>
>>> 	"zram: Cannot initialise %s compressing backend"
>>>
>> OK, now I see that. Sorry for the noise.
>>
>>> second, there is not much value in exposing zcomp internals,
>>> especially when the result is just another line in dmesg output.
>>
>>  From the other hand, the only valid values that can be written are
>> in 'comp_algorithm'.
>> So when writing other one, returning -EINVAL seems to be reasonable.
>> The user would get immediately information that he can't do that,
>> now the information can be very deferred in time.
>
> it's not.
> the error message appears in syslog right before we return -EINVAL
> back to user.

Yes I've read up the code more detailed and I saw that error message
just before returning to user with error value.

But this happens when 'disksize' is wirtten, not when 'comp_algorithm'.
I understood, the error message in dmesg is clear there is no such 
algorithm.

But this is not an immediate error, when setting the 'comp_algorithm',
where we already know that it's wrong, not existing etc.
Anything after that moment would be wrong and would not work at all.

 From what I saw 'comp_algorithm_store' is the only *_store in zram that
believes user that he writes proper value and just makes strlcpy.

So what I've ing mind is to provide direct feedback, you have
written wrong name of compressor, you got -EINVAL, please write
correct value. This would be very useful when scripting.

Sorry for being so confusing.

Best regards,
Marcin Jabrzyk

>
> 	-ss
>
>> I'm not for exposing more internals, but getting -EINVAL would be nice I
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
