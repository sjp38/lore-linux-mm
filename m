Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2285E6B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:51:47 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b9so14407168wra.3
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 22:51:47 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id w5si2753877wma.208.2017.09.26.22.51.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 22:51:45 -0700 (PDT)
Message-ID: <59CB3C4D.9090609@huawei.com>
Date: Wed, 27 Sep 2017 13:51:09 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] a question about mlockall() and mprotect()
References: <59CA0847.8000508@huawei.com> <20170926081716.xo375arjoyu5ytcb@dhcp22.suse.cz> <59CA125C.8000801@huawei.com> <20170926090255.jmocezs6s3lpd6p4@dhcp22.suse.cz> <59CA1A57.5000905@huawei.com> <59CA1C6E.4010501@huawei.com> <6b38ed08-62cb-97b1-9f16-1fd8e272b137@suse.cz> <20170926110012.jiw6plglsyksj5mc@dhcp22.suse.cz>
In-Reply-To: <20170926110012.jiw6plglsyksj5mc@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>, yeyunfeng <yeyunfeng@huawei.com>, wanghaitao12@huawei.com, "Zhoukang (A)" <zhoukang7@huawei.com>

On 2017/9/26 19:00, Michal Hocko wrote:

> On Tue 26-09-17 11:45:16, Vlastimil Babka wrote:
>> On 09/26/2017 11:22 AM, Xishi Qiu wrote:
>>> On 2017/9/26 17:13, Xishi Qiu wrote:
>>>>> This is still very fuzzy. What are you actually trying to achieve?
>>>>
>>>> I don't expect page fault any more after mlock.
>>>>
>>>
>>> Our apps is some thing like RT, and page-fault maybe cause a lot of time,
>>> e.g. lock, mem reclaim ..., so I use mlock and don't want page fault
>>> any more.
>>
>> Why does your app then have restricted mprotect when calling mlockall()
>> and only later adjusts the mprotect?
> 
> Ahh, OK I see what is goging on. So you have PROT_NONE vma at the time
> mlockall and then later mprotect it something else and want to fault all
> that memory at the mprotect time?
> 
> So basically to do
> ---
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 6d3e2f082290..b665b5d1c544 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -369,7 +369,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
>  	 * Private VM_LOCKED VMA becoming writable: trigger COW to avoid major
>  	 * fault on access.
>  	 */
> -	if ((oldflags & (VM_WRITE | VM_SHARED | VM_LOCKED)) == VM_LOCKED &&
> +	if ((oldflags & (VM_WRITE | VM_LOCKED)) == VM_LOCKED &&
>  			(newflags & VM_WRITE)) {
>  		populate_vma_page_range(vma, start, end, NULL);
>  	}
> 

Hi Michal,

My kernel is v3.10, and I missed this code, thank you reminding me.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
