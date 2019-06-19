Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C41FDC31E5D
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:15:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B8FC21670
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:15:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dPqOh1g1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B8FC21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37A7D6B0003; Wed, 19 Jun 2019 10:15:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32B8F8E0002; Wed, 19 Jun 2019 10:15:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 241748E0001; Wed, 19 Jun 2019 10:15:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E01106B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:15:33 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id t2so9922546plo.10
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:15:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NBYZM4x4vonQf9U9PegTdJ8Gr3lWbvulPmcaW6blw1o=;
        b=AJT5T3xEo5HIl0Y/1lpRpKtGI1iV+TZPrhzBdu/i1oFSGHPX0e+j4hmAMt9foe/qDR
         /NJjPhbStJr/d9AAFAWx7hLgBxmb5otLV6nNgFNhmu7VS1509EOfegluW6AoXlUpdwRr
         h7LrSDnyLdRwX2PvAPwqw/u/hSdmI1HhnPO/VMPurKIyHcO85S3GnyI4JP97EnR+lSyV
         0h8pcNcsWRwEUfBxdjK4L/+LFVbv3gOqjQsc65vj7mxuqGViHeP+g9K0Bn5KGq1rm0y8
         joSwkCXvdvZKd1IsOlP3/sg4O58I2oITZNZ0PhIyVPf5/e3gb4luDHjmdC3ed9wz3ApL
         N1Ig==
X-Gm-Message-State: APjAAAVG4rfEJZn6Qqu5hYUbsZJBUSzabFV/OwVj6VZscWfOOfzgqXBR
	5M2S1X0BUX0aer3q9OZmpgD8wBkj8Uam5ZTxzBExlCOCUfKpBepEXr1ztX7QrW4z/tM0O0/UuAM
	Klk9nubatXSIXhW/iT5PPXfuBAFOSgS0VQieRXgj5a5+6ARcSZwWQcn1LNH7XtIA=
X-Received: by 2002:a62:1ec3:: with SMTP id e186mr127377501pfe.197.1560953733482;
        Wed, 19 Jun 2019 07:15:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/FNR+WoGXKYSe64L3NDuGcDUN9UtplK4T4qAR1b7LU0U0hVnIfNUn8yJJISenMCD6TGVf
X-Received: by 2002:a62:1ec3:: with SMTP id e186mr127377451pfe.197.1560953732814;
        Wed, 19 Jun 2019 07:15:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560953732; cv=none;
        d=google.com; s=arc-20160816;
        b=pNrI1n5mCLBWM3arzkmQBO1jOpF+jAikw2GglzU3ih4nQF6BY0lzYofFholqQFfa18
         kS8YbDVsGOMLHMDtfauKJGRCuHiHB955y41aXYdbgcrZ4MA3cKMckn0o59UgOTw9+O6w
         WsKY6IaoOsAqDY8R2snoIpnMHYZXZfb8IE3hs0SUbhH0NxkvApiqh16GXIuzZtckWDOj
         924jj592Pg9r/YhhSfPPBMcPLnOBv3ewqKYTwe4spaeASiNCPm4S/4mHyhZ5/Ba1Kefm
         0Cson56tOc+W6VSQCbkaqKRA4nUb4H/RUSs/NnfHCR76b2irWx/1Eq9DEoKwtGCdwZvC
         gy5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NBYZM4x4vonQf9U9PegTdJ8Gr3lWbvulPmcaW6blw1o=;
        b=VduZ4bIPBXCj8DN4Iso71yeHkhwLeoi8ohG5b8mXl34Lel059+q8PPm/utKDVlk7gi
         nh8dIAzQYdGCxpHxMmVgmjAJMXgzhY5QtVPAkstdvwqHUcjGBDtolYbUliawDvBrDX4T
         Vo5yvRSZp33u0yNsudWE0EsnR771d9TCYD/dY4uwuxfzqnPIKBaYjEvSVvmvT6giOtxD
         xhwWYhu5ZCt4PwL2iLRhRjfuKYJxuewTxDOfjJw3PF5b2rc1iIbaPy+a7SI/S1IZG/02
         ZKVU0/O17t5AEC32tSsCd0cXkV3iYIPulZKSMkdnXFltG5zHY2HztDmGxheVl0uAtXaL
         ZmbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dPqOh1g1;
       spf=softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=mchehab+samsung@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 135si3159840pgb.357.2019.06.19.07.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 07:15:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dPqOh1g1;
       spf=softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=mchehab+samsung@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:In-Reply-To:Message-ID:Subject:Cc:To:
	From:Date:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=NBYZM4x4vonQf9U9PegTdJ8Gr3lWbvulPmcaW6blw1o=; b=dPqOh1g1u6+Gx0sBalb5rkX2u
	wIbBMtAEdIsAee3Ub7W9KYWOgt2mtCWo8S4Q3A8BuyYcZpFXJIBFKLK93DcM0OgM4m/inlhuMxd4i
	xv4bXL13yE2S6AOwvmz7dbVWGoNRlTOpVocD4rVyrbv1GF1YVK56MDdeJUJ2TJdyUU/i7LDzPPxwk
	q5bBzKUGnZGKBhiO1stiWprfqZmaUIaVdpkulYzUlK2rGWSYmI7ne0f+vptRKQfKdDsKioHcQ3HVY
	ZLJmnIxZLL9Wg8XwEkfcleJ+3FQYhKRtXa8W53asUfOJcitK/KfLJc7dkOM7cGkK88AajNUpeKd7M
	OSliQfZFw==;
Received: from 177.133.86.196.dynamic.adsl.gvt.net.br ([177.133.86.196] helo=coco.lan)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdbN5-0002AD-M9; Wed, 19 Jun 2019 14:15:32 +0000
Date: Wed, 19 Jun 2019 11:15:28 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>, Linux MM
 <linux-mm@kvack.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main
 dir
Message-ID: <20190619111528.3e2665e3@coco.lan>
In-Reply-To: <11422.1560951550@warthog.procyon.org.uk>
References: <20190619072218.4437f891@coco.lan>
	<cover.1560890771.git.mchehab+samsung@kernel.org>
	<b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
	<CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com>
	<11422.1560951550@warthog.procyon.org.uk>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

Em Wed, 19 Jun 2019 14:39:10 +0100
David Howells <dhowells@redhat.com> escreveu:

> Mauro Carvalho Chehab <mchehab+samsung@kernel.org> wrote:
> 
> > > > -Documentation/nommu-mmap.rst
> > > > +Documentation/driver-api/nommu-mmap.rst    
> 
> Why is this moving to Documentation/driver-api?  

Good point. I tried to do my best with those document renames, but
I'm pretty sure some of them ended by going to the wrong place - or
at least there are arguments in favor of moving it to different
places :-)

The driver-api ended to be where most of the stuff has been moved,
as this is the main kAPI dir (there is also a core-api dir for kAPI too).

I tend to place there stuff that has a mix of kAPI and uAPI at
driver-api, as usually such documents are written assuming that
the one that would be reading it is a Kernel developer.

> It's less to do with drivers
> than with the userspace mapping interface.  Documentation/vm/ would seem a
> better home.
> 
> Or should we institute a Documentation/uapi/?  Though that might be seen to
> overlap with man2.  Actually, should this be in man7?

Actually, there is an userspace-api dir too. While the logs show that
this was created back on 2017, I only noticed it very recently.

Re-checking the file, I see your point: there are lots of
userspace-relevant contents there. Yet, it also mentions kAPI internals,
like a reference for file and vm ops (at "Providing shareable character
device support" session):

	file->f_op->get_unmapped_area()
	file->f_op->mmap()
	vm_ops->close()

It is up to MM people and Jon to decide where to place it.

In any case, the best (long term) seems to split it on separate files, 
one with kAPI and another one with uAPI (just like may other subsystem
specific docs).

Thanks,
Mauro

