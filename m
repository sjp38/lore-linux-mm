Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17858C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:40:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D021320679
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:40:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D021320679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A3356B0003; Fri,  2 Aug 2019 05:40:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6543D6B0005; Fri,  2 Aug 2019 05:40:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 541FD6B0006; Fri,  2 Aug 2019 05:40:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3395E6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 05:40:16 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x1so63965949qkn.6
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 02:40:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=C7kyb5ylqdODtDx8sU/53Gh74VhUAd0Uf9Vqy92YryQ=;
        b=OlafGQHttDVdwv5X0A/9ocFJfRbVC9sEMHiqWF9d2aMb0zmS8vCBM6ailQiZrLHfMV
         nK14284kVNRQQrS3/ZgxNj6nyS8ankKJGHfw7O9rc7OkHXLY9gONZQxdLVYiZwxpaOr5
         Kxw8tY8Jkp1YBxn9bazzeZVJ4eCRvCfHueIrnC0ai0FqZhhvMkohepr6Ko6XFpG/z+TU
         5Urs0ZzpjvuwI9h9vaNrBIYOCvt2fPFTkrp+le4ooSGSDeMm9RwSiuTbk6PT5edocm8S
         I0OuxWx/ORELrZmOJAzfcc8wNd5ZayDuL75PJncqCuRJ8qMGHFBAvfJvQMOFBH1scL6B
         7vFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW7oDqI0EYIyM9Cs/IEVKYwdpsyvIsLDpMEzx7wVzxrGjUi4bIE
	gpV5l9l4deiyqDnZEXZeOguxopkkSmzsrwyhC25nN5GwWezasKL25DPkadrFvsSf4cIy7QvEEA8
	WSxtzZah/GWy1+Caq7KhNbnruG1rA8kBQjXlOMdbbJUD+MYHzBWq9olXyFBxG56oOBw==
X-Received: by 2002:aed:254c:: with SMTP id w12mr98005734qtc.127.1564738815962;
        Fri, 02 Aug 2019 02:40:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvbaHtVl5SdhMl0dpuVRZMBLe2DXAGFgRRF3bremhpvwgteNE5P3NtaWi1tdPu7jP8IMyq
X-Received: by 2002:aed:254c:: with SMTP id w12mr98005685qtc.127.1564738815102;
        Fri, 02 Aug 2019 02:40:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564738815; cv=none;
        d=google.com; s=arc-20160816;
        b=YbejCbXOphG18uAutVhxRKq6eBRF0XKkMczWAfgk9JettcOrsLeVNfh1CKGXcSBMWj
         CDiVGwTxCLeKaOj/zo5RHn3TbxjAw3EMXW+ku9Lh10+/XX0iP5m7OOSEyuAFIozmMBp5
         YCApoC1LVgIAamYaJc6CukGPEiWiq6LJX0rNjlfUAEshn6iAc6lybxHgWG+A+Nyw6FMh
         WIYHbCm615NmSdqfsPmh839HHrfCx4dXSNjBG4wLa5qGAnGHRhK+ql9YTZj+MSsWBo5m
         7jCvcB93hqw1IJlafCuHUVt4nIJPHrrzitxgmylCfzvIs1eZtyh7067SlYNdciDt8Uyb
         Ko8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=C7kyb5ylqdODtDx8sU/53Gh74VhUAd0Uf9Vqy92YryQ=;
        b=XaLJJlEPXiX2ZUFLlmLzDGU+nsvik3zV5R4oG/fkdGvkSyGu1aPbsg1Ou4OtVTlrtQ
         ncI1ocjn8nHQ12T2NeDNBZ5v2/f6Qh2q8giQrBSycjqETeJFrFrg5pyFyJp+jKJ5904t
         xM6ZmCawGe0TlF1QIqHaSBadrXCuUsErSyq76bxGiHqEjoxttrfZuo7ci42NKlaP2IkO
         qihRkkjBR4Og+F+HoNu8EqSxdE0jypEckSz0Dz6nJ4Odatc8VmP/GxWBmKyXaWykCCuZ
         PF6s2TWjUxkE5DIQBIVnuejiv08l0oK47sBseAsSJKbhz2FEJAn9hspXw/oIZsw413lb
         SHhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k39si45639048qtc.271.2019.08.02.02.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 02:40:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3DA173001A6C;
	Fri,  2 Aug 2019 09:40:14 +0000 (UTC)
Received: from [10.72.12.134] (ovpn-12-134.pek2.redhat.com [10.72.12.134])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 15D4F60BE2;
	Fri,  2 Aug 2019 09:40:08 +0000 (UTC)
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
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
Date: Fri, 2 Aug 2019 17:40:07 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190801141512.GB23899@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 02 Aug 2019 09:40:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/1 下午10:15, Jason Gunthorpe wrote:
> On Thu, Aug 01, 2019 at 01:02:18PM +0800, Jason Wang wrote:
>> On 2019/8/1 上午3:30, Jason Gunthorpe wrote:
>>> On Wed, Jul 31, 2019 at 09:28:20PM +0800, Jason Wang wrote:
>>>> On 2019/7/31 下午8:39, Jason Gunthorpe wrote:
>>>>> On Wed, Jul 31, 2019 at 04:46:53AM -0400, Jason Wang wrote:
>>>>>> We used to use RCU to synchronize MMU notifier with worker. This leads
>>>>>> calling synchronize_rcu() in invalidate_range_start(). But on a busy
>>>>>> system, there would be many factors that may slow down the
>>>>>> synchronize_rcu() which makes it unsuitable to be called in MMU
>>>>>> notifier.
>>>>>>
>>>>>> A solution is SRCU but its overhead is obvious with the expensive full
>>>>>> memory barrier. Another choice is to use seqlock, but it doesn't
>>>>>> provide a synchronization method between readers and writers. The last
>>>>>> choice is to use vq mutex, but it need to deal with the worst case
>>>>>> that MMU notifier must be blocked and wait for the finish of swap in.
>>>>>>
>>>>>> So this patch switches use a counter to track whether or not the map
>>>>>> was used. The counter was increased when vq try to start or finish
>>>>>> uses the map. This means, when it was even, we're sure there's no
>>>>>> readers and MMU notifier is synchronized. When it was odd, it means
>>>>>> there's a reader we need to wait it to be even again then we are
>>>>>> synchronized.
>>>>> You just described a seqlock.
>>>> Kind of, see my explanation below.
>>>>
>>>>
>>>>> We've been talking about providing this as some core service from mmu
>>>>> notifiers because nearly every use of this API needs it.
>>>> That would be very helpful.
>>>>
>>>>
>>>>> IMHO this gets the whole thing backwards, the common pattern is to
>>>>> protect the 'shadow pte' data with a seqlock (usually open coded),
>>>>> such that the mmu notififer side has the write side of that lock and
>>>>> the read side is consumed by the thread accessing or updating the SPTE.
>>>> Yes, I've considered something like that. But the problem is, mmu notifier
>>>> (writer) need to wait for the vhost worker to finish the read before it can
>>>> do things like setting dirty pages and unmapping page.  It looks to me
>>>> seqlock doesn't provide things like this.
>>> The seqlock is usually used to prevent a 2nd thread from accessing the
>>> VA while it is being changed by the mm. ie you use something seqlocky
>>> instead of the ugly mmu_notifier_unregister/register cycle.
>>
>> Yes, so we have two mappings:
>>
>> [1] vring address to VA
>> [2] VA to PA
>>
>> And have several readers and writers
>>
>> 1) set_vring_num_addr(): writer of both [1] and [2]
>> 2) MMU notifier: reader of [1] writer of [2]
>> 3) GUP: reader of [1] writer of [2]
>> 4) memory accessors: reader of [1] and [2]
>>
>> Fortunately, 1) 3) and 4) have already synchronized through vq->mutex. We
>> only need to deal with synchronization between 2) and each of the reset:
>> Sync between 1) and 2): For mapping [1], I do
>> mmu_notifier_unregister/register. This help to avoid holding any lock to do
>> overlap check.
> I suspect you could have done this with a RCU technique instead of
> register/unregister.


Probably. But the issue to be addressed by this patch is the 
synchronization between MMU notifier and vhost worker.


>
>> Sync between 2) and 4): For mapping [1], both are readers, no need any
>> synchronization. For mapping [2], synchronize through RCU (or something
>> simliar to seqlock).
> You can't really use a seqlock, seqlocks are collision-retry locks,
> and the semantic here is that invalidate_range_start *MUST* not
> continue until thread doing #4 above is guarenteed no longer touching
> the memory.


Yes, that's the tricky part. For hardware like CPU, kicking through IPI 
is sufficient for synchronization. But for vhost kthread, it requires a 
low overhead synchronization.


>
> This must be a proper barrier, like a spinlock, mutex, or
> synchronize_rcu.


I start with synchronize_rcu() but both you and Michael raise some 
concern. Then I try spinlock and mutex:

1) spinlock: add lots of overhead on datapath, this leads 0 performance 
improvement.

2) SRCU: full memory barrier requires on srcu_read_lock(), which still 
leads little performance improvement

3) mutex: a possible issue is need to wait for the page to be swapped in 
(is this unacceptable ?), another issue is that we need hold vq lock 
during range overlap check.

4) using vhost_flush_work() instead of synchronize_rcu(): still need to 
wait for swap. But can do overlap checking without the lock


>
> And, again, you can't re-invent a spinlock with open coding and get
> something better.


So the question is if waiting for swap is considered to be unsuitable 
for MMU notifiers. If not, it would simplify codes. If not, we still 
need to figure out a possible solution.

Btw, I come up another idea, that is to disable preemption when vhost 
thread need to access the memory. Then register preempt notifier and if 
vhost thread is preempted, we're sure no one will access the memory and 
can do the cleanup.

Thanks


>
> Jason

