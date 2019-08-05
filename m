Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0141C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:21:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1EB220818
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:21:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1EB220818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AF996B0006; Mon,  5 Aug 2019 04:21:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3601A6B0007; Mon,  5 Aug 2019 04:21:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24FB86B0008; Mon,  5 Aug 2019 04:21:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07C4A6B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 04:21:57 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 199so71992051qkj.9
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 01:21:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=uE9Q4feKFTcgOQ7Fr9y+lLMwYFyv/7xY6FiTZqnwhgk=;
        b=T2yIRPX2nM0geChKejerwyfZMfKGsZPVok5ILYwHKhEnBCzmfMQcVDhdasz3sNPeAE
         fUd7wSFSq6k/i1KOcdYjOgDtYNx4osUCxpMtRcCYJQ+IMT9GTssTnOWAzfB9YYynJ9Ge
         w4stN1dBnjOVh00DXdgJtQKZFpUj3QefPCvzeknDj4hnIuwWFyAOM9OisbOFp+THRqxk
         nBZHfMsA8lsBrKQR66bIxg4+r5dGdoukGBzKdgsgw3edptfxOLEfQGjKSznXCkFjJhoL
         Nsn9ZIwlDC1Qq/62zc5FCf8SsfKNOcgCUvsluE8DSjbBBJlpPybnvAuFiZo6pcd3UJ8t
         DEUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWzl2hSyZzlohQduN0rHjgmD8LTo1tgsL/TpQGkgcHfFcllJUpn
	NpYa4QwIYONkZ9DBKfuUeygFU7H8hhPdVshKWJ+kXkjnaWlfsLdlAWd7illGo84H15HQDAOX/AI
	h6/xtkl3vua92mHUUGVKge/guzvqbE6FqN3QmjrvXHNJsLrKtqBWdC5uf/OxSPnk8ZA==
X-Received: by 2002:a0c:becb:: with SMTP id f11mr94500847qvj.33.1564993316790;
        Mon, 05 Aug 2019 01:21:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTQyG2oYLdDjT+YI2rXdj+IuFzf3W2jGifqSms4TIs9IIcL6JxECzL//frEIgvW3n0O3qe
X-Received: by 2002:a0c:becb:: with SMTP id f11mr94500826qvj.33.1564993316102;
        Mon, 05 Aug 2019 01:21:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564993316; cv=none;
        d=google.com; s=arc-20160816;
        b=sxb87pyzuL2FRr2JMoGEAj2MJ6Ns7IsaBppt3JyNOS2rFHGHU+FrhBC3z0FM/8zwyE
         9t51Ekelv6bHJf/eIL7wbNfqMLS1B+SiRJQngkfvfNxPSkEyuo4bB06rs8o4kdzadIEl
         5XoSXdujiP5ATNOXSuTnqZPyYvnVtAd2ku/WcL4r/w0kyw03XxYKu+Avd4QusHrMOCFY
         hwg4jQH6PLdZ/ne3zUmZWJDMG7dW+6iwtZzQPPYKBGiGYx8h+kBkpzlb24x5dsDJ3ATk
         RwsGIwqVyF9VqmXheZHdriAS1DCXcdniYhzH/VhUUgrevRo2y+Ak2zOVWtI2ys6pq34M
         0pdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uE9Q4feKFTcgOQ7Fr9y+lLMwYFyv/7xY6FiTZqnwhgk=;
        b=HgX0qXXcO3JCxo5QgdKyxdoQileRH6kV8RsDVNF+nAU4k8vr7c2YrAUtsUl6sHTd96
         g09S0ENpea3VjU6CVlZjDeY2HQUlrBKCo6yPwndvdQDBvdVH6V2FEVQi0soLpQz3pOJ6
         N/3GlUg5SXOfPZCbDHtY9LIvAHquTW+NdcFPc1k3HvQF/lY9UgxFZJPnJ6y2pX2pwco3
         kIvAKca+e/ysZ/hMZJ3Xbj6zWuLoIzM5apE/nmoFvV1UBOpqjGRAadqjku/MGlP2xIGh
         nOkKJ02g6QQTu3oDpBPrTFSrs976FEIfidQoCTrdSxPNJ4ON9v6U06HAdpwK61G2Sk5u
         GPoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r5si48089587qtk.221.2019.08.05.01.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 01:21:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 41395309175E;
	Mon,  5 Aug 2019 08:21:55 +0000 (UTC)
Received: from [10.72.12.115] (ovpn-12-115.pek2.redhat.com [10.72.12.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 176741000321;
	Mon,  5 Aug 2019 08:21:49 +0000 (UTC)
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
 <6c3a0a1c-ce87-907b-7bc8-ec41bf9056d8@redhat.com>
 <20190805020752-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <817bad8f-6a7d-e192-3a3f-621de7b0300b@redhat.com>
Date: Mon, 5 Aug 2019 16:21:48 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190805020752-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 05 Aug 2019 08:21:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/5 下午2:28, Michael S. Tsirkin wrote:
> On Mon, Aug 05, 2019 at 12:33:45PM +0800, Jason Wang wrote:
>> On 2019/8/2 下午10:03, Michael S. Tsirkin wrote:
>>> On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
>>>> Btw, I come up another idea, that is to disable preemption when vhost thread
>>>> need to access the memory. Then register preempt notifier and if vhost
>>>> thread is preempted, we're sure no one will access the memory and can do the
>>>> cleanup.
>>> Great, more notifiers :(
>>>
>>> Maybe can live with
>>> 1- disable preemption while using the cached pointer
>>> 2- teach vhost to recover from memory access failures,
>>>      by switching to regular from/to user path
>>
>> I don't get this, I believe we want to recover from regular from/to user
>> path, isn't it?
> That (disable copy to/from user completely) would be a nice to have
> since it would reduce the attack surface of the driver, but e.g. your
> code already doesn't do that.
>

Yes since it requires a lot of changes.


>
>>> So if you want to try that, fine since it's a step in
>>> the right direction.
>>>
>>> But I think fundamentally it's not what we want to do long term.
>>
>> Yes.
>>
>>
>>> It's always been a fundamental problem with this patch series that only
>>> metadata is accessed through a direct pointer.
>>>
>>> The difference in ways you handle metadata and data is what is
>>> now coming and messing everything up.
>>
>> I do propose soemthing like this in the past:
>> https://www.spinics.net/lists/linux-virtualization/msg36824.html. But looks
>> like you have some concern about its locality.
> Right and it doesn't go away. You'll need to come up
> with a test that messes it up and triggers a worst-case
> scenario, so we can measure how bad is that worst-case.




>
>> But the problem still there, GUP can do page fault, so still need to
>> synchronize it with MMU notifiers.
> I think the idea was, if GUP would need a pagefault, don't
> do a GUP and do to/from user instead.


But this still need to be synchronized with MMU notifiers (or using 
dedicated work for GUP).


>   Hopefully that
> will fault the page in and the next access will go through.
>
>> The solution might be something like
>> moving GUP to a dedicated kind of vhost work.
> Right, generally GUP.
>
>>> So if continuing the direct map approach,
>>> what is needed is a cache of mapped VM memory, then on a cache miss
>>> we'd queue work along the lines of 1-2 above.
>>>
>>> That's one direction to take. Another one is to give up on that and
>>> write our own version of uaccess macros.  Add a "high security" flag to
>>> the vhost module and if not active use these for userspace memory
>>> access.
>>
>> Or using SET_BACKEND_FEATURES?
> No, I don't think it's considered best practice to allow unpriveledged
> userspace control over whether kernel enables security features.


Get this.


>
>> But do you mean permanent GUP as I did in
>> original RFC https://lkml.org/lkml/2018/12/13/218?
>>
>> Thanks
> Permanent GUP breaks THP and NUMA.


Yes.

Thanks


>
>>>

