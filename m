Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 337BCC04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:46:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 028F626C66
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:46:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 028F626C66
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F7726B026E; Fri, 31 May 2019 12:46:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 781226B0274; Fri, 31 May 2019 12:46:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 648BB6B0278; Fri, 31 May 2019 12:46:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1736E6B026E
	for <linux-mm@kvack.org>; Fri, 31 May 2019 12:46:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y22so14777943eds.14
        for <linux-mm@kvack.org>; Fri, 31 May 2019 09:46:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aT2yKJPBijRfh3I8dT7YFwqukzizGgjs99pM6UcU/IQ=;
        b=lS6VlqMxSC+vCvpkyRvkgjd2D2UwVNc4yt+qseSDqN93vlF6nHhzUW/releOF8McQF
         cO+u21Mjftivh4noq8lNWW6ls4A1MfWxzTrH+nWY5n1ECI93yoAjP5wL7hfAmzZR+sF6
         BvauFSz0Wv7ji5CCULQERipDH2+wqFDIovA9PAAWW9Ci/h73dfPDHatjCIGujU5CMWPl
         BbIouNBLokIgehI+DkAoRSJ/RQ3whqBRfdW1Pe7P86pYHjtu1gCwXqfYkLjh3GltBSXE
         VuCPgEO0aMgaqntee5irp9BkU2XqrV3si5/bBJUlCj4/jVcmBZVJp1EylZEz20bpIWxw
         AwAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUi26jRoaWwasCieH6UHOWGw0XG0ElIXxJQy35blQxR/VwN+u/1
	daD9rLWWzqRQQSZHrR0500UHNwtXSwvEzPva4biHd9hCsqezLMReDlJ0/Tfg2xo7N++dLXSeAJm
	d3tquJ7I8EDxjZY+bcX5Pk5sLpku1WbuxgFpbWZUmbOweWW7Sxq6D8/gtzwf/7Z+8fA==
X-Received: by 2002:a17:906:2341:: with SMTP id m1mr10288064eja.165.1559321176627;
        Fri, 31 May 2019 09:46:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyd4QAaiwxOUJFVbg8NEPNu5oWM8bqBOXw9RYTYRFDFqclVFrinnlLV/mbp2QQ0tSuBcF6O
X-Received: by 2002:a17:906:2341:: with SMTP id m1mr10287988eja.165.1559321175507;
        Fri, 31 May 2019 09:46:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559321175; cv=none;
        d=google.com; s=arc-20160816;
        b=gXs9ZbRE6GKvYIN0InxRfw16neTGo0C/6vOlzCIQRfTNTvjbaLXXZbYCjl5I0m2Fm4
         /Y38pBoeTojF3t4eQ+MpwANXCZ4mk7Xo1JGhV7Nv3xM/jhHP3j5HZKr+LNN9nrX7P6MT
         6Qqbigr2yYAAZd/LlyvDwYz4AUfpIXr/djpXVvIclvjzepDXTnoxn0j/hcFGqbbT1eZT
         hduwwUyDQ+HdCDQUMxVnPEW/SLIzVALw5YoZzTXT6wLzy897ScDqBbxA8YyiiEkfGdFb
         pezHGKfSn+EBtrkZH2qupOepN0/2Sy81mB/xUSQaIM83/0Bx6aDEQ3gIQm9MeO7DOgeW
         2Kug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aT2yKJPBijRfh3I8dT7YFwqukzizGgjs99pM6UcU/IQ=;
        b=pxEzHPQXXQIya9zm7oRwzrAz80aQcA5lpZBUsPOpSz7Nh7djJbOUF4KZ35LmgRxtG7
         cQSnBR07McZmEtrMakIz5ZSbI7YIvGFeqo/ZHM21vpSvEh103GE37rxigmx+OXxoRWIZ
         9Esj9xdYbYYgUy9vIkwfSE1NG6116MQKqMlo4csAWs6vAMfsF/1oh2D/NHOFk91ZSVuy
         jkj09LOarccFcB3PK/oFlwlwRebQBb5p3hJd4cX8kXdMqO+arPgCENDz1Kvves8s1UrZ
         XUkB+uN3cAKf/Ve4uJL7sctOZjunJpSRDfsyP8DSMMrezNjAJ+b4eCHwKX1UAunogLMT
         97Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b38si1941007edb.223.2019.05.31.09.46.15
        for <linux-mm@kvack.org>;
        Fri, 31 May 2019 09:46:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2DFE0A78;
	Fri, 31 May 2019 09:46:14 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 48A043F59C;
	Fri, 31 May 2019 09:46:08 -0700 (PDT)
Date: Fri, 31 May 2019 17:46:05 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Kees Cook <keescook@chromium.org>,
	Evgenii Stepanov <eugenis@google.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Elliott Hughes <enh@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190531164605.GC3568@arrakis.emea.arm.com>
References: <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
 <20190523201105.oifkksus4rzcwqt4@mbp>
 <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com>
 <20190524101139.36yre4af22bkvatx@mbp>
 <c6dd53d8-142b-3d8d-6a40-d21c5ee9d272@oracle.com>
 <CAAeHK+yAUsZWhp6xPAbWewX5Nbw+-G3svUyPmhXu5MVeEDKYvA@mail.gmail.com>
 <20190530171540.GD35418@arrakis.emea.arm.com>
 <CAAeHK+y34+SNz3Vf+_378bOxrPaj_3GaLCeC2Y2rHAczuaSz1A@mail.gmail.com>
 <20190531161954.GA3568@arrakis.emea.arm.com>
 <CAAeHK+zRDD7ZPPUA9cpwHOdgTRrJLWAby8Wg9oPgmhqMpHwvFw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+zRDD7ZPPUA9cpwHOdgTRrJLWAby8Wg9oPgmhqMpHwvFw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 06:24:06PM +0200, Andrey Konovalov wrote:
> On Fri, May 31, 2019 at 6:20 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Fri, May 31, 2019 at 04:29:10PM +0200, Andrey Konovalov wrote:
> > > On Thu, May 30, 2019 at 7:15 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > > On Tue, May 28, 2019 at 04:14:45PM +0200, Andrey Konovalov wrote:
> > > > > Thanks for a lot of valuable input! I've read through all the replies
> > > > > and got somewhat lost. What are the changes I need to do to this
> > > > > series?
> > > > >
> > > > > 1. Should I move untagging for memory syscalls back to the generic
> > > > > code so other arches would make use of it as well, or should I keep
> > > > > the arm64 specific memory syscalls wrappers and address the comments
> > > > > on that patch?
> > > >
> > > > Keep them generic again but make sure we get agreement with Khalid on
> > > > the actual ABI implications for sparc.
> > >
> > > OK, will do. I find it hard to understand what the ABI implications
> > > are. I'll post the next version without untagging in brk, mmap,
> > > munmap, mremap (for new_address), mmap_pgoff, remap_file_pages, shmat
> > > and shmdt.
> >
> > It's more about not relaxing the ABI to accept non-zero top-byte unless
> > we have a use-case for it. For mmap() etc., I don't think that's needed
> > but if you think otherwise, please raise it.
> >
> > > > > 2. Should I make untagging opt-in and controlled by a command line argument?
> > > >
> > > > Opt-in, yes, but per task rather than kernel command line option.
> > > > prctl() is a possibility of opting in.
> > >
> > > OK. Should I store a flag somewhere in task_struct? Should it be
> > > inheritable on clone?
> >
> > A TIF flag would do but I'd say leave it out for now (default opted in)
> > until we figure out the best way to do this (can be a patch on top of
> > this series).
> 
> You mean leave the whole opt-in/prctl part out? So the only change
> would be to move untagging for memory syscalls into generic code?

Yes (or just wait until next week to see if the discussion settles
down).

-- 
Catalin

