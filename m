Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6F8CC76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 14:09:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8577121849
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 14:09:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8577121849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D1316B000A; Fri, 19 Jul 2019 10:09:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 282928E0003; Fri, 19 Jul 2019 10:09:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14A9A8E0001; Fri, 19 Jul 2019 10:09:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E43DE6B000A
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 10:09:09 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l14so26319514qke.16
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 07:09:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=NoyAblzntekDwv4W4KdyITdlBwIkLsdlXxBj6oBhpEA=;
        b=WATLM65m6YDznOxKVQkbETyzvt9SPCozbEQ0MUuNMNwAH00GBrkTt1AP4gAnsyh0lk
         c0uYA6bEcEf87ZistKhuWwZeCDGTCbSOfkqmcBn9BTleFqrITDGM99zGAldVw1AgLnZt
         usG5Pk9tyoo+7YuTazW+IhOSd7fs7amv3r5Qc6AVG0g968N/sWFsJsYr0LKHUwbsQqwU
         U1UgH5s76rHUAWzZh1y8ouXp/nIlVU+SuHbSO6HY7OsrBGDkgGaykG2mnxHz2idZFbtu
         KM8J8Vun0ElSZmcRV/E97rF6O4FKlmyOi7JG9twFCu1wLC9yKAEJ7xRTC5ztlu+wO2Xj
         5HuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVVz1d3Tq+OB9mfJDp4Ucb3KmShMwrRDaLaE+MxT7fZA8UHnaJt
	2sg+EVrIw4jRbQ0NRrzbscqC+IsXeJzDGeB18H+6flsCY9O3FjO5cCWFSW8/WSzCgDouG5eAv5j
	DpvRYKVNxLBWGreL+52OrVCCn9jByV/UfMuBKKl/y8Kd5BPzT8WKWm7TI3i85Wcx5cQ==
X-Received: by 2002:ac8:929:: with SMTP id t38mr37617832qth.287.1563545349652;
        Fri, 19 Jul 2019 07:09:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQgTNEnkOx31QVnbFst+sBeikuoirZf8hBSOWouunRmvP4DdvDupnpCnmKqd7LrpoJb/t5
X-Received: by 2002:ac8:929:: with SMTP id t38mr37617769qth.287.1563545348850;
        Fri, 19 Jul 2019 07:09:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563545348; cv=none;
        d=google.com; s=arc-20160816;
        b=NWsRuFu3UBZNPcEc+05WTMBBVVgUVsdGkb9wA1kBGY18UZp+GHTHbC2Vyg0+26HuLa
         ZOoJwYqr6WNqbSWaQearm5FuwPvdufoHr43DDIjCr6/aE8Kh/E79gPy7hYKolJsENFVH
         I98/zhC5dS/yJ7q8qs/NPpQPyLLagCywNCnH7uwp/hlGD+Nudnh7jaQXzLfDNUYiglet
         O95EnlrTXy1ClYiqXp11R1r1mRjCjLfsvQDNKG3+AxLfrWZVPUIKxtSpjEj02X3w7Idq
         au/bB3X5RNd5pBdcKasHnlsuHJXJT0mkRfzrsMYwuphRHVkcq9reh5sY6VnKA5zqlQdy
         HX0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=NoyAblzntekDwv4W4KdyITdlBwIkLsdlXxBj6oBhpEA=;
        b=dzofjrEe+z0nxvDL46MyrFhdMAHWFV5FDUJrO93pflgjzQxAkZrUz2zb5LW8LCxliQ
         UP2HpvBwYEIoj7qfRLDPJ73oJn8AFSFwYrRr/qKvOHkyzp9Rj5FOhiq6SBK9pQMIjT4P
         1yQERC5mills5K2qVLATWyXvMboTvBKNGr0ZhhmIPJ7Ecove4myPCpebZrJNje7VbnOF
         gCaMbiVrXIJlV6FHxCX65QY8e9BzAFmwd1KOf/ZM3886UAbEvIS3eriuQMIHsQEmU2E8
         h0srQYnJ1Uy2DgWfbwUi+t1S4aTgIoc5rOSOMLfR03VbNH5eViR/lEmvChkcds6MSOS7
         wmsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w2si19196593qkf.216.2019.07.19.07.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 07:09:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0616181F2F;
	Fri, 19 Jul 2019 14:09:08 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D59842FC5B;
	Fri, 19 Jul 2019 14:09:06 +0000 (UTC)
Subject: Re: [PATCH v2 1/2] mm, slab: Extend slab/shrink to shrink all memcg
 caches
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
References: <20190717202413.13237-1-longman@redhat.com>
 <20190717202413.13237-2-longman@redhat.com>
 <20190719062052.GK30461@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <caa120bb-bfcc-45ef-08e1-af40e52b43df@redhat.com>
Date: Fri, 19 Jul 2019 10:09:06 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190719062052.GK30461@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Fri, 19 Jul 2019 14:09:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/19/19 2:20 AM, Michal Hocko wrote:
> On Wed 17-07-19 16:24:12, Waiman Long wrote:
>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
>> file to shrink the slab by flushing out all the per-cpu slabs and free
>> slabs in partial lists. This can be useful to squeeze out a bit more memory
>> under extreme condition as well as making the active object counts in
>> /proc/slabinfo more accurate.
>>
>> This usually applies only to the root caches, as the SLUB_MEMCG_SYSFS_ON
>> option is usually not enabled and "slub_memcg_sysfs=1" not set. Even
>> if memcg sysfs is turned on, it is too cumbersome and impractical to
>> manage all those per-memcg sysfs files in a real production system.
>>
>> So there is no practical way to shrink memcg caches.  Fix this by
>> enabling a proper write to the shrink sysfs file of the root cache
>> to scan all the available memcg caches and shrink them as well. For a
>> non-root memcg cache (when SLUB_MEMCG_SYSFS_ON or slub_memcg_sysfs is
>> on), only that cache will be shrunk when written.
> I would mention that memcg unawareness was an overlook more than
> anything else. The interface is intended to shrink all pcp data of the
> cache. The fact that we are using per-memcg internal caches is an
> implementation detail.
>
>> On a 2-socket 64-core 256-thread arm64 system with 64k page after
>> a parallel kernel build, the the amount of memory occupied by slabs
>> before shrinking slabs were:
>>
>>  # grep task_struct /proc/slabinfo
>>  task_struct        53137  53192   4288   61    4 : tunables    0    0
>>  0 : slabdata    872    872      0
>>  # grep "^S[lRU]" /proc/meminfo
>>  Slab:            3936832 kB
>>  SReclaimable:     399104 kB
>>  SUnreclaim:      3537728 kB
>>
>> After shrinking slabs:
>>
>>  # grep "^S[lRU]" /proc/meminfo
>>  Slab:            1356288 kB
>>  SReclaimable:     263296 kB
>>  SUnreclaim:      1092992 kB
>>  # grep task_struct /proc/slabinfo
>>  task_struct         2764   6832   4288   61    4 : tunables    0    0
>>  0 : slabdata    112    112      0
> Now that you are touching the documentation I would just add a note that
> shrinking might be expensive and block other slab operations so it
> should be used with some care.
>
Good point. I will update the patch to include such a note in the
documentation.

Thanks,
Longman

