Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 816EFC282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:02:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E8E02077C
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:02:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E8E02077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2B476B000D; Thu, 11 Apr 2019 10:02:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDA5F6B000E; Thu, 11 Apr 2019 10:02:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7C796B0010; Thu, 11 Apr 2019 10:02:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86E876B000D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:02:31 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x23so5110243qka.19
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:02:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=qfpVOn1kEo43TPI82t/Dr92Tbv1uw32xbJim4SSRCoM=;
        b=qekOZZN1bdGgYshWJnXx4ueZOKsEpjIunAJDUG65QDQLzDJJmO7Ix8aCz8nCk6MWFj
         cZkq9eFYxi7vtEdMJhKxlEDgYGDBwpfZ1lVbehRE301poYx/iKozn06MfQQieeNKY0Xu
         QN3IENR77DuHuP4RdbPjsSrOQgNyai2G2BwtQ2FLeQPY9CbzWLBOi9XxBkutjdffAQg7
         7tA0k+/N/JtY4GPJtxT7P7k4e8K69Rc2p7OoJ7+67E8mXm/ejRz3m3qNA5suMEJdXN9z
         c+UF5TNXaRTE6+vXEntSXoSqRiWXpFO0D2MmepkLCUposdzH1I8/gvoiXef8IUKmt/RD
         zUhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUUPeU3XunOMETp7GaImnlN54RllaS5NcIllciLQcc7ZcHk8W6A
	bM58y/btOjS1IcdZ0gYfht0p7Wqup9ByxjjlRqZRgmahPoyLC+SEr34Pov0IHAEMqUHPrVWpz1/
	a/1QGipV6u9WIOg3mlI9BJQEP+h3X5R7pdlNmICRhfBLVBL4i3Y2qL5KCVY2EHjNsGw==
X-Received: by 2002:a0c:c950:: with SMTP id v16mr41537386qvj.204.1554991351104;
        Thu, 11 Apr 2019 07:02:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlOoZcmH0lPJkNrdZqZkHfmBeEhniHXtHcbUuOKBN70kzc7+67a9krEKr/HDGBBJy1HNG3
X-Received: by 2002:a0c:c950:: with SMTP id v16mr41537256qvj.204.1554991349832;
        Thu, 11 Apr 2019 07:02:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554991349; cv=none;
        d=google.com; s=arc-20160816;
        b=fnXr8EYP9HushIua0XK56KBgf9IaFFIRJM2SI3Uz3NhNbX16kJfNJJrLt/vMzhNg2x
         2YkRH7QOwPNHIYn6V+8+f2lVOKtdJsd9ah7HQNTaj0sMqc3J7Koqe3mPrmMaZ4dvJqfB
         U01Ps5qmozCKOpu1fdiUb2WLfA4AMaN0l8fITAhx3OkHXseVLMUol2NMscvzjs2pM07e
         KcdjaoS6ew+zqDI1e9ZK6OpNPcOotf9NR+II6SvmawRhfm1hWMh8sGwlssdXYyOLdYX+
         NAKv5NxnSxuKxtRAYsTWSeoGYO2xO6MezRnOHweRQN0yqoPJgPNnAVjMa34X0x/BCobf
         zI/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=qfpVOn1kEo43TPI82t/Dr92Tbv1uw32xbJim4SSRCoM=;
        b=cQUN9AgQ76lH2/GxfW07bK7U1nLEUr+WHk9OMKO7DUePXU8fBdxI9ytp9rTfpVbVRT
         eHkVzdHyCSSl1bEJQelIdQMuK6WGR5N+wWi34vXG6TQZP+IzEz70H+UsQ+PG1FR+bvcw
         XeiYEH4dXu4mmDcdS3ss5jJohPWE8EcUwmdRcBo8quA6ZyNqt6+tygR9elGoP0+k7Ut1
         yCcr9THwHDieLgd7QKS1xDN4AfiRoDtncX05tsc8SUmtHedooFXmSyCb/q7oQNGzAI3n
         5G5nER44BOkFm6WHWbWuPbczr8GGx/UYRdPJ+jm6Tpti3a+Z6lfjRUUcbsgCkB9mQSkh
         Zf2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h22si2881975qkg.26.2019.04.11.07.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 07:02:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6A5D53DBE7;
	Thu, 11 Apr 2019 14:02:23 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-47.bos.redhat.com [10.18.17.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BF490108F821;
	Thu, 11 Apr 2019 14:02:16 +0000 (UTC)
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Jonathan Corbet <corbet@lwn.net>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org,
 cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
 Shakeel Butt <shakeelb@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>,
 Aaron Lu <aaron.lu@intel.com>
References: <20190410191321.9527-1-longman@redhat.com>
 <20190410195443.GL10383@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=longman@redhat.com; prefer-encrypt=mutual; keydata=
 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
 weim8xU=
Organization: Red Hat
Message-ID: <daef5f22-0bc2-a637-fa3d-833205623fb6@redhat.com>
Date: Thu, 11 Apr 2019 10:02:16 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190410195443.GL10383@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 11 Apr 2019 14:02:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/10/2019 03:54 PM, Michal Hocko wrote:
> On Wed 10-04-19 15:13:19, Waiman Long wrote:
>> The current control mechanism for memory cgroup v2 lumps all the memor=
y
>> together irrespective of the type of memory objects. However, there
>> are cases where users may have more concern about one type of memory
>> usage than the others.
>>
>> We have customer request to limit memory consumption on anonymous memo=
ry
>> only as they said the feature was available in other OSes like Solaris=
=2E
> Please be more specific about a usecase.

=46rom that customer's point of view, page cache is more like common good=
s
that can typically be shared by a number of different groups. Depending
on which groups touch the pages first, it is possible that most of those
pages can be disproportionately attributed to one group than the others.
Anonymous memory, on the other hand, are not shared and so can more
correctly represent the memory footprint of an application. Of course,
there are certainly cases where an application can have large private
files that can consume a lot of cache pages. These are probably not the
case for the applications used by that customer.

>
>> To allow finer-grained control of memory, this patchset 2 new control
>> knobs for memory controller:
>>  - memory.subset.list for specifying the type of memory to be under co=
ntrol.
>>  - memory.subset.high for the high limit of memory consumption of that=

>>    memory type.
> Please be more specific about the semantic.
>
> I am really skeptical about this feature to be honest, though.
>

Please see patch 1 which has a more detailed description. This is just
an overview for the cover letter.

>> For simplicity, the limit is not hierarchical and applies to only task=
s
>> in the local memory cgroup.
> This is a no-go to begin with.

The reason for doing that is to introduce as little overhead as
possible. We can certainly make it hierarchical, but it will complicate
the code and increase runtime overhead. Another alternative is to limit
this feature to only leaf memory cgroups. That should be enough to cover
what the customer is asking for and leave room for future hierarchical
extension, if needed.

Cheers,
Longman

