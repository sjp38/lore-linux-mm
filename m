Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C6D8C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:40:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D944E20679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:40:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D944E20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CC346B0005; Tue, 13 Aug 2019 11:40:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67B626B0006; Tue, 13 Aug 2019 11:40:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56A2E6B0007; Tue, 13 Aug 2019 11:40:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0145.hostedemail.com [216.40.44.145])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE036B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:40:14 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D9173181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:40:13 +0000 (UTC)
X-FDA: 75817815906.07.love75_765a969968141
X-HE-Tag: love75_765a969968141
X-Filterd-Recvd-Size: 1781
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:40:13 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 4A99E68C4E; Tue, 13 Aug 2019 17:40:09 +0200 (CEST)
Date: Tue, 13 Aug 2019 17:40:08 +0200
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Atish Patra <Atish.Patra@wdc.com>, Christoph Hellwig <hch@lst.de>,
	Paul Walmsley <paul.walmsley@sifive.com>, linux-mm@kvack.org,
	Damien Le Moal <Damien.LeMoal@wdc.com>,
	linux-riscv@lists.infradead.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 16/17] riscv: clear the instruction cache and all
 registers when booting
Message-ID: <20190813154008.GB8686@lst.de>
References: <78919862d11f6d56446f8fffd8a1a8c601ea5c32.camel@wdc.com> <mhng-3f43f4b8-473d-429d-9a09-12d3542e33bc@palmer-si-x1e>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <mhng-3f43f4b8-473d-429d-9a09-12d3542e33bc@palmer-si-x1e>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 08, 2019 at 01:26:33AM -0700, Palmer Dabbelt wrote:
>>> +	csrs	sstatus, t1
>
> You need to check that the write stuck and branch around the FP instructions.
> Specifically, CONFIG_FPU means there may be an FPU, not there's definately an
> FPU.  You should also turn the FPU back off after zeroing the state.

Well, that is why we check the hwcaps from misa just above and skip
this fp reg clearing if it doesn't contain the 'F' or 'D' extension.

The caller disables the FPU a few instructions later:

	/*
         * Disable FPU to detect illegal usage of
	 * floating point in kernel space
	 */
	li t0, SR_FS
	csrc CSR_XSTATUS, t0

