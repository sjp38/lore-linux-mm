Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32D1DC3A59B
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 07:54:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1A812173E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 07:54:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1A812173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F69C6B0003; Mon,  2 Sep 2019 03:54:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47F8A6B0006; Mon,  2 Sep 2019 03:54:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 396036B0007; Mon,  2 Sep 2019 03:54:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id 19A3E6B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 03:54:01 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BD18B824CA26
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:54:00 +0000 (UTC)
X-FDA: 75889217040.29.lake57_7a43b187b6041
X-HE-Tag: lake57_7a43b187b6041
X-Filterd-Recvd-Size: 3730
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:53:59 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3F54F227A8A; Mon,  2 Sep 2019 09:53:56 +0200 (CEST)
Date: Mon, 2 Sep 2019 09:53:56 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>, linuxppc-dev@lists.ozlabs.org,
	kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
	linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
	cclaudio@linux.ibm.com
Subject: Re: [PATCH v7 1/7] kvmppc: Driver to manage pages of secure guest
Message-ID: <20190902075356.GA28967@lst.de>
References: <20190822102620.21897-1-bharata@linux.ibm.com> <20190822102620.21897-2-bharata@linux.ibm.com> <20190829083810.GA13039@lst.de> <20190830034259.GD31913@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190830034259.GD31913@in.ibm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 30, 2019 at 09:12:59AM +0530, Bharata B Rao wrote:
> On Thu, Aug 29, 2019 at 10:38:10AM +0200, Christoph Hellwig wrote:
> > On Thu, Aug 22, 2019 at 03:56:14PM +0530, Bharata B Rao wrote:
> > > +/*
> > > + * Bits 60:56 in the rmap entry will be used to identify the
> > > + * different uses/functions of rmap.
> > > + */
> > > +#define KVMPPC_RMAP_DEVM_PFN	(0x2ULL << 56)
> > 
> > How did you come up with this specific value?
> 
> Different usage types of RMAP array are being defined.
> https://patchwork.ozlabs.org/patch/1149791/
> 
> The above value is reserved for device pfn usage.

Shouldn't all these defintions go in together in a patch?  Also is bi
t 56+ a set of values, so is there 1 << 56 and 3 << 56 as well?  Seems
like even that other patch doesn't fully define these "pfn" values.

> > No need for !! when returning a bool.  Also the helper seems a little
> > pointless, just opencoding it would make the code more readable in my
> > opinion.
> 
> I expect similar routines for other usages of RMAP to come up.

Please drop them all.  Having to wade through a header to check for
a specific bit that also is set manually elsewhere in related code
just obsfucates it for the reader.

> > > +	*mig->dst = migrate_pfn(page_to_pfn(dpage)) | MIGRATE_PFN_LOCKED;
> > > +	return 0;
> > > +}
> > 
> > I think you can just merge this trivial helper into the only caller.
> 
> Yes I can, but felt it is nicely abstracted out to a function right now.

Not really.  It just fits the old calling conventions before I removed
the indirection.

> > Here we actually have two callers, but they have a fair amount of
> > duplicate code in them.  I think you want to move that common
> > code (including setting up the migrate_vma structure) into this
> > function and maybe also give it a more descriptive name.
> 
> Sure, I will give this a try. The name is already very descriptive, will
> come up with an appropriate name.

I don't think alloc_and_copy is very helpful.  It matches some of the
implementation, but not the intent.  Why not kvmppc_svm_page_in/out
similar to the hypervisor calls calling them?  Yes, for one case it
also gets called from the pagefault handler, but it still performs
these basic page in/out actions.

> BTW this file and the fuction prefixes in this file started out with
> kvmppc_hmm, switched to kvmppc_devm when HMM routines weren't used anymore.
> Now with the use of only non-dev versions, planning to swtich to
> kvmppc_uvmem_

That prefix sounds fine to me as well.

