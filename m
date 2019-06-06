Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 052EEC28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 16:09:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C860320868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 16:09:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C860320868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CE766B027A; Thu,  6 Jun 2019 12:09:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5571B6B027C; Thu,  6 Jun 2019 12:09:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F82A6B027D; Thu,  6 Jun 2019 12:09:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03A2D6B027A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 12:09:36 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w14so1788601plp.4
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 09:09:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aS6SgQCUgpAlfekzcs0j12/zQ4C4gYrQgtAeq/L/cEE=;
        b=untqTlzak1ODMdvtFC5WukgszskhXb3+Id+BXiWCE8RD9UNedp7u966u7ZJ0N5RmRV
         DqE1IRFLYsjOI6zcSmobq6FrTb1eEioUkDsYIfABFNBgkDScyC3k6bNLpjo4oMaqLhOI
         lRzi5M5Nrnxj/N/QxFoodSbW98O/I4cKTydrHr+LYHqJZsNWjub02WRrDXuuOeFTzqSf
         m7Pp3efjSg965YfDSFoEeetyVucLOwO045tZ9zzoJ5FkJiNG5Hz2C4acoF8oi7eQAAsQ
         gzAqZ7bdTAWUGEjsjx+srpn1rilw/XJ/r91YsJCoOhkX8Nt0qdyySX0VuuHl0TH5MwMY
         nhzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUZ1OQM7IMjjx0pc4u+3fmhykia2ulFCLkJf75TPEXIG4jHO9gT
	SO5FEC8PxCvk8wBZaLDX6VkE9qnauUtfN8gRuoJdoBvhmciNgJbnxNsa3ls4xYnVSlw3tPotm8m
	Zaka3cDCDt9Hkivro6ZLt7t/iZT2Ssy2LToR9Nfja2rn/EnPafpebysrVLylxNVQ7Yw==
X-Received: by 2002:aa7:8145:: with SMTP id d5mr54788260pfn.11.1559837375658;
        Thu, 06 Jun 2019 09:09:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwm/0ef6h6sYEMM8iQBsRpuUANobQPVIxDyat3PFeW+MJtVErkV2p9Q1jV/tLmuPlr7r8Y9
X-Received: by 2002:aa7:8145:: with SMTP id d5mr54788207pfn.11.1559837374912;
        Thu, 06 Jun 2019 09:09:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559837374; cv=none;
        d=google.com; s=arc-20160816;
        b=z2Z1wTIywvbBEAuHl/8JY8pUv4gbssISntU+GMiThBvIr0nokd3Cg15NtTke586sl5
         YkTb9PBrgt1jo7v2Rly4/iwbWqyTb4YpCBPzslzhk2QJZ19VIeeYyKJhfj+X+K/UcdHP
         hRHQQh2Ut5P44Vz5JAyIQ9zh7VADJKq9x8+ttQoy8JjzjDY4HSCG3S8+IiqBL78QSDcQ
         HGUU36ag/DFIhtZRu6Rfy6OY8mEdN/vgS2YJcfeNzLbDuE3fkhtmx9t4x5uubzfOrG74
         zVKW2lJ7goRb2PjTQ+wVC1OkUx5hpn445/WfPLDfS4qj/yKDElAtopBvcMlo/oXJ45E8
         NTPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aS6SgQCUgpAlfekzcs0j12/zQ4C4gYrQgtAeq/L/cEE=;
        b=ER2W1c3FHWNB/o5LDplB2j2Iu/4fmrhfxKI8tWkABHJkhV0KlJqiRDUpWSccsYzPHV
         IIC33qYQymCXc1UbtXa35JjjsbE+Usoil6G+PWtnd53FN2nlAj9gCCZ/h6oyoRKEjIfP
         +eMb2SDwhTd7ddGccJ+nxAEnAJCsCDe9LfN4o81dv1xPyHg6ZrMTXx/9HGL3sh5O0KHa
         VaeTix1c4is7MPGhZCd0NurrlMbZUx0FFNYL7LK99DBg+JohceBvFZq5lvbZq71y6opl
         bI3eDdCYmhzpZduOEJTsw5HWDIh3F1O1hcfOqAL9Oa6hCE19XtFdhPkd3PSDr8urX0Ys
         GVww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id g1si2166980pfi.249.2019.06.06.09.09.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 09:09:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 09:09:34 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,559,1557212400"; 
   d="scan'208";a="182358981"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga002.fm.intel.com with ESMTP; 06 Jun 2019 09:09:34 -0700
Date: Thu, 6 Jun 2019 09:10:46 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 03/10] mm/gup: Pass flags down to __gup_device_huge*
 calls
Message-ID: <20190606161045.GA11331@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606014544.8339-4-ira.weiny@intel.com>
 <20190606061819.GA20520@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606061819.GA20520@infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 11:18:19PM -0700, Christoph Hellwig wrote:
> On Wed, Jun 05, 2019 at 06:45:36PM -0700, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > In order to support checking for a layout lease on a FS DAX inode these
> > calls need to know if FOLL_LONGTERM was specified.
> > 
> > Prepare for this with this patch.
> 
> The GUP fast argument passing is a mess.  That is why I've come up
> with this as part of the (not ready) get_user_pages_fast_bvec
> implementation:
> 
> http://git.infradead.org/users/hch/misc.git/commitdiff/c3d019802dbde5a4cc4160e7ec8ccba479b19f97

Agreed that looks better.

And I'm sure I will have to re-roll this to deal with conflicts with this set.
But for now I needed this for the follow ons and having a nice separate little
patch like this means I can just drop it after I get your clean up!  :-D

Ira

