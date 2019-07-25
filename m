Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 233C6C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:44:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBBEC218F0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:44:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBBEC218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72CB78E0046; Thu, 25 Jul 2019 03:44:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DCE68E0031; Thu, 25 Jul 2019 03:44:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A56D8E0046; Thu, 25 Jul 2019 03:44:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 37EFD8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:44:24 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e32so43710002qtc.7
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 00:44:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=acAUfxbZ2yCJCgOcrOJ/SiLQh/4Iw8FfpHBr0uZv6Bc=;
        b=AsWricVrjoeWOLMNnwL6oEMAFut/J44fQdsRN7JKCJgBVRebm058QIz9VwbH7s9fBM
         IWH8lVBcDJYi/WLakZIinyV5j+4y7/FYUFMpRHR/gi0dJuzAq2gJ84kAae8Nkegk1AHw
         Z6B4w6+JU+e9//gwBJjXf2gTIwHdwAUfUYk/VHsIs9Hm+MrLHbaLnAAklZvtaMYzdVO1
         bBdul5rZw19EPAphbXeMJVUoF8O/ilMvdqJNMkHSnS17EsH4dGGhmVNHBKyTBSXLngtM
         3q7ZiNWGrHs/CANL7N0fLjZmCw083mZh5BLWjXbtNazij1gJ2HhBTHG9HFe24ds9LWrF
         ybDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVAxmw0wK1Pxgr3F9AuxNoikAMFgXtwbYimuVIVKYi4mh75LFMK
	YPjOi3yhqb9B6WX+njwYTB9CH4yc8H9f+d4lt6phhmCF0BFCGxBzUl/2PUYT1yVcRxHImyZOtMM
	tsM0RZOQ33wXQKEfaK7kgN/3Xl61azKgPDuAj9ItcsmK4foTWO9z2zwmdpW5d6DI6Pg==
X-Received: by 2002:a37:9a8b:: with SMTP id c133mr52567648qke.261.1564040663932;
        Thu, 25 Jul 2019 00:44:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyp2UNuYn0pFVMFfTQhFDP+47XzzrVBU7CDOSY3DIp7OByfxxoFgljUd9n7LmEi0rKYfemj
X-Received: by 2002:a37:9a8b:: with SMTP id c133mr52567613qke.261.1564040663106;
        Thu, 25 Jul 2019 00:44:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564040663; cv=none;
        d=google.com; s=arc-20160816;
        b=nynVX1ksXKWVq+PvXwRj9t8h9CDRyRzgsG/9mLMXw7xS9RtbKkPCE9FBW+PjryhETW
         krLHVi9EatvlkA6bx9fTCIr2lUj7hoEkj1lgxLVC47/wQdViSLVGj6pcEbPyc8ki//Kz
         QwaOWrOmKZfGFslZ2AcuwwYdo3BRwLmnJRUqDyRo1g0PNAAw1rQ8sipfWGxT7PEK5oBL
         QvgQHYdr+7kvEvgaCFo9AjtzjWlXo7JN7IxMLoJW91leUPsXTObo8MsP+8i/TLxVIscz
         LAdXBVVig7+SjwSh1qf1YQZ7bIqs/xPpOL19nx6U2QmJZFCG+BDLSmDxNnE/j4He6gd6
         MuJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=acAUfxbZ2yCJCgOcrOJ/SiLQh/4Iw8FfpHBr0uZv6Bc=;
        b=AWLUL8SdMFMob40DDNkDOuiLEYvmZmp98G+9eGwtHJuasb936orwhfC4PiRyrIaLxe
         GxCiV0+uyetV2Yik/J/4/8HfYcHiliVWPFudu7UgU8QrcFVvJA6ZuQgDV2rxupzf8e2u
         1gNemHv6v3DtJ1C95PRscHqf45MXha8SmP/Dx46gh/R5531q4dOdinTbjzOKlJNPfVwp
         h3n8Oa+b4+Ic8MYbpybvCA5w8NQRERYGXwEcuG0GighIsabR432krq7cFTyoihutyI+w
         0TSoNZJYqss9GOt2av1OAXCnKYjLAhW2X6ZXNRHJcNKfYHw+uc0/n9woOsi9j8FXs9KU
         +Ctg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s54si30130225qte.241.2019.07.25.00.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 00:44:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AD73530917AF;
	Thu, 25 Jul 2019 07:44:21 +0000 (UTC)
Received: from [10.72.12.18] (ovpn-12-18.pek2.redhat.com [10.72.12.18])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B998060852;
	Thu, 25 Jul 2019 07:44:04 +0000 (UTC)
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
References: <20190722040230-mutt-send-email-mst@kernel.org>
 <4bd2ff78-6871-55f2-44dc-0982ffef3337@redhat.com>
 <20190723010019-mutt-send-email-mst@kernel.org>
 <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
 <20190723032024-mutt-send-email-mst@kernel.org>
 <1d14de4d-0133-1614-9f64-3ded381de04e@redhat.com>
 <20190723035725-mutt-send-email-mst@kernel.org>
 <3f4178f1-0d71-e032-0f1f-802428ceca59@redhat.com>
 <20190723051828-mutt-send-email-mst@kernel.org>
 <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
 <20190725012149-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
Date: Thu, 25 Jul 2019 15:43:41 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190725012149-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 25 Jul 2019 07:44:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/25 下午1:52, Michael S. Tsirkin wrote:
> On Tue, Jul 23, 2019 at 09:31:35PM +0800, Jason Wang wrote:
>> On 2019/7/23 下午5:26, Michael S. Tsirkin wrote:
>>> On Tue, Jul 23, 2019 at 04:49:01PM +0800, Jason Wang wrote:
>>>> On 2019/7/23 下午4:10, Michael S. Tsirkin wrote:
>>>>> On Tue, Jul 23, 2019 at 03:53:06PM +0800, Jason Wang wrote:
>>>>>> On 2019/7/23 下午3:23, Michael S. Tsirkin wrote:
>>>>>>>>> Really let's just use kfree_rcu. It's way cleaner: fire and forget.
>>>>>>>> Looks not, you need rate limit the fire as you've figured out?
>>>>>>> See the discussion that followed. Basically no, it's good enough
>>>>>>> already and is only going to be better.
>>>>>>>
>>>>>>>> And in fact,
>>>>>>>> the synchronization is not even needed, does it help if I leave a comment to
>>>>>>>> explain?
>>>>>>> Let's try to figure it out in the mail first. I'm pretty sure the
>>>>>>> current logic is wrong.
>>>>>> Here is what the code what to achieve:
>>>>>>
>>>>>> - The map was protected by RCU
>>>>>>
>>>>>> - Writers are: MMU notifier invalidation callbacks, file operations (ioctls
>>>>>> etc), meta_prefetch (datapath)
>>>>>>
>>>>>> - Readers are: memory accessor
>>>>>>
>>>>>> Writer are synchronized through mmu_lock. RCU is used to synchronized
>>>>>> between writers and readers.
>>>>>>
>>>>>> The synchronize_rcu() in vhost_reset_vq_maps() was used to synchronized it
>>>>>> with readers (memory accessors) in the path of file operations. But in this
>>>>>> case, vq->mutex was already held, this means it has been serialized with
>>>>>> memory accessor. That's why I think it could be removed safely.
>>>>>>
>>>>>> Anything I miss here?
>>>>>>
>>>>> So invalidate callbacks need to reset the map, and they do
>>>>> not have vq mutex. How can they do this and free
>>>>> the map safely? They need synchronize_rcu or kfree_rcu right?
>>>> Invalidation callbacks need but file operations (e.g ioctl) not.
>>>>
>>>>
>>>>> And I worry somewhat that synchronize_rcu in an MMU notifier
>>>>> is a problem, MMU notifiers are supposed to be quick:
>>>> Looks not, since it can allow to be blocked and lots of driver depends on
>>>> this. (E.g mmu_notifier_range_blockable()).
>>> Right, they can block. So why don't we take a VQ mutex and be
>>> done with it then? No RCU tricks.
>>
>> This is how I want to go with RFC and V1. But I end up with deadlock between
>> vq locks and some MM internal locks. So I decide to use RCU which is 100%
>> under the control of vhost.
>>
>> Thanks
> And I guess the deadlock is because GUP is taking mmu locks which are
> taken on mmu notifier path, right?


Yes, but it's not the only lock. I don't remember the details, but I can 
confirm I meet issues with one or two other locks.


>    How about we add a seqlock and take
> that in invalidate callbacks?  We can then drop the VQ lock before GUP,
> and take it again immediately after.
>
> something like
> 	if (!vq_meta_mapped(vq)) {
> 		vq_meta_setup(&uaddrs);
> 		mutex_unlock(vq->mutex)
> 		vq_meta_map(&uaddrs);


The problem is the vq address could be changed at this time.


> 		mutex_lock(vq->mutex)
>
> 		/* recheck both sock->private_data and seqlock count. */
> 		if changed - bail out
> 	}
>
> And also requires that VQ uaddrs is defined like this:
> - writers must have both vq mutex and dev mutex
> - readers must have either vq mutex or dev mutex
>
>
> That's a big change though. For now, how about switching to a per-vq SRCU?
> That is only a little bit more expensive than RCU, and we
> can use synchronize_srcu_expedited.
>

Consider we switch to use kfree_rcu(), what's the advantage of per-vq SRCU?

Thanks

