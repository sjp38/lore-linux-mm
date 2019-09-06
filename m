Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74661C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 16:32:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23841207FC
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 16:32:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23841207FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF96B6B0003; Fri,  6 Sep 2019 12:32:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAB3A6B0005; Fri,  6 Sep 2019 12:32:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E76A6B0006; Fri,  6 Sep 2019 12:32:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC326B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:32:47 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0EF42181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 16:32:47 +0000 (UTC)
X-FDA: 75905039574.23.can06_526ed731d0823
X-HE-Tag: can06_526ed731d0823
X-Filterd-Recvd-Size: 2236
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 16:32:46 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 7402B68B20; Fri,  6 Sep 2019 18:32:41 +0200 (CEST)
Date: Fri, 6 Sep 2019 18:32:41 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>, linuxppc-dev@lists.ozlabs.org,
	kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
	linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
	cclaudio@linux.ibm.com
Subject: Re: [PATCH v7 1/7] kvmppc: Driver to manage pages of secure guest
Message-ID: <20190906163241.GA12516@lst.de>
References: <20190822102620.21897-1-bharata@linux.ibm.com> <20190822102620.21897-2-bharata@linux.ibm.com> <20190829083810.GA13039@lst.de> <20190830034259.GD31913@in.ibm.com> <20190902075356.GA28967@lst.de> <20190906113639.GA8748@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906113639.GA8748@in.ibm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 05:06:39PM +0530, Bharata B Rao wrote:
> > Also is bit 56+ a set of values, so is there 1 << 56 and 3 << 56 as well?  Seems
> > like even that other patch doesn't fully define these "pfn" values.
> 
> I realized that the bit numbers have changed, it is no longer bits 60:56,
> but instead top 8bits. 
> 
> #define KVMPPC_RMAP_UVMEM_PFN   0x0200000000000000
> static inline bool kvmppc_rmap_is_uvmem_pfn(unsigned long *rmap)
> {
>         return ((*rmap & 0xff00000000000000) == KVMPPC_RMAP_UVMEM_PFN);
> }

In that overall scheme I'd actually much prefer something like (names
just made up, they should vaguely match the spec this written to):

static inline unsigned long kvmppc_rmap_type(unsigned long *rmap)
{
	return (rmap & 0xff00000000000000);
}

And then where you check it you can use:

	if (kvmppc_rmap_type(*rmap) == KVMPPC_RMAP_UVMEM_PFN)

and where you set it you do:

	*rmap |= KVMPPC_RMAP_UVMEM_PFN;

as in the current patch to keep things symmetric.

