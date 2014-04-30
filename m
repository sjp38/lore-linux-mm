Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id BFBBC6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:35:20 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id x48so2181336wes.21
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:35:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s1si1031049wiy.91.2014.04.30.13.35.18
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 13:35:19 -0700 (PDT)
Message-ID: <53615DEE.90808@redhat.com>
Date: Wed, 30 Apr 2014 16:32:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4] mm,writeback: fix divide by zero in pos_ratio_polynom
References: <20140429151910.53f740ef@annuminas.surriel.com>	<5360C9E7.6010701@jp.fujitsu.com>	<20140430093035.7e7226f2@annuminas.surriel.com>	<20140430134826.GH4357@dhcp22.suse.cz>	<20140430104114.4bdc588e@cuia.bos.redhat.com>	<20140430120001.b4b95061ac7252a976b8a179@linux-foundation.org>	<53614F3C.8020009@redhat.com>	<20140430123526.bc6a229c1ea4addad1fb483d@linux-foundation.org>	<20140430160218.442863e0@cuia.bos.redhat.com> <20140430131353.fa9f49604ea39425bc93c24a@linux-foundation.org>
In-Reply-To: <20140430131353.fa9f49604ea39425bc93c24a@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On 04/30/2014 04:13 PM, Andrew Morton wrote:
> On Wed, 30 Apr 2014 16:02:18 -0400 Rik van Riel <riel@redhat.com> wrote:
>
>> I believe this should do the trick.
>>
>> ---8<---
>>
>> Subject: mm,writeback: fix divide by zero in pos_ratio_polynom
>>
>> It is possible for "limit - setpoint + 1" to equal zero, leading to a
>> divide by zero error. Blindly adding 1 to "limit - setpoint" is not
>> working, so we need to actually test the divisor before calling div64.
>
> Changelog is a bit stale.

Will update.

>> -static inline long long pos_ratio_polynom(unsigned long setpoint,
>> +static long long pos_ratio_polynom(unsigned long setpoint,
>>   					  unsigned long dirty,
>>   					  unsigned long limit)
>>   {
>> +	unsigned long divisor;
>>   	long long pos_ratio;
>>   	long x;
>>
>> -	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
>> -		    limit - setpoint + 1);
>> +	divisor = limit - setpoint;
>> +	if (!divisor)
>> +		divisor = 1;	/* Avoid div-by-zero */
>
> This was a consequence of 64->32 truncation and it can't happen any
> more, can it?

That is a good question.  Looking at the code some more,
I guess it may indeed be exclusively due to the truncation,
and we can go back to the older code, just with the fully
64 bit divide functions...

Good thing Masayoshi-san has a reproducer :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
