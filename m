Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A09DC32754
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 05:02:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACFDC20B7C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 05:02:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACFDC20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14FD98E0003; Thu,  1 Aug 2019 01:02:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 100338E0001; Thu,  1 Aug 2019 01:02:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F306D8E0003; Thu,  1 Aug 2019 01:02:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2DA98E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 01:02:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x17so60141143qkf.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:02:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=GyeuUfT7sch9KfIAE7SZ+ozlZB6lJcbAeF8sXvyXO8E=;
        b=UZen6FcE7uQsKD1JjyQOkzHlyi6xphspR4ll7SC3RjHwnrconvBMtLMV6iwtLyGOcX
         ksU7xWvhx+R6b45cr+2/fjCbRlh0bPY/yRjcPZylv6MDb+s/4WV6r5H7q96SAKdmo15D
         zVZtYSuOKfzmstHxSflPz8YCUO05t+MK2RzTC3vSGJ8iC0hJuF96UYZfQjAqGUelEUpN
         azk2FSymz7ocN3bbOkcGabJn60TVJtmtF8UhCQKHugufYfowZszLSApNnDoQl6Ivx/gR
         bPMDspBanz6mf7PVGrCizSeGJMm5MGrwb4uYNqgIANQnaTCpUhmTezbhXUPdkZZHn/lP
         7+oA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXrqXPoPdbq+zr2GBya/ywseyI3tF63mQeH2KlSFVhi09ZQblbE
	CdW8Z/iJWCiajb+wFGW9+t++U05VXyj23FqViTMFy39BRzV3djC7zqXBgsMPW1VhFbqc0gsBlGI
	4DnqcInyJ5WYLAQn7e3SlbQMPxby9l7nnqkedDXP94mz2V6PjisiNDGR/Znzmh4GmLA==
X-Received: by 2002:ac8:1c2d:: with SMTP id a42mr87373970qtk.311.1564635747551;
        Wed, 31 Jul 2019 22:02:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+02c1VBGqMX5sKqRIqhf7CGr/jHqYcJ8SJA/iWyCY7NaXUXMPq6B42WzVSbgk+NhX12rm
X-Received: by 2002:ac8:1c2d:: with SMTP id a42mr87373903qtk.311.1564635746455;
        Wed, 31 Jul 2019 22:02:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564635746; cv=none;
        d=google.com; s=arc-20160816;
        b=t56F7cNtfqnkUXjz6ZKThmNxEvNxVMGGIY0977+E9+MLFKxIpLl624mIaVh1l2E1CQ
         8JVhCIhvCUFmilVic9vLtZCUu/5JLe+8q40mnLXba+TQZbTOV7GPIqw4rBjVMaqxqg3B
         sGNG2i16HuuaLb6zDUNbYoBe+9+AqwZKn9dltue18UwNu6kXw/ce5xTlD6eMlZpuRqH7
         ax98aBUmtcTldDrnRehFZAaFbqEtPEhuT4YoN+JnoksymtNdyy749Ux1Xjx8M8odZPER
         4vtBGMiUUsSO3BBIR7K0QYSd6a6nuWH5unsOX336MZ+Ss96OuxUQNihUi2sPxCavPI8Q
         7mig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=GyeuUfT7sch9KfIAE7SZ+ozlZB6lJcbAeF8sXvyXO8E=;
        b=OrX8+lY1JUpzq5xuKWZcKe1iLSxf/7ljxIkyqOSMJdPNx6txL30vSqMQMcga8D3j/P
         uZIjzF1PnOflPQkrYUK1dsnl5QkVpY7TGNx02iKHgAeux32qLEAA48c+xoBfiBH2pXAv
         fS+8ZTsn2KuS2eU8jAtHmoLt2CitnRNGRbEfWhVtrml2SGP3ltZsLFjMWm522GW6a9yq
         gDxeNWJCePztPcmXXe5jtIHJ53uvL5vzN6RWHUCukZw7jtPCvi4pgO/OLj64F+859dSy
         UeJOqcSr/t33M2addP6Fh0tcjh8/6ojoqXbHxV8TgYiNbO/0Hgj6xpy4FhKYiULHlLa9
         KEaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u23si38900043qkj.318.2019.07.31.22.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 22:02:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 218028A004;
	Thu,  1 Aug 2019 05:02:25 +0000 (UTC)
Received: from [10.72.12.66] (ovpn-12-66.pek2.redhat.com [10.72.12.66])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CC4F4600C4;
	Thu,  1 Aug 2019 05:02:19 +0000 (UTC)
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com> <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
Date: Thu, 1 Aug 2019 13:02:18 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190731193057.GG3946@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 01 Aug 2019 05:02:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/1 上午3:30, Jason Gunthorpe wrote:
> On Wed, Jul 31, 2019 at 09:28:20PM +0800, Jason Wang wrote:
>> On 2019/7/31 下午8:39, Jason Gunthorpe wrote:
>>> On Wed, Jul 31, 2019 at 04:46:53AM -0400, Jason Wang wrote:
>>>> We used to use RCU to synchronize MMU notifier with worker. This leads
>>>> calling synchronize_rcu() in invalidate_range_start(). But on a busy
>>>> system, there would be many factors that may slow down the
>>>> synchronize_rcu() which makes it unsuitable to be called in MMU
>>>> notifier.
>>>>
>>>> A solution is SRCU but its overhead is obvious with the expensive full
>>>> memory barrier. Another choice is to use seqlock, but it doesn't
>>>> provide a synchronization method between readers and writers. The last
>>>> choice is to use vq mutex, but it need to deal with the worst case
>>>> that MMU notifier must be blocked and wait for the finish of swap in.
>>>>
>>>> So this patch switches use a counter to track whether or not the map
>>>> was used. The counter was increased when vq try to start or finish
>>>> uses the map. This means, when it was even, we're sure there's no
>>>> readers and MMU notifier is synchronized. When it was odd, it means
>>>> there's a reader we need to wait it to be even again then we are
>>>> synchronized.
>>> You just described a seqlock.
>>
>> Kind of, see my explanation below.
>>
>>
>>> We've been talking about providing this as some core service from mmu
>>> notifiers because nearly every use of this API needs it.
>>
>> That would be very helpful.
>>
>>
>>> IMHO this gets the whole thing backwards, the common pattern is to
>>> protect the 'shadow pte' data with a seqlock (usually open coded),
>>> such that the mmu notififer side has the write side of that lock and
>>> the read side is consumed by the thread accessing or updating the SPTE.
>>
>> Yes, I've considered something like that. But the problem is, mmu notifier
>> (writer) need to wait for the vhost worker to finish the read before it can
>> do things like setting dirty pages and unmapping page.  It looks to me
>> seqlock doesn't provide things like this.
> The seqlock is usually used to prevent a 2nd thread from accessing the
> VA while it is being changed by the mm. ie you use something seqlocky
> instead of the ugly mmu_notifier_unregister/register cycle.


Yes, so we have two mappings:

[1] vring address to VA
[2] VA to PA

And have several readers and writers

1) set_vring_num_addr(): writer of both [1] and [2]
2) MMU notifier: reader of [1] writer of [2]
3) GUP: reader of [1] writer of [2]
4) memory accessors: reader of [1] and [2]

Fortunately, 1) 3) and 4) have already synchronized through vq->mutex. 
We only need to deal with synchronization between 2) and each of the reset:
Sync between 1) and 2): For mapping [1], I do 
mmu_notifier_unregister/register. This help to avoid holding any lock to 
do overlap check. Anyway we only care about one or three pages , but the 
whole guest memory could be several TBs. For mapping [2], both 1) and 2) 
are writers, so use spinlock (mmu_lock) to synchronize.
Sync between 2) and 3): For mapping [1], both are readers, no need any 
synchronization. For mapping [2], both 2) and 3) are writers, so 
synchronize through spinlock (mmu_lock);
Sync between 2) and 4): For mapping [1], both are readers, no need any 
synchronization. For mapping [2], synchronize through RCU (or something 
simliar to seqlock).

You suggestion is about the synchronization of [1] which may make sense, 
but it could be done on top as an optimization. What this path tries to 
do is to not use RCU for [2]. Of course, the simplest way is to use vq 
mutex in 2) but it means:
- we must hold vq lock to check range overlap
- since the critical section was increased, the worst case is to wait 
guest memory to be swapped in, this could be even slower than 
synchronize_rcu().


>
> You are supposed to use something simple like a spinlock or mutex
> inside the invalidate_range_start to serialized tear down of the SPTEs
> with their accessors.


Technically yes, but we probably can't afford that for vhost fast path, 
the atomics eliminate almost all the performance improvement brought by 
this patch on a machine without SMAP.


>
>> write_seqcount_begin()
>>
>> map = vq->map[X]
>>
>> write or read through map->addr directly
>>
>> write_seqcount_end()
>>
>>
>> There's no rmb() in write_seqcount_begin(), so map could be read before
>> write_seqcount_begin(), but it looks to me now that this doesn't harm at
>> all, maybe we can try this way.
> That is because it is a write side lock, not a read lock. IIRC
> seqlocks have weaker barriers because the write side needs to be
> serialized in some other way.


Yes. Having a hard thought of the code, it looks to me 
write_seqcount_begin()/end() is sufficient here:

- Notifier will only assign NULL to map, so it doesn't harm to read map 
before seq, then we will fallback to normal copy_from/to_user() slow 
path earlier
- if we write through map->addr, it should be done before increasing the 
seqcount because of the smp_wmb() in write_seqcount_end()
- if we read through map->addr which also contain a store to a pointer, 
we have a good data dependency so smp_wmb() also work here.


>
> The requirement I see is you need invalidate_range_start to block
> until another thread exits its critical section (ie stops accessing
> the SPTEs).


Yes.


>
> That is a spinlock/mutex.


Or a semantics similar to RCU.


>
> You just can't invent a faster spinlock by open coding something with
> barriers, it doesn't work.
>
> Jason


If write_seqlock() works here, we can simply wait for seqcount to move 
advance in MMU notifier. The original idea is to use RCU which solves 
this perfectly. But as pointed out it could be slow.

Thanks

