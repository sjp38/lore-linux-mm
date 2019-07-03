Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C67EC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 13:12:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE74D218A0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 13:12:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE74D218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A2C66B0005; Wed,  3 Jul 2019 09:12:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 753D78E0005; Wed,  3 Jul 2019 09:12:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6419E8E0003; Wed,  3 Jul 2019 09:12:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 436856B0005
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 09:12:47 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o4so2586371qko.8
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 06:12:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=hXPFy16fekQXoBjoxpCbxUg7MHgVJGOjPog0jNK7b30=;
        b=fRfVzqulnrOb9fVAUpqiE2bGj1Sos7f+HRjm/0CMkoG0Jy1ssjMqdor3mnNklg4VdA
         ZnWpiMj9jaP9r3Ro+7t3S5jP3zaioYMoLQ2Rhkz5EO3DlDnHKpdXgUPNw4jT5jhhtEgv
         /T44bpx+OCccgEKK9zmENYpFbHP6xZ/te9/veErvv77UuSnfdHfv7LzWDiQ+hjt4XUNA
         /bUJ3nGJIsgGKhBCEEINov1UQJJOkr2P6RUioCLJ0B+yjM+heKMsDhEEFXC7XFUPmc0I
         tpb1GTaXF8IO7Zxs9pmErxfFRWE7FUsT70L8E97J18mvGbDLHQQuWU6GKn9Gq+ts5yrg
         Nflw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWvy7ttHZKFGB/SyE25ahGgrcBCVf/2W03JLsY84SimYdSaICek
	Pli4S6uzgFgZsJ3g1ftvTajq68J86BQOCE3g+BgTR9rxryQqZ3p0KtH5AWMW9bIN4X9pXiShb7J
	lNj5ozgdPzbPHKGUismZRADP5gOb1pn21N2GVUVh5OqwVCa2E9jc9i76SVhS86LVqHg==
X-Received: by 2002:a0c:942c:: with SMTP id h41mr32170191qvh.146.1562159567050;
        Wed, 03 Jul 2019 06:12:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzspckEWE6IMZYadwXoOYzhrWL0MNhs4236A7ASV3QUbyPVDu+jFMYIg/t7qUMhD+xYIWji
X-Received: by 2002:a0c:942c:: with SMTP id h41mr32170120qvh.146.1562159566402;
        Wed, 03 Jul 2019 06:12:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562159566; cv=none;
        d=google.com; s=arc-20160816;
        b=qAiD8G2H+RtWX83YA1vJwaDJVxt60Dq/KvlES6zMiACQL2Uiake51ThavdqWeA9ckN
         WraHIE1PyGwHjPkgb3M5WESOTL8LNX9nUEt7nIj05i9tmue+cvfNU9G51y6UIXve8fR2
         xvV99XqLyDNDmZITBPgYS8jFHnFsYlCiFZ0Ss2JLL/6KqRbYvBVBFoC7oDRNvkt/f2eJ
         h+UNu38ztMALwy66Q/rfPQU5SOy9QBMqXR0HXeYXvxEXuJts+SEdIGltoyLOiW5VCLJi
         J8234qMNqpPFIOH0xLWsO+UD/WzWEm4HShvnJEG4Z4DBgh5cnqVpIHKVPoCQItDsJrYt
         v0pA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=hXPFy16fekQXoBjoxpCbxUg7MHgVJGOjPog0jNK7b30=;
        b=zhK9ZxeVE0P6sUvIXZqwg7DtL1BH15PZVQM+gAidJq6hv//IUFhiBP7VbLT3uFDq26
         cmxWMNQd6123fNKRCFlNR3OS71ktfU3bfwnRHgnaq/DMu1yP5RBf3d+MfMWD7MaF5y7m
         Orh9Rseu3rPrleEXCi0qjy25x6So7ir29cG2JFn0sjuv6b8LVex4fQZpn6QzFh/ocZv9
         WZFgaQZtq2mgH2GTKoZkDX2CiETT4QfpMroQdaJTlFXhmEzZHMonQnx9M2AnkT1ULTA3
         VZVjY8YAOoJUScE2dceVE0G2hmny140Yxd6xwc4wnePgbly6KCuS8YIJs8iVnDCyfVcN
         Ua4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i57si2348463qvh.125.2019.07.03.06.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 06:12:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 92AF1308FEC6;
	Wed,  3 Jul 2019 13:12:19 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7702C1001B04;
	Wed,  3 Jul 2019 13:12:13 +0000 (UTC)
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
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
References: <20190702183730.14461-1-longman@redhat.com>
 <20190703065628.GK978@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <9ade5859-b937-c1ac-9881-2289d734441d@redhat.com>
Date: Wed, 3 Jul 2019 09:12:13 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190703065628.GK978@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 03 Jul 2019 13:12:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/3/19 2:56 AM, Michal Hocko wrote:
> On Tue 02-07-19 14:37:30, Waiman Long wrote:
>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
>> file to shrink the slab by flushing all the per-cpu slabs and free
>> slabs in partial lists. This applies only to the root caches, though.
>>
>> Extends this capability by shrinking all the child memcg caches and
>> the root cache when a value of '2' is written to the shrink sysfs file.
> Why do we need a new value for this functionality? I would tend to think
> that skipping memcg caches is a bug/incomplete implementation. Or is it
> a deliberate decision to cover root caches only?

It is just that I don't want to change the existing behavior of the
current code. It will definitely take longer to shrink both the root
cache and the memcg caches. If we all agree that the only sensible
operation is to shrink root cache and the memcg caches together. I am
fine just adding memcg shrink without changing the sysfs interface
definition and be done with it.

Cheers,
Longman

