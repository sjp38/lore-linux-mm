Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1783C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 03:45:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51F0C216F4
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 03:45:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51F0C216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B63138E002A; Wed, 24 Jul 2019 23:45:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B14D88E001C; Wed, 24 Jul 2019 23:45:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A03078E002A; Wed, 24 Jul 2019 23:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81A6F8E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:45:03 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o11so34769839qtq.10
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 20:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=VBgul7HxRwUXu+djqbZSy3DHzU0zb3bRVlYqd2unL5k=;
        b=hyyMvS3dnllVZsDsFCHgqE9+kSfmz+VW0H1Iv2ZlCsjiDfKiSj9nKWcIINf9IwGJi8
         kh8pgjZJOX6AF0AK9ne3wEjbsSXz7GKPyCb/BuMpDWh/qpXiiU++WLYsYyY0ebHXHGJS
         HtsidTbaARlh9P87FP4v+5qISdim8BaUwVKTatKBPP1RN5TcfWBJgzNsRX7asU4yitbU
         CO4Fk1aS0iOrRncshwbqfHNtr4W+PrcWmBinSJ5+Mi+M+wi3uT2tNUJnD3wb55MjLyot
         ilF+4K1UNmYmD8oQ+iYNcsqSsHn7I9klAxX8jcL2nBH0WEJXqV51xXXhXxpnmKqeVgMi
         TqNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXZb7b5oqj7iw3tXJoCjOEjqLsEhJdf1w9Qv225B4xj1+f7jFgX
	NaXCA3gt/u4GTCvRTxk2FnHiGgny4v0i/3AEpy50blH1tksY3r0jy48E0ZVM5KPqc0N8OBSXhfb
	c5iRNY57AmezgZXw0eZtZKFEEJFceEzi1FEB69+DbFEUNA7501topuPlFR6Tm+05fHQ==
X-Received: by 2002:a05:620a:15f0:: with SMTP id p16mr56430431qkm.141.1564026303213;
        Wed, 24 Jul 2019 20:45:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdZRCXfSYhlHks4pf5vj2agcnfN9MbPkcxQFUa0nWhu2saZgScAEEwXyC3AmHnhjefA0/1
X-Received: by 2002:a05:620a:15f0:: with SMTP id p16mr56430407qkm.141.1564026302315;
        Wed, 24 Jul 2019 20:45:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564026302; cv=none;
        d=google.com; s=arc-20160816;
        b=ox/u4YiHhbV65SU/ATE19Y5GwEe2BTcURtlBNKDfndITmBIthGXZIBJ48lOWdcTrDp
         gpYVTdemommpEZh7l00XZOOK4qLGDg4Li3xOtCY2mxAioxDKT88zLjeYVYCWFqXrd/6Q
         UzUw4WL9MOEiAIBYoUZAmolFisSX0rXPn59xyOgg+SWkKOjShk6PDtrCNNe7BkFSM1hb
         2aixjSbbDCHZFWm4v2mzKwBXujP6RIFUwnEDQ3a7saPMo/8nwFWvZD9cUC4dqaTSram3
         C+UGR1Qe3NSDZA48VLW14BcnS+JTJOIkwLyA71d9/0Pd2lDVR+6cs4fJ9nxGD3m1VDSl
         uKqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=VBgul7HxRwUXu+djqbZSy3DHzU0zb3bRVlYqd2unL5k=;
        b=yeKByP0qlAAo8prCo1aTajPDkYSiFMmTrOjyVcf0Rzoi6rAHR5SZ2XBMhY8lm22kVD
         t9D3hZO6A54ZBqZIr2UjzK5quMEshxY8M1ZE3VXc4QkceVF23KIzaMI+yilwYjwNiza/
         0d73BEBHkUNFi9VUT1LIAtW/5ZVInnoi3b4oeWRgcPSTpOLXFouByxGznbYgxa//m1fz
         5UDqCkaEt8Vh+6J8kGsArI0mueNoVJqJRVw6K2naoWhgBnLp+8W3XuSf4wEikbURGH+9
         FBLAv5pm8kdjtsYN42Y1dMW4MYa2cr2xf3hXxYihzgHfuk/SD0QERJJORVDOhI9vjwA2
         fnEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x12si9718508qta.126.2019.07.24.20.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 20:45:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E14BF30C62A0;
	Thu, 25 Jul 2019 03:45:00 +0000 (UTC)
Received: from [10.72.12.18] (ovpn-12-18.pek2.redhat.com [10.72.12.18])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 40D9B60603;
	Thu, 25 Jul 2019 03:44:42 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
 aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
 davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com,
 guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com,
 jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-parisc@vger.kernel.org, luto@amacapital.net,
 mhocko@suse.com, mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
 syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, wad@chromium.org
References: <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
 <20190723062221-mutt-send-email-mst@kernel.org>
 <9baa4214-67fd-7ad2-cbad-aadf90bbfc20@redhat.com>
 <20190723110219-mutt-send-email-mst@kernel.org>
 <e0c91b89-d1e8-9831-00fe-23fe92d79fa2@redhat.com>
 <20190724040238-mutt-send-email-mst@kernel.org>
 <3dfa2269-60ba-7dd8-99af-5aef8552bd98@redhat.com>
 <20190724142533-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <d786141f-9145-788d-6a10-6fa673dd584c@redhat.com>
Date: Thu, 25 Jul 2019 11:44:27 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724142533-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 25 Jul 2019 03:45:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/25 上午2:25, Michael S. Tsirkin wrote:
> On Wed, Jul 24, 2019 at 06:08:05PM +0800, Jason Wang wrote:
>> On 2019/7/24 下午4:05, Michael S. Tsirkin wrote:
>>> On Wed, Jul 24, 2019 at 10:17:14AM +0800, Jason Wang wrote:
>>>> On 2019/7/23 下午11:02, Michael S. Tsirkin wrote:
>>>>> On Tue, Jul 23, 2019 at 09:34:29PM +0800, Jason Wang wrote:
>>>>>> On 2019/7/23 下午6:27, Michael S. Tsirkin wrote:
>>>>>>>> Yes, since there could be multiple co-current invalidation requests. We need
>>>>>>>> count them to make sure we don't pin wrong pages.
>>>>>>>>
>>>>>>>>
>>>>>>>>> I also wonder about ordering. kvm has this:
>>>>>>>>>             /*
>>>>>>>>>               * Used to check for invalidations in progress, of the pfn that is
>>>>>>>>>               * returned by pfn_to_pfn_prot below.
>>>>>>>>>               */
>>>>>>>>>              mmu_seq = kvm->mmu_notifier_seq;
>>>>>>>>>              /*
>>>>>>>>>               * Ensure the read of mmu_notifier_seq isn't reordered with PTE reads in
>>>>>>>>>               * gfn_to_pfn_prot() (which calls get_user_pages()), so that we don't
>>>>>>>>>               * risk the page we get a reference to getting unmapped before we have a
>>>>>>>>>               * chance to grab the mmu_lock without mmu_notifier_retry() noticing.
>>>>>>>>>               *
>>>>>>>>>               * This smp_rmb() pairs with the effective smp_wmb() of the combination
>>>>>>>>>               * of the pte_unmap_unlock() after the PTE is zapped, and the
>>>>>>>>>               * spin_lock() in kvm_mmu_notifier_invalidate_<page|range_end>() before
>>>>>>>>>               * mmu_notifier_seq is incremented.
>>>>>>>>>               */
>>>>>>>>>              smp_rmb();
>>>>>>>>>
>>>>>>>>> does this apply to us? Can't we use a seqlock instead so we do
>>>>>>>>> not need to worry?
>>>>>>>> I'm not familiar with kvm MMU internals, but we do everything under of
>>>>>>>> mmu_lock.
>>>>>>>>
>>>>>>>> Thanks
>>>>>>> I don't think this helps at all.
>>>>>>>
>>>>>>> There's no lock between checking the invalidate counter and
>>>>>>> get user pages fast within vhost_map_prefetch. So it's possible
>>>>>>> that get user pages fast reads PTEs speculatively before
>>>>>>> invalidate is read.
>>>>>>>
>>>>>>> -- 
>>>>>> In vhost_map_prefetch() we do:
>>>>>>
>>>>>>            spin_lock(&vq->mmu_lock);
>>>>>>
>>>>>>            ...
>>>>>>
>>>>>>            err = -EFAULT;
>>>>>>            if (vq->invalidate_count)
>>>>>>                    goto err;
>>>>>>
>>>>>>            ...
>>>>>>
>>>>>>            npinned = __get_user_pages_fast(uaddr->uaddr, npages,
>>>>>>                                            uaddr->write, pages);
>>>>>>
>>>>>>            ...
>>>>>>
>>>>>>            spin_unlock(&vq->mmu_lock);
>>>>>>
>>>>>> Is this not sufficient?
>>>>>>
>>>>>> Thanks
>>>>> So what orders __get_user_pages_fast wrt invalidate_count read?
>>>> So in invalidate_end() callback we have:
>>>>
>>>> spin_lock(&vq->mmu_lock);
>>>> --vq->invalidate_count;
>>>>           spin_unlock(&vq->mmu_lock);
>>>>
>>>>
>>>> So even PTE is read speculatively before reading invalidate_count (only in
>>>> the case of invalidate_count is zero). The spinlock has guaranteed that we
>>>> won't read any stale PTEs.
>>>>
>>>> Thanks
>>> I'm sorry I just do not get the argument.
>>> If you want to order two reads you need an smp_rmb
>>> or stronger between them executed on the same CPU.
>>>
>>> Executing any kind of barrier on another CPU
>>> will have no ordering effect on the 1st one.
>>>
>>>
>>> So if CPU1 runs the prefetch, and CPU2 runs invalidate
>>> callback, read of invalidate counter on CPU1 can bypass
>>> read of PTE on CPU1 unless there's a barrier
>>> in between, and nothing CPU2 does can affect that outcome.
>>>
>>>
>>> What did I miss?
>>
>> It doesn't harm if PTE is read before invalidate_count, this is because:
>>
>> 1) This speculation is serialized with invalidate_range_end() because of the
>> spinlock
>>
>> 2) This speculation can only make effect when we read invalidate_count as
>> zero.
>>
>> 3) This means the speculation is done after the last invalidate_range_end()
>> and because of the spinlock, when we enter the critical section of spinlock
>> in prefetch, we can not see any stale PTE that was unmapped before.
>>
>> Am I wrong?
>>
>> Thanks
> OK I think you are right. Sorry it took me a while to figure out.


No problem. So do you want me to send a V2 of the fixes (e.g with the 
conversion from synchronize_rcu() to kfree_rcu()). Or you want something 
else. (e.g revert or a config option)?

Thanks

