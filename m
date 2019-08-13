Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F94FC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:49:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6CE020679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:49:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6CE020679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98F006B0003; Tue, 13 Aug 2019 09:49:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93F806B0006; Tue, 13 Aug 2019 09:49:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87C926B0007; Tue, 13 Aug 2019 09:49:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0150.hostedemail.com [216.40.44.150])
	by kanga.kvack.org (Postfix) with ESMTP id 632F86B0003
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:49:13 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 141918248AA2
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:49:13 +0000 (UTC)
X-FDA: 75817536186.20.boot51_1623d885ded27
X-HE-Tag: boot51_1623d885ded27
X-Filterd-Recvd-Size: 2322
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:49:12 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id ADFFC344;
	Tue, 13 Aug 2019 06:49:10 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AB36B3F694;
	Tue, 13 Aug 2019 06:49:09 -0700 (PDT)
Date: Tue, 13 Aug 2019 14:49:07 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 3/3] mm: kmemleak: Use the memory pool for early
 allocations
Message-ID: <20190813134907.GJ62772@arrakis.emea.arm.com>
References: <20190812160642.52134-1-catalin.marinas@arm.com>
 <20190812160642.52134-4-catalin.marinas@arm.com>
 <1565699754.8572.8.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1565699754.8572.8.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 08:35:54AM -0400, Qian Cai wrote:
> On Mon, 2019-08-12 at 17:06 +0100, Catalin Marinas wrote:
> > diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> > index 4d39540011e2..39df06ffd9f4 100644
> > --- a/lib/Kconfig.debug
> > +++ b/lib/Kconfig.debug
> > @@ -592,17 +592,18 @@ config DEBUG_KMEMLEAK
> > =A0	=A0=A0In order to access the kmemleak file, debugfs needs to be
> > =A0	=A0=A0mounted (usually at /sys/kernel/debug).
> > =A0
> > -config DEBUG_KMEMLEAK_EARLY_LOG_SIZE
> > -	int "Maximum kmemleak early log entries"
> > +config DEBUG_KMEMLEAK_MEM_POOL_SIZE
> > +	int "Kmemleak memory pool size"
> > =A0	depends on DEBUG_KMEMLEAK
> > =A0	range 200 40000
> > =A0	default 16000
>=20
> Hmm, this seems way too small. My previous round of testing with
> kmemleak.mempool=3D524288 works quite well on all architectures.

We can change the upper bound here to 1M but I'd keep the default sane.
Not everyone is running tests under OOM.

--=20
Catalin

