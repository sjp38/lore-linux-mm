Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E4BDA6B00A4
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 20:58:57 -0500 (EST)
Received: by gwb11 with SMTP id 11so1443021gwb.14
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 17:58:56 -0800 (PST)
Message-ID: <4B90655B.4000005@gmail.com>
Date: Thu, 04 Mar 2010 19:58:51 -0600
From: Robert Hancock <hancockrwd@gmail.com>
MIME-Version: 1.0
Subject: Re: Linux kernel - Libata bad block error handling to user mode
 program
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>	 <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>	 <4B8FC6AC.4060801@teksavvy.com>	 <f875e2fe1003040733h20d5523ex5d18b84f47fee8c7@mail.gmail.com>	 <4B8FF2C3.1060808@teksavvy.com> <f875e2fe1003041020t7cbab2c2x585df9b2dfc10dd2@mail.gmail.com>
In-Reply-To: <f875e2fe1003041020t7cbab2c2x585df9b2dfc10dd2@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: s ponnusa <foosaa@gmail.com>
Cc: Mark Lord <kernel@teksavvy.com>, Greg Freemyer <greg.freemyer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/04/2010 12:20 PM, s ponnusa wrote:
> SMART data consists only the count of remapped sectors, seek failures,
> raw read error rate, uncorrectable sector counts, crc errors etc., and
> technically one should be aware of the error during write operation as
> well.
>
> As per the ATAPI specifications, the media will report error for both
> read / write operations. It times out / sends out error code for both
> read and write operations. Correct me if I am wrong. What happens if
> all the available free sectors are remapped and there are no more
> sectors to map? In that atleast the drive should return an error
> right? When using the O_DIRECT more, the i/o error, media bad,
> softreset, hardreset error messages are starting to fill up dmesg
> almost immediately after the write call.
>
> It just tries in a continous loop and then finally returns success
> (even without remapping). I don't know how to change the behavior of
> libata / or other such driver which does it. All I want to do it to
> know the error in my program while it is reporting it in the syslog at
> kernel / driver level.

There's nothing in libata which will cause the operation to eventually 
return success if the drive keeps failing it (at least there definitely 
should not be and I very much doubt there is). My guess is that somehow 
what you think should be happening is not what the drive is actually 
doing (maybe one of the retries you're seeing is actually succeeding in 
writing to the disk, or at least the drive reports it was).

You haven't posted any of the actual kernel output you're seeing, so 
it's difficult to say exactly what's going on. However, attempting to 
scan for disk errors using writes seems like a flawed strategy. As 
several people have mentioned, drives can't necessarily detect errors on 
a write.

>
> Thank you.
>
> On Thu, Mar 4, 2010 at 12:49 PM, Mark Lord<kernel@teksavvy.com>  wrote:
>> On 03/04/10 10:33, foo saa wrote:
>> ..
>>>
>>> hdparm is good, but I don't want to use the internal ATA SECURE ERASE
>>> because I can never get the amount of bad sectors the drive had.
>>
>> ..
>>
>> Oh.. but isn't that information in the S.M.A.R.T. data ??
>>
>> You'll not find the bad sectors by writing -- a true WRITE nearly never
>> reports a media error.  Instead, the drive simply remaps to a good sector
>> on the fly and returns success.
>>
>> Generally, only READs report media errors.
>>
>> Cheers
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ide" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
