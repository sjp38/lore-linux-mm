Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id A24B46B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 05:54:25 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so580924wes.29
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 02:54:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ej2si8454483wib.24.2014.06.18.02.54.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jun 2014 02:54:24 -0700 (PDT)
Message-ID: <53A161C1.2070304@redhat.com>
Date: Wed, 18 Jun 2014 11:54:09 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmscan.c: fix an implementation flaw in proportional
 scanning
References: <1402980902-6345-1-git-send-email-slaoub@gmail.com>	 <53A15544.2010505@redhat.com> <1403082532.9368.4.camel@debian>
In-Reply-To: <1403082532.9368.4.camel@debian>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/18/2014 11:08 AM, Chen Yucong wrote:
> On Wed, 2014-06-18 at 11:00 +0200, Jerome Marchand wrote:
>>>               if (!nr_file || !nr_anon)
>>>                       break;
>>>  
>>> -             if (nr_file > nr_anon) {
>>> -                     unsigned long scan_target =
>> targets[LRU_INACTIVE_ANON] +
>>>
>> -                                             targets[LRU_ACTIVE_ANON]
>> + 1;
>>> +             file_percent = nr_file * 100 / file_target;
>>> +             anon_percent = nr_anon * 100 / anon_target;
>>
>> Here it could happen.
>>
>>
> The snippet 
> 	...
>                if (!nr_file || !nr_anon)
>                       break;

Looks like nr[] values can only decrease and stay positive. Then the
following should be true at all times:

file_target >= nr_file >= 0
anon_target >= nr_anon >= 0

and the code above should indeed avoid the divide by zero.

Thanks,
Jerome

>         ...
>  can help us to filter the situation which you have described. It comes
> from Mel's patch that is called:
> 
> mm: vmscan: use proportional scanning during direct reclaim and full
> scan at DEF_PRIORITY
> 
> thx!
> cyc
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
