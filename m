Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BAE9C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 01:27:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26121214AE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 01:27:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26121214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7DA98E0004; Tue, 12 Mar 2019 21:27:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C042A8E0002; Tue, 12 Mar 2019 21:27:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A57688E0004; Tue, 12 Mar 2019 21:27:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5A68E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 21:27:11 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id b3so181527qkd.21
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:27:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=um0r7NxHpZAEIj2XWQs5JYojdIIDlGSLJxxWq2fz7/Q=;
        b=V+E2SWoDg2cWn1FpL9JjYJ+SsSEwJh4yg7zk9ibE4/rIR1VbY00SBgEQxkoB2PHahd
         lezC7bDEDoIAyPoOdXZ/nfhF3KEX5nMBJ/dNlXpFykP/22JpBfrbnWwQ/ZaRyFuJ3qen
         ++j11xO8dVaIKl99DXskXtlzqpV9PdjCFHRjh9Ah1icGesHmMy093H1zbufzMMwJGN18
         vBTH2NKi1buUwyWspv1dzTmSRdQBvSUCxw+OwZm/Ky8h5iubQiILOSBQf7hlI+ker3Xa
         0MFikyPfeGDQYZhmtbbMiC+e+QCzFQOvo9q95VY5YCdZ5UZiB5PN5ahZiRreGvMezcTv
         4UVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV4oc/HMF+tfcvCAGj3YQeDi8+7WIa9A455f9GvI7L9G6WPYKDj
	FWyRWK3RQTvhuKTqxADKKy4wnU0BOu/O0y9kvri+SFDCPux1eyMPgB3Hm+jLKsT5HMmrsXLfXwP
	8Q8a5mn35K9bOMTaqpt5ZBDsXFMkFJFn8Z5kkCZemipkZ0NkVwM2vFvk/wb2v45KJBA==
X-Received: by 2002:a37:949:: with SMTP id 70mr4681372qkj.355.1552440431269;
        Tue, 12 Mar 2019 18:27:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPJLKSu6XCW9S/TCEkhiXkRNnuYwuKzaCo5Z82bM4xnj4LxR2o8T4fWqrbu/3JT3A0JYsL
X-Received: by 2002:a37:949:: with SMTP id 70mr4681341qkj.355.1552440430559;
        Tue, 12 Mar 2019 18:27:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552440430; cv=none;
        d=google.com; s=arc-20160816;
        b=mcm1pds+xpqeIBC8ID++9dpn3oyy55SBE8caFz2xmP5/nZX7e/WjrHDUUdGrPHjblu
         /YrlVRQNmFu58kdf7azc+MyaH+fpwjtj/R05grPdTPpuwV+opj4SR5sfXOmNDQY6NcGg
         H7r8vef1Y4LuPBveI6r1H/4p1T6Rthk4sC44KDZPcnZgpidH3iKYH/jvf70lqaBlWF3N
         3AhUfvkFs6Et/xlEEj4se6FmldhNHzL7oa9Nhdg1XvS0okxVsOY35Er2l4KLcJ7/KyzQ
         Qk5R6akr1jaExIcd/b17gh4N0eyxITvE/NkcQmpS01A9arFTfsVNPRxmBw6QYhXCAQbE
         flNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=um0r7NxHpZAEIj2XWQs5JYojdIIDlGSLJxxWq2fz7/Q=;
        b=obEXtHFCB9SM/hxoZvCUdeaFG7qYiwQuLOpL+FUb2tiHexfBzosi0nvtO98HqDFcRE
         kNGOK4deVSbh0y9pyxp8fDDA8nIUN2mvnzSYk2ah1+2tv9vQEAiQdcZmLZ2hO+3+XGJC
         fXoBt/KmCg6lzXGVd5Lee3KXyE9P00lYy3MUKWwmiHIJ0IUN0lzVd0U5idvKtnlgp9Ly
         enQLTtR9pnxGGskfQ8fhwYIZpFA8yqVD6ivsEw2SjLXhmnl9WCILT+Fi2Ox39mEKVr/k
         vSIQ1c01c5aKkR6L9hfkwH91Ub8O+o6+GX26hnpIcrwoxsf2c/mtXsQNlY2JkxbeU5i1
         uWaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z48si393021qvc.138.2019.03.12.18.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 18:27:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C87C17FD59;
	Wed, 13 Mar 2019 01:27:09 +0000 (UTC)
Received: from redhat.com (ovpn-116-53.phx2.redhat.com [10.3.116.53])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 76E8F6031F;
	Wed, 13 Mar 2019 01:27:08 +0000 (UTC)
Date: Tue, 12 Mar 2019 21:27:06 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Felix Kuehling <Felix.Kuehling@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190313012706.GB3402@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 13 Mar 2019 01:27:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew you will not be pushing this patchset in 5.1 ?

Cheers,
Jérôme

