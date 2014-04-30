Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id E74D96B003A
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 10:34:03 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so1445485eek.23
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 07:34:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w48si31081603eel.176.2014.04.30.07.34.01
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 07:34:02 -0700 (PDT)
Message-ID: <53610941.8030309@redhat.com>
Date: Wed, 30 Apr 2014 10:31:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm,writeback: fix divide by zero in pos_ratio_polynom
References: <20140429151910.53f740ef@annuminas.surriel.com> <5360C9E7.6010701@jp.fujitsu.com> <20140430093035.7e7226f2@annuminas.surriel.com> <20140430134826.GH4357@dhcp22.suse.cz>
In-Reply-To: <20140430134826.GH4357@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, akpm@linux-foundation.org, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On 04/30/2014 09:48 AM, Michal Hocko wrote:
> On Wed 30-04-14 09:30:35, Rik van Riel wrote:
> [...]
>> Subject: mm,writeback: fix divide by zero in pos_ratio_polynom
>>
>> It is possible for "limit - setpoint + 1" to equal zero, leading to a
>> divide by zero error. Blindly adding 1 to "limit - setpoint" is not
>> working, so we need to actually test the divisor before calling div64.
>>
>> Signed-off-by: Rik van Riel <riel@redhat.com>
>> ---
>>   mm/page-writeback.c | 13 +++++++++++--
>>   1 file changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index ef41349..f98a297 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -597,11 +597,16 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
>>   					  unsigned long dirty,
>>   					  unsigned long limit)
>>   {
>> +	unsigned long divisor;
>>   	long long pos_ratio;
>>   	long x;
>>
>> +	divisor = limit - setpoint;
>> +	if (!divisor)
>> +		divisor = 1;	/* Avoid div-by-zero */
>> +
>
> This is still prone to u64 -> s32 issue, isn't it?
> What was the original problem anyway? Was it really setpoint > limit or
> rather the overflow?

Thinking about it some more, is it possible that
limit and/or setpoint are larger than 32 bits, but
the difference between them is not?

In that case, truncating both to 32 bits before
doing the subtraction would be troublesome, and
it would be better to do a cast in the comparison:

if (!(s32)divisor)
	divisor = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
