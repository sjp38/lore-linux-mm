Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20484C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:45:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D94D121850
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:45:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D94D121850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A12886B0005; Fri, 19 Jul 2019 02:45:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C3976B0006; Fri, 19 Jul 2019 02:45:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B2F08E0001; Fri, 19 Jul 2019 02:45:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38B666B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 02:45:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so21392536ede.23
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 23:45:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EIPSwslmeVrrTs9BNCWWQRRzh7YmDEt3r9YIjkvtTPk=;
        b=o9iRbbZCJe9sD2oCJBvq4fEH1TbhWYUNYXwkYwJ5XyMLCl49k9RR5X113TmG+IoKpx
         TcP8NYsIqyvsRMRqARY3IZal6BX8zQwTPagO8Kqj1x8TZdRx4oBWdcQ/FvveEjD5AZrI
         k4XYR+RoT8RXlOZ/SaKDD0edzkzS/6r5nMfdnpYZwI9yS+UWLlK5xAcWU/MiOEEvbZcl
         RDJTbXEB3blgiFmnzfXtZnJqepCc6YO//Cw7Bs5VMWpGv3/WvSS/5xuvqpR6x3uO6udw
         cGRqqygZfDoALNva4Lerq1U6xt9cE4MYaFPBpgSYKrigqauKjVi7obBAZD4VYbwxkoI8
         LghA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWDIt+JzmmyspCVf6U0tumBE5+Oakop0m9DMxxOhUWOY5+s8blH
	S3d/GcSvUt1/BadLa/x1z5gqzFs8oN5B3kmdfmdINbxYg2eeDnp82obEIpLeK32E7epozqqmGW1
	AyhpuoC1n2jOxeOTEozn4+ZtwCgmC36bSZJZFv2LvGeeCjcnGqaegWvS8OiYOUEY=
X-Received: by 2002:a50:a3ec:: with SMTP id t41mr44634522edb.43.1563518712802;
        Thu, 18 Jul 2019 23:45:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1YC1Jn9IA8q6+qOfRBxFOKVbUcWD8WY8C/XOUeDPVUFAm5qryuEBKQUPd9oJRVzH3fW29
X-Received: by 2002:a50:a3ec:: with SMTP id t41mr44634479edb.43.1563518712024;
        Thu, 18 Jul 2019 23:45:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563518712; cv=none;
        d=google.com; s=arc-20160816;
        b=SwDMQf1tkK2NUADJvIIR7u5HuTZ2d00ojQM++JA4Sdk+BclOZk2HG9kNHBx/WdEfAF
         lsG5zBvRAXkf0PuMBgbYRMhFEILD2M/5dse7mtTyijiMwaNp8p8SPZ+LjWQz/7t0SuuJ
         NLg9wMByt3ysor/xAE+yw+WXf2aTPsaOnYYBtbKtDRooJflsnTcFNikcwERk503SUL3o
         +BfNZInSh3vA3/WXNFDDlB8TggaG8tw4rgxC/bvPgfQ5ZVcKXpq2RB1a64SQJhvC3q79
         FZWYaa/WxC95w6OTiwZEA3NAKs/hsYGROZKPKB7NFz/EJDIZsiXNzAXTbgQHbv3ghIdX
         mypA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EIPSwslmeVrrTs9BNCWWQRRzh7YmDEt3r9YIjkvtTPk=;
        b=f2jiUyCVc8iginbcljhrQoPfJT6lt1l2UTdZSZ/VamXMaScSK3sIejX1Mp9m1C30se
         K5dAGGrpFnlBt6p2axSMEJsEFZZ7jcZhEaAR+8okX60ux+BrsYa5xe/SyW6j0DNuC6VW
         ETHH/D1Hg7HXlXCVEIRON/LVsLnqZDTdBNNZryigP3YrXtdAz8sPlh7JlnXfPXClPjfJ
         5/ajSAJ1Kenpq23t//LTRqHJM82WAIIbkyrqZfza0aRpZspAcllYnBZUcCXCwz2Fhuxn
         aEH4gkHlr5/HlYxgDYBB0p98xr/j+yUJ77Sijjw7JuWt9+wWGeZWH9jpXz01pbFFxDCc
         RTeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nq5si531910ejb.124.2019.07.18.23.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 23:45:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6BDADAC8F;
	Fri, 19 Jul 2019 06:45:11 +0000 (UTC)
Date: Fri, 19 Jul 2019 08:45:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.com>
Subject: Re: [PATCH v3 02/11] s390x/mm: Fail when an altmap is used for
 arch_add_memory()
Message-ID: <20190719064510.GL30461@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-3-david@redhat.com>
 <20190701074306.GC6376@dhcp22.suse.cz>
 <20190701124628.GT6376@dhcp22.suse.cz>
 <86f3ff3d-d035-a806-88b7-b8c7b77c206e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86f3ff3d-d035-a806-88b7-b8c7b77c206e@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 15-07-19 12:51:27, David Hildenbrand wrote:
> On 01.07.19 14:46, Michal Hocko wrote:
> > On Mon 01-07-19 09:43:06, Michal Hocko wrote:
> >> On Mon 27-05-19 13:11:43, David Hildenbrand wrote:
> >>> ZONE_DEVICE is not yet supported, fail if an altmap is passed, so we
> >>> don't forget arch_add_memory()/arch_remove_memory() when unlocking
> >>> support.
> >>
> >> Why do we need this? Sure ZONE_DEVICE is not supported for s390 and so
> >> might be the case for other arches which support hotplug. I do not see
> >> much point in adding warning to each of them.
> > 
> > I would drop this one. If there is a strong reason to have something
> > like that it should come with a better explanation and it can be done on
> > top.
> > 
> 
> This was requested by Dan and I agree it is the right thing to do.

This is probably a matter of taste. I would argue that altmap doesn't
really equal ZONE_DEVICE. This is more a mechanism to use an alternative
memmap allocator. Sure ZONE_DEVICE is the only in tree user of the
feature but I really do not see why the arh specific code should care
about it. The lack of altmap allocator is handled in the sparse code so
this is just adding an early check which might confuse people in future.

> In
> the context of paravirtualized devices (e.g., virtio-pmem), it makes
> sense to block functionality an arch does not support.

Then block it on the config dependences.

-- 
Michal Hocko
SUSE Labs

