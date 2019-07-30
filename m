Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45DE9C32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 07:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D86B5206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 07:45:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D86B5206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43C5B8E0005; Tue, 30 Jul 2019 03:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EDC38E0002; Tue, 30 Jul 2019 03:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DB988E0005; Tue, 30 Jul 2019 03:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08CEF8E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 03:45:06 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o16so57566323qtj.6
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 00:45:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=/u+7PBGONpChj9bsCyMR6/PNwLHKML+JATmP8hgGVAs=;
        b=NGmb1Tn2Bve7AgPDBL8lv+gtYHM+zgjZdrK7eowcoWs3Nw5oLxSsjw5kg/Cni+Ryz6
         nBaf3ddh+eqgy7Y8e6jFP0BHKm/Kd1CfEJZOqeIespknw6xhVgfFzPBTTEOph4eEn/fX
         SwEENHAKL8PfDIELmgSDgWo94cXI/K/l5gW23fc0Cc98Z88CN8LF6CXpyUj2u4P4fJIP
         ZEWhJH7TAnxi0uTAjLdI1VSDWofu34hkbCjyGaEv5UUlzm0MzcDe55gsS/BCX7V1Gf73
         xtdYlxHO6Ae58wIJ/wdG69BfpAMoGiSz09iePaBuMgZkwQeotf6w/uEHwBLVZyDaeXof
         LcKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAURziQD34GJOq7Rk4liFstyHGPhgmPZpUcIQJ9UJ9zHgOEu63yL
	KcGlbc2m8mdotrfEEpEsjQBOXPEgfJo/vxEQzHPE9SlmfLv/5sMDMgbsY9UKgnZ1Gfv3xUGU+19
	8gsZ9EO++Y8YpbWktYfiMOVcgvt/LSL14J1om3WdsNo1gFT45QD/mbqydA2UIBAqQCw==
X-Received: by 2002:aed:2961:: with SMTP id s88mr79640684qtd.120.1564472705775;
        Tue, 30 Jul 2019 00:45:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTApot1QSPkNHZuZ+WEnYEFAevlbdmOPN74h1j1ti+9CaEJcILidf068OMbigjdQ4R5Zgr
X-Received: by 2002:aed:2961:: with SMTP id s88mr79640649qtd.120.1564472705004;
        Tue, 30 Jul 2019 00:45:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564472704; cv=none;
        d=google.com; s=arc-20160816;
        b=O/jEFb6peVNtc/PSgXlvDz6hQimNxxtk7zwVVzZbJVJS/aPa7C5DpxRRGNkzoWVgdE
         Y8eJ3OcTTp8bvyeoTRdu59oq8eX7kPU2coT8j57iHFjldGx/4UV5CkXQL4e4ppBUfaIf
         yd09Qc4KEiHePm3pRK4N7Z7dcnMffHW8davK6AXb+lvU1QLK/ot6UDTZfHstq0I3R4/T
         HHfDvGx4E81+GZJiqcYjVAeK0CONjZRyUI5k/ZHTz3b4C9Y9G70mLuseRszHPV0olO2b
         P0kwFMFG9a/nWIVIogqX6Nfu+o++rh4Rucle1R4Hr29sVp6LUcKo2tkNnFDTaJnH94vc
         0Iog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=/u+7PBGONpChj9bsCyMR6/PNwLHKML+JATmP8hgGVAs=;
        b=sGpJRawwxDaMQNEku6ulQfP3YZ7rGwvBlXQee2w5cn5wWCrlzw6mAsWzMV4ljS1pHL
         8i5gLvxJk7q5OZNFEMI7EgO/HI5I8S+ST959JYytlEu2DXvNUxVEtJ/vHkfKhmwAwY5H
         7xhjTDTOHDAnQUp9xS2BqXBSOqgrpvJnc0PCY7PScKFt1+iWpzGJ5wXAL92c1cFEzMcK
         XVii4tAvTt5IVIXp6TgxdAeSuNM1XI1uQVlefBI+CnyKy/NFMzH5pEvmpD/R9841tv5z
         q5qSdw1fri3gEHyMKekslSjxBi8C52dXHvEMh/BxrJwPJknfaDPAEsHdWDNXNS4y1R9C
         kWqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q9si36018310qtj.4.2019.07.30.00.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 00:45:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3AD0BC027339;
	Tue, 30 Jul 2019 07:45:03 +0000 (UTC)
Received: from [10.72.12.185] (ovpn-12-185.pek2.redhat.com [10.72.12.185])
	by smtp.corp.redhat.com (Postfix) with ESMTP id ECA805C1A1;
	Tue, 30 Jul 2019 07:44:48 +0000 (UTC)
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
References: <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
 <20190726094756-mutt-send-email-mst@kernel.org>
 <0792ee09-b4b7-673c-2251-e5e0ce0fbe32@redhat.com>
 <20190729045127-mutt-send-email-mst@kernel.org>
 <4d43c094-44ed-dbac-b863-48fc3d754378@redhat.com>
 <20190729104028-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <96b1d67c-3a8d-1224-e9f0-5f7725a3dc10@redhat.com>
Date: Tue, 30 Jul 2019 15:44:47 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190729104028-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 30 Jul 2019 07:45:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/29 下午10:44, Michael S. Tsirkin wrote:
> On Mon, Jul 29, 2019 at 10:24:43PM +0800, Jason Wang wrote:
>> On 2019/7/29 下午4:59, Michael S. Tsirkin wrote:
>>> On Mon, Jul 29, 2019 at 01:54:49PM +0800, Jason Wang wrote:
>>>> On 2019/7/26 下午9:49, Michael S. Tsirkin wrote:
>>>>>>> Ok, let me retry if necessary (but I do remember I end up with deadlocks
>>>>>>> last try).
>>>>>> Ok, I play a little with this. And it works so far. Will do more testing
>>>>>> tomorrow.
>>>>>>
>>>>>> One reason could be I switch to use get_user_pages_fast() to
>>>>>> __get_user_pages_fast() which doesn't need mmap_sem.
>>>>>>
>>>>>> Thanks
>>>>> OK that sounds good. If we also set a flag to make
>>>>> vhost_exceeds_weight exit, then I think it will be all good.
>>>> After some experiments, I came up two methods:
>>>>
>>>> 1) switch to use vq->mutex, then we must take the vq lock during range
>>>> checking (but I don't see obvious slowdown for 16vcpus + 16queues). Setting
>>>> flags during weight check should work but it still can't address the worst
>>>> case: wait for the page to be swapped in. Is this acceptable?
>>>>
>>>> 2) using current RCU but replace synchronize_rcu() with vhost_work_flush().
>>>> The worst case is the same as 1) but we can check range without holding any
>>>> locks.
>>>>
>>>> Which one did you prefer?
>>>>
>>>> Thanks
>>> I would rather we start with 1 and switch to 2 after we
>>> can show some gain.
>>>
>>> But the worst case needs to be addressed.
>>
>> Yes.
>>
>>
>>> How about sending a signal to
>>> the vhost thread?  We will need to fix up error handling (I think that
>>> at the moment it will error out in that case, handling this as EFAULT -
>>> and we don't want to drop packets if we can help it, and surely not
>>> enter any error states.  In particular it might be especially tricky if
>>> we wrote into userspace memory and are now trying to log the write.
>>> I guess we can disable the optimization if log is enabled?).
>>
>> This may work but requires a lot of changes.
> I agree.
>
>> And actually it's the price of
>> using vq mutex.
> Not sure what's meant here.


I mean if we use vq mutex, it means the critical section was increased 
and we need to deal with swapping then.


>
>> Actually, the critical section should be rather small, e.g
>> just inside memory accessors.
> Also true.
>
>> I wonder whether or not just do synchronize our self like:
>>
>> static void inline vhost_inc_vq_ref(struct vhost_virtqueue *vq)
>> {
>>          int ref = READ_ONCE(vq->ref);
>>
>>          WRITE_ONCE(vq->ref, ref + 1);
>> smp_rmb();
>> }
>>
>> static void inline vhost_dec_vq_ref(struct vhost_virtqueue *vq)
>> {
>>          int ref = READ_ONCE(vq->ref);
>>
>> smp_wmb();
>>          WRITE_ONCE(vq->ref, ref - 1);
>> }
>>
>> static void inline vhost_wait_for_ref(struct vhost_virtqueue *vq)
>> {
>>          while (READ_ONCE(vq->ref));
>> mb();
>> }
> Looks good but I'd like to think of a strategy/existing lock that let us
> block properly as opposed to spinning, that would be more friendly to
> e.g. the realtime patch.


Does it make sense to disable preemption in the critical section? Then 
we don't need to block and we have a deterministic time spent on memory 
accssors?


>
>> Or using smp_load_acquire()/smp_store_release() instead?
>>
>> Thanks
> These are cheaper on x86, yes.


Will use this.

Thanks


>

