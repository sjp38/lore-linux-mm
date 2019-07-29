Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C465C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:25:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C0AE206DD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:25:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C0AE206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B9268E0006; Mon, 29 Jul 2019 10:25:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 945AE8E0002; Mon, 29 Jul 2019 10:25:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 799108E0006; Mon, 29 Jul 2019 10:25:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 544B58E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:25:01 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id d14so26591318vka.6
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:25:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Dae4/IXxIKvok4ax7clnXozmTE0V8dNaujdRqd/9frk=;
        b=QPrHHGCoxKv0vsAVcSUfk8zaMKWPimdZmumnlhbMTdmoQxCvenWanA6aDngmithQCj
         CRvOzFUd5V6I2/upG5+ewuGM4pBxJBU3hGZHQYGlkGc2aazsiz+VjICHYObvi3vXGJhv
         8cZ2+ACTu/3ERC3FGRnc54REtaXhEn3DGTZbyrENmDQW0kAdTCLR1N935cg1IrufmhNo
         Lcrdfb14dixDzy3Shp1vDZdiMsOW4EadMc65yUJUvfwlSlFqM7xM+3oxK7HTPLH7slEG
         QTA5LMJa1YyueK/gQQc345CjB6LUoobrpvEmi0fv70jdzTH650tZAdhgN3p8ABHr1J3T
         i6HA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU9SjDvlQkJUjMNrmm0vrSYyGTbyX7sszUAcdL+rPkf5oY1XYiS
	+ft8L+TffHhiNCAOXdZCfdv1bY18ZBz9OdMGz3i0czECTwaOoSaxqvyJmlNL6BfS/QviP8g+EfV
	zufFfB2w6Tie77PAb9TayrgEiExYAx4MJEa5SEPaMxz4TwiQZIrM5z2mBbxqt/FThPQ==
X-Received: by 2002:a1f:5945:: with SMTP id n66mr41209737vkb.58.1564410300966;
        Mon, 29 Jul 2019 07:25:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGFsCQVb7ICcMJC8Ls6GignYlZODl5tPFY5ZssmCZsdMrYzBMHVwPpNOTxxoI5+oIa7RDW
X-Received: by 2002:a1f:5945:: with SMTP id n66mr41209654vkb.58.1564410299993;
        Mon, 29 Jul 2019 07:24:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410299; cv=none;
        d=google.com; s=arc-20160816;
        b=zw0/a9pB9n7IfjbL9JgLtwTYS5XU5XMJUgT0YfVcpUKZbzrsXShlNENt/DBv+H9dEg
         HxzQK6+5Hekk9vpasaFXi+vBn6nH97ceFfAR4vHZTJH2E0MZlUYJ+71610mPJTlje2Wh
         yvHM9vJW+SJC2MipD39GtCT/yufYExvYNSwiw8g/TxXtOoIeTCuvhn4Pp5ISP7scmbPp
         iLZmbInk6LFXKBwzOI+qCnBFxggOknyc2PViPvbGVqnxFzKH4Xj/a+dcwZ530WXzjNaI
         R0onnS/VAt6WueFVH7MruP15ERdkdBLuBe5SyHHn4GDFvUNWMlwozN6/xZ4XMMOM9ZQt
         mfUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Dae4/IXxIKvok4ax7clnXozmTE0V8dNaujdRqd/9frk=;
        b=mkU4jah7e+jf6at8zH9BhZzQXusjr+ouAcQdjc7GCNiMr8AXY26f2rHaFV9vCJUSWd
         BZspFvJ8Z8qOTsRNwgRvErzv/SOA3QFgQkBegGZ4F96RqsO954lU88zouPFMst2PHEm4
         PD5tRcqlaqRpw+3QFPAXygnKoOTIiUdSFtyjq/5Y+cVBu5TaU5lQwNuKJugqDPg/QchI
         jAmIKZlB3CMLklZboKUMtqpf7cNA6UFynvTdHAU7Khy0XcheYJGz8MoXXky6GG80K9xh
         6+hjxkDC0+q9xBwcgFB9QAhPLzxwkcIQ9kAUlJ7aVRAVvnT8/OI4K5Bxvvli1kK1Byof
         lHew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x62si14697195vkg.89.2019.07.29.07.24.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 07:24:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 81BE3C049E12;
	Mon, 29 Jul 2019 14:24:58 +0000 (UTC)
Received: from [10.72.12.68] (ovpn-12-68.pek2.redhat.com [10.72.12.68])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 14E8E5D6A0;
	Mon, 29 Jul 2019 14:24:44 +0000 (UTC)
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
References: <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
 <20190726094756-mutt-send-email-mst@kernel.org>
 <0792ee09-b4b7-673c-2251-e5e0ce0fbe32@redhat.com>
 <20190729045127-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <4d43c094-44ed-dbac-b863-48fc3d754378@redhat.com>
Date: Mon, 29 Jul 2019 22:24:43 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190729045127-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 29 Jul 2019 14:24:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/29 下午4:59, Michael S. Tsirkin wrote:
> On Mon, Jul 29, 2019 at 01:54:49PM +0800, Jason Wang wrote:
>> On 2019/7/26 下午9:49, Michael S. Tsirkin wrote:
>>>>> Ok, let me retry if necessary (but I do remember I end up with deadlocks
>>>>> last try).
>>>> Ok, I play a little with this. And it works so far. Will do more testing
>>>> tomorrow.
>>>>
>>>> One reason could be I switch to use get_user_pages_fast() to
>>>> __get_user_pages_fast() which doesn't need mmap_sem.
>>>>
>>>> Thanks
>>> OK that sounds good. If we also set a flag to make
>>> vhost_exceeds_weight exit, then I think it will be all good.
>>
>> After some experiments, I came up two methods:
>>
>> 1) switch to use vq->mutex, then we must take the vq lock during range
>> checking (but I don't see obvious slowdown for 16vcpus + 16queues). Setting
>> flags during weight check should work but it still can't address the worst
>> case: wait for the page to be swapped in. Is this acceptable?
>>
>> 2) using current RCU but replace synchronize_rcu() with vhost_work_flush().
>> The worst case is the same as 1) but we can check range without holding any
>> locks.
>>
>> Which one did you prefer?
>>
>> Thanks
> I would rather we start with 1 and switch to 2 after we
> can show some gain.
>
> But the worst case needs to be addressed.


Yes.


> How about sending a signal to
> the vhost thread?  We will need to fix up error handling (I think that
> at the moment it will error out in that case, handling this as EFAULT -
> and we don't want to drop packets if we can help it, and surely not
> enter any error states.  In particular it might be especially tricky if
> we wrote into userspace memory and are now trying to log the write.
> I guess we can disable the optimization if log is enabled?).


This may work but requires a lot of changes. And actually it's the price 
of using vq mutex. Actually, the critical section should be rather 
small, e.g just inside memory accessors.

I wonder whether or not just do synchronize our self like:

static void inline vhost_inc_vq_ref(struct vhost_virtqueue *vq)
{
         int ref = READ_ONCE(vq->ref);

         WRITE_ONCE(vq->ref, ref + 1);
smp_rmb();
}

static void inline vhost_dec_vq_ref(struct vhost_virtqueue *vq)
{
         int ref = READ_ONCE(vq->ref);

smp_wmb();
         WRITE_ONCE(vq->ref, ref - 1);
}

static void inline vhost_wait_for_ref(struct vhost_virtqueue *vq)
{
         while (READ_ONCE(vq->ref));
mb();
}


Or using smp_load_acquire()/smp_store_release() instead?

Thanks

>

