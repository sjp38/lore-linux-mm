Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F4DBC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 14:00:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3D3D22CF5
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 14:00:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3D3D22CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55BB56B0003; Fri, 26 Jul 2019 10:00:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50CB28E0005; Fri, 26 Jul 2019 10:00:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AC7B8E0003; Fri, 26 Jul 2019 10:00:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17EE86B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 10:00:52 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id e18so45136605qkl.17
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 07:00:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=stcUXmd1EWMweb01P1UeC7yCi2kg8YuWNOzdoxvJgRU=;
        b=MTiJXIIYWeYukIn8QG5J+mSLnEIhzmn4wEr6eiDHMUiaQk7oSMAYdev0zKOgonmrKg
         taV0AXVj6OKmMoCQdQVe9zuHmkZPs5Fj4b33y8AzmRkRiJORcA7avsfOoczixSKZpyFA
         N9xB/F2mxjP1d5I+7d+DxQQLmJw7zdN6wuKgDsC2ldA5jYkQGaFaqiZm3ZqVaT9C1OIm
         mE6jPOKcX1Lkjni3+HTpGOhA5yelp9TKnpPc+w4MVDDqijpIiozHR8PL6mPM9Temb2y2
         c3jEq5gly2lGFkVgiFmzXbzk4Tu5nFMIGm7iw8c0RAvrmPfjD1ZDieeClHLj9DC0P3Wl
         tMFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXQxDF+JBPeLs2Oe+NR3IXxpcmIF9V/tGIJYYW7+fYKRz7GOKDg
	gfdEqFhgGl4Bsn8Mt1ELicAb1omBlbHULhvH1X0iWTs4Rzg/W305a1/A2Ve+SC5Bb3MF0VOHjvu
	FXO+HdqVQTwH8rJGHwXb55zlA3gCKDxrlI/O9iNmNHFuv1enNm44pdwFDbqKPos/4Cg==
X-Received: by 2002:aed:2fe6:: with SMTP id m93mr37879933qtd.114.1564149651626;
        Fri, 26 Jul 2019 07:00:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1Sd9sAoo5hUiRKSCSnj8oh70rrVkG8fGynoAWEGqVQDP57Bh6pf+mSf/QZyYXWf/G3LKU
X-Received: by 2002:aed:2fe6:: with SMTP id m93mr37879812qtd.114.1564149650414;
        Fri, 26 Jul 2019 07:00:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564149650; cv=none;
        d=google.com; s=arc-20160816;
        b=ZTwXgPEvwpaGqjBd3uzkuI5CbxtQbNy8f0jtnhdnkcY9JyHK90UF8vHxm/XQXBkm7Q
         eLgmfkvG1Bvvni6c3fxFbMI4FSLZwvvlNQEh/4Dx37qmIxpHlfVw1Gi6B8JzmXvDAS/9
         jrP2Z8v+5DgbPqyqWC3N4KctbQNtGckRbQwIehI4I9NN44dKs7+A05Sr/o7cCm9801mW
         IsyB0BQAxuJ86VeoepijAnkUveCIKe/5AH/ETzTJMjNcOHAObcA9hm28p7zwwr70mTNn
         HRD77C6IwB4AbFqlXYoG2me/usAahQhujz5gWE1P3Ae5nVxfRfib9w7s0muKH1Z+JNhj
         5uWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=stcUXmd1EWMweb01P1UeC7yCi2kg8YuWNOzdoxvJgRU=;
        b=R3BeQWKKnmp+KdPGGHnKI5M6YAMMYORWRn2K9MzV434TBXXVhnbo0XcGgUARkE8Fdh
         Rqr1E4Qwr60Xq317atzwha7KsG/2I5URcV23rftjBxGUry6hCve8C7Np9BSZxtw+MN3u
         GnBYD5tRxYl00XOIEq9x77HsmNXER5wbQV/Iss85goP3G8cjobiZ+QCuxiuNF05g3pPk
         /WpzTWgd/7infXWwqxX1qbFVTN/WyVT/tssk38Vr1Kq/xM/SkUKaw6VCAq95lMIuyB7V
         Sc5FlkAsqtQ8E2b9P8LMj/FzBS17ULJXQoHbx7xFMiroG4M89APhfj5UqWD0ODvg2h9c
         c2Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q39si34566109qtk.284.2019.07.26.07.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 07:00:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 07A33C059B6F;
	Fri, 26 Jul 2019 14:00:49 +0000 (UTC)
Received: from [10.72.12.238] (ovpn-12-238.pek2.redhat.com [10.72.12.238])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 894BC6062E;
	Fri, 26 Jul 2019 14:00:22 +0000 (UTC)
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
References: <20190725012149-mutt-send-email-mst@kernel.org>
 <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <20190726094353-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <63754251-a39a-1e0e-952d-658102682094@redhat.com>
Date: Fri, 26 Jul 2019 22:00:20 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190726094353-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Fri, 26 Jul 2019 14:00:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/26 下午9:47, Michael S. Tsirkin wrote:
> On Fri, Jul 26, 2019 at 08:53:18PM +0800, Jason Wang wrote:
>> On 2019/7/26 下午8:38, Michael S. Tsirkin wrote:
>>> On Fri, Jul 26, 2019 at 08:00:58PM +0800, Jason Wang wrote:
>>>> On 2019/7/26 下午7:49, Michael S. Tsirkin wrote:
>>>>> On Thu, Jul 25, 2019 at 10:25:25PM +0800, Jason Wang wrote:
>>>>>> On 2019/7/25 下午9:26, Michael S. Tsirkin wrote:
>>>>>>>> Exactly, and that's the reason actually I use synchronize_rcu() there.
>>>>>>>>
>>>>>>>> So the concern is still the possible synchronize_expedited()?
>>>>>>> I think synchronize_srcu_expedited.
>>>>>>>
>>>>>>> synchronize_expedited sends lots of IPI and is bad for realtime VMs.
>>>>>>>
>>>>>>>> Can I do this
>>>>>>>> on through another series on top of the incoming V2?
>>>>>>>>
>>>>>>>> Thanks
>>>>>>>>
>>>>>>> The question is this: is this still a gain if we switch to the
>>>>>>> more expensive srcu? If yes then we can keep the feature on,
>>>>>> I think we only care about the cost on srcu_read_lock() which looks pretty
>>>>>> tiny form my point of view. Which is basically a READ_ONCE() + WRITE_ONCE().
>>>>>>
>>>>>> Of course I can benchmark to see the difference.
>>>>>>
>>>>>>
>>>>>>> if not we'll put it off until next release and think
>>>>>>> of better solutions. rcu->srcu is just a find and replace,
>>>>>>> don't see why we need to defer that. can be a separate patch
>>>>>>> for sure, but we need to know how well it works.
>>>>>> I think I get here, let me try to do that in V2 and let's see the numbers.
>>>>>>
>>>>>> Thanks
>>>> It looks to me for tree rcu, its srcu_read_lock() have a mb() which is too
>>>> expensive for us.
>>> I will try to ponder using vq lock in some way.
>>> Maybe with trylock somehow ...
>>
>> Ok, let me retry if necessary (but I do remember I end up with deadlocks
>> last try).
>>
>>
>>>
>>>> If we just worry about the IPI,
>>> With synchronize_rcu what I would worry about is that guest is stalled
>>
>> Can this synchronize_rcu() be triggered by guest? If yes, there are several
>> other MMU notifiers that can block. Is vhost something special here?
> Sorry, let me explain: guests (and tasks in general)
> can trigger activity that will
> make synchronize_rcu take a long time.


Yes, I get this.


>   Thus blocking
> an mmu notifier until synchronize_rcu finishes
> is a bad idea.


The question is, MMU notifier are allowed to be blocked on 
invalidate_range_start() which could be much slower than 
synchronize_rcu() to finish.

Looking at amdgpu_mn_invalidate_range_start_gfx() which calls 
amdgpu_mn_invalidate_node() which did:

                 r = reservation_object_wait_timeout_rcu(bo->tbo.resv,
                         true, false, MAX_SCHEDULE_TIMEOUT);

...


>>> because system is busy because of other guests.
>>> With expedited it's the IPIs...
>>>
>> The current synchronize_rcu()  can force a expedited grace period:
>>
>> void synchronize_rcu(void)
>> {
>>          ...
>>          if (rcu_blocking_is_gp())
>> return;
>>          if (rcu_gp_is_expedited())
>> synchronize_rcu_expedited();
>> else
>> wait_rcu_gp(call_rcu);
>> }
>> EXPORT_SYMBOL_GPL(synchronize_rcu);
>
> An admin can force rcu to finish faster, trading
> interrupts for responsiveness.


Yes, so when set, all each synchronize_rcu() will go for 
synchronize_rcu_expedited().


>
>>>> can we do something like in
>>>> vhost_invalidate_vq_start()?
>>>>
>>>>           if (map) {
>>>>                   /* In order to avoid possible IPIs with
>>>>                    * synchronize_rcu_expedited() we use call_rcu() +
>>>>                    * completion.
>>>> */
>>>> init_completion(&c.completion);
>>>>                   call_rcu(&c.rcu_head, vhost_finish_vq_invalidation);
>>>> wait_for_completion(&c.completion);
>>>>                   vhost_set_map_dirty(vq, map, index);
>>>> vhost_map_unprefetch(map);
>>>>           }
>>>>
>>>> ?
>>> Why would that be faster than synchronize_rcu?
>>
>> No faster but no IPI.
>>
> Sorry I still don't see the point.
> synchronize_rcu doesn't normally do an IPI either.
>

Not the case of when rcu_expedited is set. This can just 100% make sure 
there's no IPI.


>>>
>>>>> There's one other thing that bothers me, and that is that
>>>>> for large rings which are not physically contiguous
>>>>> we don't implement the optimization.
>>>>>
>>>>> For sure, that can wait, but I think eventually we should
>>>>> vmap large rings.
>>>> Yes, worth to try. But using direct map has its own advantage: it can use
>>>> hugepage that vmap can't
>>>>
>>>> Thanks
>>> Sure, so we can do that for small rings.
>>
>> Yes, that's possible but should be done on top.
>>
>> Thanks
> Absolutely. Need to fix up the bugs first.
>

Yes.

Thanks

