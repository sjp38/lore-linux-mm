Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AF53C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 08:28:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD81E20828
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 08:28:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD81E20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 310826B0003; Wed, 28 Aug 2019 04:28:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C1476B0008; Wed, 28 Aug 2019 04:28:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B1A36B000D; Wed, 28 Aug 2019 04:28:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0041.hostedemail.com [216.40.44.41])
	by kanga.kvack.org (Postfix) with ESMTP id F0A9B6B0003
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 04:28:04 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A3ACA824CA1C
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 08:28:04 +0000 (UTC)
X-FDA: 75871158888.04.songs32_80a5a4e37e93d
X-HE-Tag: songs32_80a5a4e37e93d
X-Filterd-Recvd-Size: 2823
Received: from mga06.intel.com (mga06.intel.com [134.134.136.31])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 08:28:03 +0000 (UTC)
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Aug 2019 01:28:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,440,1559545200"; 
   d="scan'208";a="210081623"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga002.fm.intel.com with ESMTP; 28 Aug 2019 01:28:00 -0700
Date: Wed, 28 Aug 2019 16:27:38 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Wei Yang <richardw.yang@linux.intel.com>, akpm@linux-foundation.org,
	kirill.shutemov@linux.intel.com, yang.shi@linux.alibaba.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [RESEND [PATCH] 0/2] mm/mmap.c: reduce subtree gap propagation a
 little
Message-ID: <20190828082738.GA20183@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190828060614.19535-1-richardw.yang@linux.intel.com>
 <4503e006-76ba-ed06-0184-6e361a66ba88@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4503e006-76ba-ed06-0184-6e361a66ba88@suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 10:01:40AM +0200, Vlastimil Babka wrote:
>On 8/28/19 8:06 AM, Wei Yang wrote:
>> When insert and delete a vma, it will compute and propagate related subtree
>> gap. After some investigation, we can reduce subtree gap propagation a little.
>> 
>> [1]: This one reduce the propagation by update *next* gap after itself, since
>>      *next* must be a parent in this case.
>> [2]: This one achieve this by unlinking vma from list.
>> 
>> After applying these two patches, test shows it reduce 0.3% function call for
>> vma_compute_subtree_gap.
>
>BTW, what's the overall motivation of focusing so much
>micro-optimization effort on the vma tree lately? This has been rather
>stable code where we can be reasonably sure of all bugs being found. Now
>even after some review effort, subtle bugs can be introduced. And
>Matthew was warning for a while about an upcoming major rewrite of the
>whole data structure, which will undo all this effort?
>

Hi, Vlastimil

Thanks for your comment.

I just found there could be some refine for the code and then I modify and
test it. Hope this could help a little.

You concern is valid. The benefits / cost may be not that impressive. The
community have the final decision. For me, I just want to make it better if we
can.

-- 
Wei Yang
Help you, Help me

