Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC16EC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 20:34:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A5E5218EA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 20:34:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A5E5218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E0878E0002; Thu, 31 Jan 2019 15:34:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0913F8E0001; Thu, 31 Jan 2019 15:34:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE87A8E0002; Thu, 31 Jan 2019 15:34:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1D628E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 15:34:06 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z11so4568588qkf.19
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 12:34:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Q7O0jcgITA3XebH5XyJvXJXGReDcsuC8W+QDfX39/cU=;
        b=DXYuMqTD04EbynbLX0ET7DWj4rD1xrxSQABH9GQFf/omM+J+uC72yPlMcjPhMLXd59
         eWFRaTOEkgCo7zIOzmeO20qPjtpchaPUfI4W+sy4C0Efaeoewi7NSLZWXs3JeNHUdDMx
         YArVdnCN124NfoEgiHN8CCgfJg5IjurCROCCvcJfpay07DcbIGL9LexUjtL+UPJehZ+T
         y4UX4kjeM/asVvSEna7zCMp4HGcO8cnY/WW8whnbvBpVkPzBndZwBVmKkEPNKPN2rFtr
         En5Ho/1VtHOr46DRxF/UPlcm+9azkZAv6L/Rvubg8lJseEgpU8t2TUrB7nik9nGlqkry
         lPQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukf4guFmWadqvLYSVqqFfaCtpq7b1M+VoEq68EAl8ZsYPbQ/FqGm
	UNw6KwEq8Vosr2YjNEvtrkq6nA/mTG1mXQhDZXZr3+IBaUwvsKB06o7zfDTmwp7VxbNZvIdUR3R
	KVIgs68IoCleYy12tO8N6ITbTCmcAo+jHd02CD/dkmzePYLVMa0LxxjPkkpTnD4l8Bg==
X-Received: by 2002:a0c:ec92:: with SMTP id u18mr34175728qvo.168.1548966846543;
        Thu, 31 Jan 2019 12:34:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN67INaKMqjIbzdXB4nEGXnJeOtj8Zqo18WHL6KdgSqT2WZBrFr/v9G7R/x9EdhCoNIUBKjg
X-Received: by 2002:a0c:ec92:: with SMTP id u18mr34175701qvo.168.1548966845882;
        Thu, 31 Jan 2019 12:34:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548966845; cv=none;
        d=google.com; s=arc-20160816;
        b=oZggihkMNnfb7VZjQrWd682nxixjFiqiqUVfJOnpXRwF6cS63mIh8TzBQGdw+Tttt3
         FPrMO+PWOGP7/nk+vFer4gjnW7Q8lZTD1Yk2Rw2cbJwGOGmsGXlfI7Dv4HcqqfBiHOoE
         Dk5+qnvu0WxvqFnG41L0pcTiNvZPj+z7Mqqj3moAWpLZp7CzynsHCHTrJUM7gYI8NSwG
         F78wzqGaRMUmVCzH2HqDaDamxBRI5Iq5xwwW3raq+Gi5ASWzs8qYHBveVWO7Um1Id9a6
         nzk/vFa1YEDfKq9CgYu1vYbqqtW18aeCS3Xs//vHOj+ptJWMpSGT780x91xu1eFEcDAE
         lGOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Q7O0jcgITA3XebH5XyJvXJXGReDcsuC8W+QDfX39/cU=;
        b=NxRT+tWnCxFmy8lG95d7cdLtBQbBHtRnp2t1V5noEVBP+ZrZR8yWyPsdzTp7uosy2L
         2cM9LYXRw19/SnIfdAoTaQLS93C9338j9/qu88S+dn+jqpWq9wj63Hn5ui30fkyaLHi2
         L5UKcgHtjTn+wjNZWjpt1zc8w0kcHkvkQtiiWrL9tIUxtWPl4CGQFFnA1InKq1t48aMD
         Fbdslb5J6WGcm916ZiX/gO+H1h2uSkUZpci7WOCRQ0hAJt3eW/VSfjcWl3mpia33au/0
         Pherz/hnCIf30rudr5bT5mdDHplbGAfofdfWFHeSa/UmGuFl89tBE61NsVhAxKZ4uhqU
         Ybcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p27si3738040qvf.190.2019.01.31.12.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 12:34:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9B8B9432B8;
	Thu, 31 Jan 2019 20:34:04 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 619A860BF7;
	Thu, 31 Jan 2019 20:34:01 +0000 (UTC)
Date: Thu, 31 Jan 2019 15:33:59 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Jan Kara <jack@suse.cz>, Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 0/9] mmu notifier provide context informations
Message-ID: <20190131203359.GA22145@redhat.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
 <20190131161006.GA16593@redhat.com>
 <20190131115535.7eeecf501615f8bad2f139eb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190131115535.7eeecf501615f8bad2f139eb@linux-foundation.org>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 31 Jan 2019 20:34:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 11:55:35AM -0800, Andrew Morton wrote:
> On Thu, 31 Jan 2019 11:10:06 -0500 Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > Andrew what is your plan for this ? I had a discussion with Peter Xu
> > and Andrea about change_pte() and kvm. Today the change_pte() kvm
> > optimization is effectively disabled because of invalidate_range
> > calls. With a minimal couple lines patch on top of this patchset
> > we can bring back the kvm change_pte optimization and we can also
> > optimize some other cases like for instance when write protecting
> > after fork (but i am not sure this is something qemu does often so
> > it might not help for real kvm workload).
> > 
> > I will be posting a the extra patch as an RFC, but in the meantime
> > i wanted to know what was the status for this.
> 
> The various drm patches appear to be headed for collisions with drm
> tree development so we'll need to figure out how to handle that and in
> what order things happen.
> 
> It's quite unclear from the v4 patchset's changelogs that this has
> anything to do with KVM and "the change_pte() kvm optimization" hasn't
> been described anywhere(?).
> 
> So..  I expect the thing to do here is to get everything finished, get
> the changelogs completed with this new information and do a resend.
> 
> Can we omit the drm and rdma patches for now?  Feed them in via the
> subsystem maintainers when the dust has settled?

Yes, i should have pointed out that you can ignore the driver patches
i will resumit them through the appropriate tree once the mm bits are
in. I just wanted to show case how i intended to use this. I will try
not to forget next time to clearly tag things that are just there to
show case and that will be merge latter through different tree.

I will do a v5 with kvm bits once we have enough testing and confidence.
So i guess this all will be delayed to 5.2 and 5.3 for driver bits.
The kvm bits are outcomes of private emails and previous face to face
discussion around mmu notifier and kvm. I believe the context information
will turn to be useful to more users than the ones i am doing it for.

Cheers,
Jérôme

