Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D61F0C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 10:08:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 744E9229F3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 10:08:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 744E9229F3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA5F06B0003; Wed, 24 Jul 2019 06:08:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C57FD6B0005; Wed, 24 Jul 2019 06:08:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B45048E0002; Wed, 24 Jul 2019 06:08:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94C456B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 06:08:28 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p34so41046683qtp.1
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 03:08:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=+ccyRBdfeg5D7HrnTdhNfpBk6LNFEhnyOqKJ3596EgA=;
        b=HyOZo6aBb41xUQfEe9o3uqkKB7jOtiEODVq4zh56OuICCqGzwj6FChXhMKTZibecO7
         YA2wDHY059K5Sw20iORy/iQjIl23dCOh8Sypj8NkVxLzJrN7nqz0NffkJmAd+9mCEw2U
         YgQXDxl/c5blOIuy76XAgXtasIu3Kkyt/fthY5RYUYL2WO+KGvz5MO6bhnKCMQYCixb2
         s/0XgzR6DDnYtW8DZOjzpMRgG6FZQnmUYkrYr/grVI4GIdGM4N+yqNh7ntHidmdFqGwp
         3VIJ/SZg86f4IAB1wU8YaWuc4WiZsXdCRaRG8df9HK1TwvO93Om12kyC+Oi2HpHmFNFo
         OEIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVQfn3JBGmDRUnDskZmEnTEnQLvC6Vjh2I3z7FVJ2PAy2NHu1aP
	cUQiudKqpBZWS4oRgCkSdIyKceexWBFpoR5HJeEGBeSuiBx7IyfaIUYXKQHujhqsqljaHlbGT3r
	B9HW2QZTiWUslt+Wk1cD9kFpJq0Spe+5O7euokykn44n03Vjwg9uLOetaj4xanzLY3Q==
X-Received: by 2002:ac8:7404:: with SMTP id p4mr57558873qtq.181.1563962908362;
        Wed, 24 Jul 2019 03:08:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3cZu7XxL++sBQJMmZMqNi00cmxXxVr4WnEzFFm5KsP7oN9W9SXfyldrRlFb9RiXKv7BAR
X-Received: by 2002:ac8:7404:: with SMTP id p4mr57558820qtq.181.1563962907578;
        Wed, 24 Jul 2019 03:08:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563962907; cv=none;
        d=google.com; s=arc-20160816;
        b=T9Hg+my5lcbHyOhHnRhUHiHwfIw5wha1f6G2b+ctosmI0eWIcR2r6M/yzCExT2436r
         0g2SOr5y961G1IGDFyLnoYmLRKj0pOSwNbtY0ViHI8QOP4RnVUbO7Pu5k9ZQcAvbkkwM
         jtvED/jG7CJ8BHnRfm0/9u7NyChX9woLHGdVUWmcoXHn2JD409SX3TJ+NqnEFVkl75FN
         z46PGxGr2dbcJ5Jxhr5G0Tj67K1yaKl25HEOWyPwDk6W+klcmwkeA7KRHP5fhXEXrPJ1
         8H2kRxRyRDo61UhdoIqg9ZxL7Usux0R2ADAZGvoOiRk2eaE48Q3rt/rmMYrGkgCEDasE
         rZrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+ccyRBdfeg5D7HrnTdhNfpBk6LNFEhnyOqKJ3596EgA=;
        b=bmNX5uf3K4NwbJLU5XlWiaTOw257N4Ws4/2NX+ZRA4aSZ/q5Z1g82utZIY2HF8FvYN
         xkhsTtz63TN5BXURGP4Z0sYIBdMfjrjVk8TOYaLyZR+IYZzZQUxBNBoo15mz1v8SrlPs
         p3n/Y0vLdHP85sXIUqAjDGJEpC3KtpxlUV8++MZm9j0pp1ap0JGLCPSYMGjQpSJ8xL//
         8kC4YUS3syPTzyAv7lvRvpzH8hHAH51ykOoAm4BP8pJ5V+//4cO6jnuWq6gffTwDL9AH
         pvApso86qSaeyeWU2II2i5QPTg2YNi3JzHN5zDtCIaO1YHMI25EXInkbEXdiWkcUceRD
         XCRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q20si28689633qke.380.2019.07.24.03.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 03:08:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 15AD230ADC87;
	Wed, 24 Jul 2019 10:08:26 +0000 (UTC)
Received: from [10.72.12.18] (ovpn-12-18.pek2.redhat.com [10.72.12.18])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7395F19C70;
	Wed, 24 Jul 2019 10:08:10 +0000 (UTC)
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
References: <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
 <20190723062221-mutt-send-email-mst@kernel.org>
 <9baa4214-67fd-7ad2-cbad-aadf90bbfc20@redhat.com>
 <20190723110219-mutt-send-email-mst@kernel.org>
 <e0c91b89-d1e8-9831-00fe-23fe92d79fa2@redhat.com>
 <20190724040238-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <3dfa2269-60ba-7dd8-99af-5aef8552bd98@redhat.com>
Date: Wed, 24 Jul 2019 18:08:05 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724040238-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Wed, 24 Jul 2019 10:08:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/24 下午4:05, Michael S. Tsirkin wrote:
> On Wed, Jul 24, 2019 at 10:17:14AM +0800, Jason Wang wrote:
>> On 2019/7/23 下午11:02, Michael S. Tsirkin wrote:
>>> On Tue, Jul 23, 2019 at 09:34:29PM +0800, Jason Wang wrote:
>>>> On 2019/7/23 下午6:27, Michael S. Tsirkin wrote:
>>>>>> Yes, since there could be multiple co-current invalidation requests. We need
>>>>>> count them to make sure we don't pin wrong pages.
>>>>>>
>>>>>>
>>>>>>> I also wonder about ordering. kvm has this:
>>>>>>>            /*
>>>>>>>              * Used to check for invalidations in progress, of the pfn that is
>>>>>>>              * returned by pfn_to_pfn_prot below.
>>>>>>>              */
>>>>>>>             mmu_seq = kvm->mmu_notifier_seq;
>>>>>>>             /*
>>>>>>>              * Ensure the read of mmu_notifier_seq isn't reordered with PTE reads in
>>>>>>>              * gfn_to_pfn_prot() (which calls get_user_pages()), so that we don't
>>>>>>>              * risk the page we get a reference to getting unmapped before we have a
>>>>>>>              * chance to grab the mmu_lock without mmu_notifier_retry() noticing.
>>>>>>>              *
>>>>>>>              * This smp_rmb() pairs with the effective smp_wmb() of the combination
>>>>>>>              * of the pte_unmap_unlock() after the PTE is zapped, and the
>>>>>>>              * spin_lock() in kvm_mmu_notifier_invalidate_<page|range_end>() before
>>>>>>>              * mmu_notifier_seq is incremented.
>>>>>>>              */
>>>>>>>             smp_rmb();
>>>>>>>
>>>>>>> does this apply to us? Can't we use a seqlock instead so we do
>>>>>>> not need to worry?
>>>>>> I'm not familiar with kvm MMU internals, but we do everything under of
>>>>>> mmu_lock.
>>>>>>
>>>>>> Thanks
>>>>> I don't think this helps at all.
>>>>>
>>>>> There's no lock between checking the invalidate counter and
>>>>> get user pages fast within vhost_map_prefetch. So it's possible
>>>>> that get user pages fast reads PTEs speculatively before
>>>>> invalidate is read.
>>>>>
>>>>> -- 
>>>> In vhost_map_prefetch() we do:
>>>>
>>>>           spin_lock(&vq->mmu_lock);
>>>>
>>>>           ...
>>>>
>>>>           err = -EFAULT;
>>>>           if (vq->invalidate_count)
>>>>                   goto err;
>>>>
>>>>           ...
>>>>
>>>>           npinned = __get_user_pages_fast(uaddr->uaddr, npages,
>>>>                                           uaddr->write, pages);
>>>>
>>>>           ...
>>>>
>>>>           spin_unlock(&vq->mmu_lock);
>>>>
>>>> Is this not sufficient?
>>>>
>>>> Thanks
>>> So what orders __get_user_pages_fast wrt invalidate_count read?
>>
>> So in invalidate_end() callback we have:
>>
>> spin_lock(&vq->mmu_lock);
>> --vq->invalidate_count;
>>          spin_unlock(&vq->mmu_lock);
>>
>>
>> So even PTE is read speculatively before reading invalidate_count (only in
>> the case of invalidate_count is zero). The spinlock has guaranteed that we
>> won't read any stale PTEs.
>>
>> Thanks
> I'm sorry I just do not get the argument.
> If you want to order two reads you need an smp_rmb
> or stronger between them executed on the same CPU.
>
> Executing any kind of barrier on another CPU
> will have no ordering effect on the 1st one.
>
>
> So if CPU1 runs the prefetch, and CPU2 runs invalidate
> callback, read of invalidate counter on CPU1 can bypass
> read of PTE on CPU1 unless there's a barrier
> in between, and nothing CPU2 does can affect that outcome.
>
>
> What did I miss?


It doesn't harm if PTE is read before invalidate_count, this is because:

1) This speculation is serialized with invalidate_range_end() because of 
the spinlock

2) This speculation can only make effect when we read invalidate_count 
as zero.

3) This means the speculation is done after the last 
invalidate_range_end() and because of the spinlock, when we enter the 
critical section of spinlock in prefetch, we can not see any stale PTE 
that was unmapped before.

Am I wrong?

Thanks

