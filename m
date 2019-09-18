Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F150C4CECE
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 16:49:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0125C218AE
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 16:49:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0125C218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FB876B02DA; Wed, 18 Sep 2019 12:49:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AC396B02DC; Wed, 18 Sep 2019 12:49:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C1E86B02DD; Wed, 18 Sep 2019 12:49:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0160.hostedemail.com [216.40.44.160])
	by kanga.kvack.org (Postfix) with ESMTP id 5CAF66B02DA
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:49:32 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 09E79211B6
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 16:49:32 +0000 (UTC)
X-FDA: 75948627384.03.dust91_3612ee7ba8314
X-HE-Tag: dust91_3612ee7ba8314
X-Filterd-Recvd-Size: 2791
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 16:49:31 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A0961337;
	Wed, 18 Sep 2019 09:49:30 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F0AAA3F59C;
	Wed, 18 Sep 2019 09:49:27 -0700 (PDT)
Date: Wed, 18 Sep 2019 17:49:25 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jia He <justin.he@arm.com>, Will Deacon <will@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	James Morse <james.morse@arm.com>, Marc Zyngier <maz@kernel.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Suzuki Poulose <Suzuki.Poulose@arm.com>,
	Punit Agrawal <punitagrawal@gmail.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	Alex Van Brunt <avanbrunt@nvidia.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, hejianet@gmail.com,
	Kaly Xin <Kaly.Xin@arm.com>
Subject: Re: [PATCH v4 1/3] arm64: cpufeature: introduce helper
 cpu_has_hw_af()
Message-ID: <20190918164925.GB41588@arrakis.emea.arm.com>
References: <20190918131914.38081-1-justin.he@arm.com>
 <20190918131914.38081-2-justin.he@arm.com>
 <20190918142017.GC9880@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190918142017.GC9880@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 18, 2019 at 07:20:17AM -0700, Matthew Wilcox wrote:
> On Wed, Sep 18, 2019 at 09:19:12PM +0800, Jia He wrote:
> > +/* Decouple AF from AFDBM. */
> > +bool cpu_has_hw_af(void)
> > +{
> > +	return (read_cpuid(ID_AA64MMFR1_EL1) & 0xf);
> > +}
> > +
> 
> Do you really want to call read_cpuid() every time?  I would have thought
> you'd want to use the static branch mechanism to do the right thing at
> boot time.  See Documentation/static-keys.txt.

We do have a static branch mechanism for other CPU features but mostly
because on some big.LITTLE systems, the CPUs may differ slightly so we
only advertise the common features.

I guess here the additional instructions for reading and checking the
CPUID here would be lost in the noise compared to the actual page
copying.

-- 
Catalin

