Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3746C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 07:56:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5BD82239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 07:56:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5BD82239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3856C6B0003; Tue, 23 Jul 2019 03:56:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 337728E0003; Tue, 23 Jul 2019 03:56:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 224318E0001; Tue, 23 Jul 2019 03:56:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 022D86B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 03:56:01 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c207so35676419qkb.11
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 00:56:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=I47drxZV+bxntA7KGot7pP5Rlxi1vSKyOGRk7uplDGg=;
        b=VHf/NH1wtUJYdx9KBAJKR57Hc+BFnXn5cRWJMSxZKd+ynkTca0LiM9cvIIajn/Stax
         PSNxpABP6VP2khS2QvbsvgAuLaFTskXgcbBz9Nc6RsvjKSAyaSgCiRsIbMEaGw5fvaTa
         aUCJPWfBhZRd2Vfop7W91Wwlq4lzf0mnqtQnwPcNBQVez6JycWwZU/o8L1nvCwQ7EH9m
         RvWZL9pCNooeW5i+pVsKD7Z2o+gF0L/BwFcgt//CvBi6qFeChTjY+AZiC/ZWmjFgQOzw
         FiMOq45yA8VBAnhHWqazcY2GgnqunO0OfRLQ48b2+cW0h6pffEeZNmL784V8ZbnrvSBb
         dyWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXQ8VygJx+IhsbcOC0kz451bj278PM9J9BnFgsLfhZqA6TKLIOE
	n97RJIl7Uc8nlZ+UdvaZPNtVJrAwu8d+JnygJFfORU+8HBD8CwlbLZk39teOTUT8a1r1rRI+sMn
	PAE35jLxjwAYgYbw/aVDrz2qiwl88Et5widbkLYKawn/2o9LFrHiSNqtLredRNIyOsQ==
X-Received: by 2002:ac8:3118:: with SMTP id g24mr51926788qtb.390.1563868560734;
        Tue, 23 Jul 2019 00:56:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuapwcxNAvY9g8XDjUFbBXM2A38lWghABF7lUexWiJiQwMu9W/uICzJBm+Zl4kOdqXwm0d
X-Received: by 2002:ac8:3118:: with SMTP id g24mr51926761qtb.390.1563868560019;
        Tue, 23 Jul 2019 00:56:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563868560; cv=none;
        d=google.com; s=arc-20160816;
        b=lJEQyHYw7b5q5k2jau5a35Mh9jJjyKB9JWTgKnDUx01QCbuifUp9WlPoWRySJO0N9A
         j9hjNB72MXldHvG49jwA4OnmCIukJh9nvuRf5S8wcveUwXpCIn5jDKtFAKiPKeu4PjTy
         SV9jI5ToliGhDS9Dspu9x38HanoMia19LzeXexud/1QPncD6dlUxSyhXRGWbeOQrYeW0
         3suLgXCtQ3lYBwAEHFCjBkT3FEfSgzw1nPbrXxApSkc4wwUyiFrbo9l3AiwUb2NdkCzd
         CuIm9Z8du1BQfAQpuZ499Kf2wlRWMHPDMRcQCN/XkB5SgX3H9TwPut1BC9m3pfaaOXqy
         jaeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=I47drxZV+bxntA7KGot7pP5Rlxi1vSKyOGRk7uplDGg=;
        b=Ihw0uQqNRJ+4a2T/MGfMGq3TFOwmCtVsI9fYRg/VoTJ9k2RhmBEaxjCvzaIuO7fnic
         JVsJqufzgALr/uaBS4FDXoJtS3zugIRLPhFSpTSlMtipGZUx/Y9slPfHG2U0OqTQ2QmY
         ttnjVn1NzEi3rrnMKXVMHghleBtGmJfcKb+Z6f9u4rS1og/v5VQZGeg8ppFZM+WZWbKL
         5P2wUgkFX2txk5n7U6JkXWgVxSPSNFg7ZxcWJ77L3ZPa5fQ+wzDFP7CXRfrr+2A67gfm
         J1EvVbgEEpVCox08EC2CQEjkZ2pLWfqNIGN3NiYWy4QgTOqA5VKOwZ1tZMh4ij5ap8yz
         MtlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c191si25820829qkb.4.2019.07.23.00.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 00:56:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CA944859FF;
	Tue, 23 Jul 2019 07:55:58 +0000 (UTC)
Received: from [10.72.12.26] (ovpn-12-26.pek2.redhat.com [10.72.12.26])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AD23F60603;
	Tue, 23 Jul 2019 07:55:46 +0000 (UTC)
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
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032346-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <9a9a7ac0-2657-ff09-2644-f8d7ae0f9222@redhat.com>
Date: Tue, 23 Jul 2019 15:55:47 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723032346-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 23 Jul 2019 07:55:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/23 下午3:25, Michael S. Tsirkin wrote:
> On Tue, Jul 23, 2019 at 01:48:52PM +0800, Jason Wang wrote:
>> On 2019/7/23 下午1:02, Michael S. Tsirkin wrote:
>>> On Tue, Jul 23, 2019 at 11:55:28AM +0800, Jason Wang wrote:
>>>> On 2019/7/22 下午4:02, Michael S. Tsirkin wrote:
>>>>> On Mon, Jul 22, 2019 at 01:21:59PM +0800, Jason Wang wrote:
>>>>>> On 2019/7/21 下午6:02, Michael S. Tsirkin wrote:
>>>>>>> On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
>>>>>>>> syzbot has bisected this bug to:
>>>>>>>>
>>>>>>>> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
>>>>>>>> Author: Jason Wang<jasowang@redhat.com>
>>>>>>>> Date:   Fri May 24 08:12:18 2019 +0000
>>>>>>>>
>>>>>>>>         vhost: access vq metadata through kernel virtual address
>>>>>>>>
>>>>>>>> bisection log:https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
>>>>>>>> start commit:   6d21a41b Add linux-next specific files for 20190718
>>>>>>>> git tree:       linux-next
>>>>>>>> final crash:https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
>>>>>>>> console output:https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
>>>>>>>> kernel config:https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
>>>>>>>> dashboard link:https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
>>>>>>>> syz repro:https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
>>>>>>>>
>>>>>>>> Reported-by:syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
>>>>>>>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
>>>>>>>> address")
>>>>>>>>
>>>>>>>> For information about bisection process see:https://goo.gl/tpsmEJ#bisection
>>>>>>> OK I poked at this for a bit, I see several things that
>>>>>>> we need to fix, though I'm not yet sure it's the reason for
>>>>>>> the failures:
>>>>>>>
>>>>>>>
>>>>>>> 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
>>>>>>>        That's just a bad hack,
>>>>>> This is used to avoid holding lock when checking whether the addresses are
>>>>>> overlapped. Otherwise we need to take spinlock for each invalidation request
>>>>>> even if it was the va range that is not interested for us. This will be very
>>>>>> slow e.g during guest boot.
>>>>> KVM seems to do exactly that.
>>>>> I tried and guest does not seem to boot any slower.
>>>>> Do you observe any slowdown?
>>>> Yes I do.
>>>>
>>>>
>>>>> Now I took a hard look at the uaddr hackery it really makes
>>>>> me nervious. So I think for this release we want something
>>>>> safe, and optimizations on top. As an alternative revert the
>>>>> optimization and try again for next merge window.
>>>> Will post a series of fixes, let me know if you're ok with that.
>>>>
>>>> Thanks
>>> I'd prefer you to take a hard look at the patch I posted
>>> which makes code cleaner,
>> I did. But it looks to me a series that is only about 60 lines of code can
>> fix all the issues we found without reverting the uaddr optimization.
>>
>>
>>>    and ad optimizations on top.
>>> But other ways could be ok too.
>> I'm waiting for the test result from syzbot and will post. Let's see if you
>> are OK with that.
>>
>> Thanks
> Oh I didn't know one can push a test to syzbot and get back
> a result. How does one do that?


See here https://github.com/google/syzkaller/blob/master/docs/syzbot.md

Just reply this thread by attaching a fix with command like: "#syz test: 
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git 
7f466032dc9e5a61217f22ea34b2df932786bbfc"

Btw, I've let syzbot test you patch, and it passes.

Thanks


>

