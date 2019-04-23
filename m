Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91424C282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:19:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C9F62175B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:19:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C9F62175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1CC76B0003; Tue, 23 Apr 2019 12:19:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA35B6B0005; Tue, 23 Apr 2019 12:19:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6D386B0007; Tue, 23 Apr 2019 12:19:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 73ACB6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:19:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w5so7463028eda.16
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:19:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ShdelWa0SnJVuS9NeeHLECeve8FIaEzLn2zENZakrrI=;
        b=Qj/WNyAqpVujLxlNZE8W+7+YNeqr57AIctuX04tUqCZf06HW/zdS5rRgbngvyemCBu
         wjXe5a0gEFFXNPnuruFDdgsLzzf/fLWkawFiEjcClCdc8SgbeqQ9SLk29LS+2xJ08fSy
         Sr+GZY0oI2ZSi8Md7uMvuBpWE7ADKJ9uvz21b/3rBmEZ/s0ag01zAlJQDVLxJ0uy7Vj7
         6xzK5BhL3oyEHtXaliPrifK667cSgv+dDtkfYhDpMB15jsB6iR63Q0XUyH3LqjNlAWRN
         i9O1IVnYAdcT6JB7nzmQIZtFzoQLMdDxsuIIZ7bMvNmldWPQN7ELd2+7t4x3OLXUnSbJ
         CvjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAXSqkofZ71uLV9vIVPBuHnmAaTx2CSPJqwBWuNHTdVzN9YF1fDV
	+yrlstg6rtWhgX/XFXd19A2uJAF6L/eBWpYIMDIzQwFOrNKrw7gc8rqkqLTUUwZhFazu0jO4eGq
	sQbvXMB2SOIWGRrQGrNV0LAuxOd2I4wINW/1WbA9JQ9VGBBTlPOIcMvlj6PzoUPKypw==
X-Received: by 2002:a17:906:bce2:: with SMTP id op2mr5078229ejb.105.1556036384001;
        Tue, 23 Apr 2019 09:19:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNSBi8f8V/b/UwGioozAn4HDl2LfM7cDFZCNwJeRu3J7iR5vQkmHvhcxMvWjN8fEJxZV37
X-Received: by 2002:a17:906:bce2:: with SMTP id op2mr5078188ejb.105.1556036383183;
        Tue, 23 Apr 2019 09:19:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556036383; cv=none;
        d=google.com; s=arc-20160816;
        b=JQ5l3dyvUw6tUBoMKk48iF6RajQ2gNyW3rJyHnw7bSrKsbn3xN0eSF1+WqnPsy+UVo
         HReih4ePICPA3Yfn2kfTS2oZO9/Z4tNT7XPGnutW2tibNce/cQDo24Z295B6goGQeBXj
         6L2rvZg3wmfxfpAZxcn76PZR+Rgxt9d6cCg3gT85cIpU1OiXDPydwqUo0z9q/hYJKYlv
         Ol5SYY8xEtFNjt+n6DD3HsRGDAHWa0HDgNq1SqPJISSqGfoZWplWEt3dkhIPZPEgqe50
         hcTdXxs3lgnYjVnTQ70xK1IQ4kMrGDCSKg05/I7GXa2Arauck7B+0yFeiYUCWNBFMmXc
         0iFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ShdelWa0SnJVuS9NeeHLECeve8FIaEzLn2zENZakrrI=;
        b=r289kTRUduLpn17I5kBEx9nhogwyi9tki189wwZG9zXoNEPi49CUQlo4Ynihq0Api9
         UBJMUXLOKC/vd9QEuI3UL9rHOkrk0VBEiTDRFZG+rHPZHh5ZrBSrA7/1nNuJOw/tPYDs
         5EXaV6rl1QQk9j0Y1gjqeWJun1Kipa8Lg1ZM9AP+Y0BXBJ+is0VSMmKdEAAsKdzK6gYr
         C/sQghTYIfFKfuZMK04LnMrnMmIZZkyveFSnoVI7nqWwqzec15/5HYFbZzdrnsIMFMSF
         B04gRS4a3u0Mp9Tlpb/PCR0SYchsKpVv8aoWEUi2nnVeDtpKszBo6vtPB9E1Rh5Z+AAs
         E2uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z11si177998ejp.297.2019.04.23.09.19.42
        for <linux-mm@kvack.org>;
        Tue, 23 Apr 2019 09:19:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C1AFD80D;
	Tue, 23 Apr 2019 09:19:41 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BD5F03F557;
	Tue, 23 Apr 2019 09:19:34 -0700 (PDT)
Date: Tue, 23 Apr 2019 17:19:32 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: Jerome Glisse <jglisse@redhat.com>, akpm@linux-foundation.org,
	mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name,
	ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz,
	Matthew Wilcox <willy@infradead.org>, aneesh.kumar@linux.ibm.com,
	benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 04/31] arm64/mm: define
 ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Message-ID: <20190423161931.GE56999@lakrids.cambridge.arm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-5-ldufour@linux.ibm.com>
 <20190416142710.GA54515@lakrids.cambridge.arm.com>
 <4ef9ff4b-2230-0644-2254-c1de22d41e6c@linux.ibm.com>
 <20190416144156.GB54708@lakrids.cambridge.arm.com>
 <20190418215113.GD11645@redhat.com>
 <73a3650d-7e9f-bc9e-6ea1-2cef36411b0c@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <73a3650d-7e9f-bc9e-6ea1-2cef36411b0c@linux.ibm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 05:36:31PM +0200, Laurent Dufour wrote:
> Le 18/04/2019 à 23:51, Jerome Glisse a écrit :
> > On Tue, Apr 16, 2019 at 03:41:56PM +0100, Mark Rutland wrote:
> > > On Tue, Apr 16, 2019 at 04:31:27PM +0200, Laurent Dufour wrote:
> > > > Le 16/04/2019 à 16:27, Mark Rutland a écrit :
> > > > > On Tue, Apr 16, 2019 at 03:44:55PM +0200, Laurent Dufour wrote:
> > > > > > From: Mahendran Ganesh <opensource.ganesh@gmail.com>
> > > > > > 
> > > > > > Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
> > > > > > enables Speculative Page Fault handler.
> > > > > > 
> > > > > > Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> > > > > 
> > > > > This is missing your S-o-B.
> > > > 
> > > > You're right, I missed that...
> > > > 
> > > > > The first patch noted that the ARCH_SUPPORTS_* option was there because
> > > > > the arch code had to make an explicit call to try to handle the fault
> > > > > speculatively, but that isn't addeed until patch 30.
> > > > > 
> > > > > Why is this separate from that code?
> > > > 
> > > > Andrew was recommended this a long time ago for bisection purpose. This
> > > > allows to build the code with CONFIG_SPECULATIVE_PAGE_FAULT before the code
> > > > that trigger the spf handler is added to the per architecture's code.
> > > 
> > > Ok. I think it would be worth noting that in the commit message, to
> > > avoid anyone else asking the same question. :)
> > 
> > Should have read this thread before looking at x86 and ppc :)
> > 
> > In any case the patch is:
> > 
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> Thanks Mark and Jérôme for reviewing this.
> 
> Regarding the change in the commit message, I'm wondering if this would be
> better to place it in the Series's letter head.
> 
> But I'm fine to put it in each architecture's commit.

I think noting it in both the cover letter and specific patches is best.

Having something in the commit message means that the intent will be
clear when the patch is viewed in isolation (e.g. as they will be once
merged).

All that's necessary is something like:

  Note that this patch only enables building the common speculative page
  fault code such that this can be bisected, and has no functional
  impact. The architecture-specific code to make use of this and enable
  the feature will be addded in a subsequent patch.

Thanks,
Mark.

