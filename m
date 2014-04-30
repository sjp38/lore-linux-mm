Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id ADDE06B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 15:32:39 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id x48so2108013wes.7
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 12:32:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ep15si1435629wid.87.2014.04.30.12.32.37
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 12:32:38 -0700 (PDT)
Message-ID: <53614F3C.8020009@redhat.com>
Date: Wed, 30 Apr 2014 15:30:04 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm,writeback: fix divide by zero in pos_ratio_polynom
References: <20140429151910.53f740ef@annuminas.surriel.com>	<5360C9E7.6010701@jp.fujitsu.com>	<20140430093035.7e7226f2@annuminas.surriel.com>	<20140430134826.GH4357@dhcp22.suse.cz>	<20140430104114.4bdc588e@cuia.bos.redhat.com> <20140430120001.b4b95061ac7252a976b8a179@linux-foundation.org>
In-Reply-To: <20140430120001.b4b95061ac7252a976b8a179@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On 04/30/2014 03:00 PM, Andrew Morton wrote:
> On Wed, 30 Apr 2014 10:41:14 -0400 Rik van Riel <riel@redhat.com> wrote:
>
>> It is possible for "limit - setpoint + 1" to equal zero, leading to a
>> divide by zero error. Blindly adding 1 to "limit - setpoint" is not
>> working, so we need to actually test the divisor before calling div64.
>>
>> ...
>>
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -598,10 +598,15 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
>>   					  unsigned long limit)
>>   {
>>   	long long pos_ratio;
>> +	long divisor;
>>   	long x;
>>
>> +	divisor = limit - setpoint;
>> +	if (!(s32)divisor)
>> +		divisor = 1;	/* Avoid div-by-zero */
>> +
>>   	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
>> -		    limit - setpoint + 1);
>> +		    (s32)divisor);
>
> Doesn't this just paper over the bug one time in four billion?  The
> other 3999999999 times, pos_ratio_polynom() returns an incorect result?
>
> If it is indeed the case that pos_ratio_polynom() callers are
> legitimately passing a setpoint which is more than 2^32 less than limit
> then it would be better to handle that input correctly.

The easy way would be by calling div64_s64 and div64_u64,
which are 64 bit all the way through.

Any objections?

The inlined bits seem to be stubs calling the _rem variants
of the functions, and discarding the remainder.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
