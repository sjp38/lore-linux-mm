Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF654C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 00:43:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9106F21871
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 00:43:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9106F21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CE286B0006; Thu, 28 Mar 2019 20:43:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 180B26B0007; Thu, 28 Mar 2019 20:43:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06DEB6B0008; Thu, 28 Mar 2019 20:43:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C02D26B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 20:43:40 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n5so409835pgk.9
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:43:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=FxtF+AhUzAPcrVAxbh18uVNW0hHyZ7swL6SEvJrG2ME=;
        b=KmMdWlUEKYrN7UNNrAdZF9xC5wXlUYo/SYDRnz+C+CT0hLsUXLs1W2WhZWuK4L8wGw
         4r3VEEqXRFR05Sgrls9PFSoivQ1tNKmCwJGt/YQ3Zwi1aqHSUUvAYaBOVUAgJkUfaX6w
         6Gf6lmaSpvWn+Ls03xQcBT7FWjjs3lWs+vMDZ8rU/tUXJohwjcJn4ZBOXGfU6RfK1Or2
         qB4JRPTFPG48l/NsDB3UAZ4ZEHv1Y2zzWGb5kzbecmH0Jam/YtepXJjczrOIyAX9Mnj9
         KrHFkF4tgcCIO4HIoZ6WfRKT83cUMGYbluOv9dOJbUXE8ncviHbrEyVSRCGd6bJAmXXG
         sJyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXbQ09+TP8QTb6UdYryh2bf3Qh/T/MstAhjr4JViW6ECR2xolDk
	s0bKpBdKdGiZOUSv17Ftw4fZtPeBMmwNk8aEmgG0oLOiZi9+43FYdvDkzD35KuJW/hF042Idsxl
	KY7eQNxmzsSNCn+cdsZraEqaA8Vh7cRR8xVts1oA6iz3UrrRz/hzVlvjckETfk0iBNg==
X-Received: by 2002:a63:c10b:: with SMTP id w11mr43293955pgf.39.1553820220391;
        Thu, 28 Mar 2019 17:43:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygdfHC+czckaPop5XQehgmuIElFmXI8Saz5M9SUsROO5HlM/t5dUFGYN8HaAWh2MWjC+RD
X-Received: by 2002:a63:c10b:: with SMTP id w11mr43293900pgf.39.1553820219442;
        Thu, 28 Mar 2019 17:43:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553820219; cv=none;
        d=google.com; s=arc-20160816;
        b=xBMWnmvI4gwzd3v2ri3ATBP3wU4dqxzPa9wl32yq/IsT9Y1QhXuZtfPuHba5BbkWtZ
         MoXd4qMjpzOYN4VV+nhWxnDQyytP5W4/ZQDOHOpEoKfkaO8/Up5Zjj5dawT6ctiz2si3
         Ojv/F4v9AS3jXo93gXiXLYLIXlpOqp/AyvS5za+Nnj6I0jjLqyTh/R6OWSGKkxWuY7dg
         03chiUlcvQXGqfvb5cRm/okgMoQS1XFRI56D36ewB3ipUK/rzwpQFuHcPLUgKSVIWAdX
         6x/WLuK2zlt+KiYUb4otOadTYva4wmB+QIYLzbexM+7Djs3jiVADrUNv8XJyf0pZ338o
         s77A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=FxtF+AhUzAPcrVAxbh18uVNW0hHyZ7swL6SEvJrG2ME=;
        b=e3RcbuiUuWK4cf2g7ELdaR/fSYgtY83wvSbDpyfCvMBCMkur2rZ+/p4eC/iNqKWPZJ
         R2QlaJaau1S2le9hjoMkfqBkW/xpivBx3OzZZnRp3CLC/KsLCUtfzdATU3Kz+MjQ57Fz
         GKPUU/czGUCDfLCzpXNkM53fkRzqaEaXx0Nk5zJDv9lgZ5oFXIF5LkOWWpBspfp7W9nZ
         H4IS5FmP2nahTy5NryM9pYApc54/zp+kW5zLWAPER8Ssyd3o3X7vP/CpLIkwjbUUkYW6
         FwqrntWMs/4WIeTge4vqP4gcB0KIfosY1EFPXcJByBcsUXQqmyPv35kXz/+zvjp868L3
         ly3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p2si475185pfi.103.2019.03.28.17.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 17:43:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 17:43:38 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,282,1549958400"; 
   d="scan'208";a="331710051"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga006.fm.intel.com with ESMTP; 28 Mar 2019 17:43:38 -0700
Date: Thu, 28 Mar 2019 09:42:31 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
Message-ID: <20190328164231.GF31324@iweiny-DESK2.sc.intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-8-jglisse@redhat.com>
 <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
 <20190328221203.GF13560@redhat.com>
 <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
 <20190328223153.GG13560@redhat.com>
 <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
 <20190328232125.GJ13560@redhat.com>
 <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 04:28:47PM -0700, John Hubbard wrote:
> On 3/28/19 4:21 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 03:40:42PM -0700, John Hubbard wrote:
> >> On 3/28/19 3:31 PM, Jerome Glisse wrote:
> >>> On Thu, Mar 28, 2019 at 03:19:06PM -0700, John Hubbard wrote:
> >>>> On 3/28/19 3:12 PM, Jerome Glisse wrote:
> >>>>> On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
> >>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> >>>>>>> From: Jérôme Glisse <jglisse@redhat.com>
> [...]
> >> Hi Jerome,
> >>
> >> I think you're talking about flags, but I'm talking about the mask. The 
> >> above link doesn't appear to use the pfn_flags_mask, and the default_flags 
> >> that it uses are still in the same lower 3 bits:
> >>
> >> +static uint64_t odp_hmm_flags[HMM_PFN_FLAG_MAX] = {
> >> +	ODP_READ_BIT,	/* HMM_PFN_VALID */
> >> +	ODP_WRITE_BIT,	/* HMM_PFN_WRITE */
> >> +	ODP_DEVICE_BIT,	/* HMM_PFN_DEVICE_PRIVATE */
> >> +};
> >>
> >> So I still don't see why we need the flexibility of a full 0xFFFFFFFFFFFFFFFF
> >> mask, that is *also* runtime changeable. 
> > 
> > So the pfn array is using a device driver specific format and we have
> > no idea nor do we need to know where the valid, write, ... bit are in
> > that format. Those bits can be in the top 60 bits like 63, 62, 61, ...
> > we do not care. They are device with bit at the top and for those you
> > need a mask that allows you to mask out those bits or not depending on
> > what the user want to do.
> > 
> > The mask here is against an _unknown_ (from HMM POV) format. So we can
> > not presume where the bits will be and thus we can not presume what a
> > proper mask is.
> > 
> > So that's why a full unsigned long mask is use here.
> > 
> > Maybe an example will help let say the device flag are:
> >     VALID (1 << 63)
> >     WRITE (1 << 62)
> > 
> > Now let say that device wants to fault with at least read a range
> > it does set:
> >     range->default_flags = (1 << 63)
> >     range->pfn_flags_mask = 0;
> > 
> > This will fill fault all page in the range with at least read
> > permission.
> > 
> > Now let say it wants to do the same except for one page in the range
> > for which its want to have write. Now driver set:
> >     range->default_flags = (1 << 63);
> >     range->pfn_flags_mask = (1 << 62);
> >     range->pfns[index_of_write] = (1 << 62);
> > 
> > With this HMM will fault in all page with at least read (ie valid)
> > and for the address: range->start + index_of_write << PAGE_SHIFT it
> > will fault with write permission ie if the CPU pte does not have
> > write permission set then handle_mm_fault() will be call asking for
> > write permission.
> > 
> > 
> > Note that in the above HMM will populate the pfns array with write
> > permission for any entry that have write permission within the CPU
> > pte ie the default_flags and pfn_flags_mask is only the minimun
> > requirement but HMM always returns all the flag that are set in the
> > CPU pte.
> > 
> > 
> > Now let say you are an "old" driver like nouveau upstream, then it
> > means that you are setting each individual entry within range->pfns
> > with the exact flags you want for each address hence here what you
> > want is:
> >     range->default_flags = 0;
> >     range->pfn_flags_mask = -1UL;
> > 
> > So that what we do is (for each entry):
> >     (range->pfns[index] & range->pfn_flags_mask) | range->default_flags
> > and we end up with the flags that were set by the driver for each of
> > the individual range->pfns entries.
> > 
> > 
> > Does this help ?
> > 
> 
> Yes, the key point for me was that this is an entirely device driver specific
> format. OK. But then we have HMM setting it. So a comment to the effect that
> this is device-specific might be nice, but I'll leave that up to you whether
> it is useful.

Indeed I did not realize there is an hmm "pfn" until I saw this function:

/*
 * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
 * @range: range use to encode HMM pfn value
 * @pfn: pfn value for which to create the HMM pfn
 * Returns: valid HMM pfn for the pfn
 */
static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
                                        unsigned long pfn)

So should this patch contain some sort of helper like this... maybe?

I'm assuming the "hmm_pfn" being returned above is the device pfn being
discussed here?

I'm also thinking calling it pfn is confusing.  I'm not advocating a new type
but calling the "device pfn's" "hmm_pfn" or "device_pfn" seems like it would
have shortened the discussion here.

Ira

> 
> Either way, you can add:
> 
> 	Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

