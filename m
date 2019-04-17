Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEAA8C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 22:29:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68ACB217FA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 22:29:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68ACB217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA0726B0005; Wed, 17 Apr 2019 18:29:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B50A56B0006; Wed, 17 Apr 2019 18:29:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3EDB6B0007; Wed, 17 Apr 2019 18:29:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 800FF6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 18:29:11 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g17so319428qte.17
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:29:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=l8qGR2LhMkpZQuyF/Cwt+x8J/SVCnJLnjkKEvW3pprY=;
        b=eX8nWEIvZns/HfAh3ZG4Fpzvc6AOfZ9BrFRXjQkmYOBXXrh3QtAcSHvhgzReOY/l9R
         WJOLRuT6qThYxSPjYT8ruCZO5YZ0a2ie+zx/97poNzQEQ+vZ/+xKU/8etdKBQQ/0Lv33
         d7qiUyb61xpbY7PJWYkKiOrhgLA/FgHusrxFyO3Td5UwNxxLPcxdaAueRx40C3cuZto3
         vzfPBMMkYguga6FMIabTP2o4l5SH4+UXOe4jg9TNKbGiPxqFGR3cU4Cbs5dXnLeHX9M6
         FZAP4xKJwjbrcZf9+UR+DranZZxg4wCCf+jUj0gfkQCmgCGALwWP+sUA0+LvzcWkpZkP
         T7CQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWIUwOram68IXbVWKNKcJ9Xd1dAVQXSyzhFYWur8jYn3L0+nQKJ
	xOip9xEAQ5fQoUyBOEEFAhf3Eyrp39oIygpOCk3oxNjoNsOKtyGHg8dgr11u9DflVAjJmDwrc01
	D35zxfnRRkkZU/nbo+DYD3OT3jNT4X59Wwb0oCRqkmZYkQmKojottLk2H0E2fndYJZw==
X-Received: by 2002:a37:acc:: with SMTP id 195mr10849542qkk.231.1555540151196;
        Wed, 17 Apr 2019 15:29:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKqMLajwWbcwTt16eAX5LeJfQ9MAKrBeW2TrKSuHS9qCbMD9+PqbUECRgTuDrwAvxAU7Fz
X-Received: by 2002:a37:acc:: with SMTP id 195mr10849459qkk.231.1555540150073;
        Wed, 17 Apr 2019 15:29:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555540150; cv=none;
        d=google.com; s=arc-20160816;
        b=1EFw54k3mFjFYgMBQ1rN6okwDiHBtA5/++HlN+uMp9QpZU+/X7zvD9w51adtEHtZlB
         +09B+k8svipP6o9zAIPrVL0X82LngFk3cRNDEJWS+hGI7fbY1W1LuZ8bDRFt38PVg8Uy
         NpJRHDFx65/gi1FZ/AR4htWNNCU3rfqCdrItTA3ohjcR3H6OK1T2dM4gpBn8DTd3EJFe
         LG6L4dSNhunQQ0EfX63GPmuU3vEXviQGCNTDCIGgmG638FTXTRa2bQwWg9/PRJ636cpC
         RTeFamaWKGwOvIZU+sl3rSaoAwOPHboUmg5JC8OE7eM1LE6juYNevZzC/dRedNSYzjSx
         bcxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=l8qGR2LhMkpZQuyF/Cwt+x8J/SVCnJLnjkKEvW3pprY=;
        b=PRFaIzfsndtC+tsPTYETUjFUBK1JPEoAxatSvzF7aq8nw7JhKNAV9PpKDLTaKjpi34
         FhLYmJH1uJAroqwSSL0HV0SSlOt0IcO3FMDTu0Q619ohN03q/RrTrV+zdscOzLRqtMS1
         0xm+3H95jVsm468GO4cbiD4r1XTaHgPZKbRDlTMBJ7rsg/B9k7vr+rQ0NssRRBh0FGk5
         R5n9NUYBYXOJiqmajP1tqk7a3urhr3FhyXXNX2RWXVcoJJl1+JFsMzhC9n7URe/QrUV3
         cKSIFjAj78SSyB4ckxAPETyPNloIaCoXYrdZ/pensK0SqKNQAugmTQ7KWphxGSSFRWvB
         dNxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g24si69112qtk.95.2019.04.17.15.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 15:29:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7F5A186677;
	Wed, 17 Apr 2019 22:29:08 +0000 (UTC)
Received: from redhat.com (ovpn-120-213.rdu2.redhat.com [10.10.120.213])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7DF605D9D6;
	Wed, 17 Apr 2019 22:29:00 +0000 (UTC)
Date: Wed, 17 Apr 2019 18:28:58 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
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
Message-ID: <20190417222858.GA4146@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <20190416194936.GD21526@redhat.com>
 <CAPcyv4i-YHH+dH8za1i1aMcHzQXfovVSrRFp_nfa-KYN-XhAvw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4i-YHH+dH8za1i1aMcHzQXfovVSrRFp_nfa-KYN-XhAvw@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 17 Apr 2019 22:29:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 02:53:28PM -0700, Dan Williams wrote:
> On Tue, Apr 16, 2019 at 12:50 PM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Apr 16, 2019 at 12:12:27PM -0700, Dan Williams wrote:
> > > On Tue, Apr 16, 2019 at 11:59 AM Kent Overstreet
> > > <kent.overstreet@gmail.com> wrote:
> > > >
> > > > On Tue, Apr 16, 2019 at 09:35:04PM +0300, Boaz Harrosh wrote:
> > > > > On Thu, Apr 11, 2019 at 05:08:19PM -0400, jglisse@redhat.com wrote:
> > > > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > > >
> > > > > > This patchset depends on various small fixes [1] and also on patchset
> > > > > > which introduce put_user_page*() [2] and thus is 5.3 material as those
> > > > > > pre-requisite will get in 5.2 at best. Nonetheless i am posting it now
> > > > > > so that it can get review and comments on how and what should be done
> > > > > > to test things.
> > > > > >
> > > > > > For various reasons [2] [3] we want to track page reference through GUP
> > > > > > differently than "regular" page reference. Thus we need to keep track
> > > > > > of how we got a page within the block and fs layer. To do so this patch-
> > > > > > set change the bio_bvec struct to store a pfn and flags instead of a
> > > > > > direct pointer to a page. This way we can flag page that are coming from
> > > > > > GUP.
> > > > > >
> > > > > > This patchset is divided as follow:
> > > > > >     - First part of the patchset is just small cleanup i believe they
> > > > > >       can go in as his assuming people are ok with them.
> > > > >
> > > > >
> > > > > >     - Second part convert bio_vec->bv_page to bio_vec->bv_pfn this is
> > > > > >       done in multi-step, first we replace all direct dereference of
> > > > > >       the field by call to inline helper, then we introduce macro for
> > > > > >       bio_bvec that are initialized on the stack. Finaly we change the
> > > > > >       bv_page field to bv_pfn.
> > > > >
> > > > > Why do we need a bv_pfn. Why not just use the lowest bit of the page-ptr
> > > > > as a flag (pointer always aligned to 64 bytes in our case).
> > > > >
> > > > > So yes we need an inline helper for reference of the page but is it not clearer
> > > > > that we assume a page* and not any kind of pfn ?
> > > > > It will not be the first place using low bits of a pointer for flags.
> > > > >
> > > > > That said. Why we need it at all? I mean why not have it as a bio flag. If it exist
> > > > > at all that a user has a GUP and none-GUP pages to IO at the same request he/she
> > > > > can just submit them as two separate BIOs (chained at the block layer).
> > > > >
> > > > > Many users just submit one page bios and let elevator merge them any way.
> > > >
> > > > Let's please not add additional flags and weirdness to struct bio - "if this
> > > > flag is set interpret one way, if not interpret another" - or eventually bios
> > > > will be as bad as skbuffs. I would much prefer just changing bv_page to bv_pfn.
> > >
> > > This all reminds of the failed attempt to teach the block layer to
> > > operate without pages:
> > >
> > > https://lore.kernel.org/lkml/20150316201640.33102.33761.stgit@dwillia2-desk3.amr.corp.intel.com/
> > >
> > > >
> > > > Question though - why do we need a flag for whether a page is a GUP page or not?
> > > > Couldn't the needed information just be determined by what range the pfn is not
> > > > (i.e. whether or not it has a struct page associated with it)?
> > >
> > > That amounts to a pfn_valid() check which is a bit heavier than if we
> > > can store a flag in the bv_pfn entry directly.
> > >
> > > I'd say create a new PFN_* flag, and make bv_pfn a 'pfn_t' rather than
> > > an 'unsigned long'.
> > >
> > > That said, I'm still in favor of Jan's proposal to just make the
> > > bv_page semantics uniform. Otherwise we're complicating this core
> > > infrastructure for some yet to be implemented GPU memory management
> > > capabilities with yet to be determined value. Circle back when that
> > > value is clear, but in the meantime fix the GUP bug.
> >
> > This has nothing to do with GPU, what make you think so ? Here i am
> > trying to solve GUP and to keep the value of knowing wether a page
> > has been GUP or not. I argue that if we bias every page in every bio
> > then we loose that information and thus the value.
> >
> > I gave the page protection mechanisms as an example that would be
> > impacted but it is not the only one. Knowing if a page has been GUP
> > can be useful for memory reclaimation, compaction, NUMA balancing,
> 
> Right, this is what I was reacting to in your pushback to Jan's
> proposal. You're claiming value for not doing the simple thing for
> some future "may be useful in these contexts". To my knowledge those
> things are not broken today. You're asking for the complexity to be
> carried today for some future benefit, and I'm asking for the
> simplicity to be maintained as much as possible today and let the
> value of future changes stand on their own to push for more complexity
> later.
> 
> Effectively don't use this bug fix to push complexity for a future
> agenda where the value has yet to be quantified.

Except that this solution (biasing everyone in bio) would _more complex_
it is only conceptualy appealing. The changes are on the other hand much
deeper and much riskier but you decided to ignore that and focus on some-
thing i was just giving as an example.

Jérôme

