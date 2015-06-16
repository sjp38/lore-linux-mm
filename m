Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 344926B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 20:32:18 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so1426717pdb.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 17:32:17 -0700 (PDT)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id nl4si19973046pbc.114.2015.06.15.17.32.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 17:32:17 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id ED809AC04FC
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:32:12 +0900 (JST)
Message-ID: <557F6E6E.9060104@jp.fujitsu.com>
Date: Tue, 16 Jun 2015 09:31:42 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 10/12] mm: add the buddy system interface
References: <55704A7E.5030507@huawei.com> <55704CC4.8040707@huawei.com> <557691E0.5020203@jp.fujitsu.com> <5576BA2B.6060907@huawei.com> <5577A9A9.7010108@jp.fujitsu.com> <3908561D78D1C84285E8C5FCA982C28F32A8F209@ORSMSX114.amr.corp.intel.com> <557E911F.5040602@jp.fujitsu.com> <20150615172023.GA12088@agluck-desk.sc.intel.com>
In-Reply-To: <20150615172023.GA12088@agluck-desk.sc.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/16 2:20, Luck, Tony wrote:
> On Mon, Jun 15, 2015 at 05:47:27PM +0900, Kamezawa Hiroyuki wrote:
>> So, there are 3 ideas.
>>
>>   (1) kernel only from MIRROR / user only from MOVABLE (Tony)
>>   (2) kernel only from MIRROR / user from MOVABLE + MIRROR(ASAP)  (AKPM suggested)
>>       This makes use of the fact MOVABLE memory is reclaimable but Tony pointed out
>>       the memory reclaim can be critical for GFP_ATOMIC.
>>   (3) kernel only from MIRROR / user from MOVABLE, special user from MIRROR (Xishi)
>>
>> 2 Implementation ideas.
>>    - creating ZONE
>>    - creating new alloation attribute
>>
>> I don't convince whether we need some new structure in mm. Isn't it good to use
>> ZONE_MOVABLE for not-mirrored memory ?
>> Then, disable fallback from ZONE_MOVABLE -> ZONE_NORMAL for (1) and (3)
>
> We might need to rename it ... right now the memory hotplug
> people use ZONE_MOVABLE to indicate regions of physical memory
> that can be removed from the system.  I'm wondering whether
> people will want systems that have both removable and mirrored
> areas?  Then we have four attribute combinations:
>
> mirror=no  removable=no  - prefer to use for user, could use for kernel if we run out of mirror
> mirror=no  removable=yes - can only be used for user (kernel allocation makes it not-removable)
> mirror=yes removable=no  - use for kernel, possibly for special users if we define some interface
> mirror=yes removable=yes - must not use for kernel ... would have to give to user ... seems like a bad idea to configure a system this way
>

Thank you for clarification. I see "mirror=no, removable=no" case may require a new name.

IMHO, the value of Address-Based-Memory-Mirror is that users can protect their system's
important functions without using full-memory mirror. So, I feel thinking
"mirror=no, removable=no" just makes our discussion/implemenation complex without real
user value.

Shouldn't we start with just thiking 2 cases of
  mirror=no  removable=yes
  mirror=yes removable=no
?

And then, if the naming is problem, alias name can be added.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
