Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D264EC19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:50:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9776921BF6
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:50:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9776921BF6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FDFA6B000A; Wed,  7 Aug 2019 02:50:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ADBC6B000C; Wed,  7 Aug 2019 02:50:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19CEB6B000D; Wed,  7 Aug 2019 02:50:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E60026B000A
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:50:04 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e22so15631786qtp.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:50:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=toE+6wtOlbNkJ/08bfCqpbMSQNddZO3CiuIGldc+Ghs=;
        b=jYNNbSZl8ojwTQHX9GJp/PBe0BB79P2Amyy3sBLPDR1NgHHK6fxDSV0/836cxaFIIo
         N3uIlwHyn+5x6CCcsfk2715dVgCDvoFWB6sruqcuNS7893qqFJzOQbMIdETuPsVKcl/y
         +gNJ7ZNwvGfsY5h8zOsLWRZkYbOBe7olpHx+KrJkoU4nMh7E5shh8znY8BXzXo+UggXN
         qfSNpiF+ebMwFIy+M08CCkmd0g0phBLVigEqIzS2ETyKZvnqDbBbojtdCHwkSQDx4mzO
         eFVI2b6bAL0+0CGy2Bg0Ik66j0O98Hi+uTovoim/PGwaZGqGr6GvzTAAdSqMS6rF1c5g
         m2hQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXjNu8JqAgpleO3d8hlOO8kDL9SdY0sHoL2lUNTgMCL06v6j+d8
	jsJjrjmGZkDXtrrMT+TE1+jQS2nu4hFQyIiDlubHI4pvGUzPM82o+oDzt4bh2D+taMoFe2iUOEN
	s0UVaUo+Dt1L3IAe46WT6RDTLY7H4lRSRCUuVqAzI2dJ91pCjI+9xm0ypNX/rn8ckUA==
X-Received: by 2002:ac8:2b90:: with SMTP id m16mr6556517qtm.384.1565160604688;
        Tue, 06 Aug 2019 23:50:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7zGDW3O/a3acJl0GmUsHiN48Q0owenHeNRzO9iEbvGRb3d9KJqxtoY6gdEpW+/NN3Qood
X-Received: by 2002:ac8:2b90:: with SMTP id m16mr6556480qtm.384.1565160603989;
        Tue, 06 Aug 2019 23:50:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160603; cv=none;
        d=google.com; s=arc-20160816;
        b=PKgZhhnuxjshpsQm+qOPEJn/UdqZ4LJ1kGHJ477GAsPnsaf8/wZOlJBCs/flJPZoHx
         bLpXHxvd0QazwWmeADDt+wfKAsScDYDVpp6GltzlaoiJgZCz21wS7UVXQ10LqJeS5xbV
         Rz96Yh98qITM36VpZ+rYOEFIYZ11xEOjRBEMhjAVfXHr12UOmRq7qSO4+gXsS4xApxlZ
         8gHo5MNMlrifWpZG8jc6SuE0iRvJ0AbYApg0OMD/sBjuohWoca+TUHappTB3CvNdJdav
         oCVSF37sFDWE2m+JlDihkVDyF88BBeMaYDpGnqLl2jLKqQ4e7o9U017Lg3vcJl0u80nx
         wDDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=toE+6wtOlbNkJ/08bfCqpbMSQNddZO3CiuIGldc+Ghs=;
        b=GyLm0wN+KBQQ3decQh3Dw0dStGhQm6c2ne6/Wxy4KDLnI41LP13M7wcIse684U/Qfx
         RHbg9ZDb7X6r9NvPxHtYVmVJBwDGKGUErbFplZtSOioel/GEH3czrG8TtM1JL5EczaUZ
         pSnUNSFX9Nj96IH5w1v23QvmSK+kEAh2jzCcRJ7eZV9F9assCCx5P4jN88f7zJbtCWSA
         WParOK88VRrN6y1bdYJECvUwkRjhsMGADfvqkUey/OCrtnnXC4KTSNIBwhPCeNiZa6n9
         CsrunvnXn7XN8eeUMCpqSVPLqJQDeTHB7s67ohVNi/LXAUSz7gPQACTMJ6Yi+VveIq4I
         H5zw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j26si2076853qkl.156.2019.08.06.23.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:50:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2729730DDBD8;
	Wed,  7 Aug 2019 06:50:03 +0000 (UTC)
Received: from [10.72.12.139] (ovpn-12-139.pek2.redhat.com [10.72.12.139])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7BBF825263;
	Wed,  7 Aug 2019 06:49:58 +0000 (UTC)
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com> <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <11b2a930-eae4-522c-4132-3f8a2da05666@redhat.com>
 <20190806120416.GB11627@ziepe.ca>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <4b448aa5-2c92-a6ca-67d6-d30fad67254c@redhat.com>
Date: Wed, 7 Aug 2019 14:49:57 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806120416.GB11627@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 07 Aug 2019 06:50:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/6 下午8:04, Jason Gunthorpe wrote:
> On Mon, Aug 05, 2019 at 12:20:45PM +0800, Jason Wang wrote:
>> On 2019/8/2 下午8:46, Jason Gunthorpe wrote:
>>> On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
>>>>> This must be a proper barrier, like a spinlock, mutex, or
>>>>> synchronize_rcu.
>>>> I start with synchronize_rcu() but both you and Michael raise some
>>>> concern.
>>> I've also idly wondered if calling synchronize_rcu() under the various
>>> mm locks is a deadlock situation.
>>
>> Maybe, that's why I suggest to use vhost_work_flush() which is much
>> lightweight can can achieve the same function. It can guarantee all previous
>> work has been processed after vhost_work_flush() return.
> If things are already running in a work, then yes, you can piggyback
> on the existing spinlocks inside the workqueue and be Ok
>
> However, if that work is doing any copy_from_user, then the flush
> becomes dependent on swap and it won't work again...


Yes it do copy_from_user(), so we can't do this.


>
>>>> 1) spinlock: add lots of overhead on datapath, this leads 0 performance
>>>> improvement.
>>> I think the topic here is correctness not performance improvement>
>   
>> But the whole series is to speed up vhost.
> So? Starting with a whole bunch of crazy, possibly broken, locking and
> claiming a performance win is not reasonable.


Yes, I admit this patch is tricky, I'm not going to push this. Will post 
a V3.


>
>> Spinlock is correct but make the whole series meaningless consider it won't
>> bring any performance improvement.
> You can't invent a faster spinlock by opencoding some wild
> scheme. There is nothing special about the usage here, it needs a
> blocking lock, plain and simple.
>
> Jason


Will post V3. Let's see if you are happy with that version.

Thanks


