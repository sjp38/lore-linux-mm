Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DD3EC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 08:39:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAF132339E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 08:39:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAF132339E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75CF16B000D; Thu, 29 Aug 2019 04:39:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70D8E6B000E; Thu, 29 Aug 2019 04:39:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 623756B0010; Thu, 29 Aug 2019 04:39:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0203.hostedemail.com [216.40.44.203])
	by kanga.kvack.org (Postfix) with ESMTP id 40B636B000D
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 04:39:31 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E44908243763
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 08:39:30 +0000 (UTC)
X-FDA: 75874816500.03.ice74_8d3f230921302
X-HE-Tag: ice74_8d3f230921302
X-Filterd-Recvd-Size: 1665
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 08:39:30 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 55B6568BFE; Thu, 29 Aug 2019 10:39:27 +0200 (CEST)
Date: Thu, 29 Aug 2019 10:39:27 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org,
	linux-mm@kvack.org, paulus@au1.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
	linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
	cclaudio@linux.ibm.com, hch@lst.de,
	Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH v7 4/7] kvmppc: Handle memory plug/unplug to secure VM
Message-ID: <20190829083927.GB13039@lst.de>
References: <20190822102620.21897-1-bharata@linux.ibm.com> <20190822102620.21897-5-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190822102620.21897-5-bharata@linux.ibm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 03:56:17PM +0530, Bharata B Rao wrote:
> +	/*
> +	 * TODO: Handle KVM_MR_MOVE
> +	 */
> +	if (change == KVM_MR_CREATE) {
> +		uv_register_mem_slot(kvm->arch.lpid,
> +				     new->base_gfn << PAGE_SHIFT,
> +				     new->npages * PAGE_SIZE,
> +				     0, new->id);
> +	} else if (change == KVM_MR_DELETE)
> +		uv_unregister_mem_slot(kvm->arch.lpid, old->id);
>  }

In preparation for the KVM_MR_MOVE addition just using a switch statement
here from the very beginning might make the code a little nicer to read.

