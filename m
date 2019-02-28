Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B311C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 23:56:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03A502087E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 23:56:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="EGCp7Q7n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03A502087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80E558E0003; Thu, 28 Feb 2019 18:56:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BDEC8E0001; Thu, 28 Feb 2019 18:56:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 693DF8E0003; Thu, 28 Feb 2019 18:56:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 403038E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 18:56:11 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id j205so9790438oih.9
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 15:56:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=uERLKdxddlDUmJblszVciWCaFSRB2PW3RWK+BP8ZSsU=;
        b=DhlEB1rhNqNhNRW1ENeCVdKsq6EWejyARCbENvu6m0aatYnsGpVLYmOlQTVu350VB9
         jQweObFogCVzAPE37l8InxLndpZxJ8X+hmK7sEOrfupXo5XPucDLhlTuV0ZmLrYJDDi9
         2MFqE2vkbTpICEnrKzHBNFKiddm468FGbaJTkwH+yw/I2Kz9Hzek3iy+doD4d92Z6/zX
         PzzvlNihXt5du13Fqjv7K2MCC1OP6CUOxXNawNBXPjzFc206MlUJXDfn1dDKKF1V/cAl
         DLUJq1JbV2kG7tm2hmEEZ5RENVYQcPBwJv5qiV1FV50Q/V3xuKlvWl0Bb8OavP3RF5ID
         Pqgw==
X-Gm-Message-State: APjAAAXB5C6YKO+6BNv1Dqdu46IAl8ZEKSdWtCN4iwqb8Kvc3WUosuty
	28e5tCvZ7VlXEVJy5R+QJXEu5i6hAAv38tITt+Apgr8fZ2f56QJUTVy1l3hvp6IZv/RitoSYcDu
	npCNtdmbS6lxY10iQZuQPqoC3jHmg6FkF1B+m2EX+QkEXb7GkLTNIRf1C873naz6omyAXF8PvN7
	GxVcLIvdwI2HOuFDK/TtDG/TgJ6/kJ/qmp7QC+0tLtLWKY1GGFKM7k2jy5BezyRVv8HE/eCd4C1
	nkTQ+a/63RrHcGvfqooVJguHGm/35YZ4zi+BSa70Fpaq/9bnIsX3zghnnZIruApHhOi+DOvk+VE
	O19oMquT0YyEilJgTCXuqhD284AYiAHEOoJOsEznmCe3hwLmPZn120+qmt682PA4x7ygt2FrLr7
	H
X-Received: by 2002:a9d:7602:: with SMTP id k2mr1533774otl.357.1551398170784;
        Thu, 28 Feb 2019 15:56:10 -0800 (PST)
X-Received: by 2002:a9d:7602:: with SMTP id k2mr1533735otl.357.1551398169554;
        Thu, 28 Feb 2019 15:56:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551398169; cv=none;
        d=google.com; s=arc-20160816;
        b=biIIRXGVKAqeFFgdgz2Bu5X9GBRb1oopPcpSSsfewZyeXxzQD6HQ+YPkcLnyGIw4J0
         2f4ZUAsYO+0TMdEE6Q+8pysbX7kNC3nvCmLLOP5xd5Quev+D5GOuwN0B2KK/KJOrN1sX
         lWOeS4hq2L2m9X2ITzE9vXOMF+KFvaYZeUqjJgaPILPEZHxFSWsWeCxnFlG/qisWKqp0
         1eeFyjZy8e28Avt/TXkXCmrObQrUFe+o7JOqa4tUUQKUaN+q192kvVSJW7xFRgrxJc5N
         SYosrM3uFXtHRUEY9CkH9GG6UR+UfgEg5Kno0g4yozFLuYgI0mvObkJefyNmoBSqZSUG
         cEAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=uERLKdxddlDUmJblszVciWCaFSRB2PW3RWK+BP8ZSsU=;
        b=qTxRgmNxbv34fEBMnAZ2mQ9iWOIia+XbhVAvmxkYMLoJF6KacXMHZUHjqLkYx1OaGZ
         D3Nkx5Q7ACele3HDf+oX3j+IAVc35PvCDu1o+AAvRdXQ2Jj8cOqzR3rWAkoJLEyHwv4l
         6tiTNwSU0CE3xR6CiYgpA/Ta/bR76x8jqrMQGCcpMplXJKHDwk+ntAIf47mEk22prwgW
         GFWcdAg23t8sETSvaqXQeNKxBVPVP9TMlGi64ZGM0Vg6vf9zQofzfrE7o5MbC1DFEMdX
         Dfe801oikvvZdF1GjG6+vOBT1Lr3gfee+1xsXpkmcv9lh26H/RvInwcNeKU7l1FY4NEQ
         UMSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=EGCp7Q7n;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v126sor9422679oie.101.2019.02.28.15.56.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 15:56:09 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=EGCp7Q7n;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uERLKdxddlDUmJblszVciWCaFSRB2PW3RWK+BP8ZSsU=;
        b=EGCp7Q7n1qKJ1I8XM59ZgdiZ69fefYWbcALHIz/rmNAz1BI1AtFlaoRcHCO1OuhArI
         UbO5IVqSohO/zBsgYoWyvgKMw3ZD4WLR5D9lnsoRLYkZvj/IQ8+zrwCXpRSR6cqzNNfK
         yr3tm0bDnvjELQyA7bh0juxUwbvGhmYRFUPL89npUioIQld1mxpqk7aaUCbpmmrZyyIy
         b0be3jXU+MUt/oeqB8UziuWx5ZMyp52bUeNpb9ExF1fVXNdaEf/O90hSEwWfFmTbkJSM
         odWuNpcEwU6dIpsOMn8nqqxlSEByu1Si8rd2k4DYlA156WmD0D41zpEsIpeU+5NdluUs
         tLvA==
X-Google-Smtp-Source: AHgI3IYwCchoLH3Wwe6rNTWF9xU4YpN1DXRKUzvI+0jK+ayx/oEgCTjUfXt4uS7RGHmAP07O3BqHkKJqrIPkyu8JL2M=
X-Received: by 2002:aca:3906:: with SMTP id g6mr1575935oia.149.1551398168978;
 Thu, 28 Feb 2019 15:56:08 -0800 (PST)
MIME-Version: 1.0
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com> <20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
 <20190215185151.GG7897@sirena.org.uk> <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com> <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
In-Reply-To: <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 28 Feb 2019 15:55:57 -0800
Message-ID: <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Brown <broonie@kernel.org>, "kernelci.org bot" <bot@kernelci.org>, 
	Tomeu Vizoso <tomeu.vizoso@collabora.com>, guillaume.tucker@collabora.com, 
	Matt Hart <matthew.hart@linaro.org>, Stephen Rothwell <sfr@canb.auug.org.au>, khilman@baylibre.com, 
	enric.balletbo@collabora.com, Nicholas Piggin <npiggin@gmail.com>, 
	Dominik Brodowski <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Kees Cook <keescook@chromium.org>, 
	Adrian Reber <adrian@lisas.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, 
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Michal Hocko <mhocko@suse.com>, 
	Richard Guy Briggs <rgb@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 3:14 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 26 Feb 2019 16:04:04 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
> > On Tue, Feb 26, 2019 at 4:00 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > > On Fri, 15 Feb 2019 18:51:51 +0000 Mark Brown <broonie@kernel.org> wrote:
> > >
> > > > On Fri, Feb 15, 2019 at 10:43:25AM -0800, Andrew Morton wrote:
> > > > > On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kernelci.org> wrote:
> > > >
> > > > > >   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
> > > > > >   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
> > > > > >   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html
> > > >
> > > > > Thanks.
> > > >
> > > > > But what actually went wrong?  Kernel doesn't boot?
> > > >
> > > > The linked logs show the kernel dying early in boot before the console
> > > > comes up so yeah.  There should be kernel output at the bottom of the
> > > > logs.
> > >
> > > I assume Dan is distracted - I'll keep this patchset on hold until we
> > > can get to the bottom of this.
> >
> > Michal had asked if the free space accounting fix up addressed this
> > boot regression? I was awaiting word on that.
>
> hm, does bot@kernelci.org actually read emails?  Let's try info@ as well..

Thanks, yes. The logs don't give much to go on, so I can only iterate
on this as fast as I can drum up feedback.

>
> Is it possible to determine whether this regression is still present in
> current linux-next?
>
> > I assume you're not willing to entertain a "depends
> > NOT_THIS_ARM_BOARD" hack in the meantime?
>
> We'd probably never be able to remove it.  And we don't know whether
> other systems might be affected.

Right, and agree. I was just grasping at straws because I know of
users that want to take advantage of this and was lamenting the
upcoming apology tour saying, "sorry, maybe v5.2". I had always
expected that platforms outside of x86-servers would need to do their
own validation / evaluation before recommending this, and the
regression concern is why it defaulted to disabled... but boot
regressions are boot regressions.

