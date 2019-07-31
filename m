Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C0F1C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:27:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D291120657
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:27:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=duncanthrax.net header.i=@duncanthrax.net header.b="VWmBZSuU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D291120657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stackframe.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BD388E0003; Wed, 31 Jul 2019 05:27:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66DFC8E0001; Wed, 31 Jul 2019 05:27:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50F468E0003; Wed, 31 Jul 2019 05:27:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 015648E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:27:08 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s18so33417152wru.16
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:27:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tys11WF7FiBbva0mPM06RvxVHoTJLCHaJFi1kgHKOlY=;
        b=YWtoTLiTJ5ibpeRuM0OZZc/91IcH1OGQmGCKUf8Dvg18ERx4VTgiRon8ynhNluabUM
         jaJCuqgegtu2D0FByp/G3E+3XvtPynF5gJrW+UNR2aqsMc18lyZOsb0kKSxMQst58Yi7
         qBDTbbJhu3lK/CiywM4G7C8krExMFJMLWh2oCWcIRaKnlQ0Gy1tW0IydAn6CfYuZidde
         xb1TWHy9zIl9Bf27tCXDG3lNPiZV8Zt/v4qdLxhJbajy364IOMrG3NhQZL42SCGrMlRj
         oK6zfxP4pB7wOhqQ3cfqE5PVGVjx/BzMXhpBYdy/bt9yl9lwDJde88L5nzBxc+jjkNzK
         k/CQ==
X-Gm-Message-State: APjAAAU1sgBLrO6ZAbH2F5gZqrlFm+20y/A3vRT5ogwbBs+he+8r9AWA
	9MRqzlw/Zu3Z2DV6atmivE1XV+rM1q3oM87p9j74v3pivytRs4EJ2iURSQrvasxwmf1qJi58grU
	mDSA7B6olh91+cRKNBZMw81PhCssoOwDj8zfkPLjgLVWdjLCwXIAQXeOCs7cZ1ss=
X-Received: by 2002:adf:fa49:: with SMTP id y9mr5041702wrr.6.1564565227562;
        Wed, 31 Jul 2019 02:27:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbQPTlOKpo9pfXh2lP7HiIkLx3qyfEOijuuqmIudGZAIIYMiBml1vXhBjIgf9xq+fOee7W
X-Received: by 2002:adf:fa49:: with SMTP id y9mr5041566wrr.6.1564565226515;
        Wed, 31 Jul 2019 02:27:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564565226; cv=none;
        d=google.com; s=arc-20160816;
        b=Yt6PueerR11lcQmlBpTTKtrvUMAayRbXq1TtkX5C2oOXsplCkXmWch8cZUBsWE6x5E
         7WNO0BCblhs0EU8KgdjLQh7csDWe6rnAIxP4pJwZdZ6kaM4E+vFFjLRYwUNI9nuNth6Z
         irKY9zJY7G0/F8CVU74oynyGGU+JPDIPmPwqS6/RX2mssQJ+SC9NJY8V6IuNN9KoupyL
         mkJHVBSr5s+fS0Vcdtlx3P51i2cSaTtsRH9NR0Kvra3LkUw5TsafXGlIVHXWaeWqFApA
         xk1GEvdUzKf5yaTBVxoo+bZnMwHQ9qdtvK7KjNoblZ2pzeeWYMEkWLH1qAOfl252yDvq
         TKPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tys11WF7FiBbva0mPM06RvxVHoTJLCHaJFi1kgHKOlY=;
        b=jk9UZsg2xZIi9zAUNlrAlnGuuVL+81ZlcSFriNozXfscswlqJvclitH/YvWURPSrdm
         Rx7tU+2hk2+6t3kLFBa2wletUTerLRiyKIcYF00OV5Z1fkNt8OiNacVz2AMngKFfjuwY
         e0ApFIhihdnSxHjQHA90RfiImiZ1V8l3S/+VfErWwadAsqZgM5Ogya9Mm24HzV76BDh0
         QavuouglOnoFc3UPjIsl/vvmz5fvUuzxkSjpgjCkpFX3m/t8eaGNfwOtVRJOF1fVSbUn
         jwlGt57UxJKtLPqmrikbnx6dYGx0B6SpEtXhJURN+lgQfdEILUMNWK8O96mbJ6c0NAxv
         i51g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@duncanthrax.net header.s=dkim header.b=VWmBZSuU;
       spf=neutral (google.com: 2001:470:70c5:1111::170 is neither permitted nor denied by best guess record for domain of svens@stackframe.org) smtp.mailfrom=svens@stackframe.org
Received: from smtp.duncanthrax.net (smtp.duncanthrax.net. [2001:470:70c5:1111::170])
        by mx.google.com with ESMTPS id n16si63177321wrr.443.2019.07.31.02.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 02:27:06 -0700 (PDT)
Received-SPF: neutral (google.com: 2001:470:70c5:1111::170 is neither permitted nor denied by best guess record for domain of svens@stackframe.org) client-ip=2001:470:70c5:1111::170;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@duncanthrax.net header.s=dkim header.b=VWmBZSuU;
       spf=neutral (google.com: 2001:470:70c5:1111::170 is neither permitted nor denied by best guess record for domain of svens@stackframe.org) smtp.mailfrom=svens@stackframe.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=duncanthrax.net; s=dkim; h=In-Reply-To:Content-Type:MIME-Version:References
	:Message-ID:Subject:Cc:To:From:Date;
	bh=tys11WF7FiBbva0mPM06RvxVHoTJLCHaJFi1kgHKOlY=; b=VWmBZSuU83JjDnf9gMTaxrmzwn
	L9+fc/xpWeDeXZSEI/yzPMyWYCcv0q+KeV8O2qeIlc0spZPwS8zCive5J22gcI0xvRa6BgxYG0eT8
	ty5Kg3Pq+IeY2sPwZwChlunbSVDEXqnQBnphMnW8RDTnsCCyKFs/eIxGSi6de0U8qTQw=;
Received: from frobwit.duncanthrax.net ([89.31.1.178] helo=t470p.stackframe.org)
	by smtp.eurescom.eu with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.86_2)
	(envelope-from <svens@stackframe.org>)
	id 1hsksy-0002wy-IF; Wed, 31 Jul 2019 11:27:04 +0200
Date: Wed, 31 Jul 2019 11:27:03 +0200
From: Sven Schnelle <svens@stackframe.org>
To: Steven Price <steven.price@arm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
	Helge Deller <deller@gmx.de>, Mark Rutland <Mark.Rutland@arm.com>,
	x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux-kernel@vger.kernel.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
Message-ID: <20190731092703.GA31316@t470p.stackframe.org>
References: <20190722154210.42799-1-steven.price@arm.com>
 <794fb469-00c8-af10-92a8-cb7c0c83378b@arm.com>
 <270ce719-49f9-7c61-8b25-bc9548a2f478@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <270ce719-49f9-7c61-8b25-bc9548a2f478@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Steven,

On Mon, Jul 29, 2019 at 12:32:25PM +0100, Steven Price wrote:
> 
> parisc is more interesting and I'm not sure if this is necessarily
> correct. I originally proposed a patch with the line "For parisc, we
> don't support large pages, so add stubs returning 0" which got Acked by
> Helge Deller. However going back to look at that again I see there was a
> follow up thread[2] which possibly suggests I was wrong?

I just started a week ago implementing ptdump for PA-RISC. Didn't notice that
you're working on making it generic, which is nice. I'll adjust my code
to use the infrastructure you're currently developing.

> Can anyone shed some light on whether parisc does support leaf entries
> of the page table tree at a higher than the normal depth?
> 
> [1] https://lkml.org/lkml/2019/2/27/572
> [2] https://lkml.org/lkml/2019/3/5/610

My understanding is that PA-RISC only has leaf entries on PTE level.

> The intention is that the page table walker would be available for all
> architectures so that it can be used in any generic code - PTDUMP simply
> seemed like a good place to start.
> 
> > Now that pmd_leaf() and pud_leaf() are getting used in walk_page_range() these
> > functions need to be defined on all arch irrespective if they use PTDUMP or not
> > or otherwise just define it for archs which need them now for sure i.e x86 and
> > arm64 (which are moving to new generic PTDUMP framework). Other archs can
> > implement these later.

I'll take care of the PA-RISC part - for 32 bit your generic code works, for 64Bit
i need to learn a bit more about the following hack:

arch/parisc/include/asm/pgalloc.h:15
/* Allocate the top level pgd (page directory)
 *
 * Here (for 64 bit kernels) we implement a Hybrid L2/L3 scheme: we
 * allocate the first pmd adjacent to the pgd.  This means that we can
 * subtract a constant offset to get to it.  The pmd and pgd sizes are
 * arranged so that a single pmd covers 4GB (giving a full 64-bit
 * process access to 8TB) so our lookups are effectively L2 for the
 * first 4GB of the kernel (i.e. for all ILP32 processes and all the
 * kernel for machines with under 4GB of memory)
 */

I see that your change clear P?D entries when p?d_bad() returns true, which - i think -
would be the case with the PA-RISC implementation.

Regards
Sven

