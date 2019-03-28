Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11E92C10F06
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 00:58:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBDA32183E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 00:58:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBDA32183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 520C36B0006; Thu, 28 Mar 2019 20:58:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A8066B0007; Thu, 28 Mar 2019 20:58:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34AC36B0008; Thu, 28 Mar 2019 20:58:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9D6F6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 20:58:17 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 33so418413pgv.17
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:58:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=YwfW5qsGb+26qVTPcuEgQMujY0o/mwA191y3U7RXhzk=;
        b=C6QOWakGH96rVS278Bs5tdxyjaPk35xm1uAwJ3qmnXfdwlK+E68yqqk7z7B7dWLHX+
         BqHb40Ffs2PKtFd2kmtqQnM9DCeznOQUcl85HiSYCzqEnWmK8zCao1XMqIQCfoB2Uc71
         JRYhGmbjLWj2NXghb4diDTHngKBSuqFLTsu6di2L5/RaSWIhxLF3l7iy+GnGEw8BOg+0
         rtT8IS1jyAg3nzOm53EL91KilKlxrEKLlkQ1BC8MikMDdIuUJ2ffYadgQjDUA0Ne3q4m
         9aKF2zl16ssit2taoOSmfrRMIQ/Uu55x584uIdJNrG1bYRWbWlqx88keoDV8MJJ45IxR
         vgvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV003f7PCSx0MLQr+Ue/TXHmEnjmdN3n5UXJYJdXOSwLrCD4ymv
	zZMmUrhxhjgOfDLCj9g0oBg5WYXTyH1d/qx5bUGakU/QHSzg3wPEd2F06vQ7M3iGpVUOEOESFX4
	ENQ6P2JnJGHQ65ehMnBnhxnFgk4gtXU30nfgDNrb0W9VhQJDpMQ36U4Nm4rnmXME4dg==
X-Received: by 2002:a65:664d:: with SMTP id z13mr42556157pgv.389.1553821097633;
        Thu, 28 Mar 2019 17:58:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzacuGC2ZHyW+jrLYPcS62s8TzmWRyvfmc8tpt/agPnhTssUX+ztEPsp4FZGMnNIB9JTkyl
X-Received: by 2002:a65:664d:: with SMTP id z13mr42556125pgv.389.1553821096916;
        Thu, 28 Mar 2019 17:58:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553821096; cv=none;
        d=google.com; s=arc-20160816;
        b=QNJkU4XIFK6TVji6j7bLe0+Fgp86jWxGOq8MfXu0I1JYwVLk3f7ioZscZSiKwvwccP
         ZYmnUs8JWnvw2h0VsvwLR5mz9qygii/eHPW/frIfiCZgpaCZ48eoefb8KBK4YJPeY5Hl
         PHVgTN4TM2p8FCxgC1C55hYzAX+7iOdWw9DsgPwXASZsnfGMwIoh4rpN0l8bTKNrc4YW
         h+ptMPCwoxVvFEczbDuS5zOz6Vu6I0lC1jZyW7Nuhrws9MLPxd+WtdZVpMARGeUMXv1e
         /yWTt4Sirhcc8FKKq/FqPWQOFKHDsMuopne7cAy8RvZANhLbuMvCispo5VqBVsdmAN5s
         CPvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=YwfW5qsGb+26qVTPcuEgQMujY0o/mwA191y3U7RXhzk=;
        b=ONeLdWi0zTJTI9Jhm8838bIRnD1yZdG9w5spCzOJKsodT013/K0tc+AnxA0vSX/BVT
         NVdzrSFNUFGJYHI6vBm8bo+A6gsQMOxFrppdUHWJsl5x+/j80aTzoqmIZgcvBljYabwx
         KDJsvNkW9uaids6k1oag6wiUVGMUEIG1/gwb49ktirm7p3/WTI6Rx8aeW20S4L2UCW09
         J9B35lqbIsL8gX521h4ZixgGYg0SPepfStFLOcbJDaAkL8ZouC39DwQGDTtPJNJ1QB6z
         OaHWOw2pgxRtJ2M9huT0w8IHM/7bLZmfoYxBgki/XA4v1Yp89r5dJoRH2XST01UrIuPm
         AARg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id n5si578050plp.260.2019.03.28.17.58.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 17:58:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 17:58:16 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,282,1549958400"; 
   d="scan'208";a="135750908"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 28 Mar 2019 17:58:16 -0700
Date: Thu, 28 Mar 2019 09:57:09 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
Message-ID: <20190328165708.GH31324@iweiny-DESK2.sc.intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-3-jglisse@redhat.com>
 <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
 <20190328191122.GA5740@redhat.com>
 <c8fd897f-b9d3-a77b-9898-78e20221ba44@nvidia.com>
 <20190328212145.GA13560@redhat.com>
 <fcb7be01-38c1-ed1f-70a0-d03dc9260473@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fcb7be01-38c1-ed1f-70a0-d03dc9260473@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 05:39:26PM -0700, John Hubbard wrote:
> On 3/28/19 2:21 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 01:43:13PM -0700, John Hubbard wrote:
> >> On 3/28/19 12:11 PM, Jerome Glisse wrote:
> >>> On Thu, Mar 28, 2019 at 04:07:20AM -0700, Ira Weiny wrote:
> >>>> On Mon, Mar 25, 2019 at 10:40:02AM -0400, Jerome Glisse wrote:
> >>>>> From: Jérôme Glisse <jglisse@redhat.com>
> [...]
> >>>>> @@ -67,14 +78,9 @@ struct hmm {
> >>>>>   */
> >>>>>  static struct hmm *hmm_register(struct mm_struct *mm)
> >>>>>  {
> >>>>> -	struct hmm *hmm = READ_ONCE(mm->hmm);
> >>>>> +	struct hmm *hmm = mm_get_hmm(mm);
> >>>>
> >>>> FWIW: having hmm_register == "hmm get" is a bit confusing...
> >>>
> >>> The thing is that you want only one hmm struct per process and thus
> >>> if there is already one and it is not being destroy then you want to
> >>> reuse it.
> >>>
> >>> Also this is all internal to HMM code and so it should not confuse
> >>> anyone.
> >>>
> >>
> >> Well, it has repeatedly come up, and I'd claim that it is quite 
> >> counter-intuitive. So if there is an easy way to make this internal 
> >> HMM code clearer or better named, I would really love that to happen.
> >>
> >> And we shouldn't ever dismiss feedback based on "this is just internal
> >> xxx subsystem code, no need for it to be as clear as other parts of the
> >> kernel", right?
> > 
> > Yes but i have not seen any better alternative that present code. If
> > there is please submit patch.
> > 
> 
> Ira, do you have any patch you're working on, or a more detailed suggestion there?
> If not, then I might (later, as it's not urgent) propose a small cleanup patch 
> I had in mind for the hmm_register code. But I don't want to duplicate effort 
> if you're already thinking about it.

No I don't have anything.

I was just really digging into these this time around and I was about to
comment on the lack of "get's" for some "puts" when I realized that
"hmm_register" _was_ the get...

:-(

Ira

> 
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA
> 
> 

