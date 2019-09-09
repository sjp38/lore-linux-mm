Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9639C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:12:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A735C21D7B
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:12:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A735C21D7B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45D416B000C; Mon,  9 Sep 2019 11:12:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40D3A6B000D; Mon,  9 Sep 2019 11:12:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34AFA6B000E; Mon,  9 Sep 2019 11:12:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0126.hostedemail.com [216.40.44.126])
	by kanga.kvack.org (Postfix) with ESMTP id 142D46B000C
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:12:15 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B0F44181AC9B6
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:12:14 +0000 (UTC)
X-FDA: 75915722988.15.judge01_87ecd46eec400
X-HE-Tag: judge01_87ecd46eec400
X-Filterd-Recvd-Size: 4890
Received: from mga14.intel.com (mga14.intel.com [192.55.52.115])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:12:13 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 08:12:12 -0700
X-IronPort-AV: E=Sophos;i="5.64,486,1559545200"; 
   d="scan'208";a="335622307"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga004-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 08:12:12 -0700
Message-ID: <f2fc0cda183098aa9b3b071ff0f49249f6d94bd5.camel@linux.intel.com>
Subject: Re: [PATCH v9 1/8] mm: Add per-cpu logic to page shuffling
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com, 
 catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com, 
 linux-kernel@vger.kernel.org, willy@infradead.org, mhocko@kernel.org, 
 linux-mm@kvack.org, akpm@linux-foundation.org, will@kernel.org, 
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de,
 yang.zhang.wz@gmail.com,  pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com,  lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com,  ying.huang@intel.com,
 pbonzini@redhat.com, dan.j.williams@intel.com,  fengguang.wu@intel.com,
 kirill.shutemov@linux.intel.com
Date: Mon, 09 Sep 2019 08:12:12 -0700
In-Reply-To: <20190909090701.7ebz4foxyu3rxzvc@box>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
	 <20190907172512.10910.74435.stgit@localhost.localdomain>
	 <20190909090701.7ebz4foxyu3rxzvc@box>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-09 at 12:07 +0300, Kirill A. Shutemov wrote:
> On Sat, Sep 07, 2019 at 10:25:12AM -0700, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Change the logic used to generate randomness in the suffle path so that we
> 
> Typo.
> 
> > can avoid cache line bouncing. The previous logic was sharing the offset
> > and entropy word between all CPUs. As such this can result in cache line
> > bouncing and will ultimately hurt performance when enabled.
> > 
> > To resolve this I have moved to a per-cpu logic for maintaining a unsigned
> > long containing some amount of bits, and an offset value for which bit we
> > can use for entropy with each call.
> > 
> > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >  mm/shuffle.c |   33 +++++++++++++++++++++++----------
> >  1 file changed, 23 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/shuffle.c b/mm/shuffle.c
> > index 3ce12481b1dc..9ba542ecf335 100644
> > --- a/mm/shuffle.c
> > +++ b/mm/shuffle.c
> > @@ -183,25 +183,38 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
> >  		shuffle_zone(z);
> >  }
> >  
> > +struct batched_bit_entropy {
> > +	unsigned long entropy_bool;
> > +	int position;
> > +};
> > +
> > +static DEFINE_PER_CPU(struct batched_bit_entropy, batched_entropy_bool);
> > +
> >  void add_to_free_area_random(struct page *page, struct free_area *area,
> >  		int migratetype)
> >  {
> > -	static u64 rand;
> > -	static u8 rand_bits;
> > +	struct batched_bit_entropy *batch;
> > +	unsigned long entropy;
> > +	int position;
> >  
> >  	/*
> > -	 * The lack of locking is deliberate. If 2 threads race to
> > -	 * update the rand state it just adds to the entropy.
> > +	 * We shouldn't need to disable IRQs as the only caller is
> > +	 * __free_one_page and it should only be called with the zone lock
> > +	 * held and either from IRQ context or with local IRQs disabled.
> >  	 */
> > -	if (rand_bits == 0) {
> > -		rand_bits = 64;
> > -		rand = get_random_u64();
> > +	batch = raw_cpu_ptr(&batched_entropy_bool);
> > +	position = batch->position;
> > +
> > +	if (--position < 0) {
> > +		batch->entropy_bool = get_random_long();
> > +		position = BITS_PER_LONG - 1;
> >  	}
> >  
> > -	if (rand & 1)
> > +	batch->position = position;
> > +	entropy = batch->entropy_bool;
> > +
> > +	if (1ul & (entropy >> position))
> 
> Maybe something like this would be more readble:
> 
> 	if (entropy & BIT(position))
> 
> >  		add_to_free_area(page, area, migratetype);
> >  	else
> >  		add_to_free_area_tail(page, area, migratetype);
> > -	rand_bits--;
> > -	rand >>= 1;
> >  }
> > 
> > 

Thanks for the review. I will update these two items for v10.

- Alex


