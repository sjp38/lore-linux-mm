Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC87EC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:24:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CB322067D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:24:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CB322067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 274FA6B0003; Mon,  5 Aug 2019 04:24:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FE916B0005; Mon,  5 Aug 2019 04:24:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C70F6B0006; Mon,  5 Aug 2019 04:24:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id DABCD6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 04:24:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l16so68308532qtq.16
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 01:24:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=tGNgfIjx7s4Bi+x51evZvWWhhV+RcWd4cSHvcGzYnQs=;
        b=gxbOdqO6f0xDBt6nJ8xRxXCb058IjuADT/WxQye0P3cqWMeytWjOZsYIMt2ILtsKyq
         mYP7n7LidEBR/r92gbCeK45hWoVW5+kJO31QJF4EvZIoRHV+ve+0h8EvLFgjno6Z9UeJ
         sojljTTZb9ec7j1D/4aW5367BsFz+JjGAjpP8Z3tIAjU4S9cHX3MQRNX4LO4o2Kk3V08
         OlFva+Rw/Efj1PqnHqSQbbuf1wlWYht1hYe7OZ5vta2NHrurD5/bQbKQEAA8/S6X8i1/
         bXG2Kz78KawA0YVXmSc+e3kU2v891O8yGF4uRQjbN/IR8FEB6Pnw66Ao/nNE/kiB9hW3
         4Bww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXCwzGOzofYso6Zc7FN+XZNKZ4BeEOofPtUtCm34FobX2HOK8ro
	Xv2/peBxx6XlD3yhOX2IK4/MM8ZkYkNHmCM32wu+kIFzEOtRA4XSiR/eqGMw6qivYweUjxGD4jA
	WGskCltG41Jp+zqkWH/9zeOozXOHOIkhJIFkSysqPVQqr2y9pUSS5141Roc17ZN59IQ==
X-Received: by 2002:a0c:c382:: with SMTP id o2mr70316521qvi.75.1564993474669;
        Mon, 05 Aug 2019 01:24:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzV0+3Rt3gN4gS5ChhA4xHJGS6tGa+IKNJ/6y6r/hEbmYdO/YN9pkL/sHDiv2fhC0ehGtNo
X-Received: by 2002:a0c:c382:: with SMTP id o2mr70316496qvi.75.1564993474109;
        Mon, 05 Aug 2019 01:24:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564993474; cv=none;
        d=google.com; s=arc-20160816;
        b=NMLDETgkBpPwodTRX3gUvqts3sRDc8FFbsiqgUj8dh+3Llmb38WOtbW2O8VY08pJKc
         q5mlslIABBufh7hIlervfUnwQ/7ShT0wMPp549WQM5xcEINue2WE7ec13iTJe8lvg18N
         ZfHrwsUAHHxT78tlrjQFH5cCBuie96VC/9+Cjp8bpfxwCk1AwWp06LGL/ZLARMm81vEw
         kbxIUlm+82t3920AiACNYzgJ/ne20aOru/iIc0jdVC0xAA/XPEm13jRLwBu1AWLhyqjF
         +Ys0L4Gemah9C9YSnaB6ckDgWVs5lukeiAL2TaRGx2+GqfcYuttbsraZ+3citsbvowl1
         PDjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=tGNgfIjx7s4Bi+x51evZvWWhhV+RcWd4cSHvcGzYnQs=;
        b=LAw1L0ZzPqb94M9z1MPWNJD8RO9Fc2sM47ZyZKEyUuzEM0+/Asb8WRZs+/7H3L2m/1
         2FnYOJr5mkin8YYCvu7DvdrgKUNxI98ZQDpbRvn2e6mIfBk8GZ3Jd3JR36Fe7oPWHN+d
         Lha9+Eg1GYfHCZHs94u+KV2zbCVCM4B7riaCx9Zaaqcw1vzxBH3c7I6pez1I6Wn2OAEV
         PicOgVAGHdvMjunPGY0kFo3x73h4opCQcoLIPOYtftohWqgopZonqfY/oc3cVA4SeTsq
         7Er8UlOwNdo1E3KnqTg5Fjrzi+NgA0CePkgkpxXTawnP2KmGQIl2NalbDx5DQSc8I3Lj
         s/pw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i46si52132482qte.104.2019.08.05.01.24.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 01:24:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5938630923D0;
	Mon,  5 Aug 2019 08:24:33 +0000 (UTC)
Received: from [10.72.12.115] (ovpn-12-115.pek2.redhat.com [10.72.12.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9AC761000323;
	Mon,  5 Aug 2019 08:24:28 +0000 (UTC)
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, linux-mm@kvack.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org
References: <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <e8ecb811-6653-cff4-bc11-81f4ccb0dbbf@redhat.com>
 <494ac30d-b750-52c8-b927-16cd4b9414c4@redhat.com>
 <20190805023106-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <86444f93-e507-cfd9-598b-51466bb02354@redhat.com>
Date: Mon, 5 Aug 2019 16:24:27 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190805023106-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 05 Aug 2019 08:24:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/5 下午2:40, Michael S. Tsirkin wrote:
> On Mon, Aug 05, 2019 at 12:41:45PM +0800, Jason Wang wrote:
>> On 2019/8/5 下午12:36, Jason Wang wrote:
>>> On 2019/8/2 下午10:27, Michael S. Tsirkin wrote:
>>>> On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
>>>>> On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
>>>>>>> This must be a proper barrier, like a spinlock, mutex, or
>>>>>>> synchronize_rcu.
>>>>>> I start with synchronize_rcu() but both you and Michael raise some
>>>>>> concern.
>>>>> I've also idly wondered if calling synchronize_rcu() under the various
>>>>> mm locks is a deadlock situation.
>>>>>
>>>>>> Then I try spinlock and mutex:
>>>>>>
>>>>>> 1) spinlock: add lots of overhead on datapath, this leads 0
>>>>>> performance
>>>>>> improvement.
>>>>> I think the topic here is correctness not performance improvement
>>>> The topic is whether we should revert
>>>> commit 7f466032dc9 ("vhost: access vq metadata through kernel
>>>> virtual address")
>>>>
>>>> or keep it in. The only reason to keep it is performance.
>>>
>>> Maybe it's time to introduce the config option?
>>
>> Or does it make sense if I post a V3 with:
>>
>> - introduce config option and disable the optimization by default
>>
>> - switch from synchronize_rcu() to vhost_flush_work(), but the rest are the
>> same
>>
>> This can give us some breath to decide which way should go for next release?
>>
>> Thanks
> As is, with preempt enabled?  Nope I don't think blocking an invalidator
> on swap IO is ok, so I don't believe this stuff is going into this
> release at this point.
>
> So it's more a question of whether it's better to revert and apply a clean
> patch on top, or just keep the code around but disabled with an ifdef as is.
> I'm open to both options, and would like your opinion on this.


Then I prefer to leave current code (VHOST_ARCH_CAN_ACCEL to 0) as is. 
This can also save efforts on rebasing packed virtqueues.

Thanks


>
>>>
>>>> Now as long as all this code is disabled anyway, we can experiment a
>>>> bit.
>>>>
>>>> I personally feel we would be best served by having two code paths:
>>>>
>>>> - Access to VM memory directly mapped into kernel
>>>> - Access to userspace
>>>>
>>>>
>>>> Having it all cleanly split will allow a bunch of optimizations, for
>>>> example for years now we planned to be able to process an incoming short
>>>> packet directly on softirq path, or an outgoing on directly within
>>>> eventfd.
>>>
>>> It's not hard consider we've already had our own accssors. But the
>>> question is (as asked in another thread), do you want permanent GUP or
>>> still use MMU notifiers.
>>>
>>> Thanks
>>>
>>> _______________________________________________
>>> Virtualization mailing list
>>> Virtualization@lists.linux-foundation.org
>>> https://lists.linuxfoundation.org/mailman/listinfo/virtualization

