Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1817C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:18:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 863EC20661
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:18:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 863EC20661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AD888E0003; Wed,  6 Mar 2019 14:18:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35E4F8E0002; Wed,  6 Mar 2019 14:18:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24D388E0003; Wed,  6 Mar 2019 14:18:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED2AC8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:18:56 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 207so10842769qkl.2
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:18:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=st67WvpYDi1ax5yhwOe1c4DnniPcrShdQe2ifGkKiEc=;
        b=pEBJUfMOS7wYiTu3NxkRNMRsPfYcNACa4Uuu3QevgVW58EmjIVgg/9VdGaepozgelK
         oHI1fSQ5xDSlAL8uam+QanrSJ9KUa04v0u/Dv7AT6awrARF17IYoDlj6Mj0p4xfvJSCc
         lHBnMlPzN2WtGld4jffDEl/vOCByZiOUHDs3pyfCRXZSBt8hiCZ0Yd9SUU+oH7sQIqNu
         zh7dIwcWD2esL0I+ACnQSeSWfuIGbI3MUQ9NQHpVOT7zLtaemQ85K6GbDOUqZJUxsbTE
         sVF6x2+EcwlFwqTXhwAfq8DyByRZWqFyPqKFpcrJXADCSkxbATxDbyMYjta9RlZLC1kV
         mN8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWJD5FlYyamiy9Dem3m4kQrJ2doRbErm4a8b/xYoUaijo6NyREB
	GenNarLEsiKDu5oj/3uAl8FgwJWJPAfPzZOsBvHDY2MqeOYSNsKHNqToeySXIpJ0pF2h7OoxsCi
	XmlGx40ZSD/ORx0yI4yT47KAv+YSpbxSSzmWRiOsQ8sOleTwJAgxZAinDmMLl2UjCcQ==
X-Received: by 2002:a0c:a9d7:: with SMTP id c23mr7829632qvb.24.1551899936700;
        Wed, 06 Mar 2019 11:18:56 -0800 (PST)
X-Google-Smtp-Source: APXvYqyYx5UnO1HH3IyK3bupgN2AeA4F4yi60KoTMA1dHR5CJ0xU9wUJuHJtoWzlH1tFtR34Fhn1
X-Received: by 2002:a0c:a9d7:: with SMTP id c23mr7829580qvb.24.1551899935834;
        Wed, 06 Mar 2019 11:18:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551899935; cv=none;
        d=google.com; s=arc-20160816;
        b=s4gagSgNmRH6YtM/N4guJHnND3ApkVZJ4PBkQibY4OOpkOrxnZL5wNaTFXlmQZYiRk
         ejiUkHtBupgF+m/UNiMewlX1MrOket+S0Sg8C9EZarjzPiF40W0lTv9lb/OZ2/Rn1n3U
         cF7+oeRFd7vDdLPp7XR+LWWOZoQpkbNbRnWE/8cJoVKO6+KsP7GjHgfHoYsur0+zkDNh
         F7DPZU8QLmEtBPFqPdW3MbuB2nUcRewLfR+mfZ8iGJ1Xsh8MgMsztKSD+xzRjddn0ydG
         f+IEp6C/Itsp6J4/Jt3REjpnDsPgCV9CvcU8cEhnsMSfnaFyggbvnI37br06Ehj7Mzc3
         PjeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=st67WvpYDi1ax5yhwOe1c4DnniPcrShdQe2ifGkKiEc=;
        b=v9oAcLU0cWEyBw9j/gil1avmTHDkeq8PKCNjK6cTbxb8wKT3hw5uvXyXwop16gzm/t
         OB5j4/MC/lsQnCXrsxYmgjroD62OZn4vda+u4G5qXTo6Aof6GmdBG7VsEmWUEWZQnlHk
         Zlcu80ee5UBMfvqtSO+jjDsiC2X2PjBG96IHTFI1yKyBfO4zBw9bmWMvt2po/mJ0IodD
         YBfRCM3rBJBl6givOJG23oNakYu7PHThHwb440EmW2N64WhLJrTenxWpUZTryw4nzOKC
         /UbxOd7m4pAGIUMWrpXEApVBhY7B4OW72t71PgPyqEmdKLGs0eNItlz3Fs0zDwS0Yw1I
         507A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m1si1445368qvc.72.2019.03.06.11.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 11:18:55 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EEB7B3082AED;
	Wed,  6 Mar 2019 19:18:54 +0000 (UTC)
Received: from [10.36.116.78] (ovpn-116-78.ams2.redhat.com [10.36.116.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0414460E3D;
	Wed,  6 Mar 2019 19:18:43 +0000 (UTC)
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
 <20190306133826-mutt-send-email-mst@kernel.org>
 <3f87916d-8d18-013c-8988-9eb516c9cd2e@redhat.com>
 <CAKgT0UdqCb37VNe7pABBYBXYFrVzYdPntmPf-V6ZYp9DdwmxYA@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <7b98b7b3-68f5-e4e0-1454-2217f41e46ad@redhat.com>
Date: Wed, 6 Mar 2019 20:18:43 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdqCb37VNe7pABBYBXYFrVzYdPntmPf-V6ZYp9DdwmxYA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 06 Mar 2019 19:18:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06.03.19 20:08, Alexander Duyck wrote:
> On Wed, Mar 6, 2019 at 11:00 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> On 06.03.19 19:43, Michael S. Tsirkin wrote:
>>> On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:
>>>>>> Here are the results:
>>>>>>
>>>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with
>>>>>> total memory of 15GB and no swap. In each of the guest, memhog is run
>>>>>> with 5GB. Post-execution of memhog, Host memory usage is monitored by
>>>>>> using Free command.
>>>>>>
>>>>>> Without Hinting:
>>>>>>                  Time of execution    Host used memory
>>>>>> Guest 1:        45 seconds            5.4 GB
>>>>>> Guest 2:        45 seconds            10 GB
>>>>>> Guest 3:        1  minute               15 GB
>>>>>>
>>>>>> With Hinting:
>>>>>>                 Time of execution     Host used memory
>>>>>> Guest 1:        49 seconds            2.4 GB
>>>>>> Guest 2:        40 seconds            4.3 GB
>>>>>> Guest 3:        50 seconds            6.3 GB
>>>>> OK so no improvement.
>>>> If we are looking in terms of memory we are getting back from the guest,
>>>> then there is an improvement. However, if we are looking at the
>>>> improvement in terms of time of execution of memhog then yes there is none.
>>>
>>> Yes but the way I see it you can't overcommit this unused memory
>>> since guests can start using it at any time.  You timed it carefully
>>> such that this does not happen, but what will cause this timing on real
>>> guests?
>>
>> Whenever you overcommit you will need backup swap. There is no way
>> around it. It just makes the probability of you having to go to disk
>> less likely.
>>
>> If you assume that all of your guests will be using all of their memory
>> all the time, you don't have to think about overcommiting memory in the
>> first place. But this is not what we usually have.
> 
> Right, but the general idea is that free page hinting allows us to
> avoid having to use the swap if we are hinting the pages as unused.
> The general assumption we are working with is that some percentage of
> the VMs are unused most of the time so you can share those resources
> between multiple VMs and have them free those up normally.

Yes, similar to VCPU yielding or playin scheduling when the VCPU is
spleeping. Instead of busy looping, hand over the resource to somebody
who can actually make use of it.

> 
> If we can reduce swap usage we can improve overall performance and
> that was what I was pointing out with my test. I had also done
> something similar to what Nitesh was doing with his original test
> where I had launched 8 VMs with 8GB of memory per VM on a system with
> 32G of RAM and only 4G of swap. In that setup I could keep a couple
> VMs busy at a time without issues, and obviously without the patch I
> just started to OOM qemu instances and  could only have 4 VMs at a
> time running at maximum.

While these are nice experiments (especially to showcase reduced swap
usage!), I would not suggest to use 4GB of swap on a x2 overcomited
system (32GB overcommited). Disks are so cheap nowadays that one does
not have to play with fire.

But yes, reducing swap usage implies overall system performance (unless
the hinting is terribly slow :) ). Reducing swap usage, not swap space :)

-- 

Thanks,

David / dhildenb

