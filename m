Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 665D3C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:51:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D5BE2146F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:51:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D5BE2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7055C6B0269; Thu, 11 Apr 2019 16:51:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68DC46B026A; Thu, 11 Apr 2019 16:51:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 557D66B026B; Thu, 11 Apr 2019 16:51:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03B8D6B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 16:51:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p90so3720171edp.11
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:51:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=N4DmJGRpRMXC++KQt7GTKbLUBRCE4AHAAJo/0113FgU=;
        b=Pr1BfJfEFzixHLIdjP6Y1tKVbnhbNdIonemdKtjXr6wFDJGbzp5c7DUe+KbKlmJMDo
         9VbNbk8CJaBzn/Wnqjadvnn03drBaqpSqWOBsLgDc52kYXsGdkPtsN9uOmgYXGNmik0n
         D0PlB+iHwG0BrlltB5+/SSCMZ6T4gpT5oXkfzHhKaQnurQ8c2gj8X4oCjmEX/2XiwGcL
         H5afT/Vc9iE96yxsyoiQ9Eptzm0/MZvSSqyp2zhtXR6ENLzaE3BG6XjZpK/ZKEkeyO0U
         k7URnK/NRSyKHp0+9IEQanIrA+0x6g2ZIh+yGAovgd7iFcR4IXbV5zVmcMn4W9B+9RN1
         uSyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWiLuYcHFJ4uzbfks3uWS4RL5q+huxhSdmAM7zFYZWY47LB44qC
	9K5K9zUvyP82CwY+L4XyMkwhGAW/HHM9MCe+NloLqcHgWjfGH1hne1AcEVdbDXjb3gCCoPus26S
	8E3xbZLq2lSuBaSeo+iC3aJSqM1pkKuuNQPLJzne+Rww5WtVaqU9ZByOUIX8QOCWm/w==
X-Received: by 2002:a05:6402:8d5:: with SMTP id d21mr19350661edz.225.1555015887568;
        Thu, 11 Apr 2019 13:51:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOFBwlEYNNKGCCz0auiZePFz0jaJBdoLh75OJG9+18ohy224yCLl/3sIMfxogyeyYVVsdo
X-Received: by 2002:a05:6402:8d5:: with SMTP id d21mr19350622edz.225.1555015886770;
        Thu, 11 Apr 2019 13:51:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555015886; cv=none;
        d=google.com; s=arc-20160816;
        b=QyWXWja9ZfpWx1si5KBBsSBCgvilt2oz/nPWN3YEDxH2vdcBXxSO2D0Y+feJUzJjsu
         5oWDZoAEKOuvS1RhmEcVG7g3lHUjV47aMueCynQFc04AUesGlmQkZrEN2+iswlJL40/t
         TmtNXoW6WvA2vf44uptZDu84fTbipfCJ9bL+Z1hlWi5elrSfKXmPvsosBTTGqeMG3w34
         aMn3s3GCfK2fR82dhLJwKbIFsPdBbUPt3xUusXDaCVZruY3riahZ9SRXL1GehZF1dS1s
         aScqglr0YKwn4N7AKKhZAZlfkKy/QE20EeQCiNk4gQgAprDSW99sptBHno5e/jWQJS9I
         vhew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=N4DmJGRpRMXC++KQt7GTKbLUBRCE4AHAAJo/0113FgU=;
        b=YkJYT/dBbz3xuspxliAztlqvKPmSVuQq/QvH1zY6aY0Rbbft7yw14gVEtt8M9BEcE3
         EpZbmKdSRgiuplJtnJO/MdFFtjTO7a9XUl3x5FwEt2PJmVDw0HGL9833afBzhc7DGapb
         yRgVBFP21xcXJk5kFlLfoZ1vs1+V5WMnFZTX4jUMZfXLw4n9qFnczzXJL/rJviZjAggK
         5c8oU5DcpWjIXuN5axEFhuhv3kPpm9PM7ovEvYevPakQPtXp4tsKGj6qKHhjZy+6Ebmk
         HpJc512XVhukbqQYiAVBDdW9uHi5+vwT7HyS1L4Tjv5f4cWjifluaEcbJX1rckiLKm6v
         2g9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g7si5206595edr.56.2019.04.11.13.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 13:51:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3BKpILi119542
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 16:51:25 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rtbqmu3vd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 16:51:23 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 11 Apr 2019 21:49:57 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 11 Apr 2019 21:49:51 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3BKnoGY52625548
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Apr 2019 20:49:50 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8A67CA4055;
	Thu, 11 Apr 2019 20:49:50 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 61C83A404D;
	Thu, 11 Apr 2019 20:49:48 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.230])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 11 Apr 2019 20:49:48 +0000 (GMT)
Date: Thu, 11 Apr 2019 23:49:46 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Guenter Roeck <groeck@google.com>
Cc: Kees Cook <keescook@chromium.org>, kernelci@groups.io,
        Dan Williams <dan.j.williams@intel.com>,
        Guillaume Tucker <guillaume.tucker@collabora.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@suse.com>, Mark Brown <broonie@kernel.org>,
        Tomeu Vizoso <tomeu.vizoso@collabora.com>,
        Matt Hart <matthew.hart@linaro.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Kevin Hilman <khilman@baylibre.com>,
        Enric Balletbo i Serra <enric.balletbo@collabora.com>,
        Nicholas Piggin <npiggin@gmail.com>,
        Dominik Brodowski <linux@dominikbrodowski.net>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Adrian Reber <adrian@lisas.de>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Richard Guy Briggs <rgb@redhat.com>,
        "Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
References: <3fafb552-ae75-6f63-453c-0d0e57d818f3@collabora.com>
 <CAPcyv4hMNiiM11ULjbOnOf=9N=yCABCRsAYLpjXs+98bRoRpCA@mail.gmail.com>
 <36faea07-139c-b97d-3585-f7d6d362abc3@collabora.com>
 <20190306140529.GG3549@rapoport-lnx>
 <21d138a5-13e4-9e83-d7fe-e0639a8d180a@collabora.com>
 <CAPcyv4jBjUScKExK09VkL8XKibNcbw11ET4WNUWUWbPXeT9DFQ@mail.gmail.com>
 <CAGXu5jLAPKBE-EdfXkg2AK5P=qZktW6ow4kN5Yzc0WU2rtG8LQ@mail.gmail.com>
 <CABXOdTdVvFn=Nbd_Anhz7zR1H-9QeGByF3HFg4ZFt58R8=H6zA@mail.gmail.com>
 <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com>
 <CABXOdTcXWf9iReoocaj9rZ7z17zt-62iPDuvQQSrQRtMeeZNiA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXOdTcXWf9iReoocaj9rZ7z17zt-62iPDuvQQSrQRtMeeZNiA@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19041120-0016-0000-0000-0000026DE2C6
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041120-0017-0000-0000-000032CA1B06
Message-Id: <20190411204945.GA26085@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-11_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904110136
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 01:08:15PM -0700, Guenter Roeck wrote:
> On Thu, Apr 11, 2019 at 10:35 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > On Thu, Apr 11, 2019 at 9:42 AM Guenter Roeck <groeck@google.com> wrote:
> > >
> > > On Thu, Apr 11, 2019 at 9:19 AM Kees Cook <keescook@chromium.org> wrote:
> > > >
> > > > On Thu, Mar 7, 2019 at 7:43 AM Dan Williams <dan.j.williams@intel.com> wrote:
> > > > > I went ahead and acquired one of these boards to see if I can can
> > > > > debug this locally.
> > > >
> > > > Hi! Any progress on this? Might it be possible to unblock this series
> > > > for v5.2 by adding a temporary "not on ARM" flag?
> > > >
> > >
> > > Can someone send me a pointer to the series in question ? I would like
> > > to run it through my testbed.
> >
> > It's already in -mm and linux-next (",mm: shuffle initial free memory
> > to improve memory-side-cache utilization") but it gets enabled with
> > CONFIG_SHUFFLE_PAGE_ALLOCATOR=y (which was made the default briefly in
> > -mm which triggered problems on ARM as was reverted).
> >
> 
> Boot tests report
> 
> Qemu test results:
>     total: 345 pass: 345 fail: 0
> 
> This is on top of next-20190410 with CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
> and the known crashes fixed.
> 
> $ git log --oneline next-20190410..
> 3367c36ce744 Set SHUFFLE_PAGE_ALLOCATOR=y for testing.
> d2aee8b3cd5d Revert "crypto: scompress - Use per-CPU struct instead
> multiple variables"
> 4bc9f5bc9a84 Fix: rhashtable: use bit_spin_locks to protect hash bucket.
> 
> Boot tests on arm are:
> 
> Building arm:versatilepb:versatile_defconfig:aeabi:pci:scsi:mem128:versatile-pb:rootfs
> ... running ........ passed
> Building arm:versatilepb:versatile_defconfig:aeabi:pci:mem128:versatile-pb:initrd
> ... running ........ passed

...

> Building arm:witherspoon-bmc:aspeed_g5_defconfig:notests:aspeed-bmc-opp-witherspoon:initrd
> ... running ........... passed
> Building arm:ast2500-evb:aspeed_g5_defconfig:notests:aspeed-ast2500-evb:initrd
> ... running ................ passed
> Building arm:romulus-bmc:aspeed_g5_defconfig:notests:aspeed-bmc-opp-romulus:initrd
> ... running ......................... passed
> Building arm:mps2-an385:mps2_defconfig:mps2-an385:initrd ... running
> ...... passed

The issue was with an omap2 board and, AFAIK, qemu does not simulate those.

-- 
Sincerely yours,
Mike.

