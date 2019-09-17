Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFE82C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 08:50:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74EE220862
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 08:50:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="ilkHUpp/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74EE220862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DF9F6B0003; Tue, 17 Sep 2019 04:50:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 091156B0005; Tue, 17 Sep 2019 04:50:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC1B16B0006; Tue, 17 Sep 2019 04:50:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0094.hostedemail.com [216.40.44.94])
	by kanga.kvack.org (Postfix) with ESMTP id CC7AE6B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 04:50:14 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 736DE8E6B
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 08:50:14 +0000 (UTC)
X-FDA: 75943790748.19.boy31_1f175b482191b
X-HE-Tag: boy31_1f175b482191b
X-Filterd-Recvd-Size: 7786
Received: from mail-wm1-f67.google.com (mail-wm1-f67.google.com [209.85.128.67])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 08:50:13 +0000 (UTC)
Received: by mail-wm1-f67.google.com with SMTP id t3so2095391wmj.1
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 01:50:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/VonGSSqqMDxfF4QwP1WKI+1bEgxLGoOBgLkXqBtfQA=;
        b=ilkHUpp/PYb0KHuZDcHzX1Ounlux5/YOswWqF8JQI4guW6HyXLoFNHBxUeNmgS4wgj
         K9dFh8cZLWZ/BdmJbF43N1GQBPg6kjKVLrRXRYjgVYTnMrRDG220nh4uH/Ae07miHenH
         41eiYv/vkY2/0nZDXcre85bHwnoMGFfGzSUqgb4/Zr6YXyN+4KRF5kOyRV10MSKNKVVE
         isggylYG8cxJ7Bqb3NED3KeUBFmz3uLAa7onauWOba53gvEICMBj/MDYo+Y8qIHRHc1O
         PMMWfgl1quOU1X7L9GHDhmzpPIchZUCWJ1X84ePdTR8qDIu1hS7xXVb+9iSwfCNp03eK
         vohA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=/VonGSSqqMDxfF4QwP1WKI+1bEgxLGoOBgLkXqBtfQA=;
        b=YvMvTnSap/62SoS0SQSiHFH0zi+z0AbjSdws4kysUItAGRN8LHL0BRBcYOVHIpV3Pa
         sJTYanq0S4AdXk7cphvv3ehwOEBSNW2jWst+i0gFFFzktPGx04oYTwvx6K/929RdrNrz
         /T46aauQ9LB51NxeKxBUL1tG/2mGBzMbysp/EDNjFJq6jp5IoFlszl9V7taN8R3xxonA
         7Ogro4WwO/IB3+jBL7Ps6aVd6bHg0aO2nB7eCVhsl6EDKgohsA9C8mHGDpz1O/OKfDVv
         PP9TYPZQmre/547m4KhT6O/f9Xyrc5lRJ9kRls7JcfiNfxjqNFTG1KQky+i1nYNDdSNE
         5lHA==
X-Gm-Message-State: APjAAAXnDPK90s7F2E9E2TPHvnHvHucsELa/3NyFZ7HAR7RdSFX9MdM0
	rYVpxvaHK48gyzcPYKeHxsaIug==
X-Google-Smtp-Source: APXvYqxmUuN4vsQBrM1hohQXVK4AD/ImfVSsKnQMjN5EZZTIlBaWxTXWVN88fT67M4dyPna59whj+g==
X-Received: by 2002:a7b:c949:: with SMTP id i9mr2307693wml.136.1568710212091;
        Tue, 17 Sep 2019 01:50:12 -0700 (PDT)
Received: from localhost (p4FC6BBBF.dip0.t-ipconnect.de. [79.198.187.191])
        by smtp.gmail.com with ESMTPSA id x6sm2904730wmf.35.2019.09.17.01.50.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Sep 2019 01:50:11 -0700 (PDT)
Date: Tue, 17 Sep 2019 10:50:04 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH RFC 01/14] mm: memcg: subpage charging API
Message-ID: <20190917085004.GA1486@cmpxchg.org>
References: <20190905214553.1643060-1-guro@fb.com>
 <20190905214553.1643060-2-guro@fb.com>
 <20190916125611.GB29985@cmpxchg.org>
 <20190917022713.GB8073@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190917022713.GB8073@castle.DHCP.thefacebook.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 02:27:19AM +0000, Roman Gushchin wrote:
> On Mon, Sep 16, 2019 at 02:56:11PM +0200, Johannes Weiner wrote:
> > On Thu, Sep 05, 2019 at 02:45:45PM -0700, Roman Gushchin wrote:
> > > Introduce an API to charge subpage objects to the memory cgroup.
> > > The API will be used by the new slab memory controller. Later it
> > > can also be used to implement percpu memory accounting.
> > > In both cases, a single page can be shared between multiple cgroups
> > > (and in percpu case a single allocation is split over multiple pages),
> > > so it's not possible to use page-based accounting.
> > > 
> > > The implementation is based on percpu stocks. Memory cgroups are still
> > > charged in pages, and the residue is stored in perpcu stock, or on the
> > > memcg itself, when it's necessary to flush the stock.
> > 
> > Did you just implement a slab allocator for page_counter to track
> > memory consumed by the slab allocator?
> 
> :)
> 
> > 
> > > @@ -2500,8 +2577,9 @@ void mem_cgroup_handle_over_high(void)
> > >  }
> > >  
> > >  static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > > -		      unsigned int nr_pages)
> > > +		      unsigned int amount, bool subpage)
> > >  {
> > > +	unsigned int nr_pages = subpage ? ((amount >> PAGE_SHIFT) + 1) : amount;
> > >  	unsigned int batch = max(MEMCG_CHARGE_BATCH, nr_pages);
> > >  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > >  	struct mem_cgroup *mem_over_limit;
> > > @@ -2514,7 +2592,9 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > >  	if (mem_cgroup_is_root(memcg))
> > >  		return 0;
> > >  retry:
> > > -	if (consume_stock(memcg, nr_pages))
> > > +	if (subpage && consume_subpage_stock(memcg, amount))
> > > +		return 0;
> > > +	else if (!subpage && consume_stock(memcg, nr_pages))
> > >  		return 0;
> > 
> > The layering here isn't clean. We have an existing per-cpu cache to
> > batch-charge the page counter. Why does the new subpage allocator not
> > sit on *top* of this, instead of wedged in between?
> > 
> > I think what it should be is a try_charge_bytes() that simply gets one
> > page from try_charge() and then does its byte tracking, regardless of
> > how try_charge() chooses to implement its own page tracking.
> > 
> > That would avoid the awkward @amount + @subpage multiplexing, as well
> > as annotating all existing callsites of try_charge() with a
> > non-descript "false" parameter.
> > 
> > You can still reuse the stock data structures, use the lower bits of
> > stock->nr_bytes for a different cgroup etc., but the charge API should
> > really be separate.
> 
> Hm, I kinda like the idea, however there is a complication: for the subpage
> accounting the css reference management is done in a different way, so that
> all existing code should avoid changing the css refcounter. So I'd need
> to pass a boolean argument anyway.

Can you elaborate on the refcounting scheme? I don't quite understand
how there would be complications with that.

Generally, references are held for each page that is allocated in the
page_counter. try_charge() allocates a batch of css references,
returns one and keeps the rest in stock.

So couldn't the following work?

When somebody allocates a subpage, the css reference returned by
try_charge() is shared by the allocated subpage object and the
remainder that is kept via stock->subpage_cache and stock->nr_bytes
(or memcg->nr_stocked_bytes when the percpu cache is reset).

When the subpage objects are freed, you'll eventually have a full page
again in stock->nr_bytes, at which point you page_counter_uncharge()
paired with css_put(_many) as per usual.

A remainder left in old->nr_stocked_bytes would continue to hold on to
one css reference. (I don't quite understand who is protecting this
remainder in your current version, actually. A bug?)

Instead of doing your own batched page_counter uncharging in
refill_subpage_stock() -> drain_subpage_stock(), you should be able to
call refill_stock() when stock->nr_bytes adds up to a whole page again.

Again, IMO this would be much cleaner architecture if there was a
try_charge_bytes() byte allocator that would sit on top of a cleanly
abstracted try_charge() page allocator, just like the slab allocator
is sitting on top of the page allocator - instead of breaking through
the abstraction layer of the underlying page allocator.

