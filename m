Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBAA4C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:53:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 969632054F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:53:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 969632054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 332EF8E0003; Tue, 12 Mar 2019 12:53:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ED248E0002; Tue, 12 Mar 2019 12:53:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 182FA8E0003; Tue, 12 Mar 2019 12:53:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C71458E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:53:55 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 73so3241901pga.18
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:53:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=2Nkg9wy769XzpYb2B+PxD0fsSszxvg0LWw30uzl1ROw=;
        b=TrmKeh8vYPOfxuWsEwEnZVc+QbLwXxr4dfBqiSKpdTKfpr2/SjVjYEyDMhPKgM64bf
         Q3QRffo9yF1+TqGPCqrnwboBCaSxrVZp3PsYonorQZERNQFfZJy5B6yU0B689VeKkVG3
         oiCOmCrabUKbf+9XGh7INmp+0dudZWJEWIm7I1gSipGj6YoGF9ZffiRV9lTZl2bkIjJK
         69+kfhYWQZaqISvFR8xFxyM6ZAngUAtBE8LKeE1qaVCkWuUJhcRXKEshawb241c2qjDL
         ZKcUFDMPCIe6nwK2klmuu/mLc6SWDfYSD2Ll+si2spcrhbGFOeNr9F0Q4cGmsVv+IKtd
         sLDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robert.barror@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=robert.barror@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUhae/IiQrwTTZSWeF4/He/pu2nHEo6WaUJ0/xT/YDtmvfbcvR2
	jPh4fY5eyvFMHMcZj7mDheageE6Bd8UCaZS3mxh3QsW8VvGf9zgV3R2UPNLOnqp0B1S0/xuuERs
	jWDdV8RTXbN+0zHvWO1EaN1lm9Ng7IFRbekcr1sV276nrgUiLv72Oqcy3FjBebJ6Hdg==
X-Received: by 2002:a63:eb56:: with SMTP id b22mr36132999pgk.287.1552409635439;
        Tue, 12 Mar 2019 09:53:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdQSyM2o2z+Rvn7TGfHSL5IqUwKT/kKbE/KXrQjx5tSOix5CuMBWFrZKuvudvSPvREdptb
X-Received: by 2002:a63:eb56:: with SMTP id b22mr36132945pgk.287.1552409634232;
        Tue, 12 Mar 2019 09:53:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552409634; cv=none;
        d=google.com; s=arc-20160816;
        b=HJKMf9J22LIXd9G/s/VfQ9canCM4LYN2VnfAX9+t08iyn19sheILbk2ROKjd0DP4Zm
         7W/qCdsTGvHkSzFysIP/ymtlVOwKRA1pTN2dqOmn+hzO+o6cbyElC8chd1yoFe4JEINw
         8HXdtyUqIKPiWO2dlwRA9cf/fIWVc7VO8jYXbBLzCBwFhoBZW54G9sk7Kv9RNTG5+dR1
         uvBBpDlLzenfr4y3TJ76fJp/1AsGEnVwulYHAVq9ZsQ5HtZK56nHZWLX3FXdSe3XWU9D
         Qs00oIbmzBRlmY+SyE0sxQ73VTyJWgu7L3B/gTRjr354+9NcKgOcZ8Dx4/1JBAGFcWpp
         VK6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=2Nkg9wy769XzpYb2B+PxD0fsSszxvg0LWw30uzl1ROw=;
        b=Gioktz+2rI1Ro43FiWMVf1qWvGMmzKTS9YYM68Dp0/qmZmj3jL/z0ca+Uwa5DuFp0N
         MIJmQbwjqxZ6wyY23F+J/catn1Sm7oeMuChkbew/PpDNIDE5phjGpIsu0jwaS5Q700Om
         +LGY/x8rnP5tnK6S/USuCUR3B0f6wYwJIy1k3hxf2n1HFtKAY5sJUY0mGl/ikg3Zcw+D
         AaTXsPz9LeCS1jVwT9fOajainlHlUK6GhQCWqYHh59JXJzjr1jsPDpF4ZUnPfuHzPb4E
         4g58J5XWGOGe4ieMdMtDMy9zPqDDDoCHkbp/AczAT+DrX3ow/fkZvvoS9Hr9DX9oKxIf
         hqUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robert.barror@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=robert.barror@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id d12si8302128pgt.59.2019.03.12.09.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 09:53:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of robert.barror@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robert.barror@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=robert.barror@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Mar 2019 09:53:53 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,471,1544515200"; 
   d="scan'208";a="154348254"
Received: from orsmsx101.amr.corp.intel.com ([10.22.225.128])
  by fmsmga001.fm.intel.com with ESMTP; 12 Mar 2019 09:53:53 -0700
Received: from orsmsx113.amr.corp.intel.com ([169.254.9.249]) by
 ORSMSX101.amr.corp.intel.com ([169.254.8.133]) with mapi id 14.03.0415.000;
 Tue, 12 Mar 2019 09:53:52 -0700
From: "Barror, Robert" <robert.barror@intel.com>
To: Dave Chinner <david@fromorbit.com>, "Williams, Dan J"
	<dan.j.williams@intel.com>
CC: Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>
Subject: RE: Hang / zombie process from Xarray page-fault conversion
 (bisected)
Thread-Topic: Hang / zombie process from Xarray page-fault conversion
 (bisected)
Thread-Index: AQHU1XaDf7SHWQG94E+JXnYHYO2/KqYHA1mAgADQPICAABGNAIAAVphQ
Date: Tue, 12 Mar 2019 16:53:52 +0000
Message-ID: <04FD0F1E52B84F4ABF03487D5C82D4CA773CE75B@ORSMSX113.amr.corp.intel.com>
References: <CAPcyv4hwHpX-MkUEqxwdTj7wCCZCN4RV-L4jsnuwLGyL_UEG4A@mail.gmail.com>
 <20190311150947.GD19508@bombadil.infradead.org>
 <CAPcyv4jG5r2LOesxSx+Mdf+L_gQWqnhk+gKZyKAAPTHy1Drvqw@mail.gmail.com>
 <20190312043754.GD23020@dastard>
In-Reply-To: <20190312043754.GD23020@dastard>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNGM0NTVlNzMtZGI3My00NzQ1LWJjN2YtNDllYzI2YmFlYTZhIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiaFBLWENZZVNBUHNjb29KejVsZlhUYzVJVkJpMXpSRWRSbERiWmVrdE8rVW1kd2NkdG5WZlVBXC9PbHRUSk4wMXQifQ==
x-ctpclassification: CTP_NT
x-originating-ip: [10.22.254.140]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Guys,

"> It's limited to xfs, no failure on ext4 to date", this is incorrect. I h=
ave been able to reproduce this issue with ext4. In order to do that, I nee=
d to run the full test (on both pmems in the system) and not the half test =
(only 1 pmem) that I use for inducing the hang under XFS. The test also run=
s considerably longer before failing with ext4 than XFS.

Thx bob


-----Original Message-----
From: Dave Chinner [mailto:david@fromorbit.com]=20
Sent: Monday, March 11, 2019 9:38 PM
To: Williams, Dan J <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>; Linux MM <linux-mm@kvack.org>; li=
nux-nvdimm <linux-nvdimm@lists.01.org>; linux-fsdevel <linux-fsdevel@vger.k=
ernel.org>; Barror, Robert <robert.barror@intel.com>
Subject: Re: Hang / zombie process from Xarray page-fault conversion (bisec=
ted)

On Mon, Mar 11, 2019 at 08:35:05PM -0700, Dan Williams wrote:
> On Mon, Mar 11, 2019 at 8:10 AM Matthew Wilcox <willy@infradead.org> wrot=
e:
> >
> > On Thu, Mar 07, 2019 at 10:16:17PM -0800, Dan Williams wrote:
> > > Hi Willy,
> > >
> > > We're seeing a case where RocksDB hangs and becomes defunct when=20
> > > trying to kill the process. v4.19 succeeds and v4.20 fails. Robert=20
> > > was able to bisect this to commit b15cd800682f "dax: Convert page=20
> > > fault handlers to XArray".
> > >
> > > I see some direct usage of xa_index and wonder if there are some=20
> > > more pmd fixups to do?
> > >
> > > Other thoughts?
> >
> > I don't see why killing a process would have much to do with PMD=20
> > misalignment.  The symptoms (hanging on a signal) smell much more=20
> > like leaving a locked entry in the tree.  Is this easy to reproduce? =20
> > Can you get /proc/$pid/stack for a hung task?
>=20
> It's fairly easy to reproduce, I'll see if I can package up all the=20
> dependencies into something that fails in a VM.
>=20
> It's limited to xfs, no failure on ext4 to date.
>=20
> The hung process appears to be:
>=20
>      kworker/53:1-xfs-sync/pmem0

That's completely internal to XFS. Every 30s the work is triggered and it e=
ither does a log flush (if the fs is active) or it syncs the superblock to =
clean the log and idle the filesystem. It has nothing to do with user proce=
sses, and I don't see why killing a process has any effect on what it does.=
..

> ...and then the rest of the database processes grind to a halt from there=
.
>=20
> Robert was kind enough to capture /proc/$pid/stack, but nothing interesti=
ng:
>=20
> [<0>] worker_thread+0xb2/0x380
> [<0>] kthread+0x112/0x130
> [<0>] ret_from_fork+0x1f/0x40
> [<0>] 0xffffffffffffffff

Much more useful would be:

# echo w > /proc/sysrq-trigger

And post the entire output of dmesg.

Cheers,

Dave.
--
Dave Chinner
david@fromorbit.com

