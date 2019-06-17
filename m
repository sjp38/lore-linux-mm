Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98BB5C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:16:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62F2921BA1
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:16:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62F2921BA1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED3798E0004; Mon, 17 Jun 2019 03:16:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5D1F8E0001; Mon, 17 Jun 2019 03:16:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D24D48E0004; Mon, 17 Jun 2019 03:16:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82FEE8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 03:16:09 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n49so15077234edd.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:16:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=16vsw6bIN0Mc1UCAUBB57CouRv9aYfeYS0t4pUi8PaM=;
        b=cfECTIUKvsYr1L/gFlCL+7CV9rGexRVCX+zFpwy1hy7KH41pBUguzQ8nRtl+kY3MzS
         PMz43eyPmvPVrGkhoz8ci2P0rwgLS44O7CAqB2apeaSvTwcBrpuyRuzKqPey/s9nqTEo
         gVHrNUz/KfZhpgfAH6in/i0NH2qYww+DSOfFDO9HSqTcLBNFoKh3hOh8lr4uPD5B7G9m
         5YvAUhaxmXpO2ZOc56VwPtwLBMOJLSE97HWRYwnlCkC6lZxJg1O2z+x1SV0pODT3uNy4
         tRj0oqlMrOHYgA92fDd5FEyyAYABX16fWlsXhPqGiAlRN0ErS0IT3uGmIvCUTtx2e60+
         uIDg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUxj3MS4jsVTqpXcL/RAvsV9i5cRbJRcUT65ywSlX0gHnEL0kOX
	5ECbFFEhoKU8YUudfUfocQM/RE4YASd+L0u1tnXU08hEZEJMn5vGUzXVmw6BgrRXHkzxk++gMnc
	WIoxoJe4kBLNtHov5XYxNHW2+Mq4Rwe3v9gjqtltBAY4oPdNeAhHKzyl0lQbSvMI=
X-Received: by 2002:a17:906:a950:: with SMTP id hh16mr94082540ejb.136.1560755769117;
        Mon, 17 Jun 2019 00:16:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzENU6as/YmCKyLdi1gH+fbSO4EwGd279Q4esTNhGqQ2yihPAZXSCzckGKCH93Ybv9zBx+o
X-Received: by 2002:a17:906:a950:: with SMTP id hh16mr94082488ejb.136.1560755768467;
        Mon, 17 Jun 2019 00:16:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560755768; cv=none;
        d=google.com; s=arc-20160816;
        b=t+5Za3glzYXIXzryAAmFvP7EWpqeDZw4xMJE14ETVj0SR0CquzNvaWmY1Ov8eK8SmV
         wnXvBiPfFYY/bd8rkIJu6jKdyPjbD9gQh7U1EIEs9lS/oKVAPDbkSkKyEnx5nHFuK0CT
         cEdm3905q7XgArrj5gQDITUtD0vZWlzOI/3GRg3Rono8FhgoN2bkeQGIyFfxYj6TPdLB
         91GngNf6ZxLCuK4dmPAgcrVCfGqkH1ZMXrU6Oj+j9D2/oObHpZUq5je9z6iIIO/RlHGN
         FIQwwssmVNRkK0X84dKh1nUmPsKdAAp4yZGsi3mfDzLQ96VhFhxumBMhZ3HvCtGBQgYd
         V7OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=16vsw6bIN0Mc1UCAUBB57CouRv9aYfeYS0t4pUi8PaM=;
        b=yjUMADpSNI/8Qiz4ivuEd59e7rt2gdYWEgcjoM3ysDL7iYDTzU5XuvxeQZYHU7PH+r
         rEdoulNOiaeoVOnqAZ0SVl+zmCDLPGyS/OzLNU2u6s+mZB/souLp5YOcW+CwjbRDbxCj
         egXkPTBbZE3KoZmUJ+Zeyd6ZAggM8P9hl6tW2VH8sDiXweS2sMnxBC/Oc2aR3VcC3B6/
         kvEe2QdBj4U0toVIJTkM1CnYdCpe571t9qSXxkjHxAStCBhPt8JGAoAry7XZl8ww1KKh
         yQGIVaTUF2aXnIpprj1lXbhGyi2NrDnuJEAnXiMUFFmDP2rwknA8EEpKf9b727ozji9A
         ewzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si6455001ejj.37.2019.06.17.00.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 00:16:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 64B4CADAB;
	Mon, 17 Jun 2019 07:16:07 +0000 (UTC)
Date: Mon, 17 Jun 2019 09:16:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Arun KS <arunks@codeaurora.org>,
	Mukesh Ojha <mojha@codeaurora.org>,
	Logan Gunthorpe <logang@deltatee.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org,
	Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Baoquan He <bhe@redhat.com>, David Hildenbrand <david@redhat.com>,
	Josh Poimboeuf <jpoimboe@redhat.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Oscar Salvador <osalvador@suse.com>, Jiri Kosina <jkosina@suse.cz>,
	linux-kernel@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 5/5] mm/hotplug: export try_online_node
Message-ID: <20190617071605.GD30420@dhcp22.suse.cz>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-6-alastair@au1.ibm.com>
 <20190617065921.GV3436@hirez.programming.kicks-ass.net>
 <f1bad6f784efdd26508b858db46f0192a349c7a1.camel@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f1bad6f784efdd26508b858db46f0192a349c7a1.camel@d-silva.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Jerome - email thread starts
http://lkml.kernel.org/r/20190617043635.13201-1-alastair@au1.ibm.com]

On Mon 17-06-19 17:05:30,  Alastair D'Silva  wrote:
> On Mon, 2019-06-17 at 08:59 +0200, Peter Zijlstra wrote:
> > On Mon, Jun 17, 2019 at 02:36:31PM +1000, Alastair D'Silva wrote:
> > > From: Alastair D'Silva <alastair@d-silva.org>
> > > 
> > > If an external driver module supplies physical memory and needs to
> > > expose
> > 
> > Why would you ever want to allow a module to do such a thing?
> > 
> 
> I'm working on a driver for Storage Class Memory, connected via an
> OpenCAPI link.
> 
> The memory is only usable once the card says it's OK to access it.

Isn't this what HMM is aiming for? Could you give a more precise
description of what the actual storage is, how it is going to be used
etc... In other words describe the usecase?

-- 
Michal Hocko
SUSE Labs

