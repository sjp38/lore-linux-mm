Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70200C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:36:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3198C22ADA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:36:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3198C22ADA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A77BF6B0006; Fri, 26 Jul 2019 09:36:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A27ED8E0003; Fri, 26 Jul 2019 09:36:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9152A8E0002; Fri, 26 Jul 2019 09:36:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEE26B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:36:38 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id h198so45242599qke.1
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:36:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=n5O9TO1jjMv1k00tmXn4UHHvBqHMH/0wMqk/wrvT5ng=;
        b=SQUWNLOZc54ZWW7Vgqd88M3fgK2vpfErRBdhCwvHSsKGArGO09LM9EbG27N7iIC1xl
         zc8R0OozBB1LspD05so34pLfDoK5sfjdudRciIOR2JqgijZAqozHvQMvGwrTFuaDwEBJ
         5OvJPpnIGmll6vxhJN1Cfju+JdJe9TFMWTE0knPN8FfN4hFMkzkAQSMXAn+wPkIf55i1
         pfgbiJzQ3/81b9VLqPBpcjN4rdlaTFlkaYJgWlivnfsl0ZJXnAYhWzo2HCLy/5nHD7sO
         4+wdbDieBp9ofuwraWYukOPPbhHS6wgQE/Wb5nmNiUMx/8mtOkFVSoEQKigwGocdYzM5
         3D6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXKj4QBwYJLLCXPNEPPfoMu4yhoFz9PacHROHwtl8KUp7EYei32
	ks2BfSRUvBO6uC27TH8GhV1newCb/O5HO82XbwjruBiL/G4qqSZv9Imo7GR/NG8Wu+pbRE4iaIf
	njczgFabOyJ41sEKbcp5jeRIk2JqGjp1eLWF2ys3sv7My7RGDgHIr/6hlaNfGuvAaxQ==
X-Received: by 2002:a0c:81f0:: with SMTP id 45mr69519692qve.13.1564148198189;
        Fri, 26 Jul 2019 06:36:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLdF/B/diBclVxniek4DurV9n4IszYnvCJbkZHEeBSq+3gJabI33gARpF/46btVMowhH8H
X-Received: by 2002:a0c:81f0:: with SMTP id 45mr69519607qve.13.1564148196938;
        Fri, 26 Jul 2019 06:36:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148196; cv=none;
        d=google.com; s=arc-20160816;
        b=UbqWNU6LYI4G0R6NJTB9FTvV1lK36hc3t83qN/HnhH5LNdC00AWTDSW6eRWAc8+CoZ
         uNOIpB2w3BI34ZAsgQ3Uv5BfHUyv9jjiXFpnNKPfzhd/mPpTn+Eqv7Ad6Dkv/4K7CaNb
         sAd1E008v+EG+kZ4V7sJWQRhzYsIKBnoI/3dU4MwIw8kcCOXyUFADg0e3eF5W+PTAlAQ
         ULPUPp99/PQNCGNGv6HuuQO/BMmjjPseOtNdkPmIA3fnvawe6WcuZ8FEuKPJvU7zbRgb
         RneGr4lXiM9CuGGKbk36Rc1qCrN64j9I0b62fYxlyV7D4FYDx2kX2Blp8+Vhhho26U7I
         F8JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=n5O9TO1jjMv1k00tmXn4UHHvBqHMH/0wMqk/wrvT5ng=;
        b=ftNDo6US5QvDugDJgX2dQgE5ieYZqj7EHvNMN+/mjwGZFmOBbj5oHNkqWyaJQmEYD0
         Sox3gwXuG4K9rEoKgh4GJE4ONq/DefBGVfQ88DU6l6i9Df3jxDWwJ/PAaPZE0sv32uMm
         v93Y7KnyLRDC8p6icX26S/ZYkgkoMudUPukxwRUVgaYMmGkx0g537C+z6lLErcAGTOuL
         8aOtvL+xYmJUkIa29o5NRYjCD3APbfJWDSbMor6nP3QrlecAjZgDw/Xjj2YJmY2uL8Mn
         vvc8ggfQFUCslItUn7QJH7A/U4tbWjEyH2lvK+Ap1zMWQ796/FodjvzkHleyNBZC5/Wa
         RbaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 67si32518337qki.250.2019.07.26.06.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:36:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1DB4846671;
	Fri, 26 Jul 2019 13:36:35 +0000 (UTC)
Received: from [10.72.12.238] (ovpn-12-238.pek2.redhat.com [10.72.12.238])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0A8B06A238;
	Fri, 26 Jul 2019 13:36:19 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
From: Jason Wang <jasowang@redhat.com>
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
References: <20190723051828-mutt-send-email-mst@kernel.org>
 <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
 <20190725012149-mutt-send-email-mst@kernel.org>
 <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
Message-ID: <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
Date: Fri, 26 Jul 2019 21:36:18 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Fri, 26 Jul 2019 13:36:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/26 下午8:53, Jason Wang wrote:
>
> On 2019/7/26 下午8:38, Michael S. Tsirkin wrote:
>> On Fri, Jul 26, 2019 at 08:00:58PM +0800, Jason Wang wrote:
>>> On 2019/7/26 下午7:49, Michael S. Tsirkin wrote:
>>>> On Thu, Jul 25, 2019 at 10:25:25PM +0800, Jason Wang wrote:
>>>>> On 2019/7/25 下午9:26, Michael S. Tsirkin wrote:
>>>>>>> Exactly, and that's the reason actually I use synchronize_rcu() 
>>>>>>> there.
>>>>>>>
>>>>>>> So the concern is still the possible synchronize_expedited()?
>>>>>> I think synchronize_srcu_expedited.
>>>>>>
>>>>>> synchronize_expedited sends lots of IPI and is bad for realtime VMs.
>>>>>>
>>>>>>> Can I do this
>>>>>>> on through another series on top of the incoming V2?
>>>>>>>
>>>>>>> Thanks
>>>>>>>
>>>>>> The question is this: is this still a gain if we switch to the
>>>>>> more expensive srcu? If yes then we can keep the feature on,
>>>>> I think we only care about the cost on srcu_read_lock() which 
>>>>> looks pretty
>>>>> tiny form my point of view. Which is basically a READ_ONCE() + 
>>>>> WRITE_ONCE().
>>>>>
>>>>> Of course I can benchmark to see the difference.
>>>>>
>>>>>
>>>>>> if not we'll put it off until next release and think
>>>>>> of better solutions. rcu->srcu is just a find and replace,
>>>>>> don't see why we need to defer that. can be a separate patch
>>>>>> for sure, but we need to know how well it works.
>>>>> I think I get here, let me try to do that in V2 and let's see the 
>>>>> numbers.
>>>>>
>>>>> Thanks
>>>
>>> It looks to me for tree rcu, its srcu_read_lock() have a mb() which 
>>> is too
>>> expensive for us.
>> I will try to ponder using vq lock in some way.
>> Maybe with trylock somehow ...
>
>
> Ok, let me retry if necessary (but I do remember I end up with 
> deadlocks last try). 


Ok, I play a little with this. And it works so far. Will do more testing 
tomorrow.

One reason could be I switch to use get_user_pages_fast() to 
__get_user_pages_fast() which doesn't need mmap_sem.

Thanks

