Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3789C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 09:35:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AB1C208CA
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 09:35:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="NZZkyhVj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AB1C208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04FB16B0003; Mon, 24 Jun 2019 05:35:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F40E08E0003; Mon, 24 Jun 2019 05:35:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2F988E0002; Mon, 24 Jun 2019 05:35:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A915F6B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 05:35:13 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t2so9025645pgs.21
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 02:35:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zGigdWoMEcqq0VEfxUDYzjTDj2dag+0a2I7hut2AaXc=;
        b=KDd6Ht6N4z4WU2+Hws9mf0wj2D8iZlKBAKG11rK+nd4UKTsHKGkc8e7NVai+9kEKP/
         opMU10aXoNXwNVMzdHLVxR5qVqtrkG5bHQcbzPgbWBUSo9j4Dy3Z6GhC+n5mQ02Xa00d
         G6EClQi7cpHF8pIr6XC1Hg2v709dcy5DSPwvg8C8xj1nmQK3kboVpoBwoIAzw7tpkPWO
         SnM9kkkJs4+qCxon5iQlHTOCrrNYqKDo2H5HpK+c4sf8Nw1nDLOTgTUePEpvdqhqAF4q
         oqKDGknM3j9F+cIKr7QohVmpE8ITwCAp4fYWnFAUZrQIfAwNhkFkIk6lPY8lHPoC5tYa
         VyRw==
X-Gm-Message-State: APjAAAW7GTMWCvgyGxDpolpRMEMLH4YYnUJUUUK71le6GVG0TmbbyVIy
	BhtYLAa1fDZYFJtaF6xFMJx2L7SsJJ7YX5LnsMwmrMalIM1f+Wc/2n5+H7wv77+kkCRoOj7ldAn
	z9fWL6QmXsf0PEpcu96SXxiJkapGOe+FS4ff7f9nm1reeFo5yVlSaUP08TMCldOKTIQ==
X-Received: by 2002:a17:902:b284:: with SMTP id u4mr6107320plr.36.1561368913206;
        Mon, 24 Jun 2019 02:35:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvcO+CAl/bXsBxtJVgI1w53yzwM5uouikxRsGSU4WIcWx0l/ZyXGaPM3iY/GmTxmgFqtFn
X-Received: by 2002:a17:902:b284:: with SMTP id u4mr6107264plr.36.1561368912435;
        Mon, 24 Jun 2019 02:35:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561368912; cv=none;
        d=google.com; s=arc-20160816;
        b=CSk7aI8tFgaLPgKrqKaV0WM5+EFcCb6u2pNj+QA2qTYLzFd51lqzKd3a8HJusynUZH
         4+SoWZ1vaxYijLy4WuIbpx7Z0QKa34nIOkze5KF16AmbEmvNVNeWJrE2UGHX1+yZ779J
         FDjrS9XBM7U5DQ6QqL6so5JP8+T46J+Y8LhX8AZH+8Khv7O7llyaTjPLTmH4VBJ+wAEE
         07DN+F+SpTD+9X6mDtyA4uXtx1mk194EQU+IM9fVIUzr34XByF6+GhdvOAsm7ho5hGsK
         5NFluj2jKiQrVmVNy5pjVNCPATiXkse6MSiATKGjBjqDjTIFE/bPEy3br73t+Wmk9FfT
         O+/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zGigdWoMEcqq0VEfxUDYzjTDj2dag+0a2I7hut2AaXc=;
        b=Bgdq/YOheGBPUNGs1lVJAaJ3cskg1osK86sy3cu7frnRcLBKJVIsTf3IE1+rSMZX21
         Iu+2Bv3BFm3oG+vtVqUUcke3v39u3rfKEWn+bEDYNifLL1VO7WRF5+aLSqwcunPwHN8n
         5QTOjGe2cn6wSCRVvFaIlI5w8JHZYP3EVR+CsKsYDgbZMO9jrFbqMaoXMRPQxbhhN7fC
         AwxPLS/+yMSHCEkTSfdjtXHkkokycieezmT6voJFDtmroEkvBWwpaJAKWAoqjcNDw7Kr
         OtEbIG87YpYUUiBvSDVp8nsP6bhoKXjPsJTiL3JhBcdG5fVWsrNdyw/Nn1A/fXM2VQo+
         XicA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NZZkyhVj;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o6si10808534pje.1.2019.06.24.02.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 02:35:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NZZkyhVj;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BB8EA2089F;
	Mon, 24 Jun 2019 09:35:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561368912;
	bh=V+JNcIbt/6VMBYdQNX/9snknRFUTiqfcznYN8RZhvtU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=NZZkyhVjPxs92xmMnw0gDIRG16eJWCsvHc7Hg5RDsDJmTCBhHEBTojZ9qQ98hKZWk
	 0+f3k5bX6F0Fkj813jbFbAW3IXULoD/yEAzXSX7dwjYgUVPKbDo/Z0piWvGWfN/gQt
	 JgMhb1xlGDR29eCwqhAeDu4J6YRFoheN3QL2EW70=
Date: Mon, 24 Jun 2019 10:35:07 +0100
From: Will Deacon <will@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: LTP hugemmap05 test case failure on arm64 with linux-next
 (next-20190613)
Message-ID: <20190624093507.6m2quduiacuot3ne@willie-the-truck>
References: <1560461641.5154.19.camel@lca.pw>
 <20190614102017.GC10659@fuggles.cambridge.arm.com>
 <1560514539.5154.20.camel@lca.pw>
 <054b6532-a867-ec7c-0a72-6a58d4b2723e@arm.com>
 <EC704BC3-62FF-4DCE-8127-40279ED50D65@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <EC704BC3-62FF-4DCE-8127-40279ED50D65@lca.pw>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000131, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Qian Cai,

On Sun, Jun 16, 2019 at 09:41:09PM -0400, Qian Cai wrote:
> > On Jun 16, 2019, at 9:32 PM, Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> > On 06/14/2019 05:45 PM, Qian Cai wrote:
> >> On Fri, 2019-06-14 at 11:20 +0100, Will Deacon wrote:
> >>> On Thu, Jun 13, 2019 at 05:34:01PM -0400, Qian Cai wrote:
> >>>> LTP hugemmap05 test case [1] could not exit itself properly and then degrade
> >>>> the
> >>>> system performance on arm64 with linux-next (next-20190613). The bisection
> >>>> so
> >>>> far indicates,
> >>>> 
> >>>> BAD:  30bafbc357f1 Merge remote-tracking branch 'arm64/for-next/core'
> >>>> GOOD: 0c3d124a3043 Merge remote-tracking branch 'arm64-fixes/for-next/fixes'
> >>> 
> >>> Did you finish the bisection in the end? Also, what config are you using
> >>> (you usually have something fairly esoteric ;)?
> >> 
> >> No, it is still running.
> >> 
> >> https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config
> >> 
> > 
> > Were you able to bisect the problem till a particular commit ?
> 
> Not yet, it turned out the test case needs to run a few times (usually
> within 5) to reproduce, so the previous bisection was totally wrong where
> it assume the bad commit will fail every time. Once reproduced, the test
> case becomes unkillable stuck in the D state.
> 
> I am still in the middle of running a new round of bisection. The current
> progress is,
> 
> 35c99ffa20ed GOOD (survived 20 times)
> def0fdae813d BAD

Just wondering if you got anywhere with this? We've failed to reproduce the
problem locally.

Will

