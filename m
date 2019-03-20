Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31E74C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:03:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFA082146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:03:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFA082146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86B1F6B0003; Wed, 20 Mar 2019 04:03:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81BE16B0006; Wed, 20 Mar 2019 04:03:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70B536B0008; Wed, 20 Mar 2019 04:03:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 487B96B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:03:42 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l10so17915745qkj.22
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 01:03:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6fSV1xihtFs9HIk6vq1wvpEsHnhoTbXCqEQFzUq1J4M=;
        b=CPtvbH4rZq7wzFWvLb/MVgpA9/iN8NiigF+z+OMgJeYZf6cX0048Cfrqahoc8OFzBh
         YpofNa/0rlgXq1ItYOW6XBW1gYWOG+Kyo1a+XPlvs/6vRMTSyBkUXsHXtxs8o4TUmKqL
         mdsZXO/vxQDYE+0oUzKiB/4KyIeGZIi0ttkdClcEWSS59rUKtHlTSDvbFdPv7/tdYaJI
         ELeFkecXfePu69accj4UGavEyBsFU7THt8U4l6opEaRdZe9bGcbP07idA/3pJIblmKXD
         J+1eGklxT8FnswbFD/QsvtrGWZraL8fk1TYIiPBg6+9LPsZBqsqNAR/aZJ/uw6LfzFAT
         RL+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXbYm6JRo47Tatltoz4asgFM7kqBBLpCKgrWt4iPP8Mny+qRLXN
	g6LcrYqKjb3y2BUssdlX9l8gJ3DCGxxEsW+AzSUtRmx01Hx8AAzduRrdCr4YP051XK6cjybiaPS
	/dq3HWzNMm1Tahu6mPisJQXMuNGkPvcyNOqnG+GGSpCUD4E27IyA2Y9bmw4jq3672BA==
X-Received: by 2002:ac8:196b:: with SMTP id g40mr5771142qtk.218.1553069021632;
        Wed, 20 Mar 2019 01:03:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynX7JKOOS0W9U8bYiMJj2VbL/d4rpU1vgnZg+AQ7fveVB2ZwvQ4wmQIFU8m7VfgqM+neHb
X-Received: by 2002:ac8:196b:: with SMTP id g40mr5771110qtk.218.1553069021048;
        Wed, 20 Mar 2019 01:03:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553069021; cv=none;
        d=google.com; s=arc-20160816;
        b=EI1+JsYpQKbJX373sRCZEJeTS6S1jhcasEM37pibxCLLhzY45dDXFXUZ3wBQj7AfYX
         AQg/Dxva1l9shO1uG4BDiVWfiC2qXvjuvEsC+GsjW4qHCYOABbUjb2jPCl/1HFEywgtd
         hQoSwV7ZG55NQ6pJh3do9p9DvODuN0erTOK3MaJl2bGt9rcJczgVCtcearr2cFkodZgR
         ZWFdnueix7POWlkaX4O7GW6ykULQaMMiRj91RA5VFmFNLl9X9Ylu5SoidtYMh2Yb6Rp5
         stbd/WHhnpzuzFQXLqTfSxdLaC+rVS1KY1lNlC+F/HyyfY3ucjLECS/hhcd6crjCHGnS
         CpYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6fSV1xihtFs9HIk6vq1wvpEsHnhoTbXCqEQFzUq1J4M=;
        b=EmRtBBx7+0CI48E175Ok1hfGNJt91Z3HY4q+odkIeZtSdlD/vsmLqKSi/PzrFQLOi2
         +W/l7YBDfc29PUu0Vs1ZQsj6IYp0SjNnUYYDXfq4C8C8h+AsnIBrKdObfzUmquyXS8qN
         Djp9Iinc4zHZl9RRzFUo18LoCBnadPCU55hwbCtzmA5de8a4VsKsrcOif767V9a6wAit
         a68bdUmz+OqS5nD982c+p7kkcUgaaYrAXPLUZoQAYEtdcqsMuuM2Nd5V1AiSa4bslVqV
         /oIMQSNrD6qpBHpQBQXjHhSr4SsqdpTYiStY+6M57DrBI06W3/ZH3KJgi4DCmJqIlk0b
         CVLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w21si808608qth.249.2019.03.20.01.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 01:03:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 44C1AC01089C;
	Wed, 20 Mar 2019 08:03:40 +0000 (UTC)
Received: from localhost (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2823A6B499;
	Wed, 20 Mar 2019 08:03:36 +0000 (UTC)
Date: Wed, 20 Mar 2019 16:03:34 +0800
From: Baoquan He <bhe@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 2/3] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190320080334.GM18740@MiWiFi-R3L-srv>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320073540.12866-2-bhe@redhat.com>
 <20190320075649.GC13626@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320075649.GC13626@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 20 Mar 2019 08:03:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/20/19 at 09:56am, Mike Rapoport wrote:
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 0a0f82c5d969..054b99f74181 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -697,16 +697,17 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
> >  	ret = sparse_index_init(section_nr, nid);
> >  	if (ret < 0 && ret != -EEXIST)
> >  		return ret;
> > -	ret = 0;
> > -	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> > -	if (!memmap)
> > -		return -ENOMEM;
> > +
> >  	usemap = __kmalloc_section_usemap();
> > -	if (!usemap) {
> > -		__kfree_section_memmap(memmap, altmap);
> > +	if (!usemap)
> > +		return -ENOMEM;
> > +	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> > +	if (!memmap) {
> > +		kfree(usemap);
> 
> If you are anyway changing this why not to switch to goto's for error
> handling?

OK, I am fine to switch to 'goto'. Will update and repost. Thanks.

> 
> >  		return -ENOMEM;
> >  	}
> > 
> > +	ret = 0;
> >  	ms = __pfn_to_section(start_pfn);
> >  	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
> >  		ret = -EEXIST;
> > -- 
> > 2.17.2
> > 
> 
> -- 
> Sincerely yours,
> Mike.
> 

