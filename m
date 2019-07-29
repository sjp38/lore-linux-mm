Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75D2DC7618E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 20:41:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4174E20659
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 20:41:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4174E20659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE8858E0003; Mon, 29 Jul 2019 16:41:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A98188E0002; Mon, 29 Jul 2019 16:41:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9861D8E0003; Mon, 29 Jul 2019 16:41:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74CDC8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:41:03 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id h3so16355217vsr.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 13:41:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=cHuVEa4b4yPyxQKON1clSxwXW1PRaydH2YwPKa3H6Yc=;
        b=NU465uvh2pZI0qLfnMGR1GnDbRior6qxDf7Q60Qw0dvOv42AMb7srcgWBtnEYdtsai
         2ROCHb6xcUgMf1YVOZz+O6dnJS2R+d+YJj77qGWaniOhjz3VbJiY2v5FJcMcA8fBP+8e
         LpqXfA7Q4DK4nIUz/feLWjkPgWeSEOhvYWV2hjoE0rvLjNdxAukh1GtOqQHCtB8TXB9+
         dXEvp8sEAeereMsx5VLgF7I8UN09GD8CnmBcWTXdnD586tPLVhFkD+VHCefMR8kMTrc4
         ELajBxUn+EWY+jX9NVjC2t0FiLnZuyJ3lFoO5yRLxS64GkabVKqYU2sSubVt2Stif571
         XQQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU9e9HpIaSESTnlPO9wQoRkKl7/Nr1Fr8peSIXn6GeslDjodPNx
	KszjjnyUIrV2SCUmR4zMKxwKw6mOREj8IzaTKd0tR9QGgIEy3CEIP3rVTC8Ytfe4kE7XQQ+N06a
	FfZ9r3jD64UBowlg55XAZkmbKUf+TsR8rucz2oTS6hgTCV+t4Gmgloq2r6nwArYGwfA==
X-Received: by 2002:ab0:48e7:: with SMTP id y36mr1465548uac.79.1564432863190;
        Mon, 29 Jul 2019 13:41:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJCSqLPEhndMD+BHa+XVnb2WAO+fmmRKxVR2Wn69LLLb9SPPbRqOuOEKqn202ac//QjIc1
X-Received: by 2002:ab0:48e7:: with SMTP id y36mr1465468uac.79.1564432862524;
        Mon, 29 Jul 2019 13:41:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564432862; cv=none;
        d=google.com; s=arc-20160816;
        b=gmpyUTOdq3Ezs4If4CfQpxq1TRNdMBhJR8OH6d4ooXo6lhCzXroxQPUHF9OUNfTpBu
         IBSME/VDh/1U6D4RalQ5ff/dmBMC2mqnzsXKlxCJO/1zLE7UtopjUMHz9vqTJadWDVwn
         /uiDKk4X15n/VE8rXhnuLil2ixD12D3WF3LmRlIfHRG7xzYdvuigo9zbTxLhKEQZ6yIa
         F+2Jkia9y1T4CmtBbhiU27b4NLDkMt8Ofyif3++nV8QjOQAEp+TVe90THl3JSqAm3Pad
         aVu9zEeSye+OWkctYAVr/nggjWpVZ/XgmQCXrDfDOdr8hUz5qJxE+H7KwwPbSTV+2mEa
         5UJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=cHuVEa4b4yPyxQKON1clSxwXW1PRaydH2YwPKa3H6Yc=;
        b=NaaAAduk6zUP+M6D16z7GOsukUqt2fdEwb3ywggYF6vzLMzmT8qx8PFepgMAIPmk57
         IRWui6K1J1UdZTxcGM9x+BothuXamaLrFM88cpvDRXsdfKnsjseUFNbqlfP3/a61Uo4n
         +tO6zpze/VGotRFWWzvPYbz5dKutOuNWaHmShx7BT+/0/qHQm/mohZlaGEjPsa+oWUKS
         8SJPkrs32hYbeVuAf+AyO9IId7o8VYyz6FfY+rzxeYURzpJrV/dwsplH/nuUdYoRV3Kk
         fBwhJiklYou6jEMDHVvUP9AQRRY/bTcqZd7lx6pTIHMRaaMTyNLCH0d8vTo/nAmkya5W
         lNAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k5si22702249uaq.207.2019.07.29.13.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 13:41:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B3B40368E3;
	Mon, 29 Jul 2019 20:41:01 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CD1435D9CA;
	Mon, 29 Jul 2019 20:41:00 +0000 (UTC)
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729091249.GE9330@dhcp22.suse.cz>
 <556445a2-8912-c017-413c-7a4f36c4b89e@redhat.com>
 <20190729185853.GJ9330@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <9e403b46-e0cb-0841-4ff7-6ecb30580d33@redhat.com>
Date: Mon, 29 Jul 2019 16:41:00 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190729185853.GJ9330@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 29 Jul 2019 20:41:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 2:58 PM, Michal Hocko wrote:
> On Mon 29-07-19 11:27:35, Waiman Long wrote:
>> On 7/29/19 5:12 AM, Michal Hocko wrote:
>>> On Sat 27-07-19 13:10:47, Waiman Long wrote:
>>>> It was found that a dying mm_struct where the owning task has exited
>>>> can stay on as active_mm of kernel threads as long as no other user
>>>> tasks run on those CPUs that use it as active_mm. This prolongs the
>>>> life time of dying mm holding up memory and other resources like swap
>>>> space that cannot be freed.
>>> IIRC use_mm doesn't pin the address space. It only pins the mm_struct
>>> itself. So what exactly is the problem here?
>> As explained in my response to Peter, I found that resource like swap
>> space were depleted even after the exit of the offending program in a
>> mostly idle system. This patch is to make sure that those resources get
>> freed after program exit ASAP.
> Could you elaborate more? How can a mm counter (do not confuse with
> mm_users) prevent address space to be torn down on exit?

Many of the resources tied to mm_struct are indeed freed when mm_users
becomes 0 including swap space reservation, I think. I was testing a mm
patch and it did have a missing mmput bug that cause mm_users not going
to 0. I fixed the bug, and with sched patch to speed up the release the
mm_struct, every was fine. I didn't realize that fixing the mm bug is
enough to free the swap space.

Still there are some resources not being free when the mm_count is
non-zero. It is certainly less serious than what I have thought. Sorry
for the confusion.

Cheers,
Longman

