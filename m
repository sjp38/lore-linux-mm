Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8B05C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:49:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A38B208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:49:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A38B208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 468A78E0005; Wed, 31 Jul 2019 04:49:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 440408E0001; Wed, 31 Jul 2019 04:49:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3569D8E0005; Wed, 31 Jul 2019 04:49:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15B618E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:49:49 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x1so57374990qkn.6
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:49:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=QSA+17r4oFLds0nVoVfeS0QmlJIaCOu3r1tGBRHQwcU=;
        b=ZyhU+AK9VjqOu25VmhJzaNPkwaWZCGRjHWcGQvcIprYut8MZns6/i/ClalkzzZwMju
         t9E6gP17mgqcNn6uZ1hkvA5ZySL43cHB2dl36KbK8zcoFc3aOfa9z6oF25oy39TnZxin
         DuN0XvORks5nTBFJe+G/pP9Gq1Wa+4bIn/Gk6NtIP7LnX2Q1KQ99fnNyhuxY2RCcS6tf
         bm947je+AKqOaO2VE776y6oA1Mp6c+qv5IqN81WBtIMNKvA1CgxyaS4ZvV71c7uO8yQW
         wDYNbpH6z0dK/KnOz5oqzBV00A7ZxNpzwSlX7BZRR7fF54AIuJf86Uo6xXhBMikEvj0j
         Eclw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVTPTCvz/NHWicVB+55MilxTmsr0qJS4rnyRuRuccPTdwul6iRq
	AXKVzt9uFoK37eXUyXwrDFdcvNe9aG+MiBtW4tqKxfJ8WvPhUjKbxtTircWc1UN2yzMWU5cr7Ma
	Rd/awzVRJBx1oicMIEW6w7N7LilEN4oS6tmlrkj2yHn7Bv+JdUwtVMKqGVLQ7/9Ogyg==
X-Received: by 2002:ac8:7383:: with SMTP id t3mr64462960qtp.156.1564562988833;
        Wed, 31 Jul 2019 01:49:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrLyGP7EGXYQTZOWc/c6qFbGUuiPZKOaDEEwEty78znCIUiNO9SH8TfvGv3ybZC0q3hb7B
X-Received: by 2002:ac8:7383:: with SMTP id t3mr64462922qtp.156.1564562987890;
        Wed, 31 Jul 2019 01:49:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564562987; cv=none;
        d=google.com; s=arc-20160816;
        b=TS5e4WVnuAs5/CjnYlr7Fw3A67JTEaW7snAfKRGiXlPI3ViZoGoEWfuRFZS4y4F3VR
         o7LCjvD+oOdoIz5+T56Ooy8Y1oNtxd2A7UNGyxId6ZGjiCcR4dIZQf3CNi++ITloZuGw
         qQFMU+wGMKZ51AT4KiQqZjR0MCy0jyqTBg7lATCz7e2mwjOpzytaVuy9vGRQSfJ1LOkU
         +uG66ZpoPJKyoRCMR8ANsnPeo8bpumJUbbUdTIzbhzOhjo5oIM7bezTx2eAuzkEy1xK6
         EcrYYKzODHOJs0VCO/EYBIvr2DBQuEroyQlRBX/UY2MYs1xo12G1i7zpSEnTcOuCy3sb
         wDdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QSA+17r4oFLds0nVoVfeS0QmlJIaCOu3r1tGBRHQwcU=;
        b=nMTOYFB7jSZlInUhlGuz3S2rG12/qjEU23r+2FRu24qeonbLjhABz5I+o1eU3K/xfv
         IogWul+ddyc3yizyp3eibWaLx050MfVB1crdXhPX3JmM00xJkiORfMagBdz0h29seZWd
         2CwrvtsW6kXdFcdIX51DzW4OaFh1ew8chrCfvE5SRZq161Hn29qyPMils2kIJGiI8LzY
         3y/LKPEwDh67pZoe/nSKCBINzSMEWbWrDemgiUFOTKq8IvQNwUfhmtGUTKZ4mcXqVYEA
         UmxbFub3fvy0TP0G8rKjB7vWbuWXd0X6v/v9+01YikJW7ztrL7uIdOqce6ypw/YMbh7a
         gLiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m91si39153529qte.84.2019.07.31.01.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:49:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7ED5D81DF1;
	Wed, 31 Jul 2019 08:49:46 +0000 (UTC)
Received: from [10.72.12.51] (ovpn-12-51.pek2.redhat.com [10.72.12.51])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6DEDA5D9C5;
	Wed, 31 Jul 2019 08:49:34 +0000 (UTC)
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
References: <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
 <20190726094756-mutt-send-email-mst@kernel.org>
 <0792ee09-b4b7-673c-2251-e5e0ce0fbe32@redhat.com>
 <20190729045127-mutt-send-email-mst@kernel.org>
 <4d43c094-44ed-dbac-b863-48fc3d754378@redhat.com>
 <20190729104028-mutt-send-email-mst@kernel.org>
 <96b1d67c-3a8d-1224-e9f0-5f7725a3dc10@redhat.com>
 <20190730110633-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <421a1af6-df06-e4a6-b34f-526ac123bc4a@redhat.com>
Date: Wed, 31 Jul 2019 16:49:32 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190730110633-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 31 Jul 2019 08:49:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/30 下午11:08, Michael S. Tsirkin wrote:
> On Tue, Jul 30, 2019 at 03:44:47PM +0800, Jason Wang wrote:
>> On 2019/7/29 下午10:44, Michael S. Tsirkin wrote:
>>> On Mon, Jul 29, 2019 at 10:24:43PM +0800, Jason Wang wrote:
>>>> On 2019/7/29 下午4:59, Michael S. Tsirkin wrote:
>>>>> On Mon, Jul 29, 2019 at 01:54:49PM +0800, Jason Wang wrote:
>>>>>> On 2019/7/26 下午9:49, Michael S. Tsirkin wrote:
>>>>>>>>> Ok, let me retry if necessary (but I do remember I end up with deadlocks
>>>>>>>>> last try).
>>>>>>>> Ok, I play a little with this. And it works so far. Will do more testing
>>>>>>>> tomorrow.
>>>>>>>>
>>>>>>>> One reason could be I switch to use get_user_pages_fast() to
>>>>>>>> __get_user_pages_fast() which doesn't need mmap_sem.
>>>>>>>>
>>>>>>>> Thanks
>>>>>>> OK that sounds good. If we also set a flag to make
>>>>>>> vhost_exceeds_weight exit, then I think it will be all good.
>>>>>> After some experiments, I came up two methods:
>>>>>>
>>>>>> 1) switch to use vq->mutex, then we must take the vq lock during range
>>>>>> checking (but I don't see obvious slowdown for 16vcpus + 16queues). Setting
>>>>>> flags during weight check should work but it still can't address the worst
>>>>>> case: wait for the page to be swapped in. Is this acceptable?
>>>>>>
>>>>>> 2) using current RCU but replace synchronize_rcu() with vhost_work_flush().
>>>>>> The worst case is the same as 1) but we can check range without holding any
>>>>>> locks.
>>>>>>
>>>>>> Which one did you prefer?
>>>>>>
>>>>>> Thanks
>>>>> I would rather we start with 1 and switch to 2 after we
>>>>> can show some gain.
>>>>>
>>>>> But the worst case needs to be addressed.
>>>> Yes.
>>>>
>>>>
>>>>> How about sending a signal to
>>>>> the vhost thread?  We will need to fix up error handling (I think that
>>>>> at the moment it will error out in that case, handling this as EFAULT -
>>>>> and we don't want to drop packets if we can help it, and surely not
>>>>> enter any error states.  In particular it might be especially tricky if
>>>>> we wrote into userspace memory and are now trying to log the write.
>>>>> I guess we can disable the optimization if log is enabled?).
>>>> This may work but requires a lot of changes.
>>> I agree.
>>>
>>>> And actually it's the price of
>>>> using vq mutex.
>>> Not sure what's meant here.
>>
>> I mean if we use vq mutex, it means the critical section was increased and
>> we need to deal with swapping then.
>>
>>
>>>> Actually, the critical section should be rather small, e.g
>>>> just inside memory accessors.
>>> Also true.
>>>
>>>> I wonder whether or not just do synchronize our self like:
>>>>
>>>> static void inline vhost_inc_vq_ref(struct vhost_virtqueue *vq)
>>>> {
>>>>           int ref = READ_ONCE(vq->ref);
>>>>
>>>>           WRITE_ONCE(vq->ref, ref + 1);
>>>> smp_rmb();
>>>> }
>>>>
>>>> static void inline vhost_dec_vq_ref(struct vhost_virtqueue *vq)
>>>> {
>>>>           int ref = READ_ONCE(vq->ref);
>>>>
>>>> smp_wmb();
>>>>           WRITE_ONCE(vq->ref, ref - 1);
>>>> }
>>>>
>>>> static void inline vhost_wait_for_ref(struct vhost_virtqueue *vq)
>>>> {
>>>>           while (READ_ONCE(vq->ref));
>>>> mb();
>>>> }
>>> Looks good but I'd like to think of a strategy/existing lock that let us
>>> block properly as opposed to spinning, that would be more friendly to
>>> e.g. the realtime patch.
>>
>> Does it make sense to disable preemption in the critical section? Then we
>> don't need to block and we have a deterministic time spent on memory
>> accssors?
> Hmm maybe. I'm getting really nervious at this point - we
> seem to be using every trick in the book.
>

Yes, looking at the synchronization implemented by other MMU notifiers. 
Vhost is even the simplest.


>>>> Or using smp_load_acquire()/smp_store_release() instead?
>>>>
>>>> Thanks
>>> These are cheaper on x86, yes.
>>
>> Will use this.
>>
>> Thanks
>>
>>
> This looks suspiciously like a seqlock though.
> Can that be used somehow?
>

seqlock does not provide a way to synchronize with readers. But I did 
borrow some ideas from seqlock and post a new version.

Please review.

Thanks

