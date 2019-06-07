Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96033C28EBB
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 00:25:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5756C21019
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 00:25:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5756C21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE6856B0301; Thu,  6 Jun 2019 20:24:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C95AC6B0302; Thu,  6 Jun 2019 20:24:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD29F6B0303; Thu,  6 Jun 2019 20:24:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59B666B0301
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 20:24:59 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id v188so44134lfa.20
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 17:24:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=jjpV/GVZC7/6NIkIkxAR62f8LfbTURZiuQDu/JwjMc4=;
        b=FVVdg8nV1pk4hwBhAh4oTLEpXvYEVTrid78muOPiB2eWHW9AljhAL3et5Ax1z8Hx0J
         wAlc8CtOtP4wfZW95XkBSM6dWgzHRKVJzFYUkxKYjsdUCRMZuY2ZetDaz/mvGmFkmdMf
         fHQeFmlJKY90MvRITj4byZLjFBPL4xVOxKPGvv43m/5hlkKwlVBWQiqr2ldVY+omDfDp
         QvGzF9Rep5qzmaU7WeJh4VJ9gusZT+i9wj4QhCym6fpgTq01Qcf4e4F7sWHT0cLhLkNs
         ePczWYMs+2MGH4E2zdCXxdWnY3JOfBZpCR8gt1hQmc3xeZIiSc2EB2LyTzVVs+zB+joZ
         kWpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcroce@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVHP02A2kOGSggl/1MBspkIoOl9mSawFTL83FWSd69cNGStDRA3
	mrP00Scv/nvHuPbV7+OnCb7YAYyTB/3DG2EcukYr8UjUhawY8N5bIGb+ePa/c2ZRRL0nUlIabzi
	Xy+QRxuR7XBfQxK1CCal6PW8v6ajXwaiQR+jfhwncgvf+Wkkkp3LhBn+YcZD9Nf8u1w==
X-Received: by 2002:ac2:48a5:: with SMTP id u5mr19063570lfg.62.1559867098242;
        Thu, 06 Jun 2019 17:24:58 -0700 (PDT)
X-Received: by 2002:ac2:48a5:: with SMTP id u5mr19063543lfg.62.1559867097058;
        Thu, 06 Jun 2019 17:24:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559867097; cv=none;
        d=google.com; s=arc-20160816;
        b=eidgVejXwCGw6tSVhVbDCHFtkr00YVC7R81uAZvxTwp+TJrWooss3OaEqku2dPY9be
         LDAt/1sxlCkN7P/kmUu4RxjW/giKI/0x8ECJz6BIsp2YVEAOKEGp/qIY20mSkoV8QDe4
         Lodgo+Uk1gOUB0GKafMFUWHDnBpY133V7YZG2/P+npMKJdd9/iRidrT89cl6DpRopXCN
         pdX83Gkc8f8gAaPFn+Y796lA/STJ9+PScq6lsIz9XFFqCWQEwyEq1r1XnGGZ8z1Y+tHm
         sqw5gD830q0MdB4yWoNw0zjMI2OOTydN71jJnXT3GQsjaTziWOjVDDAKc8cxk3fESuaB
         gknw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=jjpV/GVZC7/6NIkIkxAR62f8LfbTURZiuQDu/JwjMc4=;
        b=iSKCL4cdJcoOxRy1mWQq3AEaCJwSQVz3JgDS32V2QKVs24s7BdpNXrjLlBz8RAd2Eq
         lnz4oenoLFgr3w2OGj7iDVioc1W5/Bq2fQbAoq31ZLVKE25kWSHSm7g98ODISwswcVkw
         bAdvOlqk602RGEwdMsH051Q8zJvqJ9jzkT371YtIP18Uv3yga3CJPDufB3smuPo+Z1v3
         GdS8ENa/cS6V2X3MGkWvzQ6tH+F3grnDki0yaarsvLvw4qH11sx24pyuqkVtPKO2IYiK
         PW91wZobFM2hfQ9ziz1SbkW9ALbTF/KwbI542iqOK5rMWn7deJxON7/dmaCkd5mPy4LU
         6N6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcroce@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9sor237806lji.7.2019.06.06.17.24.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 17:24:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcroce@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwugrE+HvpR1/J4UXMXJZT0jDeaBBB2NZMXth8iUXpfhZxwaHA9es7vfuwPufY+SwVTgs5F2CrkwWpGfygSiyg=
X-Received: by 2002:a2e:83ca:: with SMTP id s10mr22921626ljh.163.1559867096646;
 Thu, 06 Jun 2019 17:24:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190530035339.hJr4GziBa%akpm@linux-foundation.org>
 <5a9fc4e5-eb29-99a9-dff6-2d4fdd5eb748@infradead.org> <2b1e5628-cc36-5a33-9259-08100a01d579@infradead.org>
In-Reply-To: <2b1e5628-cc36-5a33-9259-08100a01d579@infradead.org>
From: Matteo Croce <mcroce@redhat.com>
Date: Fri, 7 Jun 2019 02:24:20 +0200
Message-ID: <CAGnkfhyO0gtg=RGUMGHYH43UhUV1htmqa-56nuK2tt_CACzOfg@mail.gmail.com>
Subject: Re: mmotm 2019-05-29-20-52 uploaded (mpls) +linux-next
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, broonie@kernel.org, 
	linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm@kvack.org, Linux Next Mailing List <linux-next@vger.kernel.org>, mhocko@suse.cz, 
	mm-commits@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, 
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 5, 2019 at 12:29 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>
> On 5/30/19 3:28 PM, Randy Dunlap wrote:
> > On 5/29/19 8:53 PM, akpm@linux-foundation.org wrote:
> >> The mm-of-the-moment snapshot 2019-05-29-20-52 has been uploaded to
> >>
> >>    http://www.ozlabs.org/~akpm/mmotm/
> >>
> >> mmotm-readme.txt says
> >>
> >> README for mm-of-the-moment:
> >>
> >> http://www.ozlabs.org/~akpm/mmotm/
> >>
> >> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> >> more than once a week.
> >>
> >> You will need quilt to apply these patches to the latest Linus release (5.x
> >> or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> >> http://ozlabs.org/~akpm/mmotm/series
> >>
> >> The file broken-out.tar.gz contains two datestamp files: .DATE and
> >> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> >> followed by the base kernel version against which this patch series is to
> >> be applied.
> >>
> >
> > on i386 or x86_64:
> >
> > when CONFIG_PROC_SYSCTL is not set/enabled:
> >
> > ld: net/mpls/af_mpls.o: in function `mpls_platform_labels':
> > af_mpls.c:(.text+0x162a): undefined reference to `sysctl_vals'
> > ld: net/mpls/af_mpls.o:(.rodata+0x830): undefined reference to `sysctl_vals'
> > ld: net/mpls/af_mpls.o:(.rodata+0x838): undefined reference to `sysctl_vals'
> > ld: net/mpls/af_mpls.o:(.rodata+0x870): undefined reference to `sysctl_vals'
> >
>
> Hi,
> This now happens in linux-next 20190604.
>
>
> --
> ~Randy

Hi,
I've just sent a patch to fix it.

It seems that there is a lot of sysctl related code is built
regardless of the CONFIG_SYSCTL value, but produces a build error only
with my patch because I add a reference to sysctl_vals which is in
kernel/sysctl.c.

And it seems also that the compiler is unable to optimize out the
unused code, which gets somehow in the final binary:

$ grep PROC_SYSCTL .config
# CONFIG_PROC_SYSCTL is not set
$ readelf vmlinux -x .rodata |grep -A 2 platform_lab
  0xffffffff81b09180 2e630070 6c617466 6f726d5f 6c616265 .c.platform_labe
  0xffffffff81b09190 6c730069 705f7474 6c5f7072 6f706167 ls.ip_ttl_propag
  0xffffffff81b091a0 61746500 64656661 756c745f 74746c00 ate.default_ttl.

If the purpose of disabling sysctl is to save space, probably this
code and definitions should all go under an #ifdef

Regards,
-- 
Matteo Croce
per aspera ad upstream

