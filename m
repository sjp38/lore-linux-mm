Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC291C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:16:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE21A20717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:16:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE21A20717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B0516B0006; Thu, 25 Apr 2019 16:16:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 285166B0008; Thu, 25 Apr 2019 16:16:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 173C26B000A; Thu, 25 Apr 2019 16:16:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9B406B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:16:29 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z34so870994qtz.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:16:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=jExlb/d2nBdTGvZKiNUYJGxtMEQYL8J3MfpVu8CxHIU=;
        b=AdUl/d31ahdo+t/DaTgb8bwBGc6hW/+50iVkKX5z82ZLUQLd1LY/1oHFWA5yelFWR9
         dhNdjDukqKEWYqic00v4++trM76Oat0Fbkz9CT56+dATAuWFPvv4EEgPYa4NwjDy4Jvm
         lcpGaE3KtzbrreHFV0UQknMAAMsuKfQunAsAv+RCUGTsftT8JUeFGqEY4hUoxOYduhhy
         p5nuElqn2QiQjCKVF46zy7ZGoitY+5vC8FG2S+xmuIkMZebOr0sc1VAc3mYe2IKTYxbC
         dj25DDuyFvPkpXzTuc8SyiELnS5FqkF6qfd57yPfsg9CO8/Krt52e6fbOcbEOkER273H
         Pjig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUUMCx5emUibrAU0E3NOWTXndd64rhfdq7yy9cxzjSKsn536KEQ
	A37FR1NOxUTkXtXJm3qAFGlwl99IVDIlnZcg04ni4753n7oJAWF0RXXZk8VY6FIvBhAXAtEeI5l
	x+SszC97r1970a4GfIbAPPzpCiz27OCBdxxVgDizTJxQ0PDJDh93O7YWd56aXV14kIw==
X-Received: by 2002:a05:620a:1646:: with SMTP id c6mr15609843qko.69.1556223389735;
        Thu, 25 Apr 2019 13:16:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9bHgSgB0P+Omxq9YO+pyLdP1Pv4TjUhe7Jw4yEj4oBazG/P8saO9m0s8P7y4x8WvZNnlA
X-Received: by 2002:a05:620a:1646:: with SMTP id c6mr15609780qko.69.1556223388954;
        Thu, 25 Apr 2019 13:16:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556223388; cv=none;
        d=google.com; s=arc-20160816;
        b=xoKZuXVXsLkUtURyUCF7F3vQaGUOp+zna3/Vsx1EuUvY3QnftOJyj0gJlGwcibs3wk
         iIQert1W99MaK6iFt+7pbKEVRdaPrj1e8q+Zn9zsZIJrRkqiCscZpVX59FgghGf2/bwm
         6tE906HWKBpK0ctv1hG3efgbkrChVeDdzfFWEHZGKfHbIOe+N87IoB8KbE/6m1CVYHrb
         c0/ceOR8JahjLWLZfBZx3ch+3IOysVnt9P2iI0PBfF0liTjq3WZ4zIg/sJLQA5sI9c7i
         zyOaLHypKjtZM8e15/NcmL0+duppt7LuXw2qDYHuVyHOFVLnGVKehGNdbQoUspQbQ0jk
         wZtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=jExlb/d2nBdTGvZKiNUYJGxtMEQYL8J3MfpVu8CxHIU=;
        b=pGHGCD5dcN6iJqK6v/ur6rk1OvZ3XTldKyVYnVc8SMGv3GovweQNW7bepKkDN71y+T
         /cZYFg22DGuABZv//LHyzGo6TBmJgvmEWzPT23PgMCg8Ea+X3+h8iE/bs1V0ORqumFB4
         bLI6R2eKCC5/XBwr9dRcgrkyzoC/0M6bL2B9xXMbtr4MaWlegMOWGI+0cvL2JRkI1jUe
         lmRPwii80RdhG34RccIHyMCOWfgoh6UFxnsvFmz3Kpd4AY4fNo3SkU2i7E4e2Sf6YaRf
         AmhqKgAqoZovGW4oKgxvYXSEs+h/OxK95tHjFqmf1Jl2uXeju6nuTX5NfcNwRZKUm49e
         SMCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z11si7412473qka.196.2019.04.25.13.16.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 13:16:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7846C8E581;
	Thu, 25 Apr 2019 20:16:27 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CE9895D9CC;
	Thu, 25 Apr 2019 20:16:25 +0000 (UTC)
Date: Thu, 25 Apr 2019 16:16:24 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Keith Busch <keith.busch@intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michal Hocko <mhocko@kernel.org>,
	Paul Blinzer <Paul.Blinzer@amd.com>, linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] NUMA, memory hierarchy and device memory
Message-ID: <20190425201623.GB6391@redhat.com>
References: <20190118174512.GA3060@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190118174512.GA3060@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 25 Apr 2019 20:16:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


I see that the schedule is not full yet for the mm track and i would
really like to be able to have a discussion on this topic

Schedule:
https://docs.google.com/spreadsheets/d/1Z1pDL-XeUT1ZwMWrBL8T8q3vtSqZpLPgF3Bzu_jejfk/edit#gid=0


On Fri, Jan 18, 2019 at 12:45:13PM -0500, Jerome Glisse wrote:
> Hi, i would like to discuss about NUMA API and its short comings when
> it comes to memory hierarchy (from fast HBM, to slower persistent
> memory through regular memory) and also device memory (which can have
> its own hierarchy).
> 
> I have proposed a patch to add a new memory topology model to the
> kernel for application to be able to get that informations, it
> also included a set of new API to bind/migrate process range [1].
> Note that this model also support device memory.
> 
> So far device memory support is achieve through device specific ioctl
> and this forbid some scenario like device memory interleaving accross
> multiple devices for a range. It also make the whole userspace more
> complex as program have to mix and match multiple device specific API
> on top of NUMA API.
> 
> While memory hierarchy can be more or less expose through the existing
> NUMA API by creating node for non-regular memory [2], i do not see this
> as a satisfying solution. Moreover such scheme does not work for device
> memory that might not even be accessible by CPUs.
> 
> 
> Hence i would like to discuss few points:
>     - What proof people wants to see this as problem we need to solve ?
>     - How to build concensus to move forward on this ?
>     - What kind of syscall API people would like to see ?
> 
> People to discuss this topic:
>     Dan Williams <dan.j.williams@intel.com>
>     Dave Hansen <dave.hansen@intel.com>
>     Felix Kuehling <Felix.Kuehling@amd.com>
>     John Hubbard <jhubbard@nvidia.com>
>     Jonathan Cameron <jonathan.cameron@huawei.com>
>     Keith Busch <keith.busch@intel.com>
>     Mel Gorman <mgorman@techsingularity.net>
>     Michal Hocko <mhocko@kernel.org>
>     Paul Blinzer <Paul.Blinzer@amd.com>
> 
> Probably others, sorry if i miss anyone from previous discussions.
> 
> Cheers,
> Jérôme
> 
> [1] https://lkml.org/lkml/2018/12/3/1072
> [2] https://lkml.org/lkml/2018/12/10/1112
> 

