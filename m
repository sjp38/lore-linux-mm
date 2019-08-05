Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45EB8C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:33:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1D272070D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:33:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1D272070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DD4F6B0003; Mon,  5 Aug 2019 00:33:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78D576B0005; Mon,  5 Aug 2019 00:33:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 654D56B0006; Mon,  5 Aug 2019 00:33:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 478E66B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 00:33:53 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id e18so71308596qkl.17
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 21:33:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=fZFuQhJdAkJuKtn8/ribFpyU7cHuntr5HchtAz3a1cE=;
        b=DOxfOliqvGf2Z6L21XV5l+5lLxmxBdymeM7G4Qo1v+PQ550cyNdJks1Xo9yaEePGn/
         tOu0EQ+Rz/6EX4d4N1QWYsHpVyBFUogpFIrIL4aGZtr32XZKFC4jQAcIRGZ6L6v9QbaP
         3/w7Rx/8xVunqw9no5L5IkA7NeehpDP3mlhCbxEpdlV95ZtpSaHwhb3jPQ7sas1VBDTz
         U9OZ/RLqnp9iP1Ubv05L+++TZI3BbrHHv0wF7Hd/k2/BEJHu+T+ypz5wQU6drLSdkLNM
         R0GXXEpCUZs4V9kF7FjObmqwLmC1UjoGaDQbZf5l68D6aR1iB4PKmfriLkpc8SxiZ4Wy
         houA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXD62B7ZwB5j44ESnrDI0Bi0TtXmLaVeFwLy1erygBqq5bsmXh4
	Wb+8T0YXKALkY+mVCb99O4iYiJHR3/WRWzD14NEwfBpcvTH/OvC0XCfF02rf3RQw6snEMuaJwVL
	+oBwI4o9gTjroa04lxKe5locYFN0SsIOeO8swQ/jzSUCmyPfVjkjLN1nfmZeZaX6cQA==
X-Received: by 2002:ac8:270e:: with SMTP id g14mr107430855qtg.65.1564979633040;
        Sun, 04 Aug 2019 21:33:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwC4LzqdrYwtfqShJFn8Z26k0zQp6zxQAWwvuGGZAEsj6j9b2cSiGUm/qiMooow8aUtzyhj
X-Received: by 2002:ac8:270e:: with SMTP id g14mr107430831qtg.65.1564979632400;
        Sun, 04 Aug 2019 21:33:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564979632; cv=none;
        d=google.com; s=arc-20160816;
        b=vbHqOfekb39IbMkpk8c3q1fkcAO9tlUvTeAhyVdoab9Frui8DW4MfxBI5xJjeZ72b3
         38xkdr3a2aWyT9dyQY3QMEuuNcx2dzvyoN1eQE55DkBYUevr7OLcmtG5+SUPvTjKcfGg
         Z9QZsKOavLB8Y8HrNubzJ5zOq8niowWJyy+zttvwOrNVwX4Y0Z3zjilyfzzLG+qsUDlR
         oUt/gpsbMPKHompUOf0kdtj/UxB+iN6wsn09DYI0gDWx6IkgwsPabSlxF0TVno4uJYZf
         ePT+vNxzboxI+e32GM6xFfQiYKyPiNhXf9C5/wcvme9jNpKNcX64c5immhxC+9EBY75w
         0XSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=fZFuQhJdAkJuKtn8/ribFpyU7cHuntr5HchtAz3a1cE=;
        b=aNk+rly4FAKBOfsYI4H9KR/2T8FdfOi5N3zxpLWyt1IduwR41p55uo6YR6OL5aCdSf
         kCuHolpH4LI7/nGzLkl+CJ/EtYk/dkJ0myx9P/nblnypRGNwCoxjlO1jclMDp6Yx2djU
         bbxMkxu0BPzUDYwjobfDHWkAor2ZqeusGvD9qNuoB1MMzEs8V4qnrepnySVTIwZDm7ce
         KhY+QpCTxyn2nOc5G4P3+sL0dJmbWmxwwZuC57dEeEN1YdXAWeYtoQNs2tMcSEEeVHjl
         7Qy74cYImjkeuOFrJvoq+xux9XHfAwpUlLf8qsJ7ZeOrNhbkYgzqIto1KXae5SWsAHJC
         p9qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l68si44505702qkb.227.2019.08.04.21.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 21:33:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8E5ED793C9;
	Mon,  5 Aug 2019 04:33:51 +0000 (UTC)
Received: from [10.72.12.115] (ovpn-12-115.pek2.redhat.com [10.72.12.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D987960127;
	Mon,  5 Aug 2019 04:33:46 +0000 (UTC)
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com> <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802094331-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <6c3a0a1c-ce87-907b-7bc8-ec41bf9056d8@redhat.com>
Date: Mon, 5 Aug 2019 12:33:45 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190802094331-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Mon, 05 Aug 2019 04:33:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/2 下午10:03, Michael S. Tsirkin wrote:
> On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
>> Btw, I come up another idea, that is to disable preemption when vhost thread
>> need to access the memory. Then register preempt notifier and if vhost
>> thread is preempted, we're sure no one will access the memory and can do the
>> cleanup.
> Great, more notifiers :(
>
> Maybe can live with
> 1- disable preemption while using the cached pointer
> 2- teach vhost to recover from memory access failures,
>     by switching to regular from/to user path


I don't get this, I believe we want to recover from regular from/to user 
path, isn't it?


>
> So if you want to try that, fine since it's a step in
> the right direction.
>
> But I think fundamentally it's not what we want to do long term.


Yes.


>
> It's always been a fundamental problem with this patch series that only
> metadata is accessed through a direct pointer.
>
> The difference in ways you handle metadata and data is what is
> now coming and messing everything up.


I do propose soemthing like this in the past: 
https://www.spinics.net/lists/linux-virtualization/msg36824.html. But 
looks like you have some concern about its locality.

But the problem still there, GUP can do page fault, so still need to 
synchronize it with MMU notifiers. The solution might be something like 
moving GUP to a dedicated kind of vhost work.


>
> So if continuing the direct map approach,
> what is needed is a cache of mapped VM memory, then on a cache miss
> we'd queue work along the lines of 1-2 above.
>
> That's one direction to take. Another one is to give up on that and
> write our own version of uaccess macros.  Add a "high security" flag to
> the vhost module and if not active use these for userspace memory
> access.


Or using SET_BACKEND_FEATURES? But do you mean permanent GUP as I did in 
original RFC https://lkml.org/lkml/2018/12/13/218?

Thanks

>
>

