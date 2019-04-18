Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3972C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:30:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D28920869
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:30:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D28920869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E20F16B0007; Thu, 18 Apr 2019 11:30:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD01D6B0008; Thu, 18 Apr 2019 11:30:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC22B6B000A; Thu, 18 Apr 2019 11:30:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0C96B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:30:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f7so1453514edi.3
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:30:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rFg3kMcE+hO05VH0qb/fQxqDRa1K0LxS2sDiFgjuiuk=;
        b=SDxZSo7kenF68BlBnJmFhKIJy/Q2dD7EUCmeig9zJENDG4E01poxZQuM59mn3+pD7n
         JcYxBoQOI3N3vf7LwD6T8k56U4WinBxgMd3JxslZIIfQkq0H8pJR8AnbPTJd+pX825jq
         MoQzwp/BzObCOhdJjjZiAIW7AZLNgBwVyMGaEAueQP8P11HB8ILyKxA2p0IsheESI+Uj
         9rkLHyAfMq8nL8SZovldnPCmMwxL0UVZV6pcOIar//GCQ7nor22xdqIHaF0qFmhiq/tx
         bhl2jKyedUkAx8WT8F2bHUPZVTznPILUG6yhYXIplbwG5eJywT1+3oeLgPVgVd/C5M9G
         GF7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAV8YLodZBbDcVkor3hrf8ZQRyddLmS5PCw836up/79Zv4QfFTYP
	ofJ2tiqFrwwxAfTiZ/vIC+ZnmL814ynLxPqr0uDMI0mIr0E58PH0LqKpRLGuzM7Bi1OUw3TJxb3
	0uv4bYReVeo3vmrYz8gzlGx/zQFpoRjvSI0zWG/pn0p4ynEdUvqWK3U6IvUHNApvNNg==
X-Received: by 2002:a17:906:5ad6:: with SMTP id x22mr47625392ejs.79.1555601452977;
        Thu, 18 Apr 2019 08:30:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRyKwMLx3qcaLBeEmJiq0o3gDE47yXHYlVMCcU/mE1NIdR9AXekzNuRsICJf9PziDXCjFa
X-Received: by 2002:a17:906:5ad6:: with SMTP id x22mr47625327ejs.79.1555601451709;
        Thu, 18 Apr 2019 08:30:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555601451; cv=none;
        d=google.com; s=arc-20160816;
        b=whnNw7TP5S5kHL6qYCRYHkZmx0VPjpnVpnU+yUB7ocsj0YEYjPd5c3X/mmeXVq8YK3
         F0b16Nxnu1TYlJrcVCVhYE5fUisG721E+9nuna/tbsGX6fIG4jbF8e91kQwUzzVqncyJ
         aPSb6zx2IAqGkFEf/Bezw98NFoECQoTciPfnretp/TV6dY6Q+SBjKvxZRwByDzjHynkL
         cshptJhbZOBCKAoX2s07ZMUjS3ckZ313ur93CysKhtRa4qMpCeUJkRNaSPqwZYqWoQ7X
         p2G3W/JHqxGd+8wU68lvkxOTz1j9Ywb5PDks9uegqaV+XXcCdLW0vFTy5DPF+Zv3Bujr
         sXyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=rFg3kMcE+hO05VH0qb/fQxqDRa1K0LxS2sDiFgjuiuk=;
        b=mJeh+jRSQiWVuxRRC2JXzg2E0xr+DZ6akE7vupAUoyWZVJOvoq3DeaYBGG0f8RZcrE
         pA1azFb8lo9CWCAndMVJdwp99U4omiwkVfE75OpXvm0ZR2XaYQdpt2K9f5XBoyVZ6bOz
         NsZywgLgLJtzu/XxwQQqjRro/OkK4JI9TBlRr+cRF4KWWObylMmoDkbtcgV/MP++OFOn
         4Vb5skEjRYTQmGUZaERxMZf7EjElTgtFSrmt/FOP89QijUAG8R0B1OrfSsF1M8j/Cl6v
         a3/J4EKJ6JeX7mmpIcg3FODboIdnMxZJpvYHi4tENBL32nhwWIbEN9LkS6rmRaK94IV8
         56qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bq13si1134451ejb.7.2019.04.18.08.30.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 08:30:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B2FC1B11D;
	Thu, 18 Apr 2019 15:30:50 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 4B1B01E15AE; Thu, 18 Apr 2019 17:30:47 +0200 (CEST)
Date: Thu, 18 Apr 2019 17:30:47 +0200
From: Jan Kara <jack@suse.cz>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
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
Message-ID: <20190418153047.GN28541@quack2.suse.cz>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <20190416194936.GD21526@redhat.com>
 <CAPcyv4i-YHH+dH8za1i1aMcHzQXfovVSrRFp_nfa-KYN-XhAvw@mail.gmail.com>
 <20190417222858.GA4146@redhat.com>
 <20190418104205.GA28541@quack2.suse.cz>
 <20190418142729.GB3288@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190418142729.GB3288@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 18-04-19 10:27:29, Jerome Glisse wrote:
> On Thu, Apr 18, 2019 at 12:42:05PM +0200, Jan Kara wrote:
> > On Wed 17-04-19 18:28:58, Jerome Glisse wrote:
> > > On Wed, Apr 17, 2019 at 02:53:28PM -0700, Dan Williams wrote:
> > > > On Tue, Apr 16, 2019 at 12:50 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > >
> > > > > On Tue, Apr 16, 2019 at 12:12:27PM -0700, Dan Williams wrote:
> > > > > > On Tue, Apr 16, 2019 at 11:59 AM Kent Overstreet
> > > > > > <kent.overstreet@gmail.com> wrote:
> > > > > > >
> > > > > > > On Tue, Apr 16, 2019 at 09:35:04PM +0300, Boaz Harrosh wrote:
> > > > > > > > On Thu, Apr 11, 2019 at 05:08:19PM -0400, jglisse@redhat.com wrote:
> > > > > > > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > > > > > >
> > > > > > > > > This patchset depends on various small fixes [1] and also on patchset
> > > > > > > > > which introduce put_user_page*() [2] and thus is 5.3 material as those
> > > > > > > > > pre-requisite will get in 5.2 at best. Nonetheless i am posting it now
> > > > > > > > > so that it can get review and comments on how and what should be done
> > > > > > > > > to test things.
> > > > > > > > >
> > > > > > > > > For various reasons [2] [3] we want to track page reference through GUP
> > > > > > > > > differently than "regular" page reference. Thus we need to keep track
> > > > > > > > > of how we got a page within the block and fs layer. To do so this patch-
> > > > > > > > > set change the bio_bvec struct to store a pfn and flags instead of a
> > > > > > > > > direct pointer to a page. This way we can flag page that are coming from
> > > > > > > > > GUP.
> > > > > > > > >
> > > > > > > > > This patchset is divided as follow:
> > > > > > > > >     - First part of the patchset is just small cleanup i believe they
> > > > > > > > >       can go in as his assuming people are ok with them.
> > > > > > > >
> > > > > > > >
> > > > > > > > >     - Second part convert bio_vec->bv_page to bio_vec->bv_pfn this is
> > > > > > > > >       done in multi-step, first we replace all direct dereference of
> > > > > > > > >       the field by call to inline helper, then we introduce macro for
> > > > > > > > >       bio_bvec that are initialized on the stack. Finaly we change the
> > > > > > > > >       bv_page field to bv_pfn.
> > > > > > > >
> > > > > > > > Why do we need a bv_pfn. Why not just use the lowest bit of the page-ptr
> > > > > > > > as a flag (pointer always aligned to 64 bytes in our case).
> > > > > > > >
> > > > > > > > So yes we need an inline helper for reference of the page but is it not clearer
> > > > > > > > that we assume a page* and not any kind of pfn ?
> > > > > > > > It will not be the first place using low bits of a pointer for flags.
> > > > > > > >
> > > > > > > > That said. Why we need it at all? I mean why not have it as a bio flag. If it exist
> > > > > > > > at all that a user has a GUP and none-GUP pages to IO at the same request he/she
> > > > > > > > can just submit them as two separate BIOs (chained at the block layer).
> > > > > > > >
> > > > > > > > Many users just submit one page bios and let elevator merge them any way.
> > > > > > >
> > > > > > > Let's please not add additional flags and weirdness to struct bio - "if this
> > > > > > > flag is set interpret one way, if not interpret another" - or eventually bios
> > > > > > > will be as bad as skbuffs. I would much prefer just changing bv_page to bv_pfn.
> > > > > >
> > > > > > This all reminds of the failed attempt to teach the block layer to
> > > > > > operate without pages:
> > > > > >
> > > > > > https://lore.kernel.org/lkml/20150316201640.33102.33761.stgit@dwillia2-desk3.amr.corp.intel.com/
> > > > > >
> > > > > > >
> > > > > > > Question though - why do we need a flag for whether a page is a GUP page or not?
> > > > > > > Couldn't the needed information just be determined by what range the pfn is not
> > > > > > > (i.e. whether or not it has a struct page associated with it)?
> > > > > >
> > > > > > That amounts to a pfn_valid() check which is a bit heavier than if we
> > > > > > can store a flag in the bv_pfn entry directly.
> > > > > >
> > > > > > I'd say create a new PFN_* flag, and make bv_pfn a 'pfn_t' rather than
> > > > > > an 'unsigned long'.
> > > > > >
> > > > > > That said, I'm still in favor of Jan's proposal to just make the
> > > > > > bv_page semantics uniform. Otherwise we're complicating this core
> > > > > > infrastructure for some yet to be implemented GPU memory management
> > > > > > capabilities with yet to be determined value. Circle back when that
> > > > > > value is clear, but in the meantime fix the GUP bug.
> > > > >
> > > > > This has nothing to do with GPU, what make you think so ? Here i am
> > > > > trying to solve GUP and to keep the value of knowing wether a page
> > > > > has been GUP or not. I argue that if we bias every page in every bio
> > > > > then we loose that information and thus the value.
> > > > >
> > > > > I gave the page protection mechanisms as an example that would be
> > > > > impacted but it is not the only one. Knowing if a page has been GUP
> > > > > can be useful for memory reclaimation, compaction, NUMA balancing,
> > > > 
> > > > Right, this is what I was reacting to in your pushback to Jan's
> > > > proposal. You're claiming value for not doing the simple thing for
> > > > some future "may be useful in these contexts". To my knowledge those
> > > > things are not broken today. You're asking for the complexity to be
> > > > carried today for some future benefit, and I'm asking for the
> > > > simplicity to be maintained as much as possible today and let the
> > > > value of future changes stand on their own to push for more complexity
> > > > later.
> > > > 
> > > > Effectively don't use this bug fix to push complexity for a future
> > > > agenda where the value has yet to be quantified.
> > > 
> > > Except that this solution (biasing everyone in bio) would _more complex_
> > > it is only conceptualy appealing. The changes are on the other hand much
> > > deeper and much riskier but you decided to ignore that and focus on some-
> > > thing i was just giving as an example.
> > 
> > Yeah, after going and reading several places like fs/iomap.c, fs/mpage.c,
> > drivers/md/dm-io.c I agree with you. The places that are not doing direct
> > IO usually just don't hold any page reference that could be directly
> > attributed to the bio (and they don't drop it when bio finishes). They
> > rather use other means (like PageLocked, PageWriteback) to make sure the
> > page stays alive so mandating gup-pin reference for all pages attached to a
> > bio would require a lot of reworking of places that are not related to our
> > problem and currently work just fine. So I withdraw my suggestion. Nice in
> > theory, too much work in practice ;).
> 
> Have you seem Boaz proposal ? I have started it and it does not look to
> bad (but you knwo taste and color :)) You can take a peek:
> 
> https://cgit.freedesktop.org/~glisse/linux/log/?h=gup-bio-v2
> 
> I need to finish that and run fstests on bunch of different fs before
> posting. Dunno if i will have enough time to do that before LSF/MM.

Yes, I've seen it. I just wasn't sure how the result will look like. What
you have in your tree looks pretty clean so far. BTW (I know I'm repeating
myself ;) what if we made iov_iter_get_pages() & iov_iter_get_pages_alloc()
always return gup-pin reference? That would get rid of the need for two
ioend handlers for each call site...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

