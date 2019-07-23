Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 528E1C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:49:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1401D2239F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:49:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1401D2239F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FE336B0003; Tue, 23 Jul 2019 01:49:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B0378E0003; Tue, 23 Jul 2019 01:49:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C52F8E0001; Tue, 23 Jul 2019 01:49:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB056B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:49:05 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v4so35465737qkj.10
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:49:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Or5ymMU2ZX0t65ewBs9K5gpk86QVVFaxAwUvurUjTZQ=;
        b=Ow8s0ZUR/doxed2Bn/yAHojye/YyH/bftOMCSwymXeNAAxy/bbxV42T65BI8lq+NZh
         uZSOzp9CLRwnIF5+do2NDHgQCLURVpB2wHtPMZvTa/GfrbavOGMoHgdgisy58Q1J4/Pr
         Vyy7S3mpx2sL/6Hj/47qaB3ui6Bns4dPr6p17XGpXQjd6EM5xoP/KDymrYbXpAhS9rCB
         3MClUW+JZCPvW8g/Wr76iPkl4SOyPF2j4Z6hs7oL5/4luyMgleoMONqkEs1sTfIGOp8r
         4HxX4e9olCzNogFUKY4zkEWgNcyENEANLkBhdheKfcUZ/P63SgNhyYJr365BLLmngP3F
         FPjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUla8FFNB5wOUv1vGKZsCre+mc3fokYZZuCsgO3ZWyxv7Xu5EWN
	jDkFWj4ZbRP2DMpiHSvcA3KZJ0SRoIG10bVgwbO12c3e5iT8gS2QuQqeCSWFmrfjOR1s8twZXXc
	tyIn2M+mizD+/vBrIj5fP4S6OGMkhZ4yKcOdRnCLcHWKRpvXtgXXmcLbpj3iFkVHFqA==
X-Received: by 2002:aed:37a1:: with SMTP id j30mr52320386qtb.367.1563860945195;
        Mon, 22 Jul 2019 22:49:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHRr9bEtZcNsZltPedxm3IT68n3j8GLZX+SzJwF72J4AukhmcGjx+w1wYvK7v5nZw5yFRt
X-Received: by 2002:aed:37a1:: with SMTP id j30mr52320363qtb.367.1563860944516;
        Mon, 22 Jul 2019 22:49:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563860944; cv=none;
        d=google.com; s=arc-20160816;
        b=H19UBsJWxAvSrPghFpQnnVIeOxv/8IlU0T2+5hRP26W9QC1Z/aPGNyv6SNTZ8n3jsR
         Z2zfAZq6+jubM9j9cBqEwUsci7EY30hBOixEJ8iwXaQt95NX9jNFiA/LrU1vfY5vpGSA
         ddMqobw8GW6k8eZs4ONhSKtpv+9OePlVYnLr5J90Ab4+xLZcLKigKlJwiZNZOMPqnlSK
         RLH6+V6bcvQTWd0egH7nlrBRp9LFW5mmIg0NxVNg9E90G7qrcaQZlIiu8iIoMLpFpc+d
         81oY1MyqCIvxH9x+h6ywfAo9wqWl6ktQQ1dpwKU63urig1lh5cERU6dOwW/tebvMU652
         3h6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Or5ymMU2ZX0t65ewBs9K5gpk86QVVFaxAwUvurUjTZQ=;
        b=dPrEI4cvVEA1JGsyQP3OgmxLmb6nqtWFR9Y7iZpHzh5bbTeRNcp4iPjD3Dg6eQeppj
         dg0nQcBEEOCz3tI12mMapO3TX4vm+Ub4sWVIObxxhsB7fgepJn5uY4PiXdcLhTxYdoLr
         svpfB44EuG4SS4sPv37K3MBJdqYzC77fjyNTBf/S67h1LqkKpFw2FlR6wx4qzyEoUHCH
         gjgfPCrJZANypiBb/8Y38yxLLhTa92dE4unS3oSi59K4BqXaXegAtbhJsxBWe4efjZeZ
         kKE/EJGyl5iX3EQiCaueA99HNLnG9lJm6D4Es5q6e/M3NXKoiwC21S6+Co+KILdWoeOM
         xZbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p125si24678346qkc.197.2019.07.22.22.49.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 22:49:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8462F3083339;
	Tue, 23 Jul 2019 05:49:03 +0000 (UTC)
Received: from [10.72.12.26] (ovpn-12-26.pek2.redhat.com [10.72.12.26])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 07AAE5B684;
	Tue, 23 Jul 2019 05:48:52 +0000 (UTC)
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
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
 <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
Date: Tue, 23 Jul 2019 13:48:52 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723010156-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 23 Jul 2019 05:49:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/23 下午1:02, Michael S. Tsirkin wrote:
> On Tue, Jul 23, 2019 at 11:55:28AM +0800, Jason Wang wrote:
>> On 2019/7/22 下午4:02, Michael S. Tsirkin wrote:
>>> On Mon, Jul 22, 2019 at 01:21:59PM +0800, Jason Wang wrote:
>>>> On 2019/7/21 下午6:02, Michael S. Tsirkin wrote:
>>>>> On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
>>>>>> syzbot has bisected this bug to:
>>>>>>
>>>>>> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
>>>>>> Author: Jason Wang <jasowang@redhat.com>
>>>>>> Date:   Fri May 24 08:12:18 2019 +0000
>>>>>>
>>>>>>        vhost: access vq metadata through kernel virtual address
>>>>>>
>>>>>> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
>>>>>> start commit:   6d21a41b Add linux-next specific files for 20190718
>>>>>> git tree:       linux-next
>>>>>> final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
>>>>>> console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
>>>>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
>>>>>> dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
>>>>>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
>>>>>>
>>>>>> Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
>>>>>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
>>>>>> address")
>>>>>>
>>>>>> For information about bisection process see: https://goo.gl/tpsmEJ#bisection
>>>>> OK I poked at this for a bit, I see several things that
>>>>> we need to fix, though I'm not yet sure it's the reason for
>>>>> the failures:
>>>>>
>>>>>
>>>>> 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
>>>>>       That's just a bad hack,
>>>> This is used to avoid holding lock when checking whether the addresses are
>>>> overlapped. Otherwise we need to take spinlock for each invalidation request
>>>> even if it was the va range that is not interested for us. This will be very
>>>> slow e.g during guest boot.
>>> KVM seems to do exactly that.
>>> I tried and guest does not seem to boot any slower.
>>> Do you observe any slowdown?
>>
>> Yes I do.
>>
>>
>>> Now I took a hard look at the uaddr hackery it really makes
>>> me nervious. So I think for this release we want something
>>> safe, and optimizations on top. As an alternative revert the
>>> optimization and try again for next merge window.
>>
>> Will post a series of fixes, let me know if you're ok with that.
>>
>> Thanks
> I'd prefer you to take a hard look at the patch I posted
> which makes code cleaner,


I did. But it looks to me a series that is only about 60 lines of code 
can fix all the issues we found without reverting the uaddr optimization.


>   and ad optimizations on top.
> But other ways could be ok too.


I'm waiting for the test result from syzbot and will post. Let's see if 
you are OK with that.

Thanks


>>>

