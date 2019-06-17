Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2DC3C31E5C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:50:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73F50208C4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:50:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73F50208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 172DA8E0003; Mon, 17 Jun 2019 10:50:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FBFC8E0001; Mon, 17 Jun 2019 10:50:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F05908E0003; Mon, 17 Jun 2019 10:50:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEE3E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:50:40 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id p206so6713447qke.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:50:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=Pr2OSaag4b+DHGOVmwz9iXecK0Wb2DqRzJTONJV/vdM=;
        b=GoSf36n1mnUWywST8S+MijWComXCnlo5eKyFkVh3YDrMnqnbdquLFRpgjX7mUPWz02
         DbUhgVqHyQKLRkPHG+ki33D/HeTOZViNoC54zB6/kTMJPGElLHojFJofMC91uw6/A5vw
         BJGbpvgDGNTevjqa0EcBeb73S6g/iC0k4FNOfwkeJBTMUvb7QjlTjfitiGO+vV5sfWjJ
         st2QkwOd3MBtj9GxZmJmZPvg9Myz9+KYNxG34/ZMzimXWAb9NjXIinvP862P3MLy1Ips
         XHSh9aV7xli14H+kaZhEHSUF1r3Y0dZpNLT+fdkfKwWcGo2Nofzzw8oxtmgF2ii9DuT7
         j8YA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVQv+U4X22B928g9IwHgvqOpJjUdpOQGTSdQTDB6rwffkHIuSst
	v2eBaFAwSSUxBAhz49IWQVZY3UgLWYUzXvy5Qdocrywh5qHlY9urCvsPtKokUzFGrmUV/d+yFOK
	gRrehDJn9IlbmibvyiTWd/PODCCuO8GMrTXHEdAp7DHP2FrfqLV/qjJ8DKhRmNU/v3g==
X-Received: by 2002:a0c:d295:: with SMTP id q21mr21782717qvh.245.1560783040657;
        Mon, 17 Jun 2019 07:50:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxufpO/k5njsE4jr0m2OE+VxXHO2P4+Vj/2p8D35pNSGH9A4D11M2NiwZQdNvi2Yha48ioQ
X-Received: by 2002:a0c:d295:: with SMTP id q21mr21782668qvh.245.1560783040116;
        Mon, 17 Jun 2019 07:50:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560783040; cv=none;
        d=google.com; s=arc-20160816;
        b=0LEkOoIXhyKh1ktg6TBHXFuNFJnr3/lBwbaZwHOCXHkSjO0YU0K8QE6XIk178uYr0G
         zBpodpY6MdUxBCvMp1rmZ0Wbi4Dn2NDdXHJgfLo6HQW58TfeSGukfg4tgGabYQcsmmoM
         LnTB66uWOQ9kLRzwjOuW6PyV0vOVLjHkc6pXwmeQcC1MARBmeRlUS/hKUUZKmzAnYWdQ
         FjAp+8EoRc3GKOJRduWyPPk2y3sU6jmWlHqjCxcHVynl4IdKorsT8orKU0F3elZdZOd+
         22lFbThC4GlNauAW6VKOgiijWbGPgt5OhJmT0E70iIsZ27iitSqLAHIwqbKwHtGIMgST
         3lhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=Pr2OSaag4b+DHGOVmwz9iXecK0Wb2DqRzJTONJV/vdM=;
        b=rRLIYbZeg+oLTnHRBbGgzPz8ymRqVuzh15r/gZF6OB3MhLAQwwmUoIwvfMgDoMLdyZ
         Mzsm1L1LYq5oY5RGiy/cHpYp+VL0w8NtuavXJF1kZUQBAEwBzYo0PskfmXC0GKpJpy+e
         ypZdqUW12X/FH6GRz6s/fMW/E2WP0COTjI7HMbZ5Sj0q+PsPjYecyDaqribe/mlhp2nt
         bDobN9RdeGotqQbl4lOvosetfSwv7LBEHIiPHWg3R9cz5nSqpvocNlCRb/kZ498YUHQY
         /wYr0pFXtIslneTJJ1Hm3F1TMpxtmMDy1ngKr2heVJNNQ4YWjbaQya9FortknCC7M1CT
         W7YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n1si7914371qkd.107.2019.06.17.07.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 07:50:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2823DC02938A;
	Mon, 17 Jun 2019 14:50:26 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8730B7DF71;
	Mon, 17 Jun 2019 14:50:23 +0000 (UTC)
Subject: Re: [PATCH] mm, memcg: Report number of memcg caches in slabinfo
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-api@vger.kernel.org
References: <20190617142149.5245-1-longman@redhat.com>
 <20190617143842.GC1492@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <9e165eae-e354-04c4-6362-0f80fe819469@redhat.com>
Date: Mon, 17 Jun 2019 10:50:23 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190617143842.GC1492@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 17 Jun 2019 14:50:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/17/19 10:38 AM, Michal Hocko wrote:
> [Cc linux-api]
>
> On Mon 17-06-19 10:21:49, Waiman Long wrote:
>> There are concerns about memory leaks from extensive use of memory
>> cgroups as each memory cgroup creates its own set of kmem caches. There
>> is a possiblity that the memcg kmem caches may remain even after the
>> memory cgroup removal.
>>
>> Therefore, it will be useful to show how many memcg caches are present
>> for each of the kmem caches.
> How is a user going to use that information?  Btw. Don't we have an
> interface to display the number of (dead) cgroups?

The interface to report dead cgroups is for cgroup v2 (cgroup.stat)
only. I don't think there is a way to find that for cgroup v1. Also the
number of memcg kmem caches may not be the same as the number of
memcg's. It can range from 0 to above the number of memcg's.  So it is
an interesting number by itself.

From the user perspective, if the numbers is way above the number of
memcg's, there is probably something wrong there.

Cheers,
Longman

