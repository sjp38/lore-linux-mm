Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC2F7C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:45:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A264322CD7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:45:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A264322CD7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A9A98E0047; Thu, 25 Jul 2019 03:45:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 359B68E0031; Thu, 25 Jul 2019 03:45:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 247AE8E0047; Thu, 25 Jul 2019 03:45:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 021E18E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:45:46 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s22so43679499qtb.22
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 00:45:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=VmCxDugTG1Bzj05kzv3v5yNjDmUphNyArY+a3P3LWjw=;
        b=YTxVN1qwZHaXTu3jx2yfLaa7jK3t9ZX5CgS3q+zGeczNjm1sJCYRZwOlsa0m1i/JY6
         2JLIHpXn24fFf0BVs3VroTgZRuZ1s9krrQz4wvX2lFiwnD2IBnMTnafYR+sSMhNuziJt
         sb47SRz00zMktj70R72pgfGXuoFJ5A8lwtGnvRMAOGitVSSapjxwWkGPZoYDqePnc9Q9
         k8vDdcLhfktV/BnjFjDnYe7Kia348VQKr0zgmR/QsW/qI83Nwb1FpBh228xijDhKzGBO
         M/QevxEiOm/840LnpziboMNUL9KGNYT9Gr5Pk+gTRemAEnY/10TxpjTyYyQPI6pjD14v
         047A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX5TThb4bMllE2dT+/fqbDxPvcP4WZpDbXaXEt5sBFYcAhyFxFu
	WTPHpJGtGOKtWaCIeZCJs/8Bv2whP3eSL2MppWCSJY63+dL5iTSYkFvLgR2ZWpSYPfRCqPiE86J
	sEhU+/CG7RdjuK/i9LrtdN/w8z1x/QCbnCwPJkrq1DMfiLmz3h4xUnfdThPbKNVjLOA==
X-Received: by 2002:ac8:2ae8:: with SMTP id c37mr61425859qta.267.1564040745773;
        Thu, 25 Jul 2019 00:45:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuEq895xGx+8ye1Pg+VghCKfu0NFDSYepoYVyeH2F9a4X8GhaFpniQdkGHi9DJiRPwwd6R
X-Received: by 2002:ac8:2ae8:: with SMTP id c37mr61425838qta.267.1564040745157;
        Thu, 25 Jul 2019 00:45:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564040745; cv=none;
        d=google.com; s=arc-20160816;
        b=Q3ZuBGgQxRNC+WQzHFzh48x3G/OkgM1xzhsDP28RCf0+zmzQvM5Vq1Y9ykd7cK9jZR
         KjXuQNAN6LDCWPWXJWY7urSkYKH7lQNFjG0KVHI6yO4YDU+2yfJLwUcKoysCMO0VTsso
         FHmmgKOhVOTRLqa7Uin7cG2Vecu1W88IG+MOLCGOXeyARG+JUMgnB08gAIv8COCa0umA
         UhoVGwNbb26P1QPb9AZ08ISYqHAMlfPLNKRT6lA2ObSY2yu4u60hxjy1SF8ExXsQDdXt
         JJbAQKPqO6HibnqsvBrOQd1qQ86y+yNwbsBx4nfEiBfjBt0NXDLJdcEkhcI8TYxun/9l
         3LnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=VmCxDugTG1Bzj05kzv3v5yNjDmUphNyArY+a3P3LWjw=;
        b=aeVCRqOfmSL3u8fIrMbLbioHSHv5Npa5TGDRSh3x9KedF3xY9KdixkbM07s3aeV6Xy
         pfYw7royBXlGZMNmlqlHz+/fHm/sqqbvcX93KVg0JHmRNUWmRYngNLNBBHVIcuL9c07Y
         +DRdk4Muwr5YY/g/0Gh19ZVivo1ZtQsfuC+nBceaVIK4saQTA39Vg3zUQHg9PLdclzyF
         2Ft4vKAblfWQRfdPjIOsk0zoBBd5sM4Ki4s030XPS0Q/5Se64LbUEFUwilTyFoiFTjU/
         LOp5012YfuUjLSmtR9v56kfNClTyMyLt8BKnk1j4+/LmjHG0S3J8HpIwkWCxsBhKY8tD
         4dDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g1si29263885qki.181.2019.07.25.00.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 00:45:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 356623084246;
	Thu, 25 Jul 2019 07:45:44 +0000 (UTC)
Received: from [10.72.12.18] (ovpn-12-18.pek2.redhat.com [10.72.12.18])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2591B5C6D2;
	Thu, 25 Jul 2019 07:45:16 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>
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
 <20190722141152.GA13711@ziepe.ca>
 <20190725015402-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <6389178e-35f2-28a1-4d36-3696bcde6af0@redhat.com>
Date: Thu, 25 Jul 2019 15:44:54 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190725015402-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 25 Jul 2019 07:45:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/25 下午2:02, Michael S. Tsirkin wrote:
> On Mon, Jul 22, 2019 at 11:11:52AM -0300, Jason Gunthorpe wrote:
>> On Sun, Jul 21, 2019 at 06:02:52AM -0400, Michael S. Tsirkin wrote:
>>> On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
>>>> syzbot has bisected this bug to:
>>>>
>>>> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
>>>> Author: Jason Wang <jasowang@redhat.com>
>>>> Date:   Fri May 24 08:12:18 2019 +0000
>>>>
>>>>      vhost: access vq metadata through kernel virtual address
>>>>
>>>> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
>>>> start commit:   6d21a41b Add linux-next specific files for 20190718
>>>> git tree:       linux-next
>>>> final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
>>>> console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
>>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
>>>> dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
>>>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
>>>>
>>>> Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
>>>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
>>>> address")
>>>>
>>>> For information about bisection process see: https://goo.gl/tpsmEJ#bisection
>>>
>>> OK I poked at this for a bit, I see several things that
>>> we need to fix, though I'm not yet sure it's the reason for
>>> the failures:
>> This stuff looks quite similar to the hmm_mirror use model and other
>> places in the kernel. I'm still hoping we can share this code a bit more.
> Right. I think hmm is something we should look at.


Exactly. I plan to do that.

Thanks

