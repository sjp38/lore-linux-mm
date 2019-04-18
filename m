Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E6F5C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:27:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C885A217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:27:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C885A217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 501546B0005; Thu, 18 Apr 2019 10:27:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48A1F6B0006; Thu, 18 Apr 2019 10:27:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3520A6B0007; Thu, 18 Apr 2019 10:27:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 130596B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:27:43 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b188so1843999qkg.15
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:27:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=M9YeBkyZkesFqHmcfbg7FiAHZxxm2bJznV6I0E4+r4k=;
        b=uHaulP8mMaaBmRkwaRlZonHgnh32TOlpEKZazkh9DTM8fuxc10mfDqlfgYhJu0yzmC
         gGAiYMz/IxEALDS1g5DNVj4bJ3xXGKn98gbbj0EnGkhHVRmGLF68i/zNgCNtQq7ed0S0
         bnPNaPQ3/H+miRrKhW2A9P1pkVe7sTaN1RdtvA/XwoDMOiutI2Lz9ttwsTt4mlMO2+L0
         CVU0VRnWfqxEN1xYXJeLlEQe9mYZd9NvCwGBYeSTBVLjBBC17aCKXwfofGpaPDVHlJV2
         WJ7E5WBHBTaAPdspUnBxMgupY9sb8XHcnF01RKT39gkSQkLsiKp5WfMVJq/4wHvlsoqK
         sFHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU+pC9WO4tuvalz8YulF1oldfCfBCUdqfh2sROftRttfyvD+aas
	o1GpzcvfRJA2QMJNlyoYs50gR5iZkV2wC/sjagPtdMlM+N/Dk5p5yBhwcfh/fr65+1AMyDpzA1h
	ytRns3aEGN7Ul3CPxSBHHv56jcKaq0X9yEdAiFg8/lGmpfXRNHkbQWIXw2Gsevz9Vyg==
X-Received: by 2002:a0c:b758:: with SMTP id q24mr30689917qve.31.1555597662811;
        Thu, 18 Apr 2019 07:27:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLUIAhqO3ux5KnTs+RLFZWDV+5r3PohlilPigFaSohQy0BcSaNjbpRUoBZAd+2H4zMkhme
X-Received: by 2002:a0c:b758:: with SMTP id q24mr30689854qve.31.1555597661946;
        Thu, 18 Apr 2019 07:27:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555597661; cv=none;
        d=google.com; s=arc-20160816;
        b=ZOmExwqWajyGM5aQWzPJBFZMIC9cGWTto2oXMEk3Aw601qJmMhQ8TwnOi2SALptKqp
         y+I+1zNVUVBoaMb8UtDr2QsvhiGEZlpYqC9Gf/soGagbUAufjfje5s+1e29i31Esvo21
         Kk1jlF+z0QomuOFKYkGEX8f4vWPMjO5hSN2XO3yuIDIHPGFqbpg+ssd5mip2+JxV/aK7
         bqCFFprwcYX2sQcHfnyea3ZzlgkLw2OtVdYTqiU8fIbGiIGSFlqE56w3C0SAHdUpyA/e
         hZS9LjZt6PRXK3TV+RQ+FgFOyUVfTUxjbmgMfpw9C6nfVcmjgAkwqG1bRGFcMA0uLpj5
         tGxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=M9YeBkyZkesFqHmcfbg7FiAHZxxm2bJznV6I0E4+r4k=;
        b=XcjGNPdT5NCRZboCmFY9xw1pQg7mbVSw8/wyIpe8IdlPp0x2bxGRjI75gvlquryToU
         8771AD97LKnMEEe2Vhb/lauzv6BqWHO1rxA2OnmNrtf0J+D0rmA4OJB4oLpXXQpgdu5g
         Bj9GZy3+qHuRTSoG4DqJG6U/4GyO4LyR95hnzjzuqDj9S2fHaDoL9Wc/E/S+dai5Yor8
         lgkIfBcw6qDN6IXtwD5WGVeFFhVKEnMXX1DQ2h5N4HJxoP15sGWuREm9yHJIxtBWLQej
         TRFu6o7m2oxJIB0O10XGYNJjMWs/5UsIerNHSHcU6k9kW4DcNiW0I7EBaqHRnumkjlx0
         1Kkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 7si1660710qvg.130.2019.04.18.07.27.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 07:27:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D1F1DDBD73;
	Thu, 18 Apr 2019 14:27:40 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 39EAC600C1;
	Thu, 18 Apr 2019 14:27:31 +0000 (UTC)
Date: Thu, 18 Apr 2019 10:27:29 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
	samba-technical@lists.samba.org, Yan Zheng <zyan@redhat.com>,
	Sage Weil <sage@redhat.com>, Ilya Dryomov <idryomov@gmail.com>,
	Alex Elder <elder@kernel.org>, ceph-devel@vger.kernel.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org,
	Dominique Martinet <asmadeus@codewreck.org>,
	v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org,
	Ernesto =?iso-8859-1?Q?A=2E_Fern=E1ndez?= <ernesto.mnd.fernandez@gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
Message-ID: <20190418142729.GB3288@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <20190416194936.GD21526@redhat.com>
 <CAPcyv4i-YHH+dH8za1i1aMcHzQXfovVSrRFp_nfa-KYN-XhAvw@mail.gmail.com>
 <20190417222858.GA4146@redhat.com>
 <20190418104205.GA28541@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190418104205.GA28541@quack2.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 18 Apr 2019 14:27:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 12:42:05PM +0200, Jan Kara wrote:
> On Wed 17-04-19 18:28:58, Jerome Glisse wrote:
> > On Wed, Apr 17, 2019 at 02:53:28PM -0700, Dan Williams wrote:
> > > On Tue, Apr 16, 2019 at 12:50 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > >
> > > > On Tue, Apr 16, 2019 at 12:12:27PM -0700, Dan Williams wrote:
> > > > > On Tue, Apr 16, 2019 at 11:59 AM Kent Overstreet
> > > > > <kent.overstreet@gmail.com> wrote:
> > > > > >
> > > > > > On Tue, Apr 16, 2019 at 09:35:04PM +0300, Boaz Harrosh wrote:
> > > > > > > On Thu, Apr 11, 2019 at 05:08:19PM -0400, jglisse@redhat.com wrote:
> > > > > > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > > > > >
> > > > > > > > This patchset depends on various small fixes [1] and also on patchset
> > > > > > > > which introduce put_user_page*() [2] and thus is 5.3 material as those
> > > > > > > > pre-requisite will get in 5.2 at best. Nonetheless i am posting it now
> > > > > > > > so that it can get review and comments on how and what should be done
> > > > > > > > to test things.
> > > > > > > >
> > > > > > > > For various reasons [2] [3] we want to track page reference through GUP
> > > > > > > > differently than "regular" page reference. Thus we need to keep track
> > > > > > > > of how we got a page within the block and fs layer. To do so this patch-
> > > > > > > > set change the bio_bvec struct to store a pfn and flags instead of a
> > > > > > > > direct pointer to a page. This way we can flag page that are coming from
> > > > > > > > GUP.
> > > > > > > >
> > > > > > > > This patchset is divided as follow:
> > > > > > > >     - First part of the patchset is just small cleanup i believe they
> > > > > > > >       can go in as his assuming people are ok with them.
> > > > > > >
> > > > > > >
> > > > > > > >     - Second part convert bio_vec->bv_page to bio_vec->bv_pfn this is
> > > > > > > >       done in multi-step, first we replace all direct dereference of
> > > > > > > >       the field by call to inline helper, then we introduce macro for
> > > > > > > >       bio_bvec that are initialized on the stack. Finaly we change the
> > > > > > > >       bv_page field to bv_pfn.
> > > > > > >
> > > > > > > Why do we need a bv_pfn. Why not just use the lowest bit of the page-ptr
> > > > > > > as a flag (pointer always aligned to 64 bytes in our case).
> > > > > > >
> > > > > > > So yes we need an inline helper for reference of the page but is it not clearer
> > > > > > > that we assume a page* and not any kind of pfn ?
> > > > > > > It will not be the first place using low bits of a pointer for flags.
> > > > > > >
> > > > > > > That said. Why we need it at all? I mean why not have it as a bio flag. If it exist
> > > > > > > at all that a user has a GUP and none-GUP pages to IO at the same request he/she
> > > > > > > can just submit them as two separate BIOs (chained at the block layer).
> > > > > > >
> > > > > > > Many users just submit one page bios and let elevator merge them any way.
> > > > > >
> > > > > > Let's please not add additional flags and weirdness to struct bio - "if this
> > > > > > flag is set interpret one way, if not interpret another" - or eventually bios
> > > > > > will be as bad as skbuffs. I would much prefer just changing bv_page to bv_pfn.
> > > > >
> > > > > This all reminds of the failed attempt to teach the block layer to
> > > > > operate without pages:
> > > > >
> > > > > https://lore.kernel.org/lkml/20150316201640.33102.33761.stgit@dwillia2-desk3.amr.corp.intel.com/
> > > > >
> > > > > >
> > > > > > Question though - why do we need a flag for whether a page is a GUP page or not?
> > > > > > Couldn't the needed information just be determined by what range the pfn is not
> > > > > > (i.e. whether or not it has a struct page associated with it)?
> > > > >
> > > > > That amounts to a pfn_valid() check which is a bit heavier than if we
> > > > > can store a flag in the bv_pfn entry directly.
> > > > >
> > > > > I'd say create a new PFN_* flag, and make bv_pfn a 'pfn_t' rather than
> > > > > an 'unsigned long'.
> > > > >
> > > > > That said, I'm still in favor of Jan's proposal to just make the
> > > > > bv_page semantics uniform. Otherwise we're complicating this core
> > > > > infrastructure for some yet to be implemented GPU memory management
> > > > > capabilities with yet to be determined value. Circle back when that
> > > > > value is clear, but in the meantime fix the GUP bug.
> > > >
> > > > This has nothing to do with GPU, what make you think so ? Here i am
> > > > trying to solve GUP and to keep the value of knowing wether a page
> > > > has been GUP or not. I argue that if we bias every page in every bio
> > > > then we loose that information and thus the value.
> > > >
> > > > I gave the page protection mechanisms as an example that would be
> > > > impacted but it is not the only one. Knowing if a page has been GUP
> > > > can be useful for memory reclaimation, compaction, NUMA balancing,
> > > 
> > > Right, this is what I was reacting to in your pushback to Jan's
> > > proposal. You're claiming value for not doing the simple thing for
> > > some future "may be useful in these contexts". To my knowledge those
> > > things are not broken today. You're asking for the complexity to be
> > > carried today for some future benefit, and I'm asking for the
> > > simplicity to be maintained as much as possible today and let the
> > > value of future changes stand on their own to push for more complexity
> > > later.
> > > 
> > > Effectively don't use this bug fix to push complexity for a future
> > > agenda where the value has yet to be quantified.
> > 
> > Except that this solution (biasing everyone in bio) would _more complex_
> > it is only conceptualy appealing. The changes are on the other hand much
> > deeper and much riskier but you decided to ignore that and focus on some-
> > thing i was just giving as an example.
> 
> Yeah, after going and reading several places like fs/iomap.c, fs/mpage.c,
> drivers/md/dm-io.c I agree with you. The places that are not doing direct
> IO usually just don't hold any page reference that could be directly
> attributed to the bio (and they don't drop it when bio finishes). They
> rather use other means (like PageLocked, PageWriteback) to make sure the
> page stays alive so mandating gup-pin reference for all pages attached to a
> bio would require a lot of reworking of places that are not related to our
> problem and currently work just fine. So I withdraw my suggestion. Nice in
> theory, too much work in practice ;).

Have you seem Boaz proposal ? I have started it and it does not look to
bad (but you knwo taste and color :)) You can take a peek:

https://cgit.freedesktop.org/~glisse/linux/log/?h=gup-bio-v2

I need to finish that and run fstests on bunch of different fs before
posting. Dunno if i will have enough time to do that before LSF/MM.

Cheers,
Jérôme

