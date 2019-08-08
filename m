Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8278C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:23:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4783F217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 20:23:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sv3ezScU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4783F217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D059F6B0003; Thu,  8 Aug 2019 16:23:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB67D6B0006; Thu,  8 Aug 2019 16:23:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA46B6B0007; Thu,  8 Aug 2019 16:23:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80DC36B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 16:23:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so59849627pfa.23
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 13:23:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=khUis8U74kkcKVpZjn/Mp0bv9eDyEII73MVGVvtvdsQ=;
        b=JXAax7+daCffvfE5uX/Ef4VLR+K7UjGcJRyFTwAWGZjnkTiZaOmM4axEsfUwp4x7Y6
         2CSGiSVBImSrQTJ12JtvtOJo0slnjs10Vw/8MXGVvirYVYnGUzR3bE6390gnPTB+Ytq5
         yXMYcBSX5KpJf0jSsRQPPhJTNgvQP6+SRJfVioUcwCRYKWjUvRrzsUD8aiHntM6wxjMe
         l00lgl2IbQnXjPCPZ5dl1PIUv9bOm5+aH0Jw4fxIQsLwoIZgg0frZo4AvAZlwZ5M9vtG
         vsBuo7umzQk/RDT3E94Uco29b87LO7tAY94KG/blKR33K+ctjOjp2tQovTa3AGmWXHcd
         USIw==
X-Gm-Message-State: APjAAAUbc5pF3jOhxX9cTpaSaTqlq9Gb1BKw2QllEK0LwghzQNKnG8yr
	FZEqTCakBajzTh5gFJm5oThM5O3RzoI4HUx4oTBbdXOSfJDw20NowFHW3NmIHDn7AhRBDanhH/2
	C5gXdLHv8Y7RJItg5UqxydUZczPco7uZUWpDgaxwatCS9D90CC0x/YTzR2lHflcLC1w==
X-Received: by 2002:a65:49cc:: with SMTP id t12mr13305738pgs.83.1565295791800;
        Thu, 08 Aug 2019 13:23:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzT+uWR10wt+NcaKrUaziYpBi6K8VR3dgnKFKHc3huk1NtaaLCOYkb7N9jP8jbIl1bCabbd
X-Received: by 2002:a65:49cc:: with SMTP id t12mr13305698pgs.83.1565295790774;
        Thu, 08 Aug 2019 13:23:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565295790; cv=none;
        d=google.com; s=arc-20160816;
        b=uZ10LL6K+Ir3gRmitZEg13YRv4OMklRQJsKiERt1v8ko0s47LeCxPUEBXqxRETGN8P
         06hoXYhVobfSg1Y21De9WRWIF67gYsvvTBIFmhU7N3nb9FNRacF4mS8zeirOwNu4oZJq
         EdwtG2rUAkbEwdofLlj7oZARXWC9w+cjk37mPIMHCAsrLsvdvSL52g2WzAEbXc3rpzgM
         A23Gjm7Fpx4c+XW2+s5cQQpMMrIzHCPvxQEqkzDGEZerJHCzUoTPKbt43kjNBsuX3ZDe
         1rwr3sq0NUFcCwyGA51ea/vypAo9NvfTugNggwffppRPf7Hn1EBUCcMOTta8Vj7MqhJB
         fUfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=khUis8U74kkcKVpZjn/Mp0bv9eDyEII73MVGVvtvdsQ=;
        b=GhFnVTXIueyRu7a3iVwZfjT4NMI2l/lvl4cNbFA8VpwFraw1s1SR3OA/wmJ83tQ6Tt
         npXqda1j90fyadqdg1mDtTSQzgoirnEUy6DobmF/WdL9t4EgRKam26uWD1oSabWXbRhM
         /lAvP76Y1LHow6Nn1ImiLsNaiycpQoyJslx9Jn/4Cqi3WR95tmAX8OSJIDRSfKsave88
         fRpjqf+46nPj6s2EzsWCGeU7k8LfJ0OWfeCSXWTRy+GVZ4GfhmSamq7bO8hzZjP/poQe
         TxQwinrVP+yH8xv7v1TpcKiagronpLZevMg+fQcVUm34BIBJhcwxlCcoOTd6mAnNG7y2
         QXVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Sv3ezScU;
       spf=pass (google.com: domain of shuah@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=shuah@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 21si56029511pfo.138.2019.08.08.13.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 13:23:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of shuah@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Sv3ezScU;
       spf=pass (google.com: domain of shuah@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=shuah@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from [192.168.1.112] (c-24-9-64-241.hsd1.co.comcast.net [24.9.64.241])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7DE1C2173C;
	Thu,  8 Aug 2019 20:23:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565295790;
	bh=RHraHwfrbwkREg74Xy9SOBTOzh4EzmM+GX9f7LiI4tg=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=Sv3ezScU40/zyzSwPkXgXdl2Zfpk274kLgsFqRrBhADRQrvgV8spmG+hFWG1IoYWT
	 Pbp2ldUVK7N9APpheUobyrSNhYkO7tImql2TTefGzCTJJ5SKTkMgTlB32mCMLnkk8a
	 RywI5Y4D5/UX4eBw5YX0L4x6Q7BQPy92DbnCOaC8=
Subject: Re: [RFC PATCH] hugetlbfs: Add hugetlb_cgroup reservation limits
To: Mina Almasry <almasrymina@google.com>, mike.kravetz@oracle.com
Cc: rientjes@google.com, shakeelb@google.com, gthelen@google.com,
 akpm@linux-foundation.org, khalid.aziz@oracle.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-kselftest@vger.kernel.org, shuah <shuah@kernel.org>
References: <20190808194002.226688-1-almasrymina@google.com>
From: shuah <shuah@kernel.org>
Message-ID: <528b37c6-3e7a-c6fc-a322-beecb89011a5@kernel.org>
Date: Thu, 8 Aug 2019 14:23:08 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190808194002.226688-1-almasrymina@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 1:40 PM, Mina Almasry wrote:
> Problem:
> Currently tasks attempting to allocate more hugetlb memory than is available get
> a failure at mmap/shmget time. This is thanks to Hugetlbfs Reservations [1].
> However, if a task attempts to allocate hugetlb memory only more than its
> hugetlb_cgroup limit allows, the kernel will allow the mmap/shmget call,
> but will SIGBUS the task when it attempts to fault the memory in.
> 
> We have developers interested in using hugetlb_cgroups, and they have expressed
> dissatisfaction regarding this behavior. We'd like to improve this
> behavior such that tasks violating the hugetlb_cgroup limits get an error on
> mmap/shmget time, rather than getting SIGBUS'd when they try to fault
> the excess memory in.
> 
> The underlying problem is that today's hugetlb_cgroup accounting happens
> at hugetlb memory *fault* time, rather than at *reservation* time.
> Thus, enforcing the hugetlb_cgroup limit only happens at fault time, and
> the offending task gets SIGBUS'd.
> 
> Proposed Solution:
> A new page counter named hugetlb.xMB.reservation_[limit|usage]_in_bytes. This
> counter has slightly different semantics than
> hugetlb.xMB.[limit|usage]_in_bytes:
> 
> - While usage_in_bytes tracks all *faulted* hugetlb memory,
> reservation_usage_in_bytes tracks all *reserved* hugetlb memory.
> 
> - If a task attempts to reserve more memory than limit_in_bytes allows,
> the kernel will allow it to do so. But if a task attempts to reserve
> more memory than reservation_limit_in_bytes, the kernel will fail this
> reservation.
> 
> This proposal is implemented in this patch, with tests to verify
> functionality and show the usage.
> 
> Alternatives considered:
> 1. A new cgroup, instead of only a new page_counter attached to
>     the existing hugetlb_cgroup. Adding a new cgroup seemed like a lot of code
>     duplication with hugetlb_cgroup. Keeping hugetlb related page counters under
>     hugetlb_cgroup seemed cleaner as well.
> 
> 2. Instead of adding a new counter, we considered adding a sysctl that modifies
>     the behavior of hugetlb.xMB.[limit|usage]_in_bytes, to do accounting at
>     reservation time rather than fault time. Adding a new page_counter seems
>     better as userspace could, if it wants, choose to enforce different cgroups
>     differently: one via limit_in_bytes, and another via
>     reservation_limit_in_bytes. This could be very useful if you're
>     transitioning how hugetlb memory is partitioned on your system one
>     cgroup at a time, for example. Also, someone may find usage for both
>     limit_in_bytes and reservation_limit_in_bytes concurrently, and this
>     approach gives them the option to do so.
> 
> Caveats:
> 1. This support is implemented for cgroups-v1. I have not tried
>     hugetlb_cgroups with cgroups v2, and AFAICT it's not supported yet.
>     This is largely because we use cgroups-v1 for now. If required, I
>     can add hugetlb_cgroup support to cgroups v2 in this patch or
>     a follow up.
> 2. Most complicated bit of this patch I believe is: where to store the
>     pointer to the hugetlb_cgroup to uncharge at unreservation time?
>     Normally the cgroup pointers hang off the struct page. But, with
>     hugetlb_cgroup reservations, one task can reserve a specific page and another
>     task may fault it in (I believe), so storing the pointer in struct
>     page is not appropriate. Proposed approach here is to store the pointer in
>     the resv_map. See patch for details.
> 
> [1]: https://www.kernel.org/doc/html/latest/vm/hugetlbfs_reserv.html
> 
> Signed-off-by: Mina Almasry <almasrymina@google.com>
> ---
>   include/linux/hugetlb.h                       |  10 +-
>   include/linux/hugetlb_cgroup.h                |  19 +-
>   mm/hugetlb.c                                  | 256 ++++++++--
>   mm/hugetlb_cgroup.c                           | 153 +++++-

Is there a reason why all these changes are in a single patch?
I can see these split in at least 2 or 3 patches with the test
as a separate patch.

Makes it lot easier to review.

thanks,
-- Shuah

