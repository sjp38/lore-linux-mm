Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id BD5466B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 01:16:12 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1164836qcs.14
        for <linux-mm@kvack.org>; Wed, 02 May 2012 22:16:11 -0700 (PDT)
Message-ID: <4FA2149A.9030803@vflare.org>
Date: Thu, 03 May 2012 01:16:10 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] zsmalloc: remove unnecessary alignment
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-3-git-send-email-minchan@kernel.org> <4F97F3D6.8000404@vflare.org> <4F98A818.1080106@kernel.org>
In-Reply-To: <4F98A818.1080106@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Minchan,

Sorry for late reply.

On 4/25/12 9:42 PM, Minchan Kim wrote:
> On 04/25/2012 09:53 PM, Nitin Gupta wrote:
>
>> On 04/25/2012 02:23 AM, Minchan Kim wrote:
>>
>>> It isn't necessary to align pool size with PAGE_SIZE.
>>> If I missed something, please let me know it.
>>>
>>> Signed-off-by: Minchan Kim<minchan@kernel.org>
>>> ---
>>>   drivers/staging/zsmalloc/zsmalloc-main.c |    5 ++---
>>>   1 file changed, 2 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
>>> index 504b6c2..b99ad9e 100644
>>> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
>>> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
>>> @@ -489,14 +489,13 @@ fail:
>>>
>>>   struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>>>   {
>>> -	int i, error, ovhd_size;
>>> +	int i, error;
>>>   	struct zs_pool *pool;
>>>
>>>   	if (!name)
>>>   		return NULL;
>>>
>>> -	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
>>> -	pool = kzalloc(ovhd_size, GFP_KERNEL);
>>> +	pool = kzalloc(sizeof(*pool), GFP_KERNEL);
>>>   	if (!pool)
>>>   		return NULL;
>>>
>>
>>
>> pool metadata is rounded-up to avoid potential false-sharing problem
>> (though we could just roundup to cache_line_size()).
>
>
> Do you really have any hurt by false-sharing problem?
> If so, we can change it with
>

I've never been hit by this false-sharing in any testing but this is 
really just a random chance. Apart from aligning to cache-line size, 
there is no way to ensure some unfortunate read-mostly object never 
falls in the same line.

> kzalloc(ALIGN(sizeof(*pool), cache_line_size()), GFP_KERNEL);
>

Yes, looks better than aligning to PAGE_SIZE.


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
