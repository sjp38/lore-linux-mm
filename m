Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E653DC10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:07:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFD6E2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:07:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFD6E2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EA826B0003; Wed, 20 Mar 2019 03:07:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 473626B0006; Wed, 20 Mar 2019 03:07:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33D9C6B0007; Wed, 20 Mar 2019 03:07:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE90A6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:07:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w6so236602edq.20
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:07:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tK+8m/zJDr3FNW2MfmcJWV5ERxN2mtwyNsp24jf939A=;
        b=SMWr546eM9QsbY6zApTlUF62D6cUtdzFJOFyzr5c8TW27RixCU0/CMFMlOywmoYbwR
         CxKDQo6cBLyZL7dLa4i2GQKCcHHo5aE5hQasljT1W1G1CDARDffKELVNAk8A3fP9ckFL
         JZJ167u2X7bytMx9e3q/XGiG9pKdeICdeblrJpYH0tRpifbMpTCkvVGoAsUkziKZCUo2
         zRCtGJjR1WVOyaNOyNl9X5pdtAj2Nkxp0nNIX0U8hnrfqScfRyI2NM2rryDu8yWWDyD/
         cxpxN4zBef74vyqtQa5qq7sOP57WrsTBNFmPUpjlQv5MrZbSDEOX+sIqEitnQunaBnWb
         Q47w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWf7CmxmAYd4VMFrYmzn99eMiXWVCG2Nw1iXe1AmwR+kL3hed7S
	j5ulQhFL0x9/cKKVjXX04xT1CCZldj0LtvzNblJ80UfWmcjCKhrQl3sNP1Bf8367CJu0YIeiTC/
	r/ZTRVegw1DGRCBb2BQaAJt/XhWP8prBtVVEju0ALu1rQPJfUu3NjPl+A8zpyeWE=
X-Received: by 2002:a17:906:905:: with SMTP id i5mr16525150ejd.23.1553065653403;
        Wed, 20 Mar 2019 00:07:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2PufRTpK4pybK+zQOkLJj3J5CIPzQvZKxCDGRvJk5de860h2sbQXXCN3YJk23O0JPWQBy
X-Received: by 2002:a17:906:905:: with SMTP id i5mr16525115ejd.23.1553065652669;
        Wed, 20 Mar 2019 00:07:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553065652; cv=none;
        d=google.com; s=arc-20160816;
        b=DS2O58Bgaz3IjbOKfR29i9Tj3GzWm++ieF9ilWtN6NaEsBEhR/8HEI2GVJsbvVXtu8
         i0tr63sX50cmu0iXeBYMvZndU1OmWO9cjyzv9esnk4MUbQvR1B5IHVkK8bnkGOpzVECH
         rki6uCuLZkrSWpU7QGDsMOaZeYJPyKjfbHUPVkewvHVzVo7Q1XYd0E2iMO5xk+uloCJN
         gp+hwfI6xbZEjLOYbQrPEl6igUW/h6qQXHI/kmWTlNJlfnb4l2k8i7cBtkdIxTP+ObOJ
         1A5Iy+FjZKroiJnYiqlq3eeh42qXaAmM2JPdzF2ATqlE85NlpEEUv5Z2tSOIjAqX9uhW
         wEXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tK+8m/zJDr3FNW2MfmcJWV5ERxN2mtwyNsp24jf939A=;
        b=SBwuuEUweSbyDZ6GenyMXQyiowKf0lH8KsQSZCiKAu1c3IvBERZazajzM6+Z6eAPMo
         sr0cCJt+jVsdkmGDw4YvhEXlPueL2VwGUJgroTGwnGgSigN1Scyda1s4SYD4q4926y7i
         upVynsbtMlmfJrObOrzp5FkHJSU2JEiGy6nke4TspEQkVGWzSGA33L4TZu+U/N63W1xh
         vO8T9/lCHURGmZl1yfiXvqUwyJBt6yoniV0G3YUjJynNAqat7fzpOPKq69Ua2y+WIECk
         aMpANvGIFhHnpblBdH/W+w7jpVppZ0oLk+tUtBuh7lwLqlb5YRMaHjZ+y6/XHBxAkg6R
         EyQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x12si502853edx.409.2019.03.20.00.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:07:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 349ABAE16;
	Wed, 20 Mar 2019 07:07:32 +0000 (UTC)
Date: Wed, 20 Mar 2019 08:07:31 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org,
	Yong Wu <yong.wu@mediatek.com>,
	Yingjoe Chen <yingjoe.chen@mediatek.com>,
	Huaisheng Ye <yehs1@lenovo.com>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>, Vlastimil Babka <vbabka@suse.cz>,
	Tomasz Figa <tfiga@google.com>, stable@vger.kernel.org,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	David Rientjes <rientjes@google.com>,
	Pekka Enberg <penberg@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	Joerg Roedel <joro@8bytes.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Hsin-Yi Wang <hsinyi@chromium.org>, hch@infradead.org,
	Christoph Lameter <cl@linux.com>,
	Levin Alexander <Alexander.Levin@microsoft.com>, linux-mm@kvack.org
Subject: Re: + mm-add-sys-kernel-slab-cache-cache_dma32.patch added to -mm
 tree
Message-ID: <20190320070731.GE30433@dhcp22.suse.cz>
References: <20190319183751.rWqkf%akpm@linux-foundation.org>
 <20190319191721.GC30433@dhcp22.suse.cz>
 <CANMq1KAoya365L9+iGD7Uu34r_9zbbRjSHjB7L_8vi=avTtLnQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANMq1KAoya365L9+iGD7Uu34r_9zbbRjSHjB7L_8vi=avTtLnQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 20-03-19 08:17:52, Nicolas Boichat wrote:
> On Wed, Mar 20, 2019 at 3:18 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 19-03-19 11:37:51, Andrew Morton wrote:
> > > From: Nicolas Boichat <drinkcat@chromium.org>
> > > Subject: mm: add /sys/kernel/slab/cache/cache_dma32
> > >
> > > A previous patch in this series adds support for SLAB_CACHE_DMA32 kmem
> > > caches.  This adds the corresponding /sys/kernel/slab/cache/cache_dma32
> > > entries, and fixes slabinfo tool.
> >
> > I believe I have asked and didn't get a satisfactory answer before IIRC. Who
> > is going to consume this information?
> 
> No answer from me, but as a reminder, I added this note on the patch
> (https://patchwork.kernel.org/patch/10720491/):
> """
> There were different opinions on whether this sysfs entry should
> be added, so I'll leave it up to the mm/slub maintainers to decide
> whether they want to pick this up, or drop it.
> """

We have a terrible track rescord of exporting data to userspace that
kick back much later. So I am really convinced that adding new user
visible data should be justified by a useful usecase. Exporting just
because we can is a terrible justification if you ask me.
-- 
Michal Hocko
SUSE Labs

