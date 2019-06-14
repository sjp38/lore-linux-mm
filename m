Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90C4DC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DACB2183E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:14:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="sTwfKZMS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DACB2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C774A6B0269; Fri, 14 Jun 2019 13:14:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C25276B026A; Fri, 14 Jun 2019 13:14:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AED846B026B; Fri, 14 Jun 2019 13:14:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 873A56B0269
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:14:19 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 80so1446003otv.1
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:14:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1DOR0lfku3yUBhnRNWEqeIw9f7cV+CNTtUVXtGntF+g=;
        b=JrFv16i5wDZfzOavVw/C8sfHuamBdFagUtX/DKzAP+dlLswxEpNWCyTu5ho2UgivlO
         0PUACwory8iRAvNkUQ7hOZrGUzw8VxD+AxhPsfSCDYyoZIZZpKgIaM5Vm30DG9P8zv/C
         Ey7mY11ntNx8cTauiOWVBMd7EKrqOoWZlj+Z/C3uXy2yq6wGCJT8AlOSYNxHU0rRXYNI
         BjQfWi15K9OxoU8QwF5JPqbK6lHLBOFpmaCd9wEHu2ZsgtlAnMQMGhlkyCXL787lQg63
         tYZUqsqnCPaO4pHaeOWrcLZjthDUPUr37ctTSB8TjlD/BmFV9ePBq1c0P9iRzIhD6rIF
         mHzA==
X-Gm-Message-State: APjAAAUNUwmYa0hhwX8MHOItA3Qttv/Tkoea98ZZoRjEDlEUvQIj85JS
	x94LQJ9vhXqeBqoxEdOeNqzaTb9x3PB2mZr1w+z6CQsJhN2Kn2S32whoLoTa+BYsNXEB7Omk1oB
	Ksxce+j7lN31eawgpZbkH1KmtPTJp/d/LSzyGAK7vlZwANUqvmMWbpsePb3ki7xizXQ==
X-Received: by 2002:aca:4404:: with SMTP id r4mr2471407oia.130.1560532458787;
        Fri, 14 Jun 2019 10:14:18 -0700 (PDT)
X-Received: by 2002:aca:4404:: with SMTP id r4mr2471388oia.130.1560532458192;
        Fri, 14 Jun 2019 10:14:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560532458; cv=none;
        d=google.com; s=arc-20160816;
        b=k09pxZGCtfO9w9TmwQ6iZ7gCxXG5gGj5VZZEbKc+aDMEFSvMxboTGNGuf7SsSUCgnE
         XbZAi++jy3Pi2OGBq17R7+0rsMd+4VFe0sUXz/dg4TYMYhHAtlk2qm0Q0L6XIK68VqX1
         nzgxvDNEIFcLCM+tR+z2HRSlK3GCW+6+s3+BDcecsV6XF7gLn9cNuesV9WJOPtNioQoH
         WCWd9Ij5TOxRCCpta7Hnlar4syWOnFDqwIAz/zkHBcI/Pr6aRk443LAh8hSrpcWTbKG4
         MZGL1rdokS2H/htJ4ctx1PyfbakOaA07d9BJqylAzEio5y2hBg0Lzs8br4Sxp333bb71
         oEtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1DOR0lfku3yUBhnRNWEqeIw9f7cV+CNTtUVXtGntF+g=;
        b=AIcetw6pthrsa2EOPUm2pTIcYmh0pesWo51jfD3iqakXTWHtWnmHi8h6upNy267yN0
         1g3rvPhZoj4GOLxIwNH79wNT9stbHkTb+SBoyeP63uIutW8fr1BzbyoAk/1SCxhhifRa
         tgvTBziGcSMcD0AhNFUohCO0S74PQ4pZ+slssCSOdgOTh2CdUalI2L0PssWqptNdf485
         K5OTnI/PdTDubMnGZF6YhRGdV43m3nzrywyZ9i2EkpVgQvY0u0WMQnzyewLYFOzQrODt
         u1AQh7q+EnEjkwzX7Y3MbOlFuRgSROSstDm6pN07QvogaEeEtstW8nNoK5vSMJ0Hb0rp
         0sVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sTwfKZMS;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3sor1906068otc.90.2019.06.14.10.14.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 10:14:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sTwfKZMS;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1DOR0lfku3yUBhnRNWEqeIw9f7cV+CNTtUVXtGntF+g=;
        b=sTwfKZMStgwHohmnokMWPy+VfqEaV8lW2lueb7v8fb896+Vc0aKVzpBH0A2lEJlw6q
         oALCiHx77zWRNARo52nz8z+FNUxgUwVgBG+v1ofG044GSZOat+JTG9E2WNwyxxib8AG2
         gpjqossClsMvuhpes7lVdiSsvyVheT+RRZNuZS9QKm7gxXA0LXlU62z/ZeDVSIkaSKLG
         q2xdj1lK+22SHsQoDVfk25zVhm3/u/GXGDlHpOQpCSDX6j/uZMH4LMgtT9/w9S6/Uurk
         O8qQF4zoQsEqPbLE2I2goSlCiHkrB1+UDrJXIaIzjBrMd5fRfGm+SSdXADa62AeNqAyv
         0hiQ==
X-Google-Smtp-Source: APXvYqxVUrlRlBzkiByeoyFdu4dQhtacOwZjB+QoHRf7avUupN3JCPic2FiiSx+ZwD9EBq9qIkKVUnOWHfb//Vf+hT8=
X-Received: by 2002:a9d:7248:: with SMTP id a8mr5283755otk.363.1560532457937;
 Fri, 14 Jun 2019 10:14:17 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
 <20190614153535.GA9900@linux> <c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com>
 <CAPcyv4j_QQB8SrhTqL2mnEEHGYCg4H7kYanChiww35k0fwNv8Q@mail.gmail.com>
 <24fcb721-5d50-2c34-f44b-69281c8dd760@linux.ibm.com> <CAPcyv4ixq6aRQLdiMAUzQ-eDoA-hGbJQ6+_-K-nZzhXX70m1+g@mail.gmail.com>
 <16108dac-a4ca-aa87-e3b0-a79aebdcfafd@linux.ibm.com> <x49ef3wytzz.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49ef3wytzz.fsf@segfault.boston.devel.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Jun 2019 10:14:06 -0700
Message-ID: <CAPcyv4iADcyPP4su4tMnyMp8_uiBu8BYCSOjOgck8hE0ZPzLmg@mail.gmail.com>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: Jeff Moyer <jmoyer@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Oscar Salvador <osalvador@suse.de>, Qian Cai <cai@lca.pw>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 10:09 AM Jeff Moyer <jmoyer@redhat.com> wrote:
>
> "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
>
> > On 6/14/19 10:06 PM, Dan Williams wrote:
> >> On Fri, Jun 14, 2019 at 9:26 AM Aneesh Kumar K.V
> >> <aneesh.kumar@linux.ibm.com> wrote:
> >
> >>> Why not let the arch
> >>> arch decide the SUBSECTION_SHIFT and default to one subsection per
> >>> section if arch is not enabled to work with subsection.
> >>
> >> Because that keeps the implementation from ever reaching a point where
> >> a namespace might be able to be moved from one arch to another. If we
> >> can squash these arch differences then we can have a common tool to
> >> initialize namespaces outside of the kernel. The one wrinkle is
> >> device-dax that wants to enforce the mapping size,
> >
> > The fsdax have a much bigger issue right? The file system block size
> > is the same as PAGE_SIZE and we can't make it portable across archs
> > that support different PAGE_SIZE?
>
> File system blocks are not tied to page size.  They can't be *bigger*
> than the page size currently, but they can be smaller.
>
> Still, I don't see that as an arugment against trying to make the
> namespaces work across architectures.  Consider a user who only has
> sector mode namespaces.  We'd like that to work if at all possible.

Even with fsdax namespaces I don't see the concern. Yes, DAX might be
disabled if the filesystem on the namespace has a block size that is
smaller than the current system PAGE_SIZE, but the filesystem will
still work. I.e. it's fine to put a 512 byte block size filesystem on
a system that has a 4K PAGE_SIZE, you only lose DAX operations, not
your data access.

