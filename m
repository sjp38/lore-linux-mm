Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00A156B0253
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 20:29:00 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id n189so24559326qke.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 17:28:59 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id n7si2663564qkd.60.2016.10.11.17.28.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 17:28:59 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
 <20161011172228.GA30403@dhcp22.suse.cz>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <7649b844-cfe6-abce-148e-1e2236e7d443@zoho.com>
Date: Wed, 12 Oct 2016 08:28:17 +0800
MIME-Version: 1.0
In-Reply-To: <20161011172228.GA30403@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, cl@linux.com

On 2016/10/12 1:22, Michal Hocko wrote:
> On Tue 11-10-16 21:24:50, zijun_hu wrote:
>> From: zijun_hu <zijun_hu@htc.com>
>>
>> the LSB of a chunk->map element is used for free/in-use flag of a area
>> and the other bits for offset, the sufficient and necessary condition of
>> this usage is that both size and alignment of a area must be even numbers
>> however, pcpu_alloc() doesn't force its @align parameter a even number
>> explicitly, so a odd @align maybe causes a series of errors, see below
>> example for concrete descriptions.
> 
> Is or was there any user who would use a different than even (or power of 2)
> alighment? If not is this really worth handling?
> 

it seems only a power of 2 alignment except 1 can make sure it work very well,
that is a strict limit, maybe this more strict limit should be checked

i don't know since there are too many sources and too many users and too many
use cases. even if nobody, i can't be sure that it doesn't happens in the future

it is worth since below reasons
1) if it is used in right ways, this patch have no impact; otherwise, it can alert
   user by warning message and correct the behavior.
   is it better that a warning message and correcting than resulting in many terrible
   error silently under a special case by change?
   it can make program more stronger.

2) does any alignment but 1 means a power of 2 alignment conventionally and implicitly? 
   if not, is it better that adjusting both @align and @size uniformly based on the sufficient
   necessary condition than mixing supposing one part is right and correcting the other?
   i find that there is BUG_ON(!is_power_of_2(align)) statement in mm/vmalloc.c

3) this simple fix can make the function applicable in wider range, it hints the reader
   that the lowest requirement for alignment is a even number

4) for char a[10][10]; char (*p)[10]; if a user want to allocate a @size = 10 and
   @align = 10 memory block, should we reject the user's request?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
