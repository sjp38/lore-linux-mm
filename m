Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77AC1C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 01:23:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BE6422DD6
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 01:23:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BE6422DD6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8B816B0279; Tue, 20 Aug 2019 21:23:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D15F36B027A; Tue, 20 Aug 2019 21:23:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDC2E6B027B; Tue, 20 Aug 2019 21:23:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0161.hostedemail.com [216.40.44.161])
	by kanga.kvack.org (Postfix) with ESMTP id 97C926B0279
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 21:23:12 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4287255F93
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 01:23:12 +0000 (UTC)
X-FDA: 75844686624.21.cord18_561de2c47584c
X-HE-Tag: cord18_561de2c47584c
X-Filterd-Recvd-Size: 3162
Received: from mga09.intel.com (mga09.intel.com [134.134.136.24])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 01:23:11 +0000 (UTC)
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Aug 2019 18:23:10 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,410,1559545200"; 
   d="scan'208";a="202863410"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga004.fm.intel.com with ESMTP; 20 Aug 2019 18:23:08 -0700
Date: Wed, 21 Aug 2019 09:22:44 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Yang <richardw.yang@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
	mgorman@techsingularity.net, osalvador@suse.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/3] mm/mmap.c: extract __vma_unlink_list as counter part
 for __vma_link_list
Message-ID: <20190821012244.GA13653@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190814021755.1977-1-richardw.yang@linux.intel.com>
 <20190814021755.1977-3-richardw.yang@linux.intel.com>
 <20190814051611.GA1958@infradead.org>
 <20190814065703.GA6433@richard>
 <2c5cdffd-f405-23b8-98f5-37b95ca9b027@suse.cz>
 <20190820172629.GB4949@bombadil.infradead.org>
 <20190821005234.GA5540@richard>
 <20190821005417.GC18776@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821005417.GC18776@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 05:54:17PM -0700, Matthew Wilcox wrote:
>On Wed, Aug 21, 2019 at 08:52:34AM +0800, Wei Yang wrote:
>> On Tue, Aug 20, 2019 at 10:26:29AM -0700, Matthew Wilcox wrote:
>> >On Wed, Aug 14, 2019 at 11:19:37AM +0200, Vlastimil Babka wrote:
>> >> On 8/14/19 8:57 AM, Wei Yang wrote:
>> >> > On Tue, Aug 13, 2019 at 10:16:11PM -0700, Christoph Hellwig wrote:
>> >> >>Btw, is there any good reason we don't use a list_head for vma linkage?
>> >> > 
>> >> > Not sure, maybe there is some historical reason?
>> >> 
>> >> Seems it was single-linked until 2010 commit 297c5eee3724 ("mm: make the vma
>> >> list be doubly linked") and I guess it was just simpler to add the vm_prev link.
>> >> 
>> >> Conversion to list_head might be an interesting project for some "advanced
>> >> beginner" in the kernel :)
>> >
>> >I'm working to get rid of vm_prev and vm_next, so it would probably be
>> >wasted effort.
>> 
>> You mean replace it with list_head?
>
>No, replace the rbtree with a new tree.  https://lwn.net/Articles/787629/

Sounds interesting.

While I am not sure the plan is settled down, and how long it would take to
replace the rb_tree with maple tree. I guess it would probably take some time
to get merged upstream.

IMHO, it would be good to have this cleanup in current kernel. Do you agree?

-- 
Wei Yang
Help you, Help me

