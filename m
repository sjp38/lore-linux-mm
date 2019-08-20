Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76337C3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:06:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E46422CF5
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:06:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E46422CF5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A90546B000A; Tue, 20 Aug 2019 07:06:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A40C96B000C; Tue, 20 Aug 2019 07:06:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 958186B000D; Tue, 20 Aug 2019 07:06:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 77D9D6B000A
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:06:28 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0A94283F2
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:06:28 +0000 (UTC)
X-FDA: 75842527656.30.jelly83_1b50a8b4ffc0f
X-HE-Tag: jelly83_1b50a8b4ffc0f
X-Filterd-Recvd-Size: 2494
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:06:27 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CD029AE9A;
	Tue, 20 Aug 2019 11:06:25 +0000 (UTC)
Subject: Re: [PATCH] btrfs: fix allocation of bitmap pages.
To: Christoph Hellwig <hch@infradead.org>, dsterba@suse.cz,
 Christophe Leroy <christophe.leroy@c-s.fr>, erhard_f@mailbox.org,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 David Sterba <dsterba@suse.com>, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-btrfs@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org
References: <20190817074439.84C6C1056A3@localhost.localdomain>
 <20190819174600.GN24086@twin.jikos.cz> <20190820023031.GC9594@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6f99b73c-db8f-8135-b827-0a135734d7da@suse.cz>
Date: Tue, 20 Aug 2019 13:06:25 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190820023031.GC9594@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/20/19 4:30 AM, Christoph Hellwig wrote:
> On Mon, Aug 19, 2019 at 07:46:00PM +0200, David Sterba wrote:
>> Another thing that is lost is the slub debugging support for all
>> architectures, because get_zeroed_pages lacking the red zones and sanity
>> checks.
>> 
>> I find working with raw pages in this code a bit inconsistent with the
>> rest of btrfs code, but that's rather minor compared to the above.
>> 
>> Summing it up, I think that the proper fix should go to copy_page
>> implementation on architectures that require it or make it clear what
>> are the copy_page constraints.
> 
> The whole point of copy_page is to copy exactly one page and it makes
> sense to assume that is aligned.  A sane memcpy would use the same
> underlying primitives as well after checking they fit.  So I think the
> prime issue here is btrfs' use of copy_page instead of memcpy.  The
> secondary issue is slub fucking up alignments for no good reason.  We
> just got bitten by that crap again in XFS as well :(

Meh, I should finally get back to https://lwn.net/Articles/787740/ right



