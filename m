Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D047C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:43:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F254220700
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:43:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F254220700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CE036B0007; Thu, 28 Mar 2019 21:43:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87D7E6B0008; Thu, 28 Mar 2019 21:43:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76D386B000C; Thu, 28 Mar 2019 21:43:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 500376B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 21:43:04 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 54so785536qtn.15
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:43:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=TQQ9aFdyPz+4zcFeiVMXlZAcCVNG0GK7y00ibkitZKU=;
        b=Oe1dnX5e9wapKuHytM5tMUOJFrVQpzqPMPIpYNCLKf9KX5BLZOtMCNUqBha37t8Lgt
         kU52ayduYlmDT4/fjMd48IYnmH6OwIJ+HFVKDaumTdXLFIgFQ6y8RgWG5Y4Q+02Ci7Tw
         ush5wQX3FZ9MJFSqlWrwI8GsDBRn9sY77GOfdZi5htQq5PEVtfoUU5hb9YhoKdoWHk2d
         D5FgO5DpLGJSGTCsO7usRbNmo62PeagOJjvmwmx4yS/RaKw2vQcW15CXrUHVFVzid2jA
         OoX3kNWlF7y4N5EIUvd4Nqq48tilFPqw9+lZKE6bdi9fYplYod/EHg/ynEXZucizYOcM
         Qlcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW1cF/QHZhujJY7PkTyLDP11gPR1/amaCQbL1frGjVT4B9HKA/P
	I3xc0zDfEfpOGfOkxsNV79cD56sowx2vKc3x2JJQ4D4I7xxQucpfZP8YN+2bGQQwYA+1yxxn1cJ
	M2OJEWuf9+DpIXkNNOIYgjqxlLQmyOERyXsfMg91XxTzSIJ6rknVXPWGGdJMwXvZS5w==
X-Received: by 2002:a0c:d7c2:: with SMTP id g2mr10644358qvj.90.1553823784078;
        Thu, 28 Mar 2019 18:43:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcBmczRkFeTBNXR0R+CT+N3V9i0IN9A2O06kL1ygKeqQNwoSHK/TPyyUepy8WJR+s0EDJs
X-Received: by 2002:a0c:d7c2:: with SMTP id g2mr10644345qvj.90.1553823783423;
        Thu, 28 Mar 2019 18:43:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553823783; cv=none;
        d=google.com; s=arc-20160816;
        b=GNyBBh5rbcNTrSAt2G8nmlW40lTaC8iIL3deBLZnDwFPKx0jGFBTfvoKeeXS2CGZAI
         IMebZeu5oXwsL3VgVrAmsw38PvHSz7l96lkNLBk1PW2D3vUNDky21VJRW18lE+fe8ogE
         CQU52OcskUQ5BcMh+NEMGpfTHtg6ZHFBnkuLBlGt1mSGQ+L9QhTqzCpk73RE4tehY8Dl
         QKHwmWWXcOgfngGOnoMg53IJKNtsCzcv/vmCdgP1JnTdwMQBNikht7ycRRo/72Jk7pbH
         VtYwPrI36uBfxXvhRZLjsTMDSkX3Zf7Dt251xpZ4ZdymfZZf2qKnlfIigYXLpqkJNuky
         tfJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=TQQ9aFdyPz+4zcFeiVMXlZAcCVNG0GK7y00ibkitZKU=;
        b=n29qMm+2qLF3sh1GYwwJPQ+3slb39CQbnzVZ5EcG8+/tm97LMym4jj1Sbm7/2ZYEmA
         7VK5abUEujo7e8kgKvMvwyEm3+AjJmXAQxjiFH43udCpeKySfivUCoFejIcr8xzTzQVX
         Eow79gBwZhD6yhmCLR3tjVqeeLT3WQnaKztg0DU6py9f04daiNgAgWjrhmoS4V6CCBVm
         IlYVEuapBArM59EqGqZe+GJSkf72Pv8VL0RSfDdGZ1zV0QOvTZN69IgN9tKrqDNqp6r2
         QstHFTVw6qBbnv99iGCQVzVPmD3/ISZlACMDNlS9PrUdOK94K2wbaa9m1CAopJP4gH+l
         /mBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z40si435780qtz.287.2019.03.28.18.43.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 18:43:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 735573082E1E;
	Fri, 29 Mar 2019 01:43:02 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 787981001E6E;
	Fri, 29 Mar 2019 01:43:01 +0000 (UTC)
Date: Thu, 28 Mar 2019 21:42:59 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
Message-ID: <20190329014259.GD16680@redhat.com>
References: <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
 <20190328221203.GF13560@redhat.com>
 <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
 <20190328223153.GG13560@redhat.com>
 <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
 <20190328232125.GJ13560@redhat.com>
 <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
 <20190328164231.GF31324@iweiny-DESK2.sc.intel.com>
 <20190329011727.GC16680@redhat.com>
 <f053e75e-25b5-d95a-bb3c-73411ba49e3e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f053e75e-25b5-d95a-bb3c-73411ba49e3e@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 29 Mar 2019 01:43:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 06:30:26PM -0700, John Hubbard wrote:
> On 3/28/19 6:17 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 09:42:31AM -0700, Ira Weiny wrote:
> >> On Thu, Mar 28, 2019 at 04:28:47PM -0700, John Hubbard wrote:
> >>> On 3/28/19 4:21 PM, Jerome Glisse wrote:
> >>>> On Thu, Mar 28, 2019 at 03:40:42PM -0700, John Hubbard wrote:
> >>>>> On 3/28/19 3:31 PM, Jerome Glisse wrote:
> >>>>>> On Thu, Mar 28, 2019 at 03:19:06PM -0700, John Hubbard wrote:
> >>>>>>> On 3/28/19 3:12 PM, Jerome Glisse wrote:
> >>>>>>>> On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
> >>>>>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> >>>>>>>>>> From: Jérôme Glisse <jglisse@redhat.com>
> >>> [...]
> >> Indeed I did not realize there is an hmm "pfn" until I saw this function:
> >>
> >> /*
> >>  * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
> >>  * @range: range use to encode HMM pfn value
> >>  * @pfn: pfn value for which to create the HMM pfn
> >>  * Returns: valid HMM pfn for the pfn
> >>  */
> >> static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
> >>                                         unsigned long pfn)
> >>
> >> So should this patch contain some sort of helper like this... maybe?
> >>
> >> I'm assuming the "hmm_pfn" being returned above is the device pfn being
> >> discussed here?
> >>
> >> I'm also thinking calling it pfn is confusing.  I'm not advocating a new type
> >> but calling the "device pfn's" "hmm_pfn" or "device_pfn" seems like it would
> >> have shortened the discussion here.
> >>
> > 
> > That helper is also use today by nouveau so changing that name is not that
> > easy it does require the multi-release dance. So i am not sure how much
> > value there is in a name change.
> > 
> 
> Once the dust settles, I would expect that a name change for this could go
> via Andrew's tree, right? It seems incredible to claim that we've built something
> that effectively does not allow any minor changes!
> 
> I do think it's worth some *minor* trouble to improve the name, assuming that we
> can do it in a simple patch, rather than some huge maintainer-level effort.

Change to nouveau have to go through nouveau tree so changing name means:
 -  release N add function with new name, maybe make the old function just
    a wrapper to the new function
 -  release N+1 update user to use the new name
 -  release N+2 remove the old name

So it is do-able but it is painful so i rather do that one latter that now
as i am sure people will then complain again about some little thing and it
will post pone this whole patchset on that new bit. To avoid post-poning
RDMA and bunch of other patchset that build on top of that i rather get
this patchset in and then do more changes in the next cycle.

This is just a capacity thing.

Cheers,
Jérôme

