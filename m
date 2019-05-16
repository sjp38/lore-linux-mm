Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56CFFC04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 07:08:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E182920848
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 07:08:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E182920848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 336786B0005; Thu, 16 May 2019 03:08:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E6316B0006; Thu, 16 May 2019 03:08:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D5586B0007; Thu, 16 May 2019 03:08:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5EF96B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 03:08:36 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id n9so944546wrq.12
        for <linux-mm@kvack.org>; Thu, 16 May 2019 00:08:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2QFBfiR8VI/6EkQt+vuqBNOU1C/FdNF/sGlGiprXM9A=;
        b=jtwC90SXH6U3WkCD63Ga/KTm9/VfyuubTz50UU8dzsRFF/FKZVznDraft1/l0ESGGQ
         zHTB2uTBmcQdCY/jysPSVNf6H0bEMAouVxppMiAv9TAWrQXIjnAJHv1ggiG5wvi3S00i
         3B+JWuwiyq/sO1kHeupv2YhOa/0dXVLvaZrajNYp6ryhLYWJ6U64hmSNiTtPCVje+0m8
         sEdbsArAUI5dJI38KCkTgqhZBPfUXoJ4AZsNOIyH/oTU8A2xU2haVCzykUgqebhQIs+B
         cvG69iuBUUogHV+K/ZHhdJzzZywcLc8YlMW9ix94MN6aTyrQVlf6sbM8DQ0N/mvn2f/e
         PonQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kheib@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kheib@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXUf71VVW+mjD4d+n9bD6N2Wgth7g/oYlWN7zojQR7R+rqzr6uD
	CJF1wNTQ4tLH+Ejc8A5/h+RTneznlyV1nnjVcHKiMioJRwHVBtZ7d7U2wxRpusaUgph4YVh+Zx6
	kdMgl0Yc0CCsSLRa+dEvS4qKvLIjH4+ESEcWUWnCvGvoRhiZkUvkOuiQbMR+6tao5lA==
X-Received: by 2002:adf:aa0a:: with SMTP id p10mr19260623wrd.125.1557990516283;
        Thu, 16 May 2019 00:08:36 -0700 (PDT)
X-Received: by 2002:adf:aa0a:: with SMTP id p10mr19260571wrd.125.1557990515408;
        Thu, 16 May 2019 00:08:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557990515; cv=none;
        d=google.com; s=arc-20160816;
        b=gSxhYKFWQ1ajWatLT8kFNOVOs78WXHadlX+qDKEYjwjPZ1ychm8uZlJLFLaafP4b2J
         grr11hj3gIA5u9PkcHbNs/oK1QyPCQms6Fh90PgQS2g7LP+SSI17YxsAbxQEfjXkRZ7C
         /CACI0CyDklvonVPA38OW3jmw5v5/XhGxepUlvA2KEEbO4pe2chsWETdUUuyhlANATFI
         t0Aa0+/7AuxKMX/41epu1avqrWbhCA88RQp+9S+Na6GV7e+SbzRVQa434QwErbpuN5NQ
         DdGu+XkO8/vqSnsIK9LlRbmxO94wkxZVJbI8bUTZbNO0I4RErP1pB8OmZOSd3Q5PgPUh
         t34A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=2QFBfiR8VI/6EkQt+vuqBNOU1C/FdNF/sGlGiprXM9A=;
        b=BI025C3iIt0G5cvGP4wiOJRmhYNVVtOYNeuP5teLcRoOsiINgokVZJAzN0+IZe57Gc
         NysPdLZGuPZGGqiSlhCfKdRvNCpuh0KuQqtUD/ibdCh03wDbkbGLKmL811wQvTYBVyAZ
         8SBm/wXql+GPeY1vE3N6PKbf/jUp3O/J5625ztxPpEO2KjLjSuzWFWcAXbO4uMlWEnEr
         stUZjpUYIdhMLp/jmBgJbwPN2ZwfLjvtwEmkN+dTloPl7E4DpWy/vWhMaLvi2XHZXp6B
         6nsvBoQbPPTrFsTRVSHJ4n3GmMfoFbn/x2thkbndFg5mFTtBzGLNnJbEd9lhIY4TOGpX
         +YmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kheib@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kheib@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19sor3627986wrd.13.2019.05.16.00.08.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 00:08:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of kheib@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kheib@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kheib@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw/XTuFioPhzaxrGOO8i0SgiDZ+sf087TBN/7+xA54JWipsUns+nX80rrXU1SpsZxTYHNrcCg==
X-Received: by 2002:adf:8184:: with SMTP id 4mr30276940wra.27.1557990514979;
        Thu, 16 May 2019 00:08:34 -0700 (PDT)
Received: from [192.168.1.105] (bzq-79-181-17-143.red.bezeqint.net. [79.181.17.143])
        by smtp.gmail.com with ESMTPSA id s10sm3062588wrt.66.2019.05.16.00.08.33
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 00:08:34 -0700 (PDT)
Subject: Re: CFP: 4th RDMA Mini-Summit at LPC 2019
To: Leon Romanovsky <leon@kernel.org>
Cc: Yuval Shaia <yuval.shaia@oracle.com>,
 RDMA mailing list <linux-rdma@vger.kernel.org>,
 linux-netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>,
 Marcel Apfelbaum <marcel.apfelbaum@gmail.com>
References: <20190514122321.GH6425@mtr-leonro.mtl.com>
 <20190515153050.GB2356@lap1> <20190515163626.GO5225@mtr-leonro.mtl.com>
 <20190515181537.GA5720@lap1>
From: Kamal Heib <kheib@redhat.com>
Message-ID: <df639315-e13c-9a20-caf5-a66b009a8aa1@redhat.com>
Date: Thu, 16 May 2019 10:08:32 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190515181537.GA5720@lap1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/15/19 9:15 PM, Yuval Shaia wrote:
> On Wed, May 15, 2019 at 07:36:26PM +0300, Leon Romanovsky wrote:
>> On Wed, May 15, 2019 at 06:30:51PM +0300, Yuval Shaia wrote:
>>> On Tue, May 14, 2019 at 03:23:21PM +0300, Leon Romanovsky wrote:
>>>> This is a call for proposals for the 4th RDMA mini-summit at the Linux
>>>> Plumbers Conference in Lisbon, Portugal, which will be happening on
>>>> September 9-11h, 2019.
>>>>
>>>> We are looking for topics with focus on active audience discussions
>>>> and problem solving. The preferable topic is up to 30 minutes with
>>>> 3-5 slides maximum.
>>>
>>> Abstract: Expand the virtio portfolio with RDMA
>>>
>>> Description:
>>> Data center backends use more and more RDMA or RoCE devices and more and
>>> more software runs in virtualized environment.
>>> There is a need for a standard to enable RDMA/RoCE on Virtual Machines.
>>> Virtio is the optimal solution since is the de-facto para-virtualizaton
>>> technology and also because the Virtio specification allows Hardware
>>> Vendors to support Virtio protocol natively in order to achieve bare metal
>>> performance.
>>> This talk addresses challenges in defining the RDMA/RoCE Virtio
>>> Specification and a look forward on possible implementation techniques.
>>
>> Yuval,
>>
>> Who is going to implement it?
>>
>> Thanks
> 
> It is going to be an open source effort by an open source contributors.
> Probably as with qemu-pvrdma it would be me and Marcel and i have an
> unofficial approval from extra person that gave promise to join (can't say
> his name but since he is also on this list then he welcome to raise a
> hand).

That person is me.
Leon: Is Mellanox willing to join too?

> I also recall once someone from Mellanox wanted to join but not sure about
> his availability now.
> 
>>
>>>
>>>>
>>>> This year, the LPC will include netdev track too and it is
>>>> collocated with Kernel Summit, such timing makes an excellent
>>>> opportunity to drive cross-tree solutions.
>>>>
>>>> BTW, RDMA is not accepted yet as a track in LPC, but let's think
>>>> positive and start collect topics.
>>>>
>>>> Thanks

