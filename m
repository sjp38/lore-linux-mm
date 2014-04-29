Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id B031F6B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 18:48:21 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so768818eek.20
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 15:48:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r9si28488161eew.348.2014.04.29.15.48.18
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 15:48:19 -0700 (PDT)
Message-ID: <53602C2B.50604@redhat.com>
Date: Tue, 29 Apr 2014 18:48:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,writeback: fix divide by zero in pos_ratio_polynom
References: <20140429151910.53f740ef@annuminas.surriel.com> <20140429153936.49a2710c0c2bba4d233032f2@linux-foundation.org>
In-Reply-To: <20140429153936.49a2710c0c2bba4d233032f2@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, mhocko@suse.cz, fengguang.wu@intel.com, mpatlasov@parallels.com

On 04/29/2014 06:39 PM, Andrew Morton wrote:
> On Tue, 29 Apr 2014 15:19:10 -0400 Rik van Riel <riel@redhat.com> wrote:
> 
>> It is possible for "limit - setpoint + 1" to equal zero, leading to a
>> divide by zero error. Blindly adding 1 to "limit - setpoint" is not
>> working, so we need to actually test the divisor before calling div64.
>>
>> ...
>>
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -597,11 +597,16 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
>>  					  unsigned long dirty,
>>  					  unsigned long limit)
>>  {
>> +	unsigned int divisor;
> 
> I'm thinking this would be better as a ulong so I don't have to worry
> my pretty head over truncation things?

I looked at div_*64, and the second argument is a 32 bit
variable. I guess a long would be ok, since if we are
dividing by more than 4 billion we don't really care :)

static inline s64 div_s64(s64 dividend, s32 divisor)

> --- a/mm/page-writeback.c~mm-page-writebackc-fix-divide-by-zero-in-pos_ratio_polynom-fix
> +++ a/mm/page-writeback.c
> @@ -597,13 +597,13 @@ static inline long long pos_ratio_polyno
>  					  unsigned long dirty,
>  					  unsigned long limit)
>  {
> -	unsigned int divisor;
> +	unsigned long divisor;
>  	long long pos_ratio;
>  	long x;
>  
>  	divisor = limit - setpoint;
>  	if (!divisor)
> -		divisor = 1;
> +		divisor = 1;	/* Avoid div-by-zero */

Works for me :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
