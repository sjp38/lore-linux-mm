Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F204CC06513
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 18:41:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF3BA21721
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 18:41:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF3BA21721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C5F26B0006; Tue,  2 Jul 2019 14:41:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44F5B8E0005; Tue,  2 Jul 2019 14:41:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3174C8E0001; Tue,  2 Jul 2019 14:41:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3986B0006
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 14:41:47 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z6so17244981qtj.7
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 11:41:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=Nzn8p76p/fgRxeqGITZo8RFgd4g8QDrQeHiNX2X+zgY=;
        b=eojEmCAyR5ivGw39Oz0LQljCwQ6I5Z1W+eZF11e2snCFIKpLRK3XlvWbXuROaLRHq5
         YURf2JLRYlbGrCkzUJiQ9QTBQrSLKw3IiZtrlT7nBpIIqhBoQc1f8ZQBmhmbespvfiQ3
         Zv45RR7wEqqki/IvaiSatY43Vn78OwJxHOlF2eDuc1SUWTXLIe6yKLKGjRFwU8wyHhj0
         IEj3JFAzA5+SokLB8Kn5mPJzScd4qYpuOxh5wJcVCpQOsr/QGqtJMXXTu65GySYbeuX5
         hLBEffH34f70ysvAdvvzJgBn67jCfXZIfDZc/Sx6/9kx8nujGhA/2bSnlnbLARPgiKTT
         N+KA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXugk4+UOAG0BC3/TXRPlEOwpvYqAsS84I6BckltiskEupcsAp1
	wJ4/J+Qy6pmae+Nf86OyTUBeyGZdB6iyF2plm/XDF6q7Zun7BM53ey31DF4j7og6TMP/J7/QUY4
	OOxZmOtmCB3gC+lqkiscQ/vS57qJjkRYeQ1T2QMrsg372ofZhuTDyr/EmMQflGYp/Ig==
X-Received: by 2002:ac8:34ce:: with SMTP id x14mr27077363qtb.33.1562092906831;
        Tue, 02 Jul 2019 11:41:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaISM5Kc7qIl7zOMPIZ54nOLJR3y/yxhLPWnF5ssBhknOplOJhhnZ1TlvrAcXGSgM9cDj3
X-Received: by 2002:ac8:34ce:: with SMTP id x14mr27077322qtb.33.1562092906150;
        Tue, 02 Jul 2019 11:41:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562092906; cv=none;
        d=google.com; s=arc-20160816;
        b=nsNHtGlx2dHRZpgzLToSjYiMNHuqQnm+iCwrdv3F14m/hRQQ6dZdO3OOtldwLdrb2D
         yKC6fJeCP4AA/0xMP+gUZ2GZW6c4M9VCGTlElMfRs0t4HHZ/j6FXCPXBNBFgs+c8v5tq
         LpLVodGCL54RSJuHkb9pDyYY5ssk0osF9SHPwzWdYOI30Yy+ujjMphITWUixepa8vCNt
         75PKYnmHybJ8v3bEJDA/fc+S+IsiWBa3xOgoSLTodsEmT5BI8VWqcjXjdOISglQS1XTN
         mHe1Q0dfg8q+9Jq3KbeFmItmR5CyUfpYEw0CrknA/RQoAZFmaBa21jscMBTLV8GiITn7
         GY8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=Nzn8p76p/fgRxeqGITZo8RFgd4g8QDrQeHiNX2X+zgY=;
        b=IcZI9OEU2chdjdF6SkCl1flsgVf4glneEGTriJbjVskgdXkQy5yXs08jGvZ+jYq99A
         tcIwvxYsWuUGxVqSRviXUT9JzV+L8bmrhLK9tvO41zxlntdYhwOI41RQzACrh0QCieN8
         d/MSPbIV+V7HeZrMcXVcUoajs+hhZXCLnw4pRV4f9AaDRllCc0a7NyJueewc+9+B3no/
         lulvENduLI9lX4RqzLJavgbxM7JsIT4TTUfPh272EP5zYbWIcb5psDRv0hqzzeKxdrS6
         FyfIj5PPKBcLG5ZGTdpxrprCBc1va3+Czzm6b/AJ2xcmR2P0iqY9wpcWTM4LGSDhyV54
         m/og==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x11si9557966qkh.103.2019.07.02.11.41.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 11:41:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5141558E5B;
	Tue,  2 Jul 2019 18:41:45 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7901A60C44;
	Tue,  2 Jul 2019 18:41:43 +0000 (UTC)
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
 linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-3-longman@redhat.com>
 <20190627151506.GE5303@dhcp22.suse.cz>
 <5cb05d2c-39a7-f138-b0b9-4b03d6008999@redhat.com>
 <20190628073128.GC2751@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <eeca4ef9-1b62-dada-3d31-c247cb0b137f@redhat.com>
Date: Tue, 2 Jul 2019 14:41:43 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190628073128.GC2751@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 02 Jul 2019 18:41:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/28/19 3:31 AM, Michal Hocko wrote:
> On Thu 27-06-19 17:16:04, Waiman Long wrote:
>> On 6/27/19 11:15 AM, Michal Hocko wrote:
>>> On Mon 24-06-19 13:42:19, Waiman Long wrote:
>>>> With the slub memory allocator, the numbers of active slab objects
>>>> reported in /proc/slabinfo are not real because they include objects
>>>> that are held by the per-cpu slab structures whether they are actually
>>>> used or not.  The problem gets worse the more CPUs a system have. For
>>>> instance, looking at the reported number of active task_struct objects,
>>>> one will wonder where all the missing tasks gone.
>>>>
>>>> I know it is hard and costly to get a real count of active objects.
>>> What exactly is expensive? Why cannot slabinfo reduce the number of
>>> active objects by per-cpu cached objects?
>>>
>> The number of cachelines that needs to be accessed in order to get an
>> accurate count will be much higher if we need to iterate through all the
>> per-cpu structures. In addition, accessing the per-cpu partial list will
>> be racy.
> Why is all that a problem for a root only interface that should be used
> quite rarely (it is not something that you should be reading hundreds
> time per second, right)?

That can be true. Anyway, I have posted a new patch to use the existing
<slab>/shrink sysfs file to perform memcg cache shrinking as well. So I
am not going to pursue this patch.

Thanks,
Longman

