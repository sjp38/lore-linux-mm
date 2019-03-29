Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBC82C10F06
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:59:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0EC621850
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:59:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0EC621850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CB2A6B000C; Thu, 28 Mar 2019 21:59:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 452756B000D; Thu, 28 Mar 2019 21:59:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F3896B000E; Thu, 28 Mar 2019 21:59:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A58C6B000C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 21:59:27 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id v18so848281qtk.5
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:59:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=2ibVBNyq9tMEYR/A3OPT67wSuY8m9obp+u6fsaryfi4=;
        b=dJgZ64P/ZAXP/ceDipkDCmeR4/SxgKPc5wnEHumqdonHDQYnmK0MDnsTFpiFXVaKUN
         x8pasfFLlv/Ll8KuKDnrEzLZTJtsU7cZodAsx+gcaP8NoltbfuRh9jjHVQ8IHuZL9vNS
         TpPpSoxMffTutOY1s9N3QFfj0Pr+61OWpB2tsO0WU0pAmxSNVnqnf99U2YrjcZNCIRy+
         YQK9So+61nWurgbc28LKiDZO/01tBRQRMajMvmRXLgb9VYUMIPiHK8iWpJ988C4hBEQA
         31AQSMlQu2XnrrUQJl46Ixc6y/rLd1sAjCJ2HlaAZNkY+Tdi1ftDsZsjX0Sxa9wekx4n
         +41A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV46ibkNQnTSRzTQTFAF4QUqDW8hjHxpexcl5UiYI1hqA/ds03P
	0QkQHraYxGe7lJBs6sg7q9pPum1sM+N0/HO5A2v8Rx07fzL/P6T4GGFtrs6p6to8FKFMxBwddvP
	s0c5xYWZRVKHL7jXuGYMFjjwi1TvkQIJGYT4dPco2IzdRtgJAU/ShmCSQ+7ojjhVJhg==
X-Received: by 2002:a0c:a8e7:: with SMTP id h39mr20461133qvc.34.1553824766802;
        Thu, 28 Mar 2019 18:59:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyK+pikUCu2PuAhTH9LLSzzams50LIB995NbT0ldL4rg1xO9P54Dg02DY4Q04rbuWVgoyM1
X-Received: by 2002:a0c:a8e7:: with SMTP id h39mr20461103qvc.34.1553824766083;
        Thu, 28 Mar 2019 18:59:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553824766; cv=none;
        d=google.com; s=arc-20160816;
        b=SbjrhnGCJ0EzicQvP7ih3OB6h51d204OfUDPhTJgBXmkdTET4fHMBkvezhveM7lZaM
         AEZ2qeXDFN2h2Hn2H6U6A6r6NepKf9u4O3VCQW9wEAvTVrkRFs4FhGSOpBVczhg0xW3x
         c89917G1LkaOi/iUjSUGWaoVFakzaTr+e20U++xs1pS5z3X5CH55FSY52lAp0nAMeMO+
         TBkOeci5nDJTcm4yP8CdK6EWh2+8aYxC59mViYvGkpUPAiTJS4UyEkDxFadz6byulN70
         fFsP3afgfCZHTmW7YiUJdxqW8Iyarp8AKsh8fwkQ44rAjQ15Jj5Jg5E8psok5U9KqDzc
         KTwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=2ibVBNyq9tMEYR/A3OPT67wSuY8m9obp+u6fsaryfi4=;
        b=eX2zI6sActlh8Pxg6cNAxKo9de3i2uUB0f9e4JXIJ/mnrwMT5fgHwyEFHdKsfXy0A0
         2CW6pi49uouDZCbRwp/ghWr8ML0kHMgyeNPbWQVSlq45uJrGkjPpcV8kvaX7AFIedqRP
         g01POUmTMvkfLwOCFsBxdSXT0VN2fEvaoSYtnDWxhe/G540ZMU954FXfQexvY7Y//laU
         Cisuvzz9iM7Gp3K+a5L8z2fB/pSALc95hZyK4vCebMWdhGSzARf0Uf8RheLjt0GIqGVf
         n9+Rp9ps9Lp7CvhcPPDdDeRlVnKaF5UKDlAe6hvxPSHT89FMRW+U793AIccJvdPC82W4
         T//A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v25si456612qtc.297.2019.03.28.18.59.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 18:59:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4A6BA3086205;
	Fri, 29 Mar 2019 01:59:25 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DC41C8958A;
	Fri, 29 Mar 2019 01:59:23 +0000 (UTC)
Date: Thu, 28 Mar 2019 21:59:19 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
Message-ID: <20190329015919.GF16680@redhat.com>
References: <20190328221203.GF13560@redhat.com>
 <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
 <20190328223153.GG13560@redhat.com>
 <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
 <20190328232125.GJ13560@redhat.com>
 <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
 <20190328164231.GF31324@iweiny-DESK2.sc.intel.com>
 <20190329011727.GC16680@redhat.com>
 <f053e75e-25b5-d95a-bb3c-73411ba49e3e@nvidia.com>
 <20190329014259.GD16680@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190329014259.GD16680@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 29 Mar 2019 01:59:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 09:42:59PM -0400, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 06:30:26PM -0700, John Hubbard wrote:
> > On 3/28/19 6:17 PM, Jerome Glisse wrote:
> > > On Thu, Mar 28, 2019 at 09:42:31AM -0700, Ira Weiny wrote:
> > >> On Thu, Mar 28, 2019 at 04:28:47PM -0700, John Hubbard wrote:
> > >>> On 3/28/19 4:21 PM, Jerome Glisse wrote:
> > >>>> On Thu, Mar 28, 2019 at 03:40:42PM -0700, John Hubbard wrote:
> > >>>>> On 3/28/19 3:31 PM, Jerome Glisse wrote:
> > >>>>>> On Thu, Mar 28, 2019 at 03:19:06PM -0700, John Hubbard wrote:
> > >>>>>>> On 3/28/19 3:12 PM, Jerome Glisse wrote:
> > >>>>>>>> On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
> > >>>>>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> > >>>>>>>>>> From: Jérôme Glisse <jglisse@redhat.com>
> > >>> [...]
> > >> Indeed I did not realize there is an hmm "pfn" until I saw this function:
> > >>
> > >> /*
> > >>  * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
> > >>  * @range: range use to encode HMM pfn value
> > >>  * @pfn: pfn value for which to create the HMM pfn
> > >>  * Returns: valid HMM pfn for the pfn
> > >>  */
> > >> static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
> > >>                                         unsigned long pfn)
> > >>
> > >> So should this patch contain some sort of helper like this... maybe?
> > >>
> > >> I'm assuming the "hmm_pfn" being returned above is the device pfn being
> > >> discussed here?
> > >>
> > >> I'm also thinking calling it pfn is confusing.  I'm not advocating a new type
> > >> but calling the "device pfn's" "hmm_pfn" or "device_pfn" seems like it would
> > >> have shortened the discussion here.
> > >>
> > > 
> > > That helper is also use today by nouveau so changing that name is not that
> > > easy it does require the multi-release dance. So i am not sure how much
> > > value there is in a name change.
> > > 
> > 
> > Once the dust settles, I would expect that a name change for this could go
> > via Andrew's tree, right? It seems incredible to claim that we've built something
> > that effectively does not allow any minor changes!
> > 
> > I do think it's worth some *minor* trouble to improve the name, assuming that we
> > can do it in a simple patch, rather than some huge maintainer-level effort.
> 
> Change to nouveau have to go through nouveau tree so changing name means:
>  -  release N add function with new name, maybe make the old function just
>     a wrapper to the new function
>  -  release N+1 update user to use the new name
>  -  release N+2 remove the old name
> 
> So it is do-able but it is painful so i rather do that one latter that now
> as i am sure people will then complain again about some little thing and it
> will post pone this whole patchset on that new bit. To avoid post-poning
> RDMA and bunch of other patchset that build on top of that i rather get
> this patchset in and then do more changes in the next cycle.
> 
> This is just a capacity thing.

Also for clarity changes to API i am doing in this patchset is to make
the ODP convertion easier and thus they bring a real hard value. Renaming
those function is esthetic, i am not saying it is useless, i am saying it
does not have the same value as those other changes and i would rather not
miss another merge window just for esthetic changes.

Cheers,
Jérôme

