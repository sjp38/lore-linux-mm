Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0B7BC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:19:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BBFC2175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:19:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BBFC2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E0E06B0006; Tue, 19 Mar 2019 18:19:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3900B6B0007; Tue, 19 Mar 2019 18:19:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27F0E6B0008; Tue, 19 Mar 2019 18:19:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC1746B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:19:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h15so490565pgi.19
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:19:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fJ0pU0f9AVQ0H8sNaBZAp743fXL+ORLTK1qP0uA9ue0=;
        b=kQTfRns7zYbvgVHybJVD+wUaEGFLH4MKWqkNbEniBhIAp/d+ol7RuSM/hEPI1NBrFp
         8cc6lV17p3H6QN/AZj8M+cXALSONoaUMGB0Oy4+eKslQW3dIENhD9o6wmVmb+YnI4hLy
         VXnZDLkb0LZ95j+esaWQZwdv9eFXHixFkdzZr8HlYmlWQY+tGxj1tfVSJDa8dcTLXVJa
         XRZX42Pm428U9Z4DGnmOiAJflz78tJ8UnHufBMRS8enc9smmTc5eHXw5Sn5qKhNNbuRl
         1JE92pqWj5bvInZPsk0aSWXWVxie8m7ieYdwFcIShSHXzj211G/u++8miZmwiaSQ4Wp8
         iOtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV1S38MaxpNHhuOZfKeZ1K+odR8xsxlbmANaNmfxuNwK+0mTK7X
	VTcRUVcLU6Q+5Puw4c/x5A5n9R3AcSFaz/A2n/ns27T+he6M15VL/q97n6oHrddu+JjTUtxDK0f
	V74OrM7NEqFQtO+vT771/vtUuxEp8nSzob5czXYM+HoSPA0RmR1T924nES8WKY324tA==
X-Received: by 2002:a63:1cd:: with SMTP id 196mr4032495pgb.58.1553033988569;
        Tue, 19 Mar 2019 15:19:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwk/5QHl/Qwd+bNCce2nxvG1feL6GASipZq76MLRMsxkZkrBWdbY8BbE9kb2Ar2VvLYVZfk
X-Received: by 2002:a63:1cd:: with SMTP id 196mr4032438pgb.58.1553033987532;
        Tue, 19 Mar 2019 15:19:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553033987; cv=none;
        d=google.com; s=arc-20160816;
        b=UQuskviyjPTmiZiAhsjXpUD8yKEg3faV/ImE2ZwmiYstTNgDw7VoNodiHrm/haWd7S
         y5jyPaZxpCHivesQ+Ogzbxt5fYu4ru4YDEpsL7Mb5U7gVJD3UJ9mqeSmiIuC/dDAGJTI
         Hd1QkpLzpqQICrjk0yYsOZ2LjeVqhNJRprhtjkYmyt9urMCq0gSJyirjWUpcs9XhtpK9
         akYk0rhxXKFnXjJ0PtdPCB2xo6H11O1ZNrLRDI0KuxFEyOHwAWOz4e+MwjxCF/Iig9FT
         FcoHtM7KAO4ZwQiNqsSrlB5FA+5KGX+NrBzqWVR8Ks7YWAZAcpLcAiVmVRHDOBZc0dv5
         j75g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fJ0pU0f9AVQ0H8sNaBZAp743fXL+ORLTK1qP0uA9ue0=;
        b=XU6u45sT5PBczFFAAYUV/OWkn6nVPsqKuJNr8/c2lIOQAYKt5/L6ak2GCEHoQ36VdB
         gy+oHza8WpEVDiGse1BGd7k2DcywaWA7yOVAOND7ls5KZtqVW06Q2+hcYfhBk71+lxeK
         qTj/W4j4Cz3XlQY2DO8EApeO0jC79CGJpa+mkjCucv3IB/VFiyE+Fgt8V2Cz6wSqDoA+
         McylXFuBTRXb+qhtHzkbK1i03XR3FFff8uoIfguFL3FPBYUvqi6F1zM+FFhZZPuMJclN
         rXp9JqV8jqC0q4lC8RFqnJwQIoLaJtmsKKVfY5pdjPEDwuEfSLTzeAq2cMJjvLwVG1OY
         SDTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id h35si200582plb.180.2019.03.19.15.19.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 15:19:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Mar 2019 15:19:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,246,1549958400"; 
   d="scan'208";a="308616822"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga005.jf.intel.com with ESMTP; 19 Mar 2019 15:19:46 -0700
Date: Tue, 19 Mar 2019 07:18:26 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Alex Deucher <alexander.deucher@amd.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190319141826.GJ7485@iweiny-DESK2.sc.intel.com>
References: <20190318170404.GA6786@redhat.com>
 <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
 <20190319165802.GA3656@redhat.com>
 <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
 <20190319171847.GC3656@redhat.com>
 <CAPcyv4iesGET_PV-QcdBbxJGgmJ_HhoGczyvb=0+SnLkFDhRuQ@mail.gmail.com>
 <20190319174552.GA3769@redhat.com>
 <CAPcyv4hFPOO0-=v3ZCNFA=LgE_QCvyFXGqF24Crveoj_NTbq0Q@mail.gmail.com>
 <20190319190528.GA4012@redhat.com>
 <CAPcyv4hg5Y_NC1iu56zcznYkCRnwg+_7bGFr==7=AC6ii=O=Ng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hg5Y_NC1iu56zcznYkCRnwg+_7bGFr==7=AC6ii=O=Ng@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 12:13:40PM -0700, Dan Williams wrote:
> On Tue, Mar 19, 2019 at 12:05 PM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Mar 19, 2019 at 11:42:00AM -0700, Dan Williams wrote:
> > > On Tue, Mar 19, 2019 at 10:45 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > >
> > > > On Tue, Mar 19, 2019 at 10:33:57AM -0700, Dan Williams wrote:
> > > > > On Tue, Mar 19, 2019 at 10:19 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > > >
> > > > > > On Tue, Mar 19, 2019 at 10:12:49AM -0700, Andrew Morton wrote:
> > > > > > > On Tue, 19 Mar 2019 12:58:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:

[snip]

> >
> > Right now i am trying to unify driver for device that have can support
> > the mmu notifier approach through HMM. Unify to a superset of driver
> > that can not abide by mmu notifier is on my todo list like i said but
> > it comes after. I do not want to make the big jump in just one go. So
> > i doing thing under HMM and thus in HMM namespace, but once i tackle
> > the larger set i will move to generic namespace what make sense.
> >
> > This exact approach did happen several time already in the kernel. In
> > the GPU sub-system we did it several time. First do something for couple
> > devices that are very similar then grow to a bigger set of devices and
> > generalise along the way.
> >
> > So i do not see what is the problem of me repeating that same pattern
> > here again. Do something for a smaller set before tackling it on for
> > a bigger set.
> 
> All of that is fine, but when I asked about the ultimate trajectory
> that replaces hmm_range_dma_map() with an updated / HMM-aware GUP
> implementation, the response was that hmm_range_dma_map() is here to
> stay. The issue is not with forking off a small side effort, it's the
> plan to absorb that capability into a common implementation across
> non-HMM drivers where possible.

Just to get on the record in this thread.

+1

I think having an interface which handles the MMU notifier stuff for drivers is
awesome but we need to agree that the trajectory is to help more drivers if
possible.

Ira

