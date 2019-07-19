Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9B36C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 14:07:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D4E82186A
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 14:07:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D4E82186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19A886B0007; Fri, 19 Jul 2019 10:07:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 124C28E0003; Fri, 19 Jul 2019 10:07:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2DA78E0001; Fri, 19 Jul 2019 10:07:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id CBA1C6B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 10:07:25 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x1so27788854qts.9
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 07:07:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=CpmT1vkqvZqsdSQbFuCpNH/AnuhPq6FWS5ZPuhy1Dd8=;
        b=MEzNn437NdeyYsdnjfb0Iwlt8bRMlnFvpoRlbCtkDk2WvgRu4ugsSczUf2Ivd61eAN
         NivCvE3XgL7+QqZcqUEYPFs8JXnH8zNrCtAP4JVYcwm5ZRpnea3wnjuLDoT8Blm/iRPh
         EvlnXa73rQn+Vn8QAk2qNkx3requ2CpY4oWan/LJhG7eK6kPbg5kmyhGdZYmY/1COBAw
         aV7RFyTC5lbWuwpBJFHN2USiTo7/JmYL18l3Y+KBInpgNowCkLXbupY9KpDixZDcdP8D
         vJ0mu7gbvJ/Bg8BgESpKKrgASupEqEe9dnfckHiFGrmUqh6qzcEfylSFHtYRNgkJ0WIr
         SiOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWnLY3rFRZQ7U9mhvdjvpSj6mq6j+bsII+C2oKrIYklkGBV4hnA
	ZgNECkUyK/wHA2m7Xe5KPCFQd1m9RICnkCCbnoA/NoPc2X1hmdzVVeXZKQVOSpfseWwTiixo5q1
	Wsx5trO6LFGg1GfCPF3kzS/CD4kSGwXwF2OgsqG20zMwlr3vK3RkJ1JnSM5FvHDxiag==
X-Received: by 2002:a37:9844:: with SMTP id a65mr35184553qke.500.1563545245636;
        Fri, 19 Jul 2019 07:07:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtYN0qA17KvIOGu1Lvd5P4qfSn2Q+aH7G6YkzPs1gR7dyxtF3O6vg9zpmgB65pjRNNiXcY
X-Received: by 2002:a37:9844:: with SMTP id a65mr35184511qke.500.1563545245078;
        Fri, 19 Jul 2019 07:07:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563545245; cv=none;
        d=google.com; s=arc-20160816;
        b=ri+z+kyBEX7SU+NsRjZBjoVkYfkpsPwMBIol9ZlH+942xA93ZuFAhyu1/5I/SjNjjL
         te4cNQLm6Yz+1x0KTDT/tcoRrCLDIcVXmWSoCAc2Ltd6b65bG/l8VjeVFS50IQormhSO
         R+m5Ynf8Yy2nxin094nNI3wzcQ/pZBN+Hkf1/Pc5fgYkwdGYsp3+bXfGmNaEIr3f6YxK
         X6SFTHOfcvHHEJrb+PsyWEC1+gr+mhOuzXdtWp/RGBKtBMjv89nOfX/vh8jsS8eQyePZ
         GUIZ82Fgq2IomAjR8cpL8ZwlVzJFkrccFRMh0yAV6j4aCNk6K5TCIC9Q+jbqn57vOTV1
         R5UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=CpmT1vkqvZqsdSQbFuCpNH/AnuhPq6FWS5ZPuhy1Dd8=;
        b=b0ykZdEAxHdO1KJFYMqJDvWkjbMC06slhsblz5rsqOCuDUfX0r9gOgUrCCs2uW7IVy
         66cNLnSBTT4vv/mHv71Zp+j5JvILGsEWJi9sgudgPG0bdVRBWRj2gR5uPAQUMZJpeOsH
         eh00E00+IRv3nXObrEj6DrTyXwKdpyZaPsUP/9wncENrRcoQx3Phfrtw+bZKClmOuq6x
         DlstS3TwgOuu7BY/tP/vpO+R6TB7FH6BzCWtPmUY0Q4IkpgzW2qn6Hv3JRcvYiFPHhHH
         7m6QlDMED+xp8Z/JO1pr1VeqMnGsp+sBV9euZdlxL0WPe1WLO9nnrC/zc2S6fXtFvmEr
         7gOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b21si20273811qta.139.2019.07.19.07.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 07:07:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4A0AEC06511B;
	Fri, 19 Jul 2019 14:07:23 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E95B3620BD;
	Fri, 19 Jul 2019 14:07:20 +0000 (UTC)
Subject: Re: [PATCH v2 2/2] mm, slab: Show last shrink time in us when
 slab/shrink is read
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
References: <20190717202413.13237-1-longman@redhat.com>
 <20190717202413.13237-3-longman@redhat.com>
 <20190719061410.GJ30461@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <a0ea7cd2-d66c-f251-d14f-979e0913c7ef@redhat.com>
Date: Fri, 19 Jul 2019 10:07:20 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190719061410.GJ30461@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 19 Jul 2019 14:07:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/19/19 2:14 AM, Michal Hocko wrote:
> On Wed 17-07-19 16:24:13, Waiman Long wrote:
>> The show method of /sys/kernel/slab/<slab>/shrink sysfs file currently
>> returns nothing. This is now modified to show the time of the last
>> cache shrink operation in us.
> Isn't this something that tracing can be used for without any kernel
> modifications?

That is true, but it will be a bit more cumbersome to get the data.
Anyway, this is just a nice to have patch for me. I am perfectly fine
with dropping it if this does not prove to be that useful.

Thanks,
Longman

