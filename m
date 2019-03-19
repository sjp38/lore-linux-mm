Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCFE8C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:24:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 926ED2175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:24:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 926ED2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BA3B6B0005; Tue, 19 Mar 2019 18:24:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 169FF6B0006; Tue, 19 Mar 2019 18:24:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 031A86B0007; Tue, 19 Mar 2019 18:24:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D325C6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:24:51 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z34so403753qtz.14
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:24:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=5hI6O0igr3c8ij5FVAHmWrRtF7GSn1W6INSTApOKnXE=;
        b=MMKQmw6Ryg21MOqPRPS9b1sqN6mn5b5u7B0dIUk7yavhtKt/cXGOYRDDOZ5H+zaYtr
         bzs9a+ZbHfSAveKOSIhLuA9HIoTXDEbLqpPS+GP4QrRM6PTdOZ9ecsd5VGy4P+vc9xv2
         izJSMLCaGw3/zK0+MMVNSakHzHGsTROZmyZStDGZiPNcQgfFLgOoU1yqep30RxWRC3xC
         14CPYNGkdwn80p82XAjASZI5xbhk3Rw0dKrIvjJqjWv1ZQeJl7ad+NCYS5jOmP/G9gtJ
         RFcawSdpwUR4hE6H6Rl+xLkaH7+Pv+myY4H38JAmKUo4i5gYv7xgZXTv/fECDlRgBbL4
         uXCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVtdiJZZJkLxiGGSab73EkuWAHs03Q2npCg5mgokCbxzz3xEacM
	sGXMoNdakh7U07essw0/DGWzIonN1q4N9OT05gepx6lGei30Ybt68goa7FxsL+A4pqq2YI6DOY/
	nKQIVHCEB6zpHqdlaH3zrZsNz1xZGS1G1klTlzLJN/yxyEOpMc7BknfXfdmxsMSm5Jg==
X-Received: by 2002:ae9:e109:: with SMTP id g9mr3698317qkm.251.1553034291625;
        Tue, 19 Mar 2019 15:24:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYocL4yVfnhBrAcOwt4nUqIIei4X2bUbHLgvg8SGgz5Rs0hsOQx+tVAucSrmDTMQUcFnG1
X-Received: by 2002:ae9:e109:: with SMTP id g9mr3698280qkm.251.1553034290804;
        Tue, 19 Mar 2019 15:24:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553034290; cv=none;
        d=google.com; s=arc-20160816;
        b=is95o8NUEYsku13p/Jx0Og7hBpj7DIkqudRqrj92jxZjf8HzR4YGEnh01lXenY03H/
         VT8wJBQjpQMJbmdt5fn2p9sq1Y38UesTcbCQo5ud6a841loFVe+udIWEr42D8hViswKN
         YVu1MUEIq+jKhZhxa8CBd+QmFEjSB0GK3JlgCMpxt9cXdsJ435IZUN3PET5eoWMnt/t0
         Yy9YAFeZQc1F8c1WVJ37HHRcKWdsPTx+L6vEAP4TbZZsgSoEtQIzfFKzqD/vXPuy8YeS
         lYcYEX8hv3r6f5hwCloMNEtFZAt9kAOOa5vv2tNNoh/ucgmuj4T1kRJhRpX+jA7gsjyU
         JbjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=5hI6O0igr3c8ij5FVAHmWrRtF7GSn1W6INSTApOKnXE=;
        b=cxqGwt7JXxr9T3dsdIlAJE06PBQykC9gLeOcEviky8xxinHfZBwgwLFniSkopL0kdm
         YEHQxvXGp2jkYIkACRLpt5T07aVI3Lfyf0gznVXqkjoZ6bMuW1/f9hy+XNZFpqUFM10L
         3vtGkaz/cUftmO5wXfrCwmGouyQenRuGWLxhRQEgrV1Z4uH/IdGq5RaiDe3SwbxDxXqm
         v25Hhg5RPogzg/wzfClwgFNvr5aUNMTtcHSyWtzJzGXwKbH1j2dPAAjete7uXRhy/emN
         osuZA5V8OFroAgWEwRsKIlz3GZmd37tDNskfF4+MBo7ydLHxUvb2uFB30tqipW8/i5J4
         pncw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i6si11280qvj.31.2019.03.19.15.24.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 15:24:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DE214307EA90;
	Tue, 19 Mar 2019 22:24:49 +0000 (UTC)
Received: from redhat.com (ovpn-120-246.rdu2.redhat.com [10.10.120.246])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C2E2B60148;
	Tue, 19 Mar 2019 22:24:47 +0000 (UTC)
Date: Tue, 19 Mar 2019 18:24:45 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
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
Message-ID: <20190319222445.GD3096@redhat.com>
References: <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
 <20190319165802.GA3656@redhat.com>
 <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
 <20190319171847.GC3656@redhat.com>
 <CAPcyv4iesGET_PV-QcdBbxJGgmJ_HhoGczyvb=0+SnLkFDhRuQ@mail.gmail.com>
 <20190319174552.GA3769@redhat.com>
 <CAPcyv4hFPOO0-=v3ZCNFA=LgE_QCvyFXGqF24Crveoj_NTbq0Q@mail.gmail.com>
 <20190319190528.GA4012@redhat.com>
 <CAPcyv4hg5Y_NC1iu56zcznYkCRnwg+_7bGFr==7=AC6ii=O=Ng@mail.gmail.com>
 <20190319141826.GJ7485@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190319141826.GJ7485@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 19 Mar 2019 22:24:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 07:18:26AM -0700, Ira Weiny wrote:
> On Tue, Mar 19, 2019 at 12:13:40PM -0700, Dan Williams wrote:
> > On Tue, Mar 19, 2019 at 12:05 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > >
> > > On Tue, Mar 19, 2019 at 11:42:00AM -0700, Dan Williams wrote:
> > > > On Tue, Mar 19, 2019 at 10:45 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > >
> > > > > On Tue, Mar 19, 2019 at 10:33:57AM -0700, Dan Williams wrote:
> > > > > > On Tue, Mar 19, 2019 at 10:19 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > > > >
> > > > > > > On Tue, Mar 19, 2019 at 10:12:49AM -0700, Andrew Morton wrote:
> > > > > > > > On Tue, 19 Mar 2019 12:58:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> 
> [snip]
> 
> > >
> > > Right now i am trying to unify driver for device that have can support
> > > the mmu notifier approach through HMM. Unify to a superset of driver
> > > that can not abide by mmu notifier is on my todo list like i said but
> > > it comes after. I do not want to make the big jump in just one go. So
> > > i doing thing under HMM and thus in HMM namespace, but once i tackle
> > > the larger set i will move to generic namespace what make sense.
> > >
> > > This exact approach did happen several time already in the kernel. In
> > > the GPU sub-system we did it several time. First do something for couple
> > > devices that are very similar then grow to a bigger set of devices and
> > > generalise along the way.
> > >
> > > So i do not see what is the problem of me repeating that same pattern
> > > here again. Do something for a smaller set before tackling it on for
> > > a bigger set.
> > 
> > All of that is fine, but when I asked about the ultimate trajectory
> > that replaces hmm_range_dma_map() with an updated / HMM-aware GUP
> > implementation, the response was that hmm_range_dma_map() is here to
> > stay. The issue is not with forking off a small side effort, it's the
> > plan to absorb that capability into a common implementation across
> > non-HMM drivers where possible.
> 
> Just to get on the record in this thread.
> 
> +1
> 
> I think having an interface which handles the MMU notifier stuff for drivers is
> awesome but we need to agree that the trajectory is to help more drivers if
> possible.
> 

Yes and i want to get there step by step not just in one giant leap.
It seems Dan would like to see this all one step and i believe this
is too risky and make the patchset much bigger and harder to review.

Cheers,
Jérôme

