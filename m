Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25595C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:53:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E641D20840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:53:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E641D20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81D688E0003; Thu,  7 Mar 2019 13:53:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CAE08E0002; Thu,  7 Mar 2019 13:53:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E1648E0003; Thu,  7 Mar 2019 13:53:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 44D2E8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:53:08 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id q15so13968915qki.14
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:53:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=GtnWDLcWe4XQrcK8Q6Ov6kZxVC6vJzbAaPKjx7ZIdO0=;
        b=SHoF4VRlHfoNoiIwgSFv22md9Y4+IHSaOC5hNdco1OFW1kJJrDUJwuwy2cJo29L6UM
         gOZpuYP8j/UoUPdkKT+v0Yun/BsOwICL39VtFRi0WTVcrkie+b6srHYNJUqTb0Y88lbP
         ZVg3v0zhr1WEyCTFE3RNqYDOmqY8mSllTjJlR2+2zQ1fqF5cb+bsAlRh4el3xQyKr6qq
         4YKA6tTJPnTjCANy62o3xNepn84DmZGcg0jRMkG0z2LM4NgfQK1hU5oNnkKnVsr4oMJY
         pDDXCqhgIudAqXgV7Y6B4aQwPaTmx26D2cBzvWolcZHlOe9qpRUSCOhO5QP7czM6477q
         3b6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUmgF+L9LIv7gSkZ6c7a5Chq8s4im/94DWEXBlpn5FF4zd+cwFn
	nssUH45DhhQfVc2NriPk4e0oV6+kuLxvw++2QCIwLGGTP4Lxz2zHBblD1lf8l6Vp7tfOVEAJtCJ
	rsJ+rdOQfYAAElhCzBStLBAisjSELm/KoJQjTVw57WVQq6v/WU3v3A53gd/EDt/xXl1auVrPr+Z
	kRt4iBIfcfxwmf9DLsHF53cSoE6WhO1I/Jd0yaDd0u3FOTc7WHuy1Dd5aJ+cvWAfKH34jK0Krfp
	IHhY7IjRCrsyYkgJBdsIkSqiYkc+4ZC5cH6ywTuOjjvCKvx9QVadZo/YWR20Osa5icPNqEfWQoL
	FFgfYernxZ71pHxTNygbLTpn9hVVULQ1sSQyG7ZP04LF4A2pIhn2nhEUkQs4s2nFkAtriPphs6k
	d
X-Received: by 2002:ac8:3559:: with SMTP id z25mr11688234qtb.336.1551984788006;
        Thu, 07 Mar 2019 10:53:08 -0800 (PST)
X-Received: by 2002:ac8:3559:: with SMTP id z25mr11688190qtb.336.1551984787296;
        Thu, 07 Mar 2019 10:53:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551984787; cv=none;
        d=google.com; s=arc-20160816;
        b=duE770vnRgVi6hSeIuhQFjdSeGor0jZMlAqXj7TJPYTdiZJITPIVjQh2u6JJxyzakj
         mnk0r0NOk8/l4Qyd5efDOUz6uAR4Gf5B7dwp1BuDpidEN7YmotvQYPh+Weq4h/TmvO4s
         jy9VwbrgrAvDDD3rFUvNspFatrAsOZLeKDlnOkVw5CYSLPcLVHStnuwNmjzneEGLOH9V
         jVdZwYsxDlIzCR8wUksbGDxeRqRqcKuhg/9ZnOPXub33NGG8dGtjZR95jyjWfP1S9wn3
         I92g88urGcPqUOoRL+mLMJyDgeXnNTJT2Nor6z9B8+ihzyYftP7p7MDWUhSTUNRrCzMK
         fsYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=GtnWDLcWe4XQrcK8Q6Ov6kZxVC6vJzbAaPKjx7ZIdO0=;
        b=UzMOH5yq/GVUWgBCif3ioRK9Z5BROHoSc7+vFsSTFa6o34+E2n+onnYF69vFx+pTga
         6NLGl7vTJADk4boeQlqlv6lLwgg7nDv6nSnSN1Gyj/3/2WpZLy/nvqcEaC3OCIF6zeDu
         5SiX3aWswiDZKO+5QZQNediOBgqxAhqHO7nnfueAOZgFcLdiPySTeG5inlYkY/TJNy3v
         lmBg1b4y8o7mOnI+P5gY8GaxzT80GKK1pn7qNsqyBMvNUWGQ53PW3zxQwmKATDXOXcv7
         miCHepFfPzCRhd4Gcsk4kX/17+epkmEnRg9uxub9l4LThrsS+iyoQXfuQkB/xvxbdi1s
         /Akg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13sor6227976qvn.37.2019.03.07.10.53.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 10:53:07 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzW9j0JzJli+Hoik7VfAelOEXtBb2ylO093NKWOvb/pOqqctTtb7pw3S3oGhuiEqQBqRTuWJA==
X-Received: by 2002:a0c:d60d:: with SMTP id c13mr12269763qvj.43.1551984787074;
        Thu, 07 Mar 2019 10:53:07 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id l24sm3674456qtf.27.2019.03.07.10.53.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 10:53:05 -0800 (PST)
Date: Thu, 7 Mar 2019 13:53:03 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
	pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>,
	David Hildenbrand <david@redhat.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
Message-ID: <20190307134744-mutt-send-email-mst@kernel.org>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
 <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
 <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com>
 <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 10:45:58AM -0800, Alexander Duyck wrote:
> To that end what I think w may want to do is instead just walk the LRU
> list for a given zone/order in reverse order so that we can try to
> identify the pages that are most likely to be cold and unused and
> those are the first ones we want to be hinting on rather than the ones
> that were just freed. If we can look at doing something like adding a
> jiffies value to the page indicating when it was last freed we could
> even have a good point for determining when we should stop processing
> pages in a given zone/order list.
> 
> In reality the approach wouldn't be too different from what you are
> doing now, the only real difference would be that we would just want
> to walk the LRU list for the given zone/order rather then pulling
> hints on what to free from the calls to free_one_page. In addition we
> would need to add a couple bits to indicate if the page has been
> hinted on, is in the middle of getting hinted on, and something such
> as the jiffies value I mentioned which we could use to determine how
> old the page is.

Do we really need bits in the page?
Would it be bad to just have a separate hint list?

If you run out of free memory you can check the hint
list, if you find stuff there you can spin
or kick the hypervisor to hurry up.

Core mm/ changes, so nothing's easy, I know.

-- 
MST

