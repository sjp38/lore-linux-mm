Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3565C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 14:18:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE9AE2075D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 14:18:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE9AE2075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 750136B0003; Tue, 26 Mar 2019 10:18:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FF0D6B0006; Tue, 26 Mar 2019 10:18:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EF9F6B0007; Tue, 26 Mar 2019 10:18:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 421B06B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 10:18:09 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 23so11689320qkl.16
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 07:18:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xedenWZ3PtHaguKYtHBOirpbQpKUUmeNt9P82J55FT8=;
        b=BEDI0IQYJnyd851TMu5Ub1xjExaRQ9tBy3qDrEFBxMkQqYOUVT0fj1B4sQxyq+Bjkc
         DqN7z4OZXzYwKS2FtPBHie7BvX+oxXp03WKVPaTbJQbh4KholDqaWCkzI2QlSNA3AlmZ
         jaujLKBFuc4fbOguqlngjLt0cVW1SRKNDjJWqLGHtaIJTM97AwimMgK9jjViTD034HtD
         8CnRAZQU674fEnAhOoERzYSnX4UvRYJKn1yFljdnc9xbBOS9lstTBOROZ38bVu/vAmkr
         AbcE0+n2hwSQcvNIdWziXL3P5QBc+t+fd5KSG8xqudsWD0nYIppv6x1w5+uVjnbn7jBc
         J3Yg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUx6FbDw/E/j1QOsw5hCao3sEETHyTqi5ZxoV4kP0DwPpFp0Muv
	ccs21phzuu1WHnNDeJ1BMITa9dGa4iNs2Vrkc0G2rSgFbAXlD1sRfco9udB8Vg/4yXl3KmiwCpw
	3bQ3fwXZvGNwJ1RFLPokxoATQn7EPjPd11qLaZuedOSpBOCb2RP/CiV8MkaxcOSdXdw==
X-Received: by 2002:aed:3aaa:: with SMTP id o39mr10950718qte.100.1553609889035;
        Tue, 26 Mar 2019 07:18:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxS5BzcFe6A94EWURnXAOJe5oKo9bXYEp7cLQKliiH0wQryFX2KiFGbaSd5IP2tHyYid/d
X-Received: by 2002:aed:3aaa:: with SMTP id o39mr10950676qte.100.1553609888519;
        Tue, 26 Mar 2019 07:18:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553609888; cv=none;
        d=google.com; s=arc-20160816;
        b=r+pqhGATxRuq9xr4C4HuviU3bihvdYUl+Gt+MK15KyIjHHYgA4eU6XFabFPkGVnNw1
         fXC6YmphVvcBjPg4AZFxubg4uN0EsvuJStK9CXsZzXDMhoVi3wRzrJImrs04h9B3IvEc
         qI0MQX8IyCAQZyelwISCHI3W4Q0/qFbIL32D8O2WrIvjLCE3c0V8+2wQj2i18TWrp2ri
         DMdoWqPgBobbQCmmicqf4fkyDTzaQMPvMSiCGK+gF8vNxoWjqeqwTE7MyycXH6UZOF6j
         lRQA4xe5zjba2pyVz7JXRmeRQ31/hKbyX6tGSQUTf9RgeXbAY+a3m6NzzW0IzXa/oL95
         O8zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xedenWZ3PtHaguKYtHBOirpbQpKUUmeNt9P82J55FT8=;
        b=IUCC/KcjAfzJYXoPcgZMUQO1OwQXtid4L9anujwEE0gEo11vUGRnppq7XbjzPiHU4k
         gvwFhZB6bTYwhu/MJ0TqfOGACl/RCDWmkape4hQeHychyuHHihZHS7w4tweHvR+ceNcO
         cv1t93zH37FnV/eLmtB+Aqcuoq7HaORXfftajZo5wNkA7i2JF9+Wtj9+TvKxAB7MCRC/
         RKXOSY8b6SPaCBhifdXFHMJsO+5PfTP3YJugHX/bNqbxH6zTltGSK4JheQozEY7Uk9dr
         V/T0RlwOT0nlzqo+uZVwhwME4aa8d3bFXnXiwjSpgsQml+FdE00DtkKTGyXk6mFpr8t7
         ov1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j14si472801qvj.157.2019.03.26.07.18.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 07:18:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A321185545;
	Tue, 26 Mar 2019 14:18:07 +0000 (UTC)
Received: from localhost (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2EC4B1001E81;
	Tue, 26 Mar 2019 14:18:05 +0000 (UTC)
Date: Tue, 26 Mar 2019 22:18:03 +0800
From: Baoquan He <bhe@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 2/4] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190326141803.GX3659@MiWiFi-R3L-srv>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-3-bhe@redhat.com>
 <20190326092936.GK28406@dhcp22.suse.cz>
 <20190326100817.GV3659@MiWiFi-R3L-srv>
 <20190326101710.GN28406@dhcp22.suse.cz>
 <20190326134522.GB21943@MiWiFi-R3L-srv>
 <20190326140348.GQ28406@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326140348.GQ28406@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 26 Mar 2019 14:18:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/26/19 at 03:03pm, Michal Hocko wrote:
> On Tue 26-03-19 21:45:22, Baoquan He wrote:
> > On 03/26/19 at 11:17am, Michal Hocko wrote:
> > > On Tue 26-03-19 18:08:17, Baoquan He wrote:
> > > > On 03/26/19 at 10:29am, Michal Hocko wrote:
> > > > > On Tue 26-03-19 17:02:25, Baoquan He wrote:
> > > > > > Reorder the allocation of usemap and memmap since usemap allocation
> > > > > > is much simpler and easier. Otherwise hard work is done to make
> > > > > > memmap ready, then have to rollback just because of usemap allocation
> > > > > > failure.
> > > > > 
> > > > > Is this really worth it? I can see that !VMEMMAP is doing memmap size
> > > > > allocation which would be 2MB aka costly allocation but we do not do
> > > > > __GFP_RETRY_MAYFAIL so the allocator backs off early.
> > > > 
> > > > In !VMEMMAP case, it truly does simple allocation directly. surely
> > > > usemap which size is 32 is smaller. So it doesn't matter that much who's
> > > > ahead or who's behind. However, this benefit a little in VMEMMAP case.
> > > 
> > > How does it help there? The failure should be even much less probable
> > > there because we simply fall back to a small 4kB pages and those
> > > essentially never fail.
> > 
> > OK, I am fine to drop it. Or only put the section existence checking
> > earlier to avoid unnecessary usemap/memmap allocation?
> 
> DO you have any data on how often that happens? Should basically never
> happening, right?

Oh, you think about it in this aspect. Yes, it rarely happens.
Always allocating firstly can increase efficiency. Then I will just drop
it.

