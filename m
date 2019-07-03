Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBC8DC06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 16:13:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D8F0218AD
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 16:13:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D8F0218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27B858E0006; Wed,  3 Jul 2019 12:13:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 204EC8E0001; Wed,  3 Jul 2019 12:13:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A5158E0006; Wed,  3 Jul 2019 12:13:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DDCAB8E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 12:13:51 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v80so3471831qkb.19
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 09:13:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=XiSTo5dVVoEEN8J4y+6WVgitQzRCktgKtG+aH1t53zM=;
        b=PSi7pE9VRSL5LSxyHXAOVO+uNmajqAaKnxIsrNQORsIh/VpaLeVKfyx7NH9d6MvPQD
         MT8KVZp4w8BHY9zHdrqK5QVBERS0OUgj+Vga08YVVwBVI4K5IGf71OgUGYAlEixDFrpa
         nYFi/seiePKKeN3KeJ2s0BeZnhhBm9pkSgwqQ5I0BryMgGiHxyiPJQZrtVfXRhMj2CKU
         2smXYjOtqOyAeY1g3lO/ENRIp4jjMDSA9k93xulLHg+rFC77baAoYY9O1MEleOEbQ8/d
         QwADMUtIbJwsTPjWWs/Z5TO5XQIRlFnLmdQY+fh4eHnuf1jRLYfH0XSnPYNwTCocs5Xw
         +0KA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVW9ye7+WRF9oIr7jli4WUWVvJmgPJ8AtlwsWpsCoG2I62h7EeT
	O9FHALFMyB1rFkAI0FSz7RrWjAf4pjGImExS4BWw0H88vUIM59PaYahkAfDD0Way5fYDC9JvF4X
	21OKb5+kz8KHqWrFJkbv5niews6PeH7QuXKwixkiEe8hZlbjZjrxo+dT0NJZryZNLbQ==
X-Received: by 2002:a0c:b999:: with SMTP id v25mr33435494qvf.36.1562170431694;
        Wed, 03 Jul 2019 09:13:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCNvSJMrpA2dFT0i7sS4BLcI4NM7D8a/xs2SZBMbAVm4XQa+cgWwqHRED8sI+ItfNiu15P
X-Received: by 2002:a0c:b999:: with SMTP id v25mr33435458qvf.36.1562170431207;
        Wed, 03 Jul 2019 09:13:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562170431; cv=none;
        d=google.com; s=arc-20160816;
        b=sEQz66KSL1QIBZ2zge+y+SZ+MhoyGZGTTZx59KnN711SKCYLVwhdfODPfJQRzaS/74
         u+wZ7vj+SKwtuy+B4KlRR6G/BIMiSVfKjo35TPMIxNLHgDuK0lWBwS314ab7Bclekp61
         YT/cNs+sPYvQwIe8fzTDPaBb9cgcsKNiGM0h8RPyONUTlYqNohDGhEGq/EbrgRD3R7Gg
         hHDBiWmmMK2zBQyj7MPo9aD5c9RtKGm8dWNCTvKeqIYG/YAm4uFtmPqbk7R5+CMk5Z6W
         dGeyCbrW0GD3++Yhj1Xg9QeYIMws0GSuklhtJwvaUIPvJNsa0B2ikq2yGJO4fEgjC8KP
         zH5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=XiSTo5dVVoEEN8J4y+6WVgitQzRCktgKtG+aH1t53zM=;
        b=tsp6yu5LyTVzDK6rrhuhCgt4ZKJRj9vIWKP7fvJIZEf4d06uXmRSXs8ddafCCJ68md
         FyrxJROYxAGCOZjeszBOx2QsCWHHIMRWDK9PxEOrLn6bS0ENli2AB4QosXcCznheSxF2
         LaYQTXzb+slxqwGEmLPolZmJvJQzTWC9eBEPMmWVEnXeBF5cVh7UHloUodrfnBnFlRks
         Of52zJKJ5miXkPYwrv9WgdGB5QVvZu0AZzPsS6b4PGlSwLF1afu1blRZwlqzuj0bPrFs
         BP1H7tS6TmMT80hguVTIb3NmIWzmCh8sHGkNFRosFsF9Shm9iuLv/Lb/u4DFrkePRcOs
         fqcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 5si2167760qtz.196.2019.07.03.09.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 09:13:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BBE813083394;
	Wed,  3 Jul 2019 16:13:24 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 95F121725D;
	Wed,  3 Jul 2019 16:13:15 +0000 (UTC)
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
To: Christopher Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Pekka Enberg <penberg@kernel.org>,
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
References: <20190702183730.14461-1-longman@redhat.com>
 <20190703065628.GK978@dhcp22.suse.cz>
 <9ade5859-b937-c1ac-9881-2289d734441d@redhat.com>
 <0100016bb89a0a6e-99d54043-4934-420f-9de0-1f71a8f943a3-000000@email.amazonses.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <1afc4772-27e5-b7f1-a15e-e912e15737e6@redhat.com>
Date: Wed, 3 Jul 2019 12:13:15 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <0100016bb89a0a6e-99d54043-4934-420f-9de0-1f71a8f943a3-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 03 Jul 2019 16:13:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/3/19 12:10 PM, Christopher Lameter wrote:
> On Wed, 3 Jul 2019, Waiman Long wrote:
>
>> On 7/3/19 2:56 AM, Michal Hocko wrote:
>>> On Tue 02-07-19 14:37:30, Waiman Long wrote:
>>>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
>>>> file to shrink the slab by flushing all the per-cpu slabs and free
>>>> slabs in partial lists. This applies only to the root caches, though.
>>>>
>>>> Extends this capability by shrinking all the child memcg caches and
>>>> the root cache when a value of '2' is written to the shrink sysfs file.
>>> Why do we need a new value for this functionality? I would tend to think
>>> that skipping memcg caches is a bug/incomplete implementation. Or is it
>>> a deliberate decision to cover root caches only?
>> It is just that I don't want to change the existing behavior of the
>> current code. It will definitely take longer to shrink both the root
>> cache and the memcg caches. If we all agree that the only sensible
>> operation is to shrink root cache and the memcg caches together. I am
>> fine just adding memcg shrink without changing the sysfs interface
>> definition and be done with it.
> I think its best and consistent behavior to shrink all memcg caches
> with the root cache. This looks like an oversight and thus a bugfix.
>
Yes, that is what I am now planning to do for the next version of the patch.

Cheers,
Longman

