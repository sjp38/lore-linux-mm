Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3CCAC28CBF
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:04:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CAF12075B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:04:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CAF12075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04F846B000C; Mon, 27 May 2019 03:04:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F41356B0266; Mon, 27 May 2019 03:04:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E30566B026B; Mon, 27 May 2019 03:04:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 958CB6B000C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 03:04:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c1so26605591edi.20
        for <linux-mm@kvack.org>; Mon, 27 May 2019 00:04:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=k/tkMiIayZFbP7u88jZyibBDIoRVeWVcY7hj5qmCMM4=;
        b=HLqvd6OkRAIJ2YHwSXYwzeoC4OHhXfkJc1zAjm9lUc7VDg8ivv/V2yv8du12rNnXO/
         EEtNM8shVXvG1u/nnTo1Fu16A09O17gpeU+prPIo2pS600AjSrAIiD3Ho2tPis7CjthX
         SZU3pVC3dihKrWufXoEwZtDA3EHTL3FeKPkr6HUv/JdGxWkwljb+stAI95Cb15UNSCNi
         HsUXl44X0fusvYct75RjLy016gyyqfG7vGDXRuXWCLnBcVwRyAPARiAB9+Cx1Z6A2cuw
         zIQdgHE73Yb/bfGB4WP/r1IC4oZZcjrH7EBJ3Cq0QF69JBbBfPXKxkBAbK28qSb3tUCv
         3g5Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWlmpfvmfqom8CRULe1WGlNnw0FgQ8WmYc6/6fG6knCy3BKdTjp
	31v1M/R6CRUI5wc5Nj3liIBHt3ISJixHO7jSAODR3kmbZdHF1jpr1gQjCPJ6h+ZBnoeUwNBzSWv
	xxq4lIQVQhf8qYv6f1tyFFR/cuECGx+yJZxwKut3CGXAJjbnB6LfYhT6q6oJkEck=
X-Received: by 2002:a50:b665:: with SMTP id c34mr120316295ede.148.1558940659163;
        Mon, 27 May 2019 00:04:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWgbY673Lpax7JI1uauyBY4PVTNagM7LFsox740arVmG3iFHD3jgaM8Q7cEuc+1JBbUhyo
X-Received: by 2002:a50:b665:: with SMTP id c34mr120316218ede.148.1558940658331;
        Mon, 27 May 2019 00:04:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558940658; cv=none;
        d=google.com; s=arc-20160816;
        b=FxU3H5xz3cF3TG3rQe+XLGh6xm1EXhxPFynD4igfuXp0KByaEVJtn+17J+/w06LdP+
         cwTm6wrxNbc4WG9gQKEMvGzw0Fs5xXl4cD4W5+rojuEIYi2haGcNpkABDRBxubIzjFjy
         Firla8a9CXd7WtvFRGayfJH0Z7XAV6/rhJfpsJO5v7nmCTuCRgszoegLudWfdDhWwfzo
         qeue+y66NHTy5YSvm5AgOxcoITRGNqgPjYOSP/cftk4pqanm9UdRNmCTeNx01hSF1820
         1ZbdDQmkWcNzvPOcca0lEIAZot68A/T2Od7HtxNKrkBHZtZH8Jdi0y/Ex7SLjMI2DAjm
         pkGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=k/tkMiIayZFbP7u88jZyibBDIoRVeWVcY7hj5qmCMM4=;
        b=0d8VFuPR9r46C5KXTu5W5GBrqlydtv+jmyyv4mHGNiyin9WbJ59z5lAGBGSKFsHcaC
         eWs1ZqWymBUwKIaxNMkuVfg7z0tPbmGXgldBhIDmvB/nRY2d0yq9NFSZ5Ej7vqVrfIMw
         HwfhljGaw25Mym101v+1OFPAYpGZmvzVOQwpZboE4ktaqeMXJMp2nY6Dtsd+qmBFRzzw
         beQWiG9nK2y9Am04U6Px2fjEEVjTXFnvMpej5Mb55Za49/FAOoCafPVHIGwMWdVas0C/
         uB1kASvoeKj3sKCJ1Zv4e5ekDscIpvd2987K35rEK/+BtEMuogdToPnIp/Dg3hUorZoL
         R+9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b28si2441065edn.15.2019.05.27.00.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 00:04:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9EFD7AD9C;
	Mon, 27 May 2019 07:04:17 +0000 (UTC)
Date: Mon, 27 May 2019 09:04:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: "Potyra, Stefan" <Stefan.Potyra@elektrobit.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Jordan, Tobias" <Tobias.Jordan@elektrobit.com>,
	akpm@linux-foundation.org, vbabka@suse.cz,
	kirill.shutemov@linux.intel.com, linux-api@vger.kernel.org
Subject: Re: [PATCH] mm: mlockall error for flag MCL_ONFAULT
Message-ID: <20190527070415.GA1658@dhcp22.suse.cz>
References: <20190522112329.GA25483@er01809n.ebgroup.elektrobit.com>
 <20190524214304.enntpu4tvzpyxzfe@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190524214304.enntpu4tvzpyxzfe@ca-dmjordan1.us.oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 24-05-19 17:43:04, Daniel Jordan wrote:
> [ Adding linux-api and some of the people who were involved in the
> MCL_ONFAULT/mlock2/etc discussions.  Author of the Fixes patch appears to
> have moved on. ]
> 
> On Wed, May 22, 2019 at 11:23:37AM +0000, Potyra, Stefan wrote:
> > If mlockall() is called with only MCL_ONFAULT as flag,
> > it removes any previously applied lockings and does
> > nothing else.
> 
> The change looks reasonable.  Hard to imagine any application relies on it, and
> they really shouldn't be if they are.  Debian codesearch turned up only a few
> cases where stress-ng was doing this for unknown reasons[1] and this change
> isn't gonna break those.  In this case I think changing the syscall's behavior
> is justified.  
> 
> > This behavior is counter-intuitive and doesn't match the
> > Linux man page.
> 
> I'd quote it for the changelog:
> 
>   For mlockall():
> 
>   EINVAL Unknown  flags were specified or MCL_ONFAULT was specified with‐
>          out either MCL_FUTURE or MCL_CURRENT.
> 
> With that you can add
> 
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> 
> [1] https://sources.debian.org/src/stress-ng/0.09.50-1/stress-mlock.c/?hl=203#L203

Well spotted and the fix looks reasonable as well. Quoting the man page
seems useful as well.

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

