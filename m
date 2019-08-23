Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D133DC3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 11:57:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 949B422CE3
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 11:57:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 949B422CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42BDC6B0393; Fri, 23 Aug 2019 07:57:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DC936B0395; Fri, 23 Aug 2019 07:57:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 319226B0396; Fri, 23 Aug 2019 07:57:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0009.hostedemail.com [216.40.44.9])
	by kanga.kvack.org (Postfix) with ESMTP id 262D66B0393
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 07:57:47 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E2CFC6D8C
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 11:57:46 +0000 (UTC)
X-FDA: 75853543332.02.rule74_43c569671a72c
X-HE-Tag: rule74_43c569671a72c
X-Filterd-Recvd-Size: 3365
Received: from ozlabs.org (bilbo.ozlabs.org [203.11.71.1])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 11:57:45 +0000 (UTC)
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 46FKds2Qn9z9s00;
	Fri, 23 Aug 2019 21:57:37 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Paul Mackerras <paulus@ozlabs.org>, Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxram@us.ibm.com, cclaudio@linux.ibm.com, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, aneesh.kumar@linux.vnet.ibm.com, paulus@au1.ibm.com, sukadev@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, hch@lst.de
Subject: Re: [PATCH v7 0/7] KVMPPC driver to manage secure guest pages
In-Reply-To: <20190823041747.ctquda5uwvy2eiqz@oak.ozlabs.ibm.com>
References: <20190822102620.21897-1-bharata@linux.ibm.com> <20190823041747.ctquda5uwvy2eiqz@oak.ozlabs.ibm.com>
Date: Fri, 23 Aug 2019 21:57:32 +1000
Message-ID: <87wof43xhv.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Mackerras <paulus@ozlabs.org> writes:
> On Thu, Aug 22, 2019 at 03:56:13PM +0530, Bharata B Rao wrote:
>> A pseries guest can be run as a secure guest on Ultravisor-enabled
>> POWER platforms. On such platforms, this driver will be used to manage
>> the movement of guest pages between the normal memory managed by
>> hypervisor(HV) and secure memory managed by Ultravisor(UV).
>> 
>> Private ZONE_DEVICE memory equal to the amount of secure memory
>> available in the platform for running secure guests is created.
>> Whenever a page belonging to the guest becomes secure, a page from
>> this private device memory is used to represent and track that secure
>> page on the HV side. The movement of pages between normal and secure
>> memory is done via migrate_vma_pages(). The reverse movement is driven
>> via pagemap_ops.migrate_to_ram().
>> 
>> The page-in or page-out requests from UV will come to HV as hcalls and
>> HV will call back into UV via uvcalls to satisfy these page requests.
>> 
>> These patches are against hmm.git
>> (https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=hmm)
>> 
>> plus
>> 
>> Claudio Carvalho's base ultravisor enablement patchset v6
>> (https://lore.kernel.org/linuxppc-dev/20190822034838.27876-1-cclaudio@linux.ibm.com/T/#t)
>
> How are you thinking these patches will go upstream?  Are you going to
> send them via the hmm tree?
>
> I assume you need Claudio's patchset as a prerequisite for your series
> to compile, which means the hmm maintainers would need to pull in a
> topic branch from Michael Ellerman's powerpc tree, or something like
> that.

I think more workable would be for me to make a topic branch based on
the hmm tree (or some commit from the hmm tree), which I then apply the
patches on top of, and merge any required powerpc changes into that. I
can then ask Linus to merge that branch late in the merge window once
the hmm changes have gone in.

The bigger problem at the moment is the lack of reviews or acks on the
bulk of the series.

cheers

