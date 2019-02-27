Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC082C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:24:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A186A20643
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:24:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A186A20643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68DC68E0025; Wed, 27 Feb 2019 12:24:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63CDB8E0001; Wed, 27 Feb 2019 12:24:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52C388E0025; Wed, 27 Feb 2019 12:24:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24B778E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:24:55 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id f70so13555403qke.8
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:24:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=jWUkl9voxbBXnTJNjfgOO3YTa2eYkBKQhp0Zy0167Gk=;
        b=qcOwJwYmoq6xdVhI4D6qbjwK4qC39f/lnKloB4vzR/ekUd5TfHQVKDF3qmGIfTSLFI
         Snj6fVv29/Bc5NHSCjcnQx01lTR8+GWh1IO70I7ZZ65bhE6feIUrJ5O/DSlEe++rwwHq
         UfGaJEodnlXsGv4EQbJrFjXjMGX3T2vxLK3ITIrMIQPUHx7OQAvLHTpbER+jdMO2CKbH
         h1zI6ixF12wl5Hsuoadpflp0yvGBDFdJ4E0gFOphQVluoGCL931LSoXUyJd3mRy2fKT7
         rORTtAJV1y8zzm+qgPrNeqCFWg8eCjAzk2itDx3Q8XPlTiUq2N2vZxaR78VpdjHc+H9d
         xC+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWl97tBVcY9FMa5zusRXOmxVfbAHwiLQv45B/6yohD0L/HhQ8MD
	iIP+DdUyFCnbns3kxNfoGMLhp3tosP0JsDc+Qbi3SYFp+jbjM8k5y9m2VoE7b47/EAGqNoUq/LN
	evhJegF/50kQQvvMkWy/yZ4vi0Tzh2VmwTogavnJZYN0zvOaawUvpAlct6mWlYPrWBQ==
X-Received: by 2002:a37:390:: with SMTP id 138mr3100220qkd.292.1551288294925;
        Wed, 27 Feb 2019 09:24:54 -0800 (PST)
X-Google-Smtp-Source: APXvYqzo96XNGNFrdtdCyaEO9xSYl2QdpqJ5hQRjVnz4nZdlVy/h7uiI++ZzbkSjTHWfQ1vqZ24f
X-Received: by 2002:a37:390:: with SMTP id 138mr3100167qkd.292.1551288294271;
        Wed, 27 Feb 2019 09:24:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551288294; cv=none;
        d=google.com; s=arc-20160816;
        b=avMsN70DOgfjumZzKkDoyixMZ1gzKNDZKRqKMw0XDpQpn21005AKM12y3q5jh0pINw
         PPBEFwF5Y10sgcQ/qlCmi2XD6wozBJwww33ggqa4h6Y79XlSLVB1tTdEsGrgRh3cfaVS
         0vVUYmDDh9QV8jBPT0qZFgOVlRB8VIsXdQd5j6kbL1PkWSq0GDrq+/K/snAHlel6Y8nc
         MZT4A0NuBqhq9fK6mfTCcK1jnVJFaSmAYmycUDh3lQUUvbMPnR4cQUz29W/ENJ8Vieuh
         Hy30TW0OtQwxNV9WqxXOWTEA7Q4bwobOdOCpW0XevwXpIVGlo6kjSXrD/fiXxqqhuOaS
         LCqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=jWUkl9voxbBXnTJNjfgOO3YTa2eYkBKQhp0Zy0167Gk=;
        b=k+V0lNwwKzv7IqIBQdtT9iu1cIzRnwMxmnfigHtwKKDTkMWkHFF7CtO89DcKEnCPf0
         sXDOSa9lQSwvi0KdCBbNGV5+lPafGmk4q1LHAt5YZNVuxeFj6H0DR7vapsPFL6XHCPp5
         vl993fXooWYAKfs5GWnFYGxqQBvUTgBewWTbbK/OSJNRgkzsyhmlbSbOQuCBXgLrtj5t
         IPDmt7RYNP9yArksDymVA6GBAsv/C4d3Wy+qVVfoSyX61VzVe5IMYf4OXeHe4tsuYvx3
         dTkl/CzDUibvsxTwbLKbDuwmp398Yr/gObRIICy4JNeWJdjyXQHQMpy5LMKHz/U84TTI
         uniQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x36si103085qvf.112.2019.02.27.09.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 09:24:54 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 67E0C30B4A0A;
	Wed, 27 Feb 2019 17:24:53 +0000 (UTC)
Received: from redhat.com (ovpn-124-76.rdu2.redhat.com [10.10.124.76])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 86C529CC7;
	Wed, 27 Feb 2019 17:24:52 +0000 (UTC)
Date: Wed, 27 Feb 2019 12:24:50 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Michel =?iso-8859-1?Q?D=E4nzer?= <michel@daenzer.net>
Cc: Philip Yang <Philip.Yang@amd.com>, amd-gfx@lists.freedesktop.org,
	linux-mm@kvack.org
Subject: Re: KASAN caught amdgpu / HMM use-after-free
Message-ID: <20190227172450.GB3296@redhat.com>
References: <e8466985-a66b-468b-5fff-6e743180da67@daenzer.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e8466985-a66b-468b-5fff-6e743180da67@daenzer.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 27 Feb 2019 17:24:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 06:02:49PM +0100, Michel Dänzer wrote:
> 
> See the attached dmesg excerpt. I've hit this a few times running piglit
> with amd-staging-drm-next, first on February 22nd.
> 
> The memory was freed after calling hmm_mirror_unregister in
> amdgpu_mn_destroy.

So that branch is not using the HMM changes queue up for 5.1 and thus
what you are doing is somewhat illegal. In 5.1 changes all is refcounted
and this bug should not be able to happen. So if you rebase your work
on top of 

https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-for-5.1

Or linux-next (i believe i saw those bits in linux-next) then this
error will vanish. Sorry if there was confusion between what is legal
now and what is legal tommorrow :)

Cheers,
Jérôme

