Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6398FC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 17:56:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DD9820840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 17:56:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DD9820840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 821428E0003; Thu,  7 Mar 2019 12:56:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CEDF8E0002; Thu,  7 Mar 2019 12:56:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6981A8E0003; Thu,  7 Mar 2019 12:56:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9E08E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 12:56:51 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id f70so13657755qke.8
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 09:56:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=GlubaI8/tdCsyayarj1cX94BX3ry6cE1EJgMPiinZzY=;
        b=W0gQkDMCb8SuXKmjJ3bOlGfDRA0u5bcgffQrQymX8ri4krktWXRMCjfTOVA2iAjUTa
         kIZRUMrEhbmmQsL2jfaSlSg7l2i7Sy1B7r97CfaXtJfPlWZxlE/aP5jgeAjpgRM41ap+
         qKR2wKGy/luX7XIHFvlMro4k34JPJsyzxpYqZMwuHmzch1kZjqyj14gca/dkqPRqJz7e
         ziAQPqU0I220VeRiMfyUX/JPlxFCx8BT4in7cNif+L3rgDUtInuO+qXk3G1F9Ass7rPL
         1aOCgxySBWKAkYMVH/WI5OmBJx4CBhuwS0vPe/SQhIohgDyxWG6+vJqC8JpEEY3r1Tdp
         y1AA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUpOZJrDcATFxeJzRLjLtcDfLCo95bJjzo9KU7dhNpj64NC3dY4
	GBQs7m8LV4lmN/tcJQI+nEwJh1eIX18W/qiWJ8vKD/wjMeAI/uAVPs/LqqS3A3LjzTBTdi0qsJk
	hSQMzwUw7HToyqYs91QfxXZP71CImzfzefytW5DNLXYHZ7MqMQ9spYuRUSV37lax8PPQnLZsCFY
	o5j5GUAcM0BCdR0YT7iymZpjWjUIHSF7YubicAWpTLLaeRyT9oeWf0ilMr/SPEGzYqxCuRyq7P1
	FU/dNAjLXOzrRRObfSuWE4PLlb/rFnec/goG67vudORH34l2GNtBLMoXWku7UkLMMUa2HKc4O4n
	sLmZtNv2qYnKhu7JRkpKJfhXqt8zVjqjAFTZ2DOZAMoc50lHEF6I1bRnUyWtWg1BWgBMP5eF24r
	K
X-Received: by 2002:a0c:8698:: with SMTP id 24mr11792061qvf.188.1551981411004;
        Thu, 07 Mar 2019 09:56:51 -0800 (PST)
X-Received: by 2002:a0c:8698:: with SMTP id 24mr11791977qvf.188.1551981409777;
        Thu, 07 Mar 2019 09:56:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551981409; cv=none;
        d=google.com; s=arc-20160816;
        b=VJJGhWwPf7p1qtycXACFJc0BpWAH2lmbNBixVKWwIDEgM8UhloF6NuS4xGvORjUU4g
         wXwXKUcJlGnb2H7zQ8F+l17ayTY1B9NJ15ugNsjhZ0/gr3u1PhkEME3tJ56T8QU6FAbW
         2oiUYqo14KrPoEHTxMQXoQChObYxJS13nN4a9d5ZJ1zHXZ1oaxiAhNHUVaaK0fh2IYzP
         yib5WxazimWlHvn51XGa8Dn3a7/dEIWXLvJ/OX83ZwY/XCC8nra+FTOKwxuo7MuBtkpO
         uHy0uILhQFrLlKC5TTs6LSuAnqwFLxakvRWkCB9W1PMD80Lyey3BFwqm1VFxKNCEkw51
         YvRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=GlubaI8/tdCsyayarj1cX94BX3ry6cE1EJgMPiinZzY=;
        b=bnNygEbUBeAxr6jRFQgtRJ0geLsp+6rkiQh3M3CHnIQ2vlcu4oiY7VCKnXa6eMTgWn
         8G2pgUJard/VOv5lViYChJVueOXweU5uFNP9pD8kahi6p7abzGsfpn77quY8+esFB6Tm
         znV9mfmSi09qtX17OHB67lFyW0/dFO/Vh9xgTcNk4gLyOZe/82SmHpluZDAuRomplNQr
         xfRF9m2nUdlLY8zew7PsPpZXQvTDCZC5xoQk3clK8RMBDtkW33cTkZiNK/sBFOEDo1SE
         xhppMrySrWXgXtFqEIlWwV1Zm55t2XrscJfFEYURv4ywO+NfI9N5/Z3M7QWESLG2uBN1
         Z0DA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y15sor6644192qtk.69.2019.03.07.09.56.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 09:56:49 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxFRpwD4FB6daKlGFu9HAvoSSE10i1RtuQ+4HSg9M3hIccAg7z5LEuuhNtsFaAZIgZcXp6wYQ==
X-Received: by 2002:ac8:354c:: with SMTP id z12mr10798499qtb.92.1551981409185;
        Thu, 07 Mar 2019 09:56:49 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id t38sm3698415qtc.12.2019.03.07.09.56.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 09:56:48 -0800 (PST)
Date: Thu, 7 Mar 2019 12:56:45 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org, aarcange@redhat.com,
	Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307124700-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307103503-mutt-send-email-mst@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 10:47:22AM -0500, Michael S. Tsirkin wrote:
> On Wed, Mar 06, 2019 at 02:18:12AM -0500, Jason Wang wrote:
> > +static const struct mmu_notifier_ops vhost_mmu_notifier_ops = {
> > +	.invalidate_range = vhost_invalidate_range,
> > +};
> > +
> >  void vhost_dev_init(struct vhost_dev *dev,
> >  		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
> >  {
> 
> I also wonder here: when page is write protected then
> it does not look like .invalidate_range is invoked.
> 
> E.g. mm/ksm.c calls
> 
> mmu_notifier_invalidate_range_start and
> mmu_notifier_invalidate_range_end but not mmu_notifier_invalidate_range.
> 
> Similarly, rmap in page_mkclean_one will not call
> mmu_notifier_invalidate_range.
> 
> If I'm right vhost won't get notified when page is write-protected since you
> didn't install start/end notifiers. Note that end notifier can be called
> with page locked, so it's not as straight-forward as just adding a call.
> Writing into a write-protected page isn't a good idea.
> 
> Note that documentation says:
> 	it is fine to delay the mmu_notifier_invalidate_range
> 	call to mmu_notifier_invalidate_range_end() outside the page table lock.
> implying it's called just later.

OK I missed the fact that _end actually calls
mmu_notifier_invalidate_range internally. So that part is fine but the
fact that you are trying to take page lock under VQ mutex and take same
mutex within notifier probably means it's broken for ksm and rmap at
least since these call invalidate with lock taken.

And generally, Andrea told me offline one can not take mutex under
the notifier callback. I CC'd Andrea for why.

That's a separate issue from set_page_dirty when memory is file backed.

It's because of all these issues that I preferred just accessing
userspace memory and handling faults. Unfortunately there does not
appear to exist an API that whitelists a specific driver along the lines
of "I checked this code for speculative info leaks, don't add barriers
on data path please".


> -- 
> MST

