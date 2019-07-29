Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C583C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:56:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D425B2087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:56:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D425B2087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84FEA8E0005; Mon, 29 Jul 2019 01:56:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 802238E0002; Mon, 29 Jul 2019 01:56:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EFAB8E0005; Mon, 29 Jul 2019 01:56:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50BCD8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:56:28 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so53978436qte.8
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:56:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=PLXBbTIVqflLLCR526gI7P+W1tUXTOc3XZo7kbVitQo=;
        b=qt3TLdNoLc1+UEVkW0aBZYVdCFMupAvadxwG6vBZjXM09fLf1btdPNc2F3AoKz885y
         teqkoPVo8JcxrtT/9wRmFlzIL5PouUHhv+u97XityUWC5VV0ohrFDd5aifFIS8xnoptF
         ZqtQUKug92ccnajpSqoO5iPkx7f91+tkH9QtCsla257NYT2b/CfyFjxYsQZ5y8CpvKPv
         HkCfUHjdqGKYUx9QnBg1NsiGZ+2lJL6+IUoUhNEbLdQkAQq4rARSiuCcipuvCY3R/tLH
         BqZeq58VMHX3auZpxvFt/BmDOWuNwKDHUIB4CffKHCY/wRStiOQsSscXsfHZYJ0AbvkO
         ostw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW0A5fIX4zPZ3VMyTdJBkiFjfeBNxMgsd6GNAsNfLCnyjSeQbIH
	dT3iBhU4afDYF7b1C4mlvV0njZyOKtJv/oyFYnvUuBtLV7mfq1Uxt5K4TX7SbRHGB/qOLsEeegr
	oCYUYM3fpx8jDylpjYo3sVylzKhfwrQwIBBEyZS2i4V3ED7wMFfiei0RbWJFlwR7dwg==
X-Received: by 2002:ac8:4442:: with SMTP id m2mr18679534qtn.107.1564379788084;
        Sun, 28 Jul 2019 22:56:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEDKeso0HaadvB+dF/GdBlfAvz6ZDO209398AWLywU7Ut5f25vQSbXExHgUe7DKnqEqC71
X-Received: by 2002:ac8:4442:: with SMTP id m2mr18679521qtn.107.1564379787672;
        Sun, 28 Jul 2019 22:56:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564379787; cv=none;
        d=google.com; s=arc-20160816;
        b=WVSuV8TBo9PLoq+WRP/uvr2hg+4efkDi8WFBmeKgISiPNp4c+l1Uo9jtDoZR6kO6aH
         e33OoEXxm6vqD7YNWS+dJsns4xJFebrGdacFcSjnGMP8oFli3wKz30hmaM7eqE4aWFQE
         XkQf++L04ARrxCqbDBVyHCRCU5o1jPB5w+QeuRgeI2nSvSBoLPg7lxjFTMF3FXBK2afv
         DlPivxeaC4K7/i5exj+6HH1bdPigWIjG0mDehJt2DtRmeIz1EmXVjPFNGZbK498JG8/M
         g825U+8bCLFfE4uZ9l4qfTD7vjxDe7S5uZmDiHF8XTzOVorTW2OLkKah7EI2wKBmhw6E
         gNnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=PLXBbTIVqflLLCR526gI7P+W1tUXTOc3XZo7kbVitQo=;
        b=Y4b1DI0bJzTEm0ILYfX0qav6dZGViudSyAvdAe1zB463oEjvucMKAMAqBLwWciscwJ
         JYie4GVobUt5jsxm+Hx5GwDI0EsWvIvnRMbGITsGO7ammu4/CCtfm5cuS+MoJvbzF2DX
         nNRSDLiUfSeWM8VTpOQ0Wx2aY8WBd/QExy1jn/VE2ddidiosWgxyjw8YCX3CWFcZj3I4
         ClRjS19RElrGWcJXfabaULHS5oiFDcfwimRkmqdveoEgbtHEem8Tf1wPm2ZWGslk5TyR
         7W+ARuHRMAtqsrvdwNu1EwRiPfu0BW00uArO6yaaatjmyDM+uaCFMkHl24Oxxss9oGCA
         tQrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n55si22898309qtf.56.2019.07.28.22.56.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 22:56:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 78B46308FC47;
	Mon, 29 Jul 2019 05:56:26 +0000 (UTC)
Received: from [10.72.12.53] (ovpn-12-53.pek2.redhat.com [10.72.12.53])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7C62660C5F;
	Mon, 29 Jul 2019 05:56:10 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
 aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
 davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com,
 guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com,
 jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-parisc@vger.kernel.org, luto@amacapital.net,
 mhocko@suse.com, mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
 syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, wad@chromium.org
References: <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <20190726094353-mutt-send-email-mst@kernel.org>
 <63754251-a39a-1e0e-952d-658102682094@redhat.com>
 <20190726150322.GB8695@ziepe.ca>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <e3850664-6c2e-689b-8a1f-4d3b8e03cbc7@redhat.com>
Date: Mon, 29 Jul 2019 13:56:08 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190726150322.GB8695@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 29 Jul 2019 05:56:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/26 下午11:03, Jason Gunthorpe wrote:
> On Fri, Jul 26, 2019 at 10:00:20PM +0800, Jason Wang wrote:
>> The question is, MMU notifier are allowed to be blocked on
>> invalidate_range_start() which could be much slower than synchronize_rcu()
>> to finish.
>>
>> Looking at amdgpu_mn_invalidate_range_start_gfx() which calls
>> amdgpu_mn_invalidate_node() which did:
>>
>>                  r = reservation_object_wait_timeout_rcu(bo->tbo.resv,
>>                          true, false, MAX_SCHEDULE_TIMEOUT);
>>
>> ...
> The general guidance has been that invalidate_start should block
> minimally, if at all.
>
> I would say synchronize_rcu is outside that guidance.


Yes, I get this.


>
> BTW, always returning EAGAIN for mmu_notifier_range_blockable() is not
> good either, it should instead only return EAGAIN if any
> vhost_map_range_overlap() is true.


Right, let me optimize that.

Thanks


>
> Jason

