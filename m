Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85B57C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:39:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3180E217D6
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:39:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="RD3cwm1Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3180E217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C138D6B000C; Fri, 14 Jun 2019 13:39:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC3DB6B000D; Fri, 14 Jun 2019 13:39:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB37A6B000E; Fri, 14 Jun 2019 13:39:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84C266B000C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:39:43 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b75so3233793ywh.8
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:39:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=XMvZxwzjKPuaGK65ch/GjywCYthR9m/ns7t8VqxrQi0=;
        b=ZW29HTWDdWghZE0/48PvHDbn5Lrfi6j4yXcxU0buhU2WEskSp94UTojd4NcnY/Dd1R
         fqMYV1ZUFDVDAq2h2JyLt6onQsOHpW/fNP0f2igh71YK4meVuz0esyY8DLILegD6Qnlf
         H3oAkMMc17my/YTDJ1wnTMYrFhfhitDm2wlb32Wm12uBNGWsP1oibd9Lc1FZ9FUUUFwp
         1pZPGILmka+WSWz4iOoPv/GSGjce/pltka6e7TmBzpQVTMrJR0aSn0Opzchupymch1TT
         4PiqH+sSqvLhQnREYusksrufLNOgKyS3oxUwvx1/ga6X+oW3eHG4L7232TFszSpDbAL+
         hiHw==
X-Gm-Message-State: APjAAAVCsJ2tM+Ol8K/RvCjBVQ8hAoDfyzexSu1WgJmq5DSnen/15m0x
	0bQp7eQrg1DznnAQvocRuIyRncQmxUWI6UgkhB7bKZ6P3BkfWXFQfb9DxWqAsq+abnR9JvsMGl0
	KvoH9rWYuDcnetdX9RLBs1mQYpPvK/FzrPf20h7ryhMqAXqX5c3V8h35VUjRhGSO1NQ==
X-Received: by 2002:a0d:fe84:: with SMTP id o126mr30718062ywf.20.1560533983195;
        Fri, 14 Jun 2019 10:39:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9TjqCePpvLjs6YVSWO8Smbx4Fk9+q4DrhdP2cJYQzhHy9v73jUSv3ydptqRBsjkQDOIgm
X-Received: by 2002:a0d:fe84:: with SMTP id o126mr30718009ywf.20.1560533982305;
        Fri, 14 Jun 2019 10:39:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560533982; cv=none;
        d=google.com; s=arc-20160816;
        b=bfjayBZGUWWbUWe9rNmBuoiJNz66YhMcbfOvw48KA8aOoT6Fhb8GXJR7z7BUz4Mgxg
         V01SklpGZKH7vLZXVWfnek9RQeoEsGE10/w+oTT2B5fyPztH8UhipLZf1XFbCHAfEbLm
         H7BtCa+r1I0Akhs6YL+JVQ9aUWEON9Q+etSVroheX+qmacj6uQpHsmq5N50+FQapAnzJ
         NhwVy5o742WwiHJIgQu6Uvq8kxcIVqdCdwu1WUxiKHe8CX8+uskCB4eiy4+c6fkG9gVP
         hUY2iNs9UwG10G7IU7pqFB5PL3DsCTvltyYSwan6RR85kBOh9Y1XLJJ+VjwiRKifog6X
         4dGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=XMvZxwzjKPuaGK65ch/GjywCYthR9m/ns7t8VqxrQi0=;
        b=Q8+GPoF3aSplkPe+XfI2RutRZatasew6rdYjZpgaWs9TC+/XrWLwpxV8D4Ak1HWGVK
         TBOVhLCKeHg7AGCDrRCP4zBR+Nv2dvTqXQtiDZujBsHvHJuNaUZRfjq4pW8xmhGNINAT
         ZoyxtGP0iTZlI+U6NAcmgnGA19Idnft9jMHdv95p3oSdh+haYwZDYRSUHJsX8w0FGuhe
         eb2+bTmvQ6iKwfl+zMi1uvJCfdl9N+2ZWqwCdVcNN3xFD8GSHx6Hcti32mx17XeJplZ4
         LxZ1DRmh7BfHF2zY7zlf/0RLJEFS80ZbYxt1D0m0k7uXSIEN0JdCzsw0mBwuF+j/BSAB
         gC7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RD3cwm1Q;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id r184si1256093ywd.235.2019.06.14.10.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 10:39:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RD3cwm1Q;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d03dbdd0000>; Fri, 14 Jun 2019 10:39:41 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 14 Jun 2019 10:39:41 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 14 Jun 2019 10:39:41 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 17:39:39 +0000
Subject: Re: [PATCH] drm/nouveau/dmem: missing mutex_lock in error path
To: John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>,
	David Airlie <airlied@linux.ie>, Ben Skeggs <bskeggs@redhat.com>, "Jason
 Gunthorpe" <jgg@mellanox.com>
CC: <nouveau@lists.freedesktop.org>, <linux-mm@kvack.org>,
	<dri-devel@lists.freedesktop.org>, <linux-kernel@vger.kernel.org>
References: <20190614001121.23950-1-rcampbell@nvidia.com>
 <1fc63655-985a-0d60-523f-00a51648dc38@nvidia.com>
From: Ralph Campbell <rcampbell@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <f67784db-dada-c827-f231-35549fc046dc@nvidia.com>
Date: Fri, 14 Jun 2019 10:39:38 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <1fc63655-985a-0d60-523f-00a51648dc38@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560533981; bh=XMvZxwzjKPuaGK65ch/GjywCYthR9m/ns7t8VqxrQi0=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=RD3cwm1QmItBD46Y4rN/RW1m17w+jMbzQkWzbdwwgjKmJyp8UbNbGoYqsSuuG3QBe
	 kIGfjNRxQ1In0vMdOLz/F0lBq3nvWRa9i4aZQnzz2n70MA3qthRMf4v2+9tuH7gNWd
	 wWmiZxVbDFAVzUvDcY68A3WkS5S8FU09One6QYe2D9gOLT2hNdj/rGPB+iguuagtnN
	 vM/DXV4dpcnnSF681VTR1Se8jWllQl5nPVxZRp7eyEhqibk5ldNf0LxhR1P0rtokqC
	 wU5q0wHRU48eq6I/wEPneUPYuabosEy/XNunE3fjwUAj8mSa5UxsJgQJEVoExs3paY
	 eb9RYPl0wBqPA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/13/19 5:49 PM, John Hubbard wrote:
> On 6/13/19 5:11 PM, Ralph Campbell wrote:
>> In nouveau_dmem_pages_alloc(), the drm->dmem->mutex is unlocked before
>> calling nouveau_dmem_chunk_alloc().
>> Reacquire the lock before continuing to the next page.
>>
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>> ---
>>
>> I found this while testing Jason Gunthorpe's hmm tree but this is
>> independent of those changes. I guess it could go through
>> David Airlie's tree for nouveau or Jason's tree.
>>
> 
> Hi Ralph,
> 
> btw, was this the fix for the crash you were seeing? It might be nice to
> mention in the commit description, if you are seeing real symptoms.
> 
> 
>>   drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
>> index 27aa4e72abe9..00f7236af1b9 100644
>> --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
>> +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
>> @@ -379,9 +379,10 @@ nouveau_dmem_pages_alloc(struct nouveau_drm *drm,
>>   			ret = nouveau_dmem_chunk_alloc(drm);
>>   			if (ret) {
>>   				if (c)
>> -					break;
> 
> Actually, the pre-existing code is a little concerning. Your change preserves
> the behavior, but it seems questionable to be doing a "return 0" (whether
> via the above break, or your change) when it's in this partially allocated
> state. It's reporting success when it only allocates part of what was requested,
> and it doesn't fill in the pages array either.
> 
> 
> 
>> +					return 0;
>>   				return ret;
>>   			}
>> +			mutex_lock(&drm->dmem->mutex);
>>   			continue;
>>   		}
>>   
>>
> 
> The above comment is about pre-existing potential problems, but your patch itself
> looks correct, so:
> 
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> 
> 
> thanks,
> 
The crash was the NULL pointer bug in Christoph's patch #10.
I sent a separate reply for that.

Below is the console output I got, then I made the changes just based on
code inspection. Do you think I should include it in the change log?

As for the "return 0", If you follow the call chain,
nouveau_dmem_pages_alloc() is only ever called for one page so this
currently "works" but I agree it is a bit of a time bomb. There are a
number of other bugs that I can see that need fixing but I think those
should be separate patches.

[ 1294.871933] =====================================
[ 1294.876656] WARNING: bad unlock balance detected!
[ 1294.881375] 5.2.0-rc3+ #5 Not tainted
[ 1294.885048] -------------------------------------
[ 1294.889773] test-malloc-vra/6299 is trying to release lock 
(&drm->dmem->mutex) at:
[ 1294.897482] [<ffffffffa01a220f>] 
nouveau_dmem_migrate_alloc_and_copy+0x79f/0xbf0 [nouveau]
[ 1294.905782] but there are no more locks to release!
[ 1294.910690]
[ 1294.910690] other info that might help us debug this:
[ 1294.917249] 1 lock held by test-malloc-vra/6299:
[ 1294.921881]  #0: 0000000016e10454 (&mm->mmap_sem#2){++++}, at: 
nouveau_svmm_bind+0x142/0x210 [nouveau]
[ 1294.931313]
[ 1294.931313] stack backtrace:
[ 1294.935702] CPU: 4 PID: 6299 Comm: test-malloc-vra Not tainted 
5.2.0-rc3+ #5
[ 1294.942786] Hardware name: ASUS X299-A/PRIME X299-A, BIOS 1401 05/21/2018
[ 1294.949590] Call Trace:
[ 1294.952059]  dump_stack+0x7c/0xc0
[ 1294.955469]  ? nouveau_dmem_migrate_alloc_and_copy+0x79f/0xbf0 [nouveau]
[ 1294.962213]  print_unlock_imbalance_bug.cold.52+0xca/0xcf
[ 1294.967641]  lock_release+0x306/0x380
[ 1294.971383]  ? nouveau_dmem_migrate_alloc_and_copy+0x79f/0xbf0 [nouveau]
[ 1294.978089]  ? lock_downgrade+0x2d0/0x2d0
[ 1294.982121]  ? find_held_lock+0xac/0xd0
[ 1294.985979]  __mutex_unlock_slowpath+0x8f/0x3f0
[ 1294.990540]  ? wait_for_completion+0x230/0x230
[ 1294.995002]  ? rwlock_bug.part.2+0x60/0x60
[ 1294.999197]  nouveau_dmem_migrate_alloc_and_copy+0x79f/0xbf0 [nouveau]
[ 1295.005751]  ? page_mapping+0x98/0x110
[ 1295.009511]  migrate_vma+0xa74/0x1090
[ 1295.013186]  ? move_to_new_page+0x480/0x480
[ 1295.017400]  ? __kmalloc+0x153/0x300
[ 1295.021052]  ? nouveau_dmem_migrate_vma+0xd8/0x1e0 [nouveau]
[ 1295.026796]  nouveau_dmem_migrate_vma+0x157/0x1e0 [nouveau]
[ 1295.032466]  ? nouveau_dmem_init+0x490/0x490 [nouveau]
[ 1295.037612]  ? vmacache_find+0xc2/0x110
[ 1295.041537]  nouveau_svmm_bind+0x1b4/0x210 [nouveau]
[ 1295.046583]  ? nouveau_svm_fault+0x13e0/0x13e0 [nouveau]
[ 1295.051912]  drm_ioctl_kernel+0x14d/0x1a0
[ 1295.055930]  ? drm_setversion+0x330/0x330
[ 1295.059971]  drm_ioctl+0x308/0x530
[ 1295.063384]  ? drm_version+0x150/0x150
[ 1295.067153]  ? find_held_lock+0xac/0xd0
[ 1295.070996]  ? __pm_runtime_resume+0x3f/0xa0
[ 1295.075285]  ? mark_held_locks+0x29/0xa0
[ 1295.079230]  ? _raw_spin_unlock_irqrestore+0x3c/0x50
[ 1295.084232]  ? lockdep_hardirqs_on+0x17d/0x250
[ 1295.088768]  nouveau_drm_ioctl+0x9a/0x100 [nouveau]
[ 1295.093661]  do_vfs_ioctl+0x137/0x9a0
[ 1295.097341]  ? ioctl_preallocate+0x140/0x140
[ 1295.101623]  ? match_held_lock+0x1b/0x230
[ 1295.105646]  ? match_held_lock+0x1b/0x230
[ 1295.109660]  ? find_held_lock+0xac/0xd0
[ 1295.113512]  ? __do_page_fault+0x324/0x630
[ 1295.117617]  ? lock_downgrade+0x2d0/0x2d0
[ 1295.121648]  ? mark_held_locks+0x79/0xa0
[ 1295.125583]  ? handle_mm_fault+0x352/0x430
[ 1295.129687]  ksys_ioctl+0x60/0x90
[ 1295.133020]  ? mark_held_locks+0x29/0xa0
[ 1295.136964]  __x64_sys_ioctl+0x3d/0x50
[ 1295.140726]  do_syscall_64+0x68/0x250
[ 1295.144400]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 1295.149465] RIP: 0033:0x7f1a3495809b
[ 1295.153053] Code: 0f 1e fa 48 8b 05 ed bd 0c 00 64 c7 00 26 00 00 00 
48 c7 c0 ff ff ff ff c3 66 0f 1f 44 00 00 f3 0f 1e fa b8 10 00 00 00 0f 
05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d bd bd 0c 00 f7 d8 64 89 01 48
[ 1295.171850] RSP: 002b:00007ffef7ed1358 EFLAGS: 00000246 ORIG_RAX: 
0000000000000010
[ 1295.179451] RAX: ffffffffffffffda RBX: 00007ffef7ed1628 RCX: 
00007f1a3495809b
[ 1295.186601] RDX: 00007ffef7ed13b0 RSI: 0000000040406449 RDI: 
0000000000000004
[ 1295.193759] RBP: 00007ffef7ed13b0 R08: 0000000000000000 R09: 
000000000157e770
[ 1295.200917] R10: 000000000151c010 R11: 0000000000000246 R12: 
0000000040406449
[ 1295.208083] R13: 0000000000000004 R14: 0000000000000000 R15: 
0000000000000000

