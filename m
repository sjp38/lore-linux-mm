Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0BB1C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:22:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9808D2067D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:22:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9808D2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 425A36B0007; Mon,  5 Aug 2019 04:22:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D49E6B0008; Mon,  5 Aug 2019 04:22:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C3456B000A; Mon,  5 Aug 2019 04:22:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3246B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 04:22:23 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 5so71906122qki.2
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 01:22:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=lEaNxX3XzmPLqcSURK1tQYMD0oikhDBVeaVtJ0ZEBfc=;
        b=UHAn1EhEiA1QHGUV00+7QtXRXdOclFM51MONl+svqBCbQ/HwtBPxZowxqEySXu8uPp
         Vs2NvX1Ypn9pQuJkhqBt+oxHU7Sl2OM6bI2fFrwO/3yged8kr9j1HxvNsKqfl8lBZSmH
         joIIBv71PDE7U7pnnNgkBLOgpncO45kFRD2wsQQLTQn86UrbeUiPnzVJ/raNSfOcQ2YD
         k+Cbh3sJ4gFZxHuUiop056Rn1wsRBmlL0/XACDP5rf2A+HIdXz/3Qp+J0nuXLKiQlmdR
         cTb3gLXA4tywr0CmUFE4OPQmGx0ndw29R7IBfo52j+D6OJlvQY0BO9GRFV4vDM5Dncfh
         5FqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWRRiAjxu4E3c1BMMTlWv2NccnOuXMMd1WpSB+67qJPMo28MXwV
	Owtm1Pw0YH/wnmGvCBW3ucIVegJebgxr/IgLkf352RzQn8oxdn+L5Cw6roxXs9tpHnnU1tlm7U7
	iP9KIuSQEmyjmbwbnKFG1Pyc1EaE1cwmkW5wscgGzeBS6ARNy6HlyeClDi1/iipI3hA==
X-Received: by 2002:a37:5942:: with SMTP id n63mr26021869qkb.69.1564993342851;
        Mon, 05 Aug 2019 01:22:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyesMy20KONkimSsNGBMXLKbnvq6yL+JL0edxMHUOSC+TXy+5Wudz5YdcoJ6DW/PdlZsJ2J
X-Received: by 2002:a37:5942:: with SMTP id n63mr26021850qkb.69.1564993342378;
        Mon, 05 Aug 2019 01:22:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564993342; cv=none;
        d=google.com; s=arc-20160816;
        b=ohCrDzR2JJCv5bpMxGs7e8Far+moXh1oMHcGgkVyis3mKVCjTrHB3nnND90jxaJ0y9
         JBRwrVCjeyn8OClVbIOdFwfDQwazkAoBVKnvYi+p+7DwknaDSLeJzRJYLSkiIWrz2/EB
         7CWiVGXp3UryNPm9a3zPXG2moTIcS5yl69FZMI+abAOGV1PhUE8wGICUomA2xXPfvNMm
         7Q2HcVFgj/9+4iNpcWxjpdI8FbupvcaIby08AjxMyOKzLc/++4zGLsWSCC3/QeZ3WggL
         DH1jx/qZcmGmWNBgmfdomS5rIeh0ub3gkLK7/nNfmNB4g/PSSW0ioRgWztivdWhTBRZ0
         Za9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=lEaNxX3XzmPLqcSURK1tQYMD0oikhDBVeaVtJ0ZEBfc=;
        b=w7WFjdjnAZB0JP6SfK3XFR1TSk/SeBoPV8RMyJmKrGn+A8LztZLqVybHhGHJ+x8uXx
         n2UnDSaNgiWggI43Mb+V6vHyUlkgfzRaz2q4c4DCWXEPkmaExPZD7rnY91i82bzcnCov
         zCAr1EFuvZKsMrr0aoFfsHcAqJspWulrQagdsat+pWmSvtooEtmjf8z1JHXGrT+WqOm+
         nRIEPiRKkkgbXbHFjUD0MqX9hajL9b/3EOoFurBway72QiFubpcbqQdV2QSAKbPxonDV
         0AJtpx2nyHdz50/XZCL3yUX8AIMGz0RSeFwAafaCb+jjdFSptWvW6wpP2+t5rDK/mSf2
         frsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si9479509qkg.238.2019.08.05.01.22.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 01:22:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A704879705;
	Mon,  5 Aug 2019 08:22:21 +0000 (UTC)
Received: from [10.72.12.115] (ovpn-12-115.pek2.redhat.com [10.72.12.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E1DB55D9C0;
	Mon,  5 Aug 2019 08:22:16 +0000 (UTC)
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <e8ecb811-6653-cff4-bc11-81f4ccb0dbbf@redhat.com>
 <20190805022833-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <9d81ac79-1cc4-fba0-5aad-7acd8578d957@redhat.com>
Date: Mon, 5 Aug 2019 16:22:15 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190805022833-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Mon, 05 Aug 2019 08:22:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/5 下午2:30, Michael S. Tsirkin wrote:
> On Mon, Aug 05, 2019 at 12:36:40PM +0800, Jason Wang wrote:
>> On 2019/8/2 下午10:27, Michael S. Tsirkin wrote:
>>> On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
>>>> On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
>>>>>> This must be a proper barrier, like a spinlock, mutex, or
>>>>>> synchronize_rcu.
>>>>> I start with synchronize_rcu() but both you and Michael raise some
>>>>> concern.
>>>> I've also idly wondered if calling synchronize_rcu() under the various
>>>> mm locks is a deadlock situation.
>>>>
>>>>> Then I try spinlock and mutex:
>>>>>
>>>>> 1) spinlock: add lots of overhead on datapath, this leads 0 performance
>>>>> improvement.
>>>> I think the topic here is correctness not performance improvement
>>> The topic is whether we should revert
>>> commit 7f466032dc9 ("vhost: access vq metadata through kernel virtual address")
>>>
>>> or keep it in. The only reason to keep it is performance.
>>
>> Maybe it's time to introduce the config option?
> Depending on CONFIG_BROKEN? I'm not sure it's a good idea.


Ok.


>>> Now as long as all this code is disabled anyway, we can experiment a
>>> bit.
>>>
>>> I personally feel we would be best served by having two code paths:
>>>
>>> - Access to VM memory directly mapped into kernel
>>> - Access to userspace
>>>
>>>
>>> Having it all cleanly split will allow a bunch of optimizations, for
>>> example for years now we planned to be able to process an incoming short
>>> packet directly on softirq path, or an outgoing on directly within
>>> eventfd.
>>
>> It's not hard consider we've already had our own accssors. But the question
>> is (as asked in another thread), do you want permanent GUP or still use MMU
>> notifiers.
>>
>> Thanks
> We want THP and NUMA to work. Both are important for performance.
>

Yes.

Thanks

