Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15B1CC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:36:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC9B320644
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:36:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC9B320644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 716586B0003; Mon,  5 Aug 2019 00:36:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C7306B0005; Mon,  5 Aug 2019 00:36:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DBE46B0006; Mon,  5 Aug 2019 00:36:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCCE6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 00:36:49 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id z13so71413125qka.15
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 21:36:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=gR9sigFYcoTvk9gZJoQ+Y4sNtzlVCmazG54lrOB5Moc=;
        b=pnLCM90+f/B5cJZRfq+tgpVOZ3pwbMPpNanqmXCiuj8CBgdBAvxxDh5iAEYLG2paWd
         0WkM/ctj5iHZ2/zQdefMNrYEVcMYaH9DoL3Rv7KVRGVCKFP3D3s/fvYSszrpwNw9jUGa
         H01gpQG0h8aGGe5L0DqSzF+cBApcxRtr1MFZShP8tvF1v1InZydnsL2Lmx1LS2bqlUon
         eRx2Nbujg54ubDdMaQhypGcccNRDU9xQhQZwlg6lImJyEemDE5YxxP2gwclaMI2/xZoj
         WMGxsmbPfWu7lGGBrvEtCsCvSthbhhGEZ7RLf1paD8Lj4x+UsIMZj+WTHQ18fOG1fZZb
         63JQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV6fbgwBEwyI5LKRUAcd05F7XLepEnGWGSzu0ekcsukow6MFGGn
	5n/pzX3p80K8Ii4NQAi806GLX5uF7ZQ2MolbrKkEkqYmYQXipgvzFiLZoNvfdGaU7yBvGHEdTAj
	QhVIZZxB+4V4x+nOBSqVYgYyOmV0hOD9A0hLynSyqi6DBO+j9z4T1nvDXeE/mJ7zxUA==
X-Received: by 2002:a37:4f16:: with SMTP id d22mr101941016qkb.307.1564979809029;
        Sun, 04 Aug 2019 21:36:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZLJKQFgU+LkoLfltZ3qgo1vxBcJzz23XP6NcMq+bb9L1CnLYx8A3IQ0wkwdF87py85slc
X-Received: by 2002:a37:4f16:: with SMTP id d22mr101940998qkb.307.1564979808509;
        Sun, 04 Aug 2019 21:36:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564979808; cv=none;
        d=google.com; s=arc-20160816;
        b=O6qnYpKMm8n7cE5oqXk2K7w+G0tYh7lx24I0uaCw+yOghc7CrQtwN9Huskmz5GhESX
         ABO/9ctP1zCwmQeHpS6xDuTqcf9clKM6CmJyjZOzYds4vUuycgMHMlUrb4QflK2YsvA+
         Bntpc7ODO5iix96+NsDutdujPAOOPgtowqOPDY3nVhEnI3evOc1zEMGAIOzmTXmLpI7n
         rJI6i+yWpvqGVK44gZBW4JcWAPIXVLx8/fBDDSzLu3vabtDkCGnDYoqD4wgKXB35c7QA
         g5lBotn7jBb4h+XLkJ/QAVtyY1ho3pZqPPwL/TbMtUZ1k3LBAE6tXakyIjCP/hJKx3Yy
         EoKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gR9sigFYcoTvk9gZJoQ+Y4sNtzlVCmazG54lrOB5Moc=;
        b=U8Gq0RxXxC9wGBZZs5n/5u/Qmk8umqJHcb54fYa+4YYjNSznB/SzPkl/CYP1FQoGbK
         XBqfgLI35mixdrGyRj4nusQXbPIMGvkJwz5E6h9ssoHbEKBKlE8hHtTZTJnUvH0gNLdD
         A6yv5jlmqT7MR8OWL8ZqLJfvncI7HqCX5Xh42HDK7scZne5b4Jr074aDOH05IEBrfCuh
         EZi9tDjYZRid7HRqq5cG1GxO/KGsCDzCqBcNDhPI3HK5ag2u63KPPqtlBMSuZJW5Io/6
         4sFPdaZxaetvmTHcEfAbCnW9amumZ0JNhdiwz/yyFqRGRwua4/pFvj1oNxuOTjYVKrQs
         /Rmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s124si18009695qkb.5.2019.08.04.21.36.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 21:36:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9FDEA30A5408;
	Mon,  5 Aug 2019 04:36:47 +0000 (UTC)
Received: from [10.72.12.115] (ovpn-12-115.pek2.redhat.com [10.72.12.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B7AA560856;
	Mon,  5 Aug 2019 04:36:42 +0000 (UTC)
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com> <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <e8ecb811-6653-cff4-bc11-81f4ccb0dbbf@redhat.com>
Date: Mon, 5 Aug 2019 12:36:40 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190802100414-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Mon, 05 Aug 2019 04:36:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/2 下午10:27, Michael S. Tsirkin wrote:
> On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
>> On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
>>>> This must be a proper barrier, like a spinlock, mutex, or
>>>> synchronize_rcu.
>>>
>>> I start with synchronize_rcu() but both you and Michael raise some
>>> concern.
>> I've also idly wondered if calling synchronize_rcu() under the various
>> mm locks is a deadlock situation.
>>
>>> Then I try spinlock and mutex:
>>>
>>> 1) spinlock: add lots of overhead on datapath, this leads 0 performance
>>> improvement.
>> I think the topic here is correctness not performance improvement
> The topic is whether we should revert
> commit 7f466032dc9 ("vhost: access vq metadata through kernel virtual address")
>
> or keep it in. The only reason to keep it is performance.


Maybe it's time to introduce the config option?


>
> Now as long as all this code is disabled anyway, we can experiment a
> bit.
>
> I personally feel we would be best served by having two code paths:
>
> - Access to VM memory directly mapped into kernel
> - Access to userspace
>
>
> Having it all cleanly split will allow a bunch of optimizations, for
> example for years now we planned to be able to process an incoming short
> packet directly on softirq path, or an outgoing on directly within
> eventfd.


It's not hard consider we've already had our own accssors. But the 
question is (as asked in another thread), do you want permanent GUP or 
still use MMU notifiers.

Thanks

