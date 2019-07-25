Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 621EBC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26424218F0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:22:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26424218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B10238E0075; Thu, 25 Jul 2019 09:21:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC0BB8E0059; Thu, 25 Jul 2019 09:21:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AE908E0075; Thu, 25 Jul 2019 09:21:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF868E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:21:59 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so44371239qte.8
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:21:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=VBKcWmuL2Fup4lxL5nKm5DsLWVTA7Z+tnul0Qcp4YBg=;
        b=Z+x3Cexu4I39nwGZSFyqtKFhZ7ymx6RaS3N/wjl+kVd0OSjCXNDRmhNujnxSrXBFsE
         cmjm0+3tnyg1GCxvqJl3NSic1wP542PbWCZdA+QNLBbEQjhs1KL0QcZpfbnuSgDQqLxT
         MLdjwp4Vs2COHGNVLA2I3KBrpEtsUdIjc321DUKazqU8YtmZ1UR7jF68dR4WeOPH0b2Z
         aXl1H5dcF992gyaq11IkU9596FOv5Daht4BhUCqCyf7Yu3nM8ToPYVQcZ+e8j3hxNrBV
         UxHzQrG7DR+DS6uMK5KzIwCydaECD6pFKgemEV2xJy9EGNegpUlcYlaVoz0j1PG1Zp+5
         psgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWTyS0aA4lpUy5OzIDiObgn6lU4esIHthsDyaQ4mMPC3O9fQwFv
	MY7yUiyUoaNmzIxxsKtTFxzZdsy+a7Jm/MRXq+y0oj+WsFp742JbWzQQ4PCNqpVQACr3C6628Ds
	/D6W6TCiFIpGxDAwu3PuEIwNLiMKc0RIi7w0AAkwbBmpsE/WrfWiQmDwYBRTbq5aJyg==
X-Received: by 2002:ac8:6c59:: with SMTP id z25mr65339597qtu.43.1564060919228;
        Thu, 25 Jul 2019 06:21:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyv8eO3Oi/pdnfGuVBiUzOlTQCa5wSlGnmJvGEh/ea4ne8pp7PS0OLrfYv/m66WCh3Y89VM
X-Received: by 2002:ac8:6c59:: with SMTP id z25mr65339538qtu.43.1564060918535;
        Thu, 25 Jul 2019 06:21:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564060918; cv=none;
        d=google.com; s=arc-20160816;
        b=ZxkpPzMcylh6WbRbLVLGJI9ff+JYEkHkvsGOZJbDGWk8gtTnrX244oYes2uLukfq6j
         u8SpQPDyFkfdVtIWJ0bfBusEU9SHOhL6pRIHC1YHJTSNUNlNdC2QnbcrNU6GoZTAw4e3
         zLjkngQ7PJKTV548wBxtYhiSm7jVMKw4i2TsacFYilREyR24T5jrmPvZMBMf/lYOHc0B
         tPF4ztY5YCazFoWU6Q+ccDyiDnvjmXHlFa/buYecb10qH4iLBy26s4o3n2Ez17bUPx0a
         ssLyvjjXXGwutTZf9ZzQItfkgIaQH0bz9dlbaIepJAjtStnZ13aMzmEmgtQHkFjuJQV4
         3uBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=VBKcWmuL2Fup4lxL5nKm5DsLWVTA7Z+tnul0Qcp4YBg=;
        b=pK2USe6UykYCh5Ja8oCJcYnOf+iNMF2CmNQyT/dM/wbWFLnWpxYyL8plY2kEjTZoBK
         Iwt3/0cRwUeqqx2vHjUG8FWLBuMqzIkGpZfvzXREW6GcCr4EUkA1xaePHetxXvJneF9w
         S785F8UyZMhxSlgPf3ZjeiobUUatj//nVtbBe5an932CxLGHlxVqZ8vC5pdiFGWeoWpm
         jlZnVY6F8+Z1BiSv3Wm+LbAIgegsYwQX2aglNJIRJWWzob9pO9ocW5RAbTJ3hfsEDP0v
         bFozzpvMp8V19dBiDjzXbnjUdLRFt2KckZ0RdoEET0gPk0msGDQVidAEfDhh6qnZkKsB
         AN+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 46si32322883qtw.234.2019.07.25.06.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 06:21:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3513730860BE;
	Thu, 25 Jul 2019 13:21:57 +0000 (UTC)
Received: from [10.72.12.18] (ovpn-12-18.pek2.redhat.com [10.72.12.18])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A59BD19723;
	Thu, 25 Jul 2019 13:21:44 +0000 (UTC)
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
References: <20190723010019-mutt-send-email-mst@kernel.org>
 <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
 <20190723032024-mutt-send-email-mst@kernel.org>
 <1d14de4d-0133-1614-9f64-3ded381de04e@redhat.com>
 <20190723035725-mutt-send-email-mst@kernel.org>
 <3f4178f1-0d71-e032-0f1f-802428ceca59@redhat.com>
 <20190723051828-mutt-send-email-mst@kernel.org>
 <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
 <20190725012149-mutt-send-email-mst@kernel.org>
 <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
Date: Thu, 25 Jul 2019 21:21:22 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190725042651-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 25 Jul 2019 13:21:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/25 下午4:28, Michael S. Tsirkin wrote:
> On Thu, Jul 25, 2019 at 03:43:41PM +0800, Jason Wang wrote:
>> On 2019/7/25 下午1:52, Michael S. Tsirkin wrote:
>>> On Tue, Jul 23, 2019 at 09:31:35PM +0800, Jason Wang wrote:
>>>> On 2019/7/23 下午5:26, Michael S. Tsirkin wrote:
>>>>> On Tue, Jul 23, 2019 at 04:49:01PM +0800, Jason Wang wrote:
>>>>>> On 2019/7/23 下午4:10, Michael S. Tsirkin wrote:
>>>>>>> On Tue, Jul 23, 2019 at 03:53:06PM +0800, Jason Wang wrote:
>>>>>>>> On 2019/7/23 下午3:23, Michael S. Tsirkin wrote:
>>>>>>>>>>> Really let's just use kfree_rcu. It's way cleaner: fire and forget.
>>>>>>>>>> Looks not, you need rate limit the fire as you've figured out?
>>>>>>>>> See the discussion that followed. Basically no, it's good enough
>>>>>>>>> already and is only going to be better.
>>>>>>>>>
>>>>>>>>>> And in fact,
>>>>>>>>>> the synchronization is not even needed, does it help if I leave a comment to
>>>>>>>>>> explain?
>>>>>>>>> Let's try to figure it out in the mail first. I'm pretty sure the
>>>>>>>>> current logic is wrong.
>>>>>>>> Here is what the code what to achieve:
>>>>>>>>
>>>>>>>> - The map was protected by RCU
>>>>>>>>
>>>>>>>> - Writers are: MMU notifier invalidation callbacks, file operations (ioctls
>>>>>>>> etc), meta_prefetch (datapath)
>>>>>>>>
>>>>>>>> - Readers are: memory accessor
>>>>>>>>
>>>>>>>> Writer are synchronized through mmu_lock. RCU is used to synchronized
>>>>>>>> between writers and readers.
>>>>>>>>
>>>>>>>> The synchronize_rcu() in vhost_reset_vq_maps() was used to synchronized it
>>>>>>>> with readers (memory accessors) in the path of file operations. But in this
>>>>>>>> case, vq->mutex was already held, this means it has been serialized with
>>>>>>>> memory accessor. That's why I think it could be removed safely.
>>>>>>>>
>>>>>>>> Anything I miss here?
>>>>>>>>
>>>>>>> So invalidate callbacks need to reset the map, and they do
>>>>>>> not have vq mutex. How can they do this and free
>>>>>>> the map safely? They need synchronize_rcu or kfree_rcu right?
>>>>>> Invalidation callbacks need but file operations (e.g ioctl) not.
>>>>>>
>>>>>>
>>>>>>> And I worry somewhat that synchronize_rcu in an MMU notifier
>>>>>>> is a problem, MMU notifiers are supposed to be quick:
>>>>>> Looks not, since it can allow to be blocked and lots of driver depends on
>>>>>> this. (E.g mmu_notifier_range_blockable()).
>>>>> Right, they can block. So why don't we take a VQ mutex and be
>>>>> done with it then? No RCU tricks.
>>>> This is how I want to go with RFC and V1. But I end up with deadlock between
>>>> vq locks and some MM internal locks. So I decide to use RCU which is 100%
>>>> under the control of vhost.
>>>>
>>>> Thanks
>>> And I guess the deadlock is because GUP is taking mmu locks which are
>>> taken on mmu notifier path, right?
>>
>> Yes, but it's not the only lock. I don't remember the details, but I can
>> confirm I meet issues with one or two other locks.
>>
>>
>>>     How about we add a seqlock and take
>>> that in invalidate callbacks?  We can then drop the VQ lock before GUP,
>>> and take it again immediately after.
>>>
>>> something like
>>> 	if (!vq_meta_mapped(vq)) {
>>> 		vq_meta_setup(&uaddrs);
>>> 		mutex_unlock(vq->mutex)
>>> 		vq_meta_map(&uaddrs);
>>
>> The problem is the vq address could be changed at this time.
>>
>>
>>> 		mutex_lock(vq->mutex)
>>>
>>> 		/* recheck both sock->private_data and seqlock count. */
>>> 		if changed - bail out
>>> 	}
>>>
>>> And also requires that VQ uaddrs is defined like this:
>>> - writers must have both vq mutex and dev mutex
>>> - readers must have either vq mutex or dev mutex
>>>
>>>
>>> That's a big change though. For now, how about switching to a per-vq SRCU?
>>> That is only a little bit more expensive than RCU, and we
>>> can use synchronize_srcu_expedited.
>>>
>> Consider we switch to use kfree_rcu(), what's the advantage of per-vq SRCU?
>>
>> Thanks
>
> I thought we established that notifiers must wait for
> all readers to finish before they mark page dirty, to
> prevent page from becoming dirty after address
> has been invalidated.
> Right?


Exactly, and that's the reason actually I use synchronize_rcu() there.

So the concern is still the possible synchronize_expedited()? Can I do 
this on through another series on top of the incoming V2?

Thanks


