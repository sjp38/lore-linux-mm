Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03F8F6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 04:45:23 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m5so31858364qtb.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:45:23 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id n66si3334083qka.157.2016.10.12.01.45.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 01:45:22 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
 <20161011172228.GA30403@dhcp22.suse.cz>
 <7649b844-cfe6-abce-148e-1e2236e7d443@zoho.com>
 <20161012065332.GA9504@dhcp22.suse.cz> <57FDE531.7060003@zoho.com>
 <20161012082538.GC17128@dhcp22.suse.cz>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57FDF7EF.6070606@zoho.com>
Date: Wed, 12 Oct 2016 16:44:31 +0800
MIME-Version: 1.0
In-Reply-To: <20161012082538.GC17128@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, akpm@linux-foundation.org, cl@linux.com

On 10/12/2016 04:25 PM, Michal Hocko wrote:
> On Wed 12-10-16 15:24:33, zijun_hu wrote:
>> On 10/12/2016 02:53 PM, Michal Hocko wrote:
>>> On Wed 12-10-16 08:28:17, zijun_hu wrote:
>>>> On 2016/10/12 1:22, Michal Hocko wrote:
>>>>> On Tue 11-10-16 21:24:50, zijun_hu wrote:
>>>>>> From: zijun_hu <zijun_hu@htc.com>
>>>>>>
>> should we have a generic discussion whether such patches which considers
>> many boundary or rare conditions are necessary.
> 
> In general, I believe that kernel internal interfaces which have no
> userspace exposure shouldn't be cluttered with sanity checks.
> 

you are right and i agree with you. but there are many internal interfaces
perform sanity checks in current linux sources

>> i found the following code segments in mm/vmalloc.c
>> static struct vmap_area *alloc_vmap_area(unsigned long size,
>>                                 unsigned long align,
>>                                 unsigned long vstart, unsigned long vend,
>>                                 int node, gfp_t gfp_mask)
>> {
>> ...
>>
>>         BUG_ON(!size);
>>         BUG_ON(offset_in_page(size));
>>         BUG_ON(!is_power_of_2(align));
> 
> See a recent Linus rant about BUG_ONs. These BUG_ONs are quite old and
> from a quick look they are even unnecessary. So rather than adding more
> of those, I think removing those that are not needed is much more
> preferred.
>
i notice that, and the above code segments is used to illustrate that
input parameter checking is necessary sometimes

>> should we make below declarations as conventions
>> 1) when we say 'alignment', it means align to a power of 2 value
>>    for example, aligning value @v to @b implicit @v is power of 2
>>    , align 10 to 4 is 12
> 
> alignment other than power-of-two makes only very limited sense to me.
> 
you are right and i agree with you.
>> 2) when we say 'round value @v up/down to boundary @b', it means the 
>>    result is a times of @b,  it don't requires @b is a power of 2
> 

i will write to linus to ask for opinions whether we should declare 
the meaning of 'align' and 'round up/down' formally and whether such
patches are necessary

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
