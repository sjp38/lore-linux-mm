Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD118C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:58:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DBE121855
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:58:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="KrCCbqJw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DBE121855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20F808E0003; Mon, 17 Jun 2019 02:58:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C2478E0001; Mon, 17 Jun 2019 02:58:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 087B38E0003; Mon, 17 Jun 2019 02:58:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id D91AF8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:58:47 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id b63so11329102ywc.12
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 23:58:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Qc0wKhR7TMnGEtRJEBVLBob7EkTOdf2YmOm3ZpgPv68=;
        b=NIvNy0ZosNOu6ipCTc7vkFph/ZEUzflor8UoHCYVu4lckSsINkEQfLA9+s8FOteWt1
         9gG70vM1vmu0nhWMIPCj/MsBo93wTUP9jMq88iNLBkGgXFIUzPtzp9so8N6c4Z9kqXEi
         9VhHCXs7d6qDBozkCkeURu5GI8UAMxgTJd3O2j0Xq/JtMycwtIBALV9y8nvpIrE3FCF8
         EoPluBoW+aPo19EvjCzDzLpucOawGM+DmbK9RA+VjFOXxkMXE+bW9+rbRHWKhJ819KEm
         Gn0HJBDtKrcejMMGwxXaEydb5JeWcxfOxsMUh5oxs7ySmmeJKn3FYR6btUfmCUzjGqQE
         QrbA==
X-Gm-Message-State: APjAAAUZTzyE2uHuJdamxkh4EtgzOOqadNS3AIBnwLi453KPB5BvMMXt
	pepleWIXY7dMFgDkHf7W7qfXyp3n03BhocMzOoAGSE26wJFzxVoxAByOQvZ4xWu94IvIGoRTQsn
	gDIbTXWhejjnSs0NsFJoNJFj/H2x8Jl1v6asReQbo95wVyXpNh4WfgaUIYnRkWgwzgA==
X-Received: by 2002:a25:a08c:: with SMTP id y12mr53983023ybh.469.1560754727602;
        Sun, 16 Jun 2019 23:58:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDo8m0HMyH6ly284WytrUnM1FGGRZhYb+eEKIr3FvSvFLE3tEFTvAwt5b/Gao5UlKpck3K
X-Received: by 2002:a25:a08c:: with SMTP id y12mr53983013ybh.469.1560754727026;
        Sun, 16 Jun 2019 23:58:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560754727; cv=none;
        d=google.com; s=arc-20160816;
        b=Gx98VKrAlBVBwJHxnyFsoGnoEwI6RaJmFpq9suMEHeSDdylzD0oU0yCUlonzxh8Ehs
         UuGan+DreFRFVz66O4XriPB8TPR53A7G8OGcivdmcYxky2nJIpkSYVHViajK+Zvk617A
         hVl/5/9CPjJFUofr3KLt2BtZ19Zg5gjLYCKDQwjqy5aEANtIPIf+OZA6xLYHSMMOQ7J8
         xCnIgalTlIWnBa9M4hymvtF/Vr/0ZSUVcZZV9NnmvEnOphy7xGTb6t1/f9UOh6UO8Iej
         9Q8cgz8StsF2B7LnGyCIbVDafW5xDx7TzLEo0e+FsbfG5UXmq8Z93SIUmLawOm8bmpYU
         OVqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=Qc0wKhR7TMnGEtRJEBVLBob7EkTOdf2YmOm3ZpgPv68=;
        b=OpiZpp+9NKk2Et47rAhukBj+NRbCEULqHMFrSQdBY/Y3pu70znlOsJ3afrf3fOBsD7
         wFMJ74X57BQzIVkPq7MlXplNHP3hZO0/wIESXnlDDLnngoNg3Z+A87o73BXhD4ELsx+H
         Ykw3Z5PdM1p5jsDvMYScz7a/agIBsP7Z0rKOISx4lkcFo/t0KNHJunlVwubqLQhhMxtY
         /ZG4GuCC2KJwgVVuA0ioGfEVR5o84MqMhu4Vm4MDfKYgx8PNaDOJ1Rcccc7byDBWjDQh
         1Q2omS46HBLvkXFhBjjPi8Nsr01gXj34UlFUAvnoG4MnAxgmg7fw3UVLanFytfGsenJD
         7iqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=KrCCbqJw;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com. [66.55.73.32])
        by mx.google.com with ESMTP id 191si3777726ybl.79.2019.06.16.23.58.46
        for <linux-mm@kvack.org>;
        Sun, 16 Jun 2019 23:58:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) client-ip=66.55.73.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=KrCCbqJw;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id E03DF2DC007F;
	Mon, 17 Jun 2019 02:58:45 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1560754726;
	bh=qtYoLQ9Jtz+QdOMQZQtS2I0PlmfBJLpviCQHIugyg54=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=KrCCbqJwEDVPV1oa+HDQWzTzSNiFMcYGZMMOmYQw9F/WU0Jd4mbKK/W8AOXM4EUKo
	 2FvKl6qyBtjfe8KwP88PsTOZUtfb1lAKkW+GyjR/YztolKQC2u2lUUgOK8+z0uNz4J
	 heIGsVRcVkbaedZxOqjsigKFfYIwCfDjfUcdiedzqqwaR0H6flnOErGxjEB72K6Pwi
	 hnKIJPA2PLyLlLICu+LYKqf92ky5qtgblyZ1hir94RpASmsX+yK9T2W1xlnEePXrWr
	 Jjm95kC+O3yA0EfVTx7qgTnb1nVw6TO4XEzRdcRmQFoDKjpFKJKQiNFnx6x8sYBoSJ
	 R50tcEWqLSW49YKe2nalt5ISXsrcOlJ4PCklJz+kkhsv364+gPdAfq/KebM41n/MRR
	 pBmPcDdbJf0/BKltr9bwIm1Hq0wnzPwv81DkVG6PWTGwcwMAJh6rgZdMqxthd3kawu
	 OdXg8gLwAPQlFgCHO1aSj08TT6/6qqFEzVQ1tNsUZYusRL67Jiq8XTm9x/S1p1ShgL
	 mdfEj/o61fknpMcUGqQ2YqCmNhKllEDvSt1oczBtefKutI0qT3iDpF19pUfeWCXbcI
	 w8n3qi6ggAcV8tEQevpUrxAF+jNxm4D/L78u7wXQsnUsA5eig/n2+Rz8ekfgXQYoce
	 sShKw4GRp7OoxN+XmPZ+gEi4=
Received: from adsilva.ozlabs.ibm.com (static-82-10.transact.net.au [122.99.82.10] (may be forged))
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x5H6wNQI056924
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NO);
	Mon, 17 Jun 2019 16:58:38 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
Message-ID: <790f8e0126abfa199cb690270c94ce163eca458d.camel@d-silva.org>
Subject: Re: [PATCH 4/5] mm/hotplug: Avoid RCU stalls when removing large
 amounts of memory
From: "Alastair D'Silva" <alastair@d-silva.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand
 <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko
 <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang
 <richard.weiyang@gmail.com>, Juergen Gross <jgross@suse.com>,
        Qian Cai
 <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar
 <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
        Jiri Kosina
 <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>,
        Mukesh Ojha
 <mojha@codeaurora.org>, Arun KS <arunks@codeaurora.org>,
        Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe
 <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Date: Mon, 17 Jun 2019 16:58:22 +1000
In-Reply-To: <20190617065357.GD16810@rapoport-lnx>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
	 <20190617043635.13201-5-alastair@au1.ibm.com>
	 <20190617065357.GD16810@rapoport-lnx>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Mon, 17 Jun 2019 16:58:42 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-17 at 09:53 +0300, Mike Rapoport wrote:
> On Mon, Jun 17, 2019 at 02:36:30PM +1000, Alastair D'Silva wrote:
> > From: Alastair D'Silva <alastair@d-silva.org>
> > 
> > When removing sufficiently large amounts of memory, we trigger RCU
> > stall
> > detection. By periodically calling cond_resched(), we avoid bogus
> > stall
> > warnings.
> > 
> > Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> > ---
> >  mm/memory_hotplug.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index e096c987d261..382b3a0c9333 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -578,6 +578,9 @@ void __remove_pages(struct zone *zone, unsigned
> > long phys_start_pfn,
> >  		__remove_section(zone, __pfn_to_section(pfn),
> > map_offset,
> >  				 altmap);
> >  		map_offset = 0;
> > +
> > +		if (!(i & 0x0FFF))
> 
> No magic numbers please. And a comment would be appreciated.
> 

Agreed, thanks for the review.

-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva    
Twitter: @EvilDeece
blog: http://alastair.d-silva.org


