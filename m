Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB4D9C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:06:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77E2F2067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:06:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77E2F2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04D2C8E0003; Mon, 29 Jul 2019 17:06:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F40408E0002; Mon, 29 Jul 2019 17:06:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2E948E0003; Mon, 29 Jul 2019 17:06:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE9B48E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 17:06:38 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id n185so27098020vkf.14
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:06:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=B3H3C6ZPDZLEX1ZSFVklsnEgxt450nda5vCqv3ww180=;
        b=WpN5RSOJirs62/P5tNik2V8GIdpVHDbbG+RPEKmbcs83RKBfQZCuVWaJdIeRXRCP56
         8ipQeGmia6tk7eaPyarNq7NtLhMbzM2Sg3Z0y0/FBc5/uG95qGdLoZ4jz1Pa97yodkTH
         gUQO9/8pm6z+oSF4pCwQnCK1M9FPRkVCEgiG+P7UFJGakioNjFgGwC/CMslKPfd/tnca
         rCrIb6GNgCOl1bXWXOmnzO8XwpPhjGBFzbRYq6tXxwgKBAZ2KR0PW42Gj1XZ6T30lCk8
         8M7PyEvMd4PEHedsLn7HoM5l2+RsjOnKuQmijAJyljAYsOZJwvcFML4LCL2/APIixSsm
         OuaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWvKnaiyqy9X6DMC6u/pjogNbT8cLUuL57okjns3q1mLVSCdY2j
	mtCK8qUaQNquKqBGarIZm36O+gj724u+uFEzmZiMieawJwR4tWIQ1T4Ay1/6dQXuWdd6T6+2vMP
	j06srai64hRA+UvLriIaZZfKqMNLsUN4vqwH9aRBgBS2OWCUyZ6Nq+JA2jsuSvMaKKg==
X-Received: by 2002:a67:fe0e:: with SMTP id l14mr9177897vsr.146.1564434398583;
        Mon, 29 Jul 2019 14:06:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdaNUN6mj3vc491bB1mOs/8qTOalVkWfCrFmJ2FfNhwRYgbq2qKS41yUBRznN20cXiVI+Y
X-Received: by 2002:a67:fe0e:: with SMTP id l14mr9177827vsr.146.1564434398030;
        Mon, 29 Jul 2019 14:06:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564434398; cv=none;
        d=google.com; s=arc-20160816;
        b=i4b2cpcq0zwM7vIKlt2aQiaEJw92AyVElL7UoXmGeJWeM37WzRQGFkt8WVl+k7cg7A
         5dd8FbpTXzpiF7BTmOJDVUrK05ygfeE6TbrnsVFCQWG/yDJepN/xfRA09LiyY9sbIJZX
         f+daDS3xesvRUXyDh33zRTLk3NmMB7ISKHbqdy/gXOj8zkrm/GoUcMVVBj8/MgW1NA1t
         NvUPBRTvs2oHAeUpwtLWpNRza6nPc1sqg4B7GZ9XpWz/PjN17DjtXJbhZrOz58dK5BBx
         qzrqZf5FpsaDjZtNeDxPk478pSaIXgi0q0k2b+p5wD/OKA4pa7y5GMIkGFYinFkQxeMP
         68iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=B3H3C6ZPDZLEX1ZSFVklsnEgxt450nda5vCqv3ww180=;
        b=k6rTJAWEmqTZcwA6XgQ+FoBVa/861X2BdHGgiY3/+OgTyBSjfYhZ7sXP+ybh235WGw
         01MAcEPhIHRrGHk4tbeX38S9f61YKx45fu2LkwYfvA6hsh6+xhQh/WtvEx4bJkb9aMQk
         cgqHq+alG4kOlY/r4JCm6TX9vNFbHtoXtRHHsC6LEoLq+3i+odcKoC2kpdUKQCQvDfPB
         BN3py9dX+LXs6QAqHr4ZBCwsob/d2WnexRqN0qNjbYxPuonexmuyhbGxr79WwsLJvf0J
         RyQUBiOIkPAH90ivL9+upB7hDwEroRpotZ+91yOZOHxgNZMTKwuQmnlRJE7v24J1qJjc
         shcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h6si13831512uac.127.2019.07.29.14.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 14:06:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D2FB37FDEC;
	Mon, 29 Jul 2019 21:06:36 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 044505C1A1;
	Mon, 29 Jul 2019 21:06:35 +0000 (UTC)
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Qais Yousef <qais.yousef@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729081800.qbamrvsf4rjna656@e107158-lin.cambridge.arm.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <be28b3d2-3f94-806b-874d-db2248a2c3a9@redhat.com>
Date: Mon, 29 Jul 2019 17:06:35 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190729081800.qbamrvsf4rjna656@e107158-lin.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 29 Jul 2019 21:06:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 4:18 AM, Qais Yousef wrote:
> On 07/27/19 13:10, Waiman Long wrote:
>> It was found that a dying mm_struct where the owning task has exited
>> can stay on as active_mm of kernel threads as long as no other user
>> tasks run on those CPUs that use it as active_mm. This prolongs the
>> life time of dying mm holding up memory and other resources like swap
>> space that cannot be freed.
>>
>> Fix that by forcing the kernel threads to use init_mm as the active_mm
>> if the previous active_mm is dying.
>>
>> The determination of a dying mm is based on the absence of an owning
>> task. The selection of the owning task only happens with the CONFIG_MEMCG
>> option. Without that, there is no simple way to determine the life span
>> of a given mm. So it falls back to the old behavior.
> I don't really know a lot about this code, but does the owner field has to
> depend on CONFIG_MEMCG? ie: can't the owner be always set?
>
Yes, the owner field is only used and defined when CONFIG_MEMCG is on.

Cheers,
Longman

