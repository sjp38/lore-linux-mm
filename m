Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74083C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 13:57:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36687214DA
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 13:57:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36687214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D84F88E0008; Wed, 26 Jun 2019 09:57:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D36328E0002; Wed, 26 Jun 2019 09:57:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD60D8E0008; Wed, 26 Jun 2019 09:57:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD618E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:57:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k15so3327290eda.6
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 06:57:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ryLS7YDAWr+S7CQfV3xFWmFFEEIbqtAo1GchtqBj7IE=;
        b=kt1K42fqk3q6I1P2ogRMkWJWBEjhxc7NGjAgkT9HYsUZY53/39PfK3GWq8U2TDE3y0
         Rbm0cpKizZP/AyEDfaijfpL0x3OJ7ahkKQTGEEoBkLqPShcUMQS8fIiecxzj9P4LlPrZ
         2HYlJrwLgWYQFC5yVfh2NMOOSqoWRnWYDkdBLvuE2fNFER4yMm7NHYs+n3cIeTl03XL4
         Ad0WSITCuz94zf7V6UAfcqTbcd2BU5L6s9xwXkA1hxIdEcespCbsnCB/09TlwHluI9CN
         I+vBjPgsUTY5d0aTomVJkQE7FgeVqU/ROGRybsOwvAtnYZfnrdNL07tobf9+a/9qjWFn
         zd0Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXU2QU+9hixigaQOiRkFzZunK0X16ZnhrqhgfXNofVqtI/HyA/m
	zRtRL9f0T/dlop5kPzHpYT7fdiKFy9TIxO1iemCyupVxJ69R2jJOGPCPcdQEgC7ABsjxRiTd5wv
	fm3SgiQcw59NtH0amkKRMrRy8wRndNDFyY7RxOPfpFGr7cngK9Coi7D/5QvTbFws=
X-Received: by 2002:a50:b662:: with SMTP id c31mr5434585ede.252.1561557467011;
        Wed, 26 Jun 2019 06:57:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKc2J3STqPXvhKJ+VDARuS/VpVA33sfNDvJKpB1Pb3RO0ZjqKLzyE4tgtFbhLYtGphvDAC
X-Received: by 2002:a50:b662:: with SMTP id c31mr5434525ede.252.1561557466298;
        Wed, 26 Jun 2019 06:57:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561557466; cv=none;
        d=google.com; s=arc-20160816;
        b=j7I4iAIqBHLQpXIwwgvZ6w/ZuNA5fbHUakjIdTivkFj3L/xu2y6w4sCeiWRyF0XWji
         /tsDA7k4BQPOlltwWZjqb2s2XJPQFB6ZCl6qGhV0OktlsgxeOmiKnY0cd1dthVjlRcFP
         QWYh4Nauf5jCbFC4Gz5UCFW3uq3agm4CAiqkrWgfchpXKsfuQgkn8pazSQTQDJgrGer5
         bPbAYbOv9yuvXwZFrNj1LbZ+QinM/8gl5X3NpnAbjxZrmTyAvdYHFDyVlfAMIq6xAJz+
         /T4CLkCe7Gl2Uf/Hz4pPpJ2KyPEnFfz4izkq34/Y8nuli7rk1O/uPb/X1M7CxArKQu2s
         IEMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ryLS7YDAWr+S7CQfV3xFWmFFEEIbqtAo1GchtqBj7IE=;
        b=jIZEGu8dUInLQv68JfuJFpjRkG4iD6mX6jlzh/Qu3Q/k1oa7IzOrgluwvJxTahENX/
         Rt7Wn4YCIv85cU0H1WeOKN9kk9oLV8uG2/3r1kTR6F1O5KO5DYFJ4RtxkGyFQgjwH73H
         xij6Yf4bUGDOiV2Bc5dP7sMnk7ZhVMLK9jFNKy+WHX3uC6fZJ3Bn1JwsC4Jw1msSl68J
         9GiGNZWbC/oFnlxP1pYei9HlDzYdNhcP5MgTO3mYJJyE78MVBSZNv6vlZtvyY0vLvCKs
         F7po/DEEtMvSOdV0cjrbMjrWPnu8lfr5V03vR5G87hxsj5FtBR2P6DeY7Qqx0M5F2y7e
         4Kzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t16si3363567eda.244.2019.06.26.06.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 06:57:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B933AAF05;
	Wed, 26 Jun 2019 13:57:45 +0000 (UTC)
Date: Wed, 26 Jun 2019 15:57:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>,
	Barret Rhoden <brho@google.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@elte.hu>,
	Oscar Salvador <osalvador@suse.de>,
	Andy Lutomirski <luto@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA
 boot
Message-ID: <20190626135744.GX17798@dhcp22.suse.cz>
References: <20190512054829.11899-1-cai@lca.pw>
 <20190513124112.GH24036@dhcp22.suse.cz>
 <1561123078.5154.41.camel@lca.pw>
 <20190621135507.GE3429@dhcp22.suse.cz>
 <CAFgQCTvSJjzFGGyt_VOvyB46yy6452wach7UmmuY5ZJZ3YZzcg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTvSJjzFGGyt_VOvyB46yy6452wach7UmmuY5ZJZ3YZzcg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 24-06-19 16:42:20, Pingfan Liu wrote:
> Hi Michal,
> 
> What about dropping the change of the online definition of your patch,
> just do the following?

I am sorry but I am unlikely to find some more time to look into this. I
am willing to help reviewing but I will not find enough time to focus on
this to fix up the patch. Are you willing to work on this and finish the
patch? It is a very tricky area with side effects really hard to see in
advance but going with a robust fix is definitely worth the effort.

Thanks!
-- 
Michal Hocko
SUSE Labs

