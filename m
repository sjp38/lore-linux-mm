Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F74DC32754
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:13:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4736621738
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:13:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="rTAT9bH7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4736621738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7D2C6B0007; Tue,  6 Aug 2019 13:13:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B545B6B0008; Tue,  6 Aug 2019 13:13:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6BC96B000A; Tue,  6 Aug 2019 13:13:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71B5A6B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 13:13:47 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id k9so48737874pls.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 10:13:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5ea3uMryef/vRDBptNhuCg1V2qLJggsyW+xZZJ8QfN0=;
        b=AvPH2wKiStxfj4RUY6IKgzHOSCfiEAcpPdie9tuFkM18mBl4cd8tSwpoJtSppsUPKw
         4gioAQpWXm7R1CQtY+VDbK22eLeO16wklbLvNeajW8ykVBu9AbAHkc+zGw4cC4ry4PGg
         ETq5tfAqXnzvW9sZkq+2jbevAqeR2vPPb/Xh9IecS5LlomTjLs/wwtl1QxVqZFs8V+oG
         oF+cbNv3kUduX97Dh+mI9FPquSiVuUADT0JT4XeKH7AEJ+6uXuLRP1rJZXOtVsnTMVZ+
         JUP5cTj+nIvvysbjcYm88eUMPrAAVYXIX9txmSR8vGYISCtl78YAA8Q3FoZtsRQP+Jry
         jHMQ==
X-Gm-Message-State: APjAAAX2PjURKE949F7EJvhKjJZdaRCu+5eH8Y+iTsVCzxW7TSQffqsw
	aTqsCD3XLO9pp8WeddI4H3LtB3FDDK4bKDmJoLkJ3+Hgai8XfDQYoQ0JhWx9Vr1d9C1QmOVPHDB
	WszzKcz7Qlr4NkFAljU94KCxsGy6+1WfGZRljpeWEO2Ud0VD40Zhli8zVO6Q/CThV+A==
X-Received: by 2002:a17:902:1107:: with SMTP id d7mr4128065pla.184.1565111627032;
        Tue, 06 Aug 2019 10:13:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlz7y44ZVKpYSsmJ39cIf2XK4aGWA9bliegIgqoJRVhGHzL6NzYSR6bEdttnQf29/6L9w8
X-Received: by 2002:a17:902:1107:: with SMTP id d7mr4128011pla.184.1565111626113;
        Tue, 06 Aug 2019 10:13:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565111626; cv=none;
        d=google.com; s=arc-20160816;
        b=zk++1Tdv3zIGXoLRAFTmqyHuVLRUTzfa/1EhUpMmkRku5Lo5t0OUAjkiXwhes8dAX6
         TbLsmOmhJfcFLbU2oIDVyKZ/tmPQ1any9T+yXc49LXsg+2nJuPQ4tRRApiXQpCUTP23/
         xBfB912HiJi85d75nmwSMolCPxfNaywKAbcpVynL5HFnm04I92SvHCzR1xqyRY4sXDU8
         ifjHUbGL8p1kc/UwaW/CAkdYiN5Y+uFRzI52ZWjIXFXMwCqauH77fsT3OwbjtDIgsdlc
         jn7e0fSOpJL4yrELa2AXjrYEc7tl9OIkklerHlcL0Uz+c33WJ6oGx18uCqzU0HVmyehz
         HKUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5ea3uMryef/vRDBptNhuCg1V2qLJggsyW+xZZJ8QfN0=;
        b=mS1mkboxh7vWYPZ7Pbcb8yMdbAbRRlnDx2nMQj8Hq3C1AwBKymTR2CxXGCa+80VhQG
         hjz9ldPJhoUnSY7e9vkC/YULB1HhThdG/r25Cdrfz9Nc0L6LglpbldE+ELgp81KOC0yK
         L2dfiAuehoH2JRMyCSNvCvruzEim8mDbUW73GGAcNMwC8X4kh/kpZHXGwUBhyh7vqAWq
         coHle0zg/ZCVem2JAgiOUcCSYVcSxOzXxJ0Q7X+MozvsaBNs1qw/4GO16cfemp3z1BqJ
         pzEYw2OyZan3zGuvuaia5l+sylI41NXz21zVv2/Kv17IGpvyk2pa9dddFe/9pxhtAg8C
         PydA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rTAT9bH7;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y22si42465969plp.192.2019.08.06.10.13.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 10:13:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rTAT9bH7;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7ACF82086D;
	Tue,  6 Aug 2019 17:13:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565111625;
	bh=GcwPgkJicx4YCfVs1IPwu6WwyqpK78qeXeT/YMfDkko=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=rTAT9bH7GKNJUZdS8BRtbH8phw4qgZ5+dRNFkldjVWk6dGxX0O1d/RnE/0V20gryu
	 PTJMl31RRRdUsoRUBPiBr87DgRaB/HWSPKLtCibTJQQUtSYBOvQ2oBVDM1HUaAlT2q
	 mkbOtB7+YYYk5DiFCNquMbqioXWuU2alu3yKrGRo=
Date: Tue, 6 Aug 2019 18:13:36 +0100
From: Will Deacon <will@kernel.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	dri-devel@lists.freedesktop.org, Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
Message-ID: <20190806171335.4dzjex5asoertaob@willie-the-truck>
References: <cover.1563904656.git.andreyknvl@google.com>
 <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
 <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
 <CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
 <20190724142059.GC21234@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724142059.GC21234@fuggles.cambridge.arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 03:20:59PM +0100, Will Deacon wrote:
> On Wed, Jul 24, 2019 at 04:16:49PM +0200, Andrey Konovalov wrote:
> > On Wed, Jul 24, 2019 at 4:02 PM Will Deacon <will@kernel.org> wrote:
> > > On Tue, Jul 23, 2019 at 08:03:29PM +0200, Andrey Konovalov wrote:
> > > > Should this go through the mm or the arm tree?
> > >
> > > I would certainly prefer to take at least the arm64 bits via the arm64 tree
> > > (i.e. patches 1, 2 and 15). We also need a Documentation patch describing
> > > the new ABI.
> > 
> > Sounds good! Should I post those patches together with the
> > Documentation patches from Vincenzo as a separate patchset?
> 
> Yes, please (although as you say below, we need a new version of those
> patches from Vincenzo to address the feedback on v5). The other thing I
> should say is that I'd be happy to queue the other patches in the series
> too, but some of them are missing acks from the relevant maintainers (e.g.
> the mm/ and fs/ changes).

Ok, I've queued patches 1, 2, and 15 on a stable branch here:

  https://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git/log/?h=for-next/tbi

which should find its way into -next shortly via our for-next/core branch.
If you want to make changes, please send additional patches on top.

This is targetting 5.4, but I will drop it before the merge window if
we don't have both of the following in place:

  * Updated ABI documentation with Acks from Catalin and Kevin
  * The other patches in the series either Acked (so I can pick them up)
    or queued via some other tree(s) for 5.4.

Make sense?

Cheers,

Will

