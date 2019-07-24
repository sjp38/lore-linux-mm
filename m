Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DB10C76190
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 02:17:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CF74229ED
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 02:17:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CF74229ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6A276B0003; Tue, 23 Jul 2019 22:17:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1AA26B0005; Tue, 23 Jul 2019 22:17:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE21F8E0002; Tue, 23 Jul 2019 22:17:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A002C6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 22:17:30 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x7so40126745qtp.15
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 19:17:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=vA8N/EEJ47nb5gb7fqdZQuvhp5yMNC3pyQx73tvJBCg=;
        b=NUs0lSFzeMrHppMsH3I/zAW18Oa3C/150bbUwW/9/RCQRPqYjJW/26hyubV0LcVQ7e
         X8JzfhVXshJslQOUT8736QyCb/wx2jDCQ9gCFk1yND1BSaicUc612ma5Xmebdg3UwiB4
         BfKdLu3mPuuLeJm/Vm2r7LE8IF8durWwNtW7M31LsuRQQQGHCiFEdrDB5hMASuzoJS8m
         kQIUA1C6La7x3Yx9RH9t0ycFKNsJper2B56nfRFUOm60KQXHzDlJxZ47w0x9NlfgO21G
         laEbyZxwXDjtQsNbYiGMKR5YEWt5jpeyv9qEOfyP4Ys+p6GnyX66fmgTd4jdkjhA8G6x
         NXKQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXRQ4RrO21IiH20vVpEcoU8sFacfMnyjN3vo8JPaejnhpRvP725
	dYeL5yzLCu8W/EAXvXIt/DF3DhUS/D0xYKuE+gXvVOgo/WYl02iK3EqW16V76jNbVRUJB4bSsHS
	Gpp/uMbNQwxKMj3JlWX2N30qKWWOjYoi3bMl55dLFQOwgnwlM6XRXdswIgrnq2kV76A==
X-Received: by 2002:a05:620a:68c:: with SMTP id f12mr52253939qkh.197.1563934650435;
        Tue, 23 Jul 2019 19:17:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYFYyIGpwZbpo+iaL9QLbnV+g+jj4Q0GjXWeAbt/K5TJWD+KVuVRrQdvEILHUqE5JXWrXX
X-Received: by 2002:a05:620a:68c:: with SMTP id f12mr52253912qkh.197.1563934649820;
        Tue, 23 Jul 2019 19:17:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563934649; cv=none;
        d=google.com; s=arc-20160816;
        b=RMWuHjzebf9q/VzdPxahexe9HFrraJZiWpsIRAUUxjVJRpernnMVAkGjT6vQD6mQ65
         SucXZ4hceFynGZuBsAV15bopshiW8Y1/s9j+rYw1lInfXNrXvWKvstYkwivI+Qgigun0
         hp2PdFYfHWMdxBozjW/PCY1h3Kq2n1wHOJ0MBg+JOFWjQDngqKjtRr8jimrOHu9xF0cX
         myinFDR5fD9We8OPAXogxexwKyyd28krXYByRwAzuN6EXqNAymQzAYFTAlp78miDITFF
         uM9XkYlJr1Ik2d3H/qBhtH+y2FxQxY2mk0eA45HgHfbmo6rlvNE8bkOpzU3hngd8szB5
         3FdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=vA8N/EEJ47nb5gb7fqdZQuvhp5yMNC3pyQx73tvJBCg=;
        b=acTehbmvxvxtRWrb478NhfsggN1YsrzFjz2Lq0+nRerGvUL6n8glwXHMjfTIfODnlL
         2UiIxAJ/YCQYLUxnpgeBiYxC0FaUBk1YatpsXBbK9szSD3Llp3O2UpByQtQQINbWqJ38
         2D/QQXq+nikh+7wL6DGuQvMAUh0LJwjFkYmiNBsEdqKHKXO9h3pKV5dYeMItab8bjBGz
         0IAwT2SgxjxN0+ebgdzQQd/9JzNLBB3oVP1iPeWcsz5BurimqbKpqP6LZeEHyaG/M8bh
         OvCIs3JPyjLfyzm3zgF7uXhLis0RuMN2fstH5vBPFTFlV2UG+l40pIYHiqoLeysIed/J
         4Eyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t123si26673986qkd.358.2019.07.23.19.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 19:17:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A97D381DF1;
	Wed, 24 Jul 2019 02:17:28 +0000 (UTC)
Received: from [10.72.12.167] (ovpn-12-167.pek2.redhat.com [10.72.12.167])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2233F60497;
	Wed, 24 Jul 2019 02:17:16 +0000 (UTC)
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
References: <20190721044615-mutt-send-email-mst@kernel.org>
 <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
 <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
 <20190723062221-mutt-send-email-mst@kernel.org>
 <9baa4214-67fd-7ad2-cbad-aadf90bbfc20@redhat.com>
 <20190723110219-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <e0c91b89-d1e8-9831-00fe-23fe92d79fa2@redhat.com>
Date: Wed, 24 Jul 2019 10:17:14 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723110219-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 24 Jul 2019 02:17:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/23 下午11:02, Michael S. Tsirkin wrote:
> On Tue, Jul 23, 2019 at 09:34:29PM +0800, Jason Wang wrote:
>> On 2019/7/23 下午6:27, Michael S. Tsirkin wrote:
>>>> Yes, since there could be multiple co-current invalidation requests. We need
>>>> count them to make sure we don't pin wrong pages.
>>>>
>>>>
>>>>> I also wonder about ordering. kvm has this:
>>>>>           /*
>>>>>             * Used to check for invalidations in progress, of the pfn that is
>>>>>             * returned by pfn_to_pfn_prot below.
>>>>>             */
>>>>>            mmu_seq = kvm->mmu_notifier_seq;
>>>>>            /*
>>>>>             * Ensure the read of mmu_notifier_seq isn't reordered with PTE reads in
>>>>>             * gfn_to_pfn_prot() (which calls get_user_pages()), so that we don't
>>>>>             * risk the page we get a reference to getting unmapped before we have a
>>>>>             * chance to grab the mmu_lock without mmu_notifier_retry() noticing.
>>>>>             *
>>>>>             * This smp_rmb() pairs with the effective smp_wmb() of the combination
>>>>>             * of the pte_unmap_unlock() after the PTE is zapped, and the
>>>>>             * spin_lock() in kvm_mmu_notifier_invalidate_<page|range_end>() before
>>>>>             * mmu_notifier_seq is incremented.
>>>>>             */
>>>>>            smp_rmb();
>>>>>
>>>>> does this apply to us? Can't we use a seqlock instead so we do
>>>>> not need to worry?
>>>> I'm not familiar with kvm MMU internals, but we do everything under of
>>>> mmu_lock.
>>>>
>>>> Thanks
>>> I don't think this helps at all.
>>>
>>> There's no lock between checking the invalidate counter and
>>> get user pages fast within vhost_map_prefetch. So it's possible
>>> that get user pages fast reads PTEs speculatively before
>>> invalidate is read.
>>>
>>> -- 
>>
>> In vhost_map_prefetch() we do:
>>
>>          spin_lock(&vq->mmu_lock);
>>
>>          ...
>>
>>          err = -EFAULT;
>>          if (vq->invalidate_count)
>>                  goto err;
>>
>>          ...
>>
>>          npinned = __get_user_pages_fast(uaddr->uaddr, npages,
>>                                          uaddr->write, pages);
>>
>>          ...
>>
>>          spin_unlock(&vq->mmu_lock);
>>
>> Is this not sufficient?
>>
>> Thanks
> So what orders __get_user_pages_fast wrt invalidate_count read?


So in invalidate_end() callback we have:

spin_lock(&vq->mmu_lock);
--vq->invalidate_count;
         spin_unlock(&vq->mmu_lock);


So even PTE is read speculatively before reading invalidate_count (only 
in the case of invalidate_count is zero). The spinlock has guaranteed 
that we won't read any stale PTEs.

Thanks


>

