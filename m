Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4209C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:53:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A40B2087E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:53:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A40B2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CD9B6B026C; Tue, 20 Aug 2019 20:53:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27E9E6B026D; Tue, 20 Aug 2019 20:53:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 194226B026E; Tue, 20 Aug 2019 20:53:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id E73126B026C
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:53:01 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 90AD78248ABF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:53:01 +0000 (UTC)
X-FDA: 75844610562.01.map32_71a44c02d4341
X-HE-Tag: map32_71a44c02d4341
X-Filterd-Recvd-Size: 2532
Received: from mga06.intel.com (mga06.intel.com [134.134.136.31])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:53:00 +0000 (UTC)
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Aug 2019 17:52:59 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,410,1559545200"; 
   d="scan'208";a="178350826"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga008.fm.intel.com with ESMTP; 20 Aug 2019 17:52:57 -0700
Date: Wed, 21 Aug 2019 08:52:34 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
	mgorman@techsingularity.net, osalvador@suse.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/3] mm/mmap.c: extract __vma_unlink_list as counter part
 for __vma_link_list
Message-ID: <20190821005234.GA5540@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190814021755.1977-1-richardw.yang@linux.intel.com>
 <20190814021755.1977-3-richardw.yang@linux.intel.com>
 <20190814051611.GA1958@infradead.org>
 <20190814065703.GA6433@richard>
 <2c5cdffd-f405-23b8-98f5-37b95ca9b027@suse.cz>
 <20190820172629.GB4949@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190820172629.GB4949@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 10:26:29AM -0700, Matthew Wilcox wrote:
>On Wed, Aug 14, 2019 at 11:19:37AM +0200, Vlastimil Babka wrote:
>> On 8/14/19 8:57 AM, Wei Yang wrote:
>> > On Tue, Aug 13, 2019 at 10:16:11PM -0700, Christoph Hellwig wrote:
>> >>Btw, is there any good reason we don't use a list_head for vma linkage?
>> > 
>> > Not sure, maybe there is some historical reason?
>> 
>> Seems it was single-linked until 2010 commit 297c5eee3724 ("mm: make the vma
>> list be doubly linked") and I guess it was just simpler to add the vm_prev link.
>> 
>> Conversion to list_head might be an interesting project for some "advanced
>> beginner" in the kernel :)
>
>I'm working to get rid of vm_prev and vm_next, so it would probably be
>wasted effort.

You mean replace it with list_head?

-- 
Wei Yang
Help you, Help me

