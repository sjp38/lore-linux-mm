Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70229C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:03:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22A162075E
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:03:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22A162075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7713E6B0005; Thu, 27 Jun 2019 17:03:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7226E8E0003; Thu, 27 Jun 2019 17:03:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C2DE8E0002; Thu, 27 Jun 2019 17:03:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9C16B0005
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 17:03:29 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z6so3758985qtj.7
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:03:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=w6Zk2X1UotXBBdbiqYU/9wWxwQErmet13FPhuMOM6+c=;
        b=gW6Mu2DizPFMvCZXYMBpueaHhbGAC0XGujZfL2cAFxJJluVVUv1XBKE4paBKVac3pp
         +lxhog1cN5n56bOsgfNM9BCmBJaz8bgEbSDZrwbuI5Mm0peFbbduXAlXw7KjgEAVjG/K
         SyouYjNLwINZwalKjzBeCOQVRXnAwDwcZce+pOWTybG/CyHC8qDDiUReLoeeRJTMwSsB
         jFfPF6ccfE1H7eGDm9aqTRj9sOZqZ4G1TKjTrNp+90JSSC8BNOrEQU2XML/bYiA+7Swq
         WKVLnhu7Y9McUb6x5+OjBNq88OH8hd6em86ltK4S/QyyyljEX/wXH6cRpGd75yx9QUOY
         CXeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/4CV5+GISb/PwMLZCEfNJjoo60pJMPolo1FhJHwz6Y7aKhWef
	s8Ee0g6k2siCefKycZ/ekPUCxMEG/BWkK52Hv3byyc6wpSjzR832/wSUA0RLdqBomP4dsrwuoDn
	9bE2i+1P/6guM0q0il6+ctJM17NTGA0NJt+n9N5laNcx5swPBtbQRb6huMuHbcMkB5g==
X-Received: by 2002:ac8:2bf1:: with SMTP id n46mr5041475qtn.372.1561669409030;
        Thu, 27 Jun 2019 14:03:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycedzOYQoGuaWpQUcmSr2R6/fg5Tqy3mTgQ3pPrvqKa7nZuNQdmxaVrJ/VhFyPhO58f+VF
X-Received: by 2002:ac8:2bf1:: with SMTP id n46mr5041435qtn.372.1561669408524;
        Thu, 27 Jun 2019 14:03:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561669408; cv=none;
        d=google.com; s=arc-20160816;
        b=vQ1pbo9OWXaLEtXwmSU0e2jb8K1e/8nkbWiRYpK3wPuKPZVc3welUi1r/BcNYpfCD/
         jUhjOlxXnSVzYp68WA5jUeFtj7tnLOwl04sxGj8/nLg/F85PIxm5+nQa2zdiU77NGpJl
         FleQ9Qc9qkAMd8ifOOOD6Bcj75rkB2MD5H5jRI4dvZJQmqAo+0vMIInzIlV9XKz+YTO1
         nREsAv47m9IH3WnMiQ58nAaeH6ev7MJ3TUHOPtFhn17VPCoouBRcxymBqMc99m9t/AeE
         ZiNse7AGMvREc/3J7uF2pqxvu6e2LFqJDn6rHetqGLk9fc5CFZkxwJI0LgYmixLWVajn
         OBqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=w6Zk2X1UotXBBdbiqYU/9wWxwQErmet13FPhuMOM6+c=;
        b=qocEkzHOdtvEkcRRUxhDCx5Su1R57i7w+VbyCgLywLse1JSa5hKvAWUjRMk4pbKrqy
         HgHq0XjkSY8/lvX7rKQPhRkkDqKKCfLhw4d88rTgytWuDakP4BzCPMDwdK2a+HEb6llO
         M8qFBoBDeiu30qfVbl3K3kUWMCeLrc1VCoWYXavZRvlOj8NR4vL4ccuxnY4nZBu4HFMk
         XroUYffcqGjs9szWDGDMyl2EOMOiQgHv3WuWbbiTZXzN8vAXSiY/S42eJFm/lLIBf7bs
         iEt1m0FWsouW3gx3vYwEBg+qOEUFJ7JQfpduOUkYIgBFPm6X5bnLSLr3QPDjAYJDEXtD
         TijA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c80si224180qke.221.2019.06.27.14.03.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 14:03:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CAEA6308620B;
	Thu, 27 Jun 2019 21:03:10 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 24CD61001284;
	Thu, 27 Jun 2019 21:03:07 +0000 (UTC)
Subject: Re: [PATCH 1/2] mm, memcontrol: Add memcg_iterate_all()
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
 <20190624174219.25513-2-longman@redhat.com>
 <20190627150746.GD5303@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <2213070d-34c3-4f40-d780-ac371a9cbbbe@redhat.com>
Date: Thu, 27 Jun 2019 17:03:06 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190627150746.GD5303@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 27 Jun 2019 21:03:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/27/19 11:07 AM, Michal Hocko wrote:
> On Mon 24-06-19 13:42:18, Waiman Long wrote:
>> Add a memcg_iterate_all() function for iterating all the available
>> memory cgroups and call the given callback function for each of the
>> memory cgruops.
> Why is a trivial wrapper any better than open coded usage of the
> iterator?

Because the iterator is only defined within memcontrol.c. So an
alternative may be to put the iterator into a header file that can be
used by others. Will take a look at that.

Cheers,
Longman

