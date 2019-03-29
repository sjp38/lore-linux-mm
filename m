Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98EC2C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:17:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4868C206B6
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:17:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4868C206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D27D46B0008; Thu, 28 Mar 2019 21:17:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD6C26B000A; Thu, 28 Mar 2019 21:17:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9EC76B000C; Thu, 28 Mar 2019 21:17:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98DD36B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 21:17:33 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x58so788990qtc.1
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:17:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vWXQHZWj5B9n9u1m4nYJc8XOzk8sgjuz0x7UCf5Np1Q=;
        b=EATDAlJzPF5J+Fe2hZQjaQVbKH+ncFT7B1TNO0eGM8OYIv1qEPL/3oz9OCIsY+c08y
         jWpv1jTneQZ4tfxMSpR4qZQaNN4ae5kcbzj8dGahnAVzTmVfrymL3e8vjRyOCa+sFLpE
         AjANN8KGzlJznvl22XwQkDEb4+vAp2lImFxA6XPUCwR55W7XHZSTL24QL+kWXkNDcvrX
         Hl8tTP7aKXokgpNYwWmAGd/jIRCkgkPcFoncWa/l5uMxb0GMjsiypw2hsUNpiTFsxmLP
         TrM2pZO4B3CmVw2jKoThegtmIVl1GC/mBoAotPeV5Z6wjwDNbjTTx0ZFuT9wzp0nTTwd
         styQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXD2EkiORD31tPRlN7zHqgHd/eP7xJx1ptv0K5kqc5RRQpcwMnq
	+RCzKIeuaAtDoeSaAwN307cPEIlvpTpqVn1tQNZ7c52ulcxbVz7/nJF/FKZ5qWbzajhi2GFGAmK
	Ud2aXQVO9OZASJePgF1W9yK1d0uJBxnflNGqLBTSauetJXENURvGCH0zL501D0rJsHQ==
X-Received: by 2002:a05:620a:15ef:: with SMTP id p15mr35550054qkm.317.1553822253360;
        Thu, 28 Mar 2019 18:17:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzb1B08dUW1H381GGtntlWXJrDK3nv2fiO1q/M6ExecmwOIIF9FlprrCPzwjg1UiEDWXpws
X-Received: by 2002:a05:620a:15ef:: with SMTP id p15mr35550004qkm.317.1553822252388;
        Thu, 28 Mar 2019 18:17:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553822252; cv=none;
        d=google.com; s=arc-20160816;
        b=H64CtvXvwU0U/HmGu0RfPogV25DEckR1H74g99GKb5ABocAbsqWRAMycuDiqxgLKok
         Fen49vcZ6Gb7PmRmUcCTPdFekby+PrJszfSqhtq+tWj7TX3JYk9B3Uno2XAvqD3Ge1Qp
         /RQdDPxuAY2e22e1Lgw7OpsHEla9Qb6WmT1/HJ81JNgwdRjDzLyb/Du9uZmzWnERd/kH
         kntaw49eBS6CMsGxvRT2xF+ixIzTgCkzhBF3ALZ/a9X7cCnP+64ywBHdJy2K4v/YxGYr
         FrZiB60H3z+poutk7pwalrnbFRFpBtfKw1dw7Q0zLb7RCU96IE8u6/ME7tzxJkf8hlXK
         Rthg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=vWXQHZWj5B9n9u1m4nYJc8XOzk8sgjuz0x7UCf5Np1Q=;
        b=0M8M8byv+aIhmJhXSGROoaq05uV637S6ImDmj91yo4cEmwTxyeYZqp54rF661pS334
         AceWXcpwaTULZb5CZ8gwkLDsYk5tNtxhQAKC+jI4BbviOx7m1Tpag5qTiaDW/PhRisWf
         Srj2LA1rQSgoUfSUlBgqUVAIdBdl4caQOM9aXkFmII/kjelkdI6ezuLzSik4sFU3Wy51
         kihFvuyrD4H4aspVCjr8EiJLmlgsIPv6Si3oQgvIFkUQtNSZQN/kiroz97oUjj/xhRsZ
         E8T2t/A+i/gHA2j/DJC8jcn4BhVUCd8GIgLW/gn8fo0mFiSieyymoI4X3ZFsKJUCKdaq
         Z0tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q16si328720qvc.13.2019.03.28.18.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 18:17:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 822D23082AED;
	Fri, 29 Mar 2019 01:17:31 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 671EE62669;
	Fri, 29 Mar 2019 01:17:30 +0000 (UTC)
Date: Thu, 28 Mar 2019 21:17:28 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
Message-ID: <20190329011727.GC16680@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-8-jglisse@redhat.com>
 <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
 <20190328221203.GF13560@redhat.com>
 <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
 <20190328223153.GG13560@redhat.com>
 <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
 <20190328232125.GJ13560@redhat.com>
 <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
 <20190328164231.GF31324@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190328164231.GF31324@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 29 Mar 2019 01:17:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 09:42:31AM -0700, Ira Weiny wrote:
> On Thu, Mar 28, 2019 at 04:28:47PM -0700, John Hubbard wrote:
> > On 3/28/19 4:21 PM, Jerome Glisse wrote:
> > > On Thu, Mar 28, 2019 at 03:40:42PM -0700, John Hubbard wrote:
> > >> On 3/28/19 3:31 PM, Jerome Glisse wrote:
> > >>> On Thu, Mar 28, 2019 at 03:19:06PM -0700, John Hubbard wrote:
> > >>>> On 3/28/19 3:12 PM, Jerome Glisse wrote:
> > >>>>> On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
> > >>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> > >>>>>>> From: Jérôme Glisse <jglisse@redhat.com>
> > [...]
> > >> Hi Jerome,
> > >>
> > >> I think you're talking about flags, but I'm talking about the mask. The 
> > >> above link doesn't appear to use the pfn_flags_mask, and the default_flags 
> > >> that it uses are still in the same lower 3 bits:
> > >>
> > >> +static uint64_t odp_hmm_flags[HMM_PFN_FLAG_MAX] = {
> > >> +	ODP_READ_BIT,	/* HMM_PFN_VALID */
> > >> +	ODP_WRITE_BIT,	/* HMM_PFN_WRITE */
> > >> +	ODP_DEVICE_BIT,	/* HMM_PFN_DEVICE_PRIVATE */
> > >> +};
> > >>
> > >> So I still don't see why we need the flexibility of a full 0xFFFFFFFFFFFFFFFF
> > >> mask, that is *also* runtime changeable. 
> > > 
> > > So the pfn array is using a device driver specific format and we have
> > > no idea nor do we need to know where the valid, write, ... bit are in
> > > that format. Those bits can be in the top 60 bits like 63, 62, 61, ...
> > > we do not care. They are device with bit at the top and for those you
> > > need a mask that allows you to mask out those bits or not depending on
> > > what the user want to do.
> > > 
> > > The mask here is against an _unknown_ (from HMM POV) format. So we can
> > > not presume where the bits will be and thus we can not presume what a
> > > proper mask is.
> > > 
> > > So that's why a full unsigned long mask is use here.
> > > 
> > > Maybe an example will help let say the device flag are:
> > >     VALID (1 << 63)
> > >     WRITE (1 << 62)
> > > 
> > > Now let say that device wants to fault with at least read a range
> > > it does set:
> > >     range->default_flags = (1 << 63)
> > >     range->pfn_flags_mask = 0;
> > > 
> > > This will fill fault all page in the range with at least read
> > > permission.
> > > 
> > > Now let say it wants to do the same except for one page in the range
> > > for which its want to have write. Now driver set:
> > >     range->default_flags = (1 << 63);
> > >     range->pfn_flags_mask = (1 << 62);
> > >     range->pfns[index_of_write] = (1 << 62);
> > > 
> > > With this HMM will fault in all page with at least read (ie valid)
> > > and for the address: range->start + index_of_write << PAGE_SHIFT it
> > > will fault with write permission ie if the CPU pte does not have
> > > write permission set then handle_mm_fault() will be call asking for
> > > write permission.
> > > 
> > > 
> > > Note that in the above HMM will populate the pfns array with write
> > > permission for any entry that have write permission within the CPU
> > > pte ie the default_flags and pfn_flags_mask is only the minimun
> > > requirement but HMM always returns all the flag that are set in the
> > > CPU pte.
> > > 
> > > 
> > > Now let say you are an "old" driver like nouveau upstream, then it
> > > means that you are setting each individual entry within range->pfns
> > > with the exact flags you want for each address hence here what you
> > > want is:
> > >     range->default_flags = 0;
> > >     range->pfn_flags_mask = -1UL;
> > > 
> > > So that what we do is (for each entry):
> > >     (range->pfns[index] & range->pfn_flags_mask) | range->default_flags
> > > and we end up with the flags that were set by the driver for each of
> > > the individual range->pfns entries.
> > > 
> > > 
> > > Does this help ?
> > > 
> > 
> > Yes, the key point for me was that this is an entirely device driver specific
> > format. OK. But then we have HMM setting it. So a comment to the effect that
> > this is device-specific might be nice, but I'll leave that up to you whether
> > it is useful.
> 
> Indeed I did not realize there is an hmm "pfn" until I saw this function:
> 
> /*
>  * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
>  * @range: range use to encode HMM pfn value
>  * @pfn: pfn value for which to create the HMM pfn
>  * Returns: valid HMM pfn for the pfn
>  */
> static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
>                                         unsigned long pfn)
> 
> So should this patch contain some sort of helper like this... maybe?
> 
> I'm assuming the "hmm_pfn" being returned above is the device pfn being
> discussed here?
> 
> I'm also thinking calling it pfn is confusing.  I'm not advocating a new type
> but calling the "device pfn's" "hmm_pfn" or "device_pfn" seems like it would
> have shortened the discussion here.
> 

That helper is also use today by nouveau so changing that name is not that
easy it does require the multi-release dance. So i am not sure how much
value there is in a name change.

Cheers,
Jérôme

