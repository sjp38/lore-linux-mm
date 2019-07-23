Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08CDCC76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:31:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEA7022543
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:31:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEA7022543
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E5D96B0008; Tue, 23 Jul 2019 09:31:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5956F6B000D; Tue, 23 Jul 2019 09:31:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45C5D8E0002; Tue, 23 Jul 2019 09:31:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF6C6B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:31:50 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x11so34091361qto.23
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:31:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=S1q7EPwvQ6FBSwcSahBuXhpDRYCWIg8eVtdeMLW9lYU=;
        b=fDnUd6epxJEXSywEAf06nDG26YBqq9LLO8TVKw1NbJHHUvO8K3P/XbWD5kOUK0mC6j
         eo2pOjbyaKQuG0yTxJyt5sTXKaBvRhbLZvMeDZ+qxiAYcl4Dml1sWA5u36gClIQSNNl/
         4p8xbjVzZtBYrUGMPng3O9gi3lWviCBuCsTEpfIiElqZIUMvnHHdmnKpL8dq78aki26k
         v/xOTrYyvIt0nvWurD57sYitr+7rAaF/g0gez5arMZW78LfO+a7AK6RiOBndIqAQ9t0P
         lH/K2RcxIEa3r6D2XR1Aq7uvbJAIam/og20Z1qvtOtpNptaXhhRBAyTrvSoUkQonXHW/
         N/Kw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXpESVVn3oHE2E9qDS/sxDZM30GOtH238+YJo7Ob/gHCeNEAfGI
	rM5GrOI4lg8cHGQ5wbsQuyhtjmHzWWetvbF+DcRkb9sUbhPythjkx0OI0njV99aMlyXsq8PXO6M
	wLlWc0tXAdJAqVADtbq/mjaUtJstzcXkl7NqgVHBvPNyW49fe/lmmAUZJigNFkoRp2A==
X-Received: by 2002:a37:5f45:: with SMTP id t66mr51046247qkb.286.1563888709879;
        Tue, 23 Jul 2019 06:31:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1Z1vw/VPXHwdLRr8b9/+/Ho5wjVwO/qs9ZpJ7VrSVQ82aiKdNIZLQN6+Azrr+T8K2Q9fz
X-Received: by 2002:a37:5f45:: with SMTP id t66mr51046174qkb.286.1563888709002;
        Tue, 23 Jul 2019 06:31:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563888708; cv=none;
        d=google.com; s=arc-20160816;
        b=VkUrfe2+TiEZ4ysT+F435GXJRlHpzaxl+7mzg+pN5+3sywpQThGpiftVwkxEMQ0GIa
         mpWcMYTXrf/F+54APfeUiKkdTC0WN7CatmaTpDlHzi2Bi3MDtyo8MWDLRcOFisMx7R+D
         fVxtaY+iXvW1Xj70V1cEnJBNvtQ0duh+W0QyVUzk25Pdm6nQUvPP0U1eEMThr+UYRC5V
         9iLL0kEf/0nsN+f1PgRomcBC5P3wVdh7J+opXkBhi58IqV6D7T9PgAmVp0DvBVoT+gcZ
         ORU1akfmzksyRkM1khZg4nuYGJyIkuw39lCNlVJ3VPmSaTRzdNngYqI4c1aDtDWG+PJF
         UP6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=S1q7EPwvQ6FBSwcSahBuXhpDRYCWIg8eVtdeMLW9lYU=;
        b=cUDi5WUj3a7mlAameTSeEd6q0HEDeWM9CtbQdqeEOab60JnxXyASUj2ng0T0BHs1i4
         hy+6mCu88Dpv+KpEJ7+3R8hMfAIyj1+92xK+Oz2uApB+Njm3AUf9UKXKdTb/aVZ3cqfu
         a+pjZUDnM+1GV+/CQa/GngnwQGeXlt2LhryAyGWGmhni8ue4ZXQxyiD78JiNMealfkc5
         SjcmGygCQip97XRaxve2QdjAsmvkqclaGWPECF5NFhrLK9QckDwGV11zXYHPlZ1s1914
         ZsOTxEy1WJj2JgEWmrtidhsxAKIOAU5TB+GWG64vNQfZXrlgllPml1O8hUF7kcpuKNv6
         0l+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 24si29737540qtx.7.2019.07.23.06.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 06:31:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B85FF2CD801;
	Tue, 23 Jul 2019 13:31:47 +0000 (UTC)
Received: from [10.72.12.26] (ovpn-12-26.pek2.redhat.com [10.72.12.26])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6BBD55C22D;
	Tue, 23 Jul 2019 13:31:33 +0000 (UTC)
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
References: <20190721081447-mutt-send-email-mst@kernel.org>
 <85dd00e2-37a6-72b7-5d5a-8bf46a3526cf@redhat.com>
 <20190722040230-mutt-send-email-mst@kernel.org>
 <4bd2ff78-6871-55f2-44dc-0982ffef3337@redhat.com>
 <20190723010019-mutt-send-email-mst@kernel.org>
 <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
 <20190723032024-mutt-send-email-mst@kernel.org>
 <1d14de4d-0133-1614-9f64-3ded381de04e@redhat.com>
 <20190723035725-mutt-send-email-mst@kernel.org>
 <3f4178f1-0d71-e032-0f1f-802428ceca59@redhat.com>
 <20190723051828-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
Date: Tue, 23 Jul 2019 21:31:35 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723051828-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 23 Jul 2019 13:31:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/23 下午5:26, Michael S. Tsirkin wrote:
> On Tue, Jul 23, 2019 at 04:49:01PM +0800, Jason Wang wrote:
>> On 2019/7/23 下午4:10, Michael S. Tsirkin wrote:
>>> On Tue, Jul 23, 2019 at 03:53:06PM +0800, Jason Wang wrote:
>>>> On 2019/7/23 下午3:23, Michael S. Tsirkin wrote:
>>>>>>> Really let's just use kfree_rcu. It's way cleaner: fire and forget.
>>>>>> Looks not, you need rate limit the fire as you've figured out?
>>>>> See the discussion that followed. Basically no, it's good enough
>>>>> already and is only going to be better.
>>>>>
>>>>>> And in fact,
>>>>>> the synchronization is not even needed, does it help if I leave a comment to
>>>>>> explain?
>>>>> Let's try to figure it out in the mail first. I'm pretty sure the
>>>>> current logic is wrong.
>>>> Here is what the code what to achieve:
>>>>
>>>> - The map was protected by RCU
>>>>
>>>> - Writers are: MMU notifier invalidation callbacks, file operations (ioctls
>>>> etc), meta_prefetch (datapath)
>>>>
>>>> - Readers are: memory accessor
>>>>
>>>> Writer are synchronized through mmu_lock. RCU is used to synchronized
>>>> between writers and readers.
>>>>
>>>> The synchronize_rcu() in vhost_reset_vq_maps() was used to synchronized it
>>>> with readers (memory accessors) in the path of file operations. But in this
>>>> case, vq->mutex was already held, this means it has been serialized with
>>>> memory accessor. That's why I think it could be removed safely.
>>>>
>>>> Anything I miss here?
>>>>
>>> So invalidate callbacks need to reset the map, and they do
>>> not have vq mutex. How can they do this and free
>>> the map safely? They need synchronize_rcu or kfree_rcu right?
>> Invalidation callbacks need but file operations (e.g ioctl) not.
>>
>>
>>> And I worry somewhat that synchronize_rcu in an MMU notifier
>>> is a problem, MMU notifiers are supposed to be quick:
>> Looks not, since it can allow to be blocked and lots of driver depends on
>> this. (E.g mmu_notifier_range_blockable()).
> Right, they can block. So why don't we take a VQ mutex and be
> done with it then? No RCU tricks.


This is how I want to go with RFC and V1. But I end up with deadlock 
between vq locks and some MM internal locks. So I decide to use RCU 
which is 100% under the control of vhost.

Thanks

