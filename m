Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85595C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 11:37:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F1D620673
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 11:37:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ev0hZVFb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F1D620673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA37C6B038D; Fri, 23 Aug 2019 07:37:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A54E06B038E; Fri, 23 Aug 2019 07:37:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 942A26B038F; Fri, 23 Aug 2019 07:37:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0009.hostedemail.com [216.40.44.9])
	by kanga.kvack.org (Postfix) with ESMTP id 88ACB6B038D
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 07:37:25 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7A35E8243760
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 11:37:21 +0000 (UTC)
X-FDA: 75853491882.02.robin17_2317b726ab222
X-HE-Tag: robin17_2317b726ab222
X-Filterd-Recvd-Size: 1967
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 11:37:21 +0000 (UTC)
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F066D20673;
	Fri, 23 Aug 2019 11:37:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566560240;
	bh=vTu4N+FWywT7DusqHwzG38gOKUROnQ/PN6+3q9xkgX0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Ev0hZVFbPDhQM8fUZYmyg+dSIGhpks6fapR6ZQAhS71StNX3QDt4qKN/IVK3VaQwP
	 Lp/jcy99LXDRvunR5miwqPGxSNxH2XIlBRSPaD7YaJ3T+jyfNqJGqX6wMCD2X/8m+d
	 6AbvLaC1cxZSjBgIeD47vslRuZF7MgXt6SguW8pM=
Date: Fri, 23 Aug 2019 12:37:16 +0100
From: Will Deacon <will@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_alloc.shuffle=1 + CONFIG_PROVE_LOCKING=y = arm64 hang
Message-ID: <20190823113715.n3lc73vtc4ea2ln4@willie-the-truck>
References: <1566509603.5576.10.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1566509603.5576.10.camel@lca.pw>
User-Agent: NeoMutt/20170113 (1.7.2)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000114, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 05:33:23PM -0400, Qian Cai wrote:
> https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config
>=20
> Booting an arm64 ThunderX2 server with page_alloc.shuffle=3D1 [1] +
> CONFIG_PROVE_LOCKING=3Dy=A0results in hanging.

Hmm, but the config you link to above has:

# CONFIG_PROVE_LOCKING is not set

so I'm confused. Also, which tree is this?

Will

