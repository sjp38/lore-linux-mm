Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29009C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 08:51:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE70C208C0
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 08:51:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="M6Wl/quw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE70C208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AB106B0006; Fri, 13 Sep 2019 04:51:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 734796B0007; Fri, 13 Sep 2019 04:51:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FD106B0008; Fri, 13 Sep 2019 04:51:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0207.hostedemail.com [216.40.44.207])
	by kanga.kvack.org (Postfix) with ESMTP id 350CC6B0006
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 04:51:37 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B9B7C180AD801
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 08:51:36 +0000 (UTC)
X-FDA: 75929278992.21.fact48_654854b628d01
X-HE-Tag: fact48_654854b628d01
X-Filterd-Recvd-Size: 8146
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 08:51:35 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id y91so26344993ede.9
        for <linux-mm@kvack.org>; Fri, 13 Sep 2019 01:51:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=ljRy//1oqpxbNqcuLvCNHWlNadtkzDq51hCzmFakYzM=;
        b=M6Wl/quwPsEOiMFNCv3xSOrdnDulq5fkBOVf8YSY3tiw77PxkkHJwmP5iEk0kohLlY
         pg4uPVtKpUEevoagc8enKn4uPrSlBiZORCgQoAOniX52xYmOZkzG1/HzuVuRwG1eo1oP
         UUMYm6uVKM/ZyICPXIY6dw0BD4t6sF6ZjlwPzQZa+ZeBzMMqOs4xYJXwzCpcBNDo8jhx
         jXjUL9kfKg583djOtcu64hthdRWYl9M2FSJHI0vB9ZCDV10OZHe+j1P2FdlMaHZTn/Du
         o7aK3kotbpwDLHIjGD7A7LXZ8OC4HcGT0NeYVB7fDkav49RWCtmQCPySSqquXilUNVHm
         pP3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=ljRy//1oqpxbNqcuLvCNHWlNadtkzDq51hCzmFakYzM=;
        b=a/iuUDoEbc8Y2en7pG9h/uZ+xEdjn+tTSLFYrY0PiNoLL5aQ7A8OaHX2SIxC50LvqH
         XDGJZwlLl7YAvLa+nzk3g1/+Y64sXh4KQC3OIjxqdSFL6z35lQZZ9KbI5k/sWFQS34sx
         08oNShcR0dguLQtU3ObS3borcYQYiv2Z/BOwfEY5cebtEh75IcvJHClA3gebh3HCZFxQ
         nSu02uq6MeatB69JEEfl6TV/In5f6HSCFTsUmm2JL7SdG9SYkgHM+9xZWAWq/bYBMAys
         /IL4paDK6hGMEPmAytePZm3pxWsUZ8qMMCL76QVc1RXjDx+ZSbFq5AbuHbCGZoB+82pt
         VFFg==
X-Gm-Message-State: APjAAAV2lVUNLK5yGHVB5RoOdzlcj+ELWP9IAnBJXPQMp+fFzjjZ4OAz
	EU8HnH3bUNqYFwlgqKuFjaya4w==
X-Google-Smtp-Source: APXvYqxZm96QADm/8SST6BnmvoIUqtDzA7VCb5AHjQ8XsG2pGy1aWbbiVHhIwmyiU7DjVjOntMuCeQ==
X-Received: by 2002:a50:ee92:: with SMTP id f18mr24791178edr.253.1568364694523;
        Fri, 13 Sep 2019 01:51:34 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j30sm5287480edb.8.2019.09.13.01.51.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Sep 2019 01:51:33 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id A972310160B; Fri, 13 Sep 2019 11:51:35 +0300 (+03)
Date: Fri, 13 Sep 2019 11:51:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org,
	Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org,
	linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	James Hogan <jhogan@kernel.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Michal Hocko <mhocko@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org,
	Dan Williams <dan.j.williams@intel.com>, linux-s390@vger.kernel.org,
	Jason Gunthorpe <jgg@ziepe.ca>, x86@kernel.org,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	Matthew Wilcox <willy@infradead.org>,
	Steven Price <Steven.Price@arm.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Vlastimil Babka <vbabka@suse.cz>,
	linux-snps-arc@lists.infradead.org,
	Kees Cook <keescook@chromium.org>, Mark Brown <broonie@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	linux-arm-kernel@lists.infradead.org,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Vineet Gupta <vgupta@synopsys.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] mm/pgtable/debug: Fix test validating architecture page
 table helpers
Message-ID: <20190913085135.rfr3zrabghi2qo2t@box>
References: <1892b37d1fd9a4ed39e76c4b999b6556077201c0.1568355752.git.christophe.leroy@c-s.fr>
 <527dd29d-45fa-4d83-1899-6cbf268dd749@arm.com>
 <e2b42446-7f91-83f1-ac12-08dff75c4d35@c-s.fr>
 <cb226b56-ff20-3136-7ffb-890657e56870@c-s.fr>
 <bdf7f152-d093-1691-4e96-77da7eb9e20a@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <bdf7f152-d093-1691-4e96-77da7eb9e20a@arm.com>
User-Agent: NeoMutt/20180716
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 13, 2019 at 02:12:45PM +0530, Anshuman Khandual wrote:
>=20
>=20
> On 09/13/2019 12:41 PM, Christophe Leroy wrote:
> >=20
> >=20
> > Le 13/09/2019 =E0 09:03, Christophe Leroy a =E9crit=A0:
> >>
> >>
> >> Le 13/09/2019 =E0 08:58, Anshuman Khandual a =E9crit=A0:
> >>> On 09/13/2019 11:53 AM, Christophe Leroy wrote:
> >>>> Fix build failure on powerpc.
> >>>>
> >>>> Fix preemption imbalance.
> >>>>
> >>>> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> >>>> ---
> >>>> =A0 mm/arch_pgtable_test.c | 3 +++
> >>>> =A0 1 file changed, 3 insertions(+)
> >>>>
> >>>> diff --git a/mm/arch_pgtable_test.c b/mm/arch_pgtable_test.c
> >>>> index 8b4a92756ad8..f2b3c9ec35fa 100644
> >>>> --- a/mm/arch_pgtable_test.c
> >>>> +++ b/mm/arch_pgtable_test.c
> >>>> @@ -24,6 +24,7 @@
> >>>> =A0 #include <linux/swap.h>
> >>>> =A0 #include <linux/swapops.h>
> >>>> =A0 #include <linux/sched/mm.h>
> >>>> +#include <linux/highmem.h>
> >>>
> >>> This is okay.
> >>>
> >>>> =A0 #include <asm/pgalloc.h>
> >>>> =A0 #include <asm/pgtable.h>
> >>>> @@ -400,6 +401,8 @@ static int __init arch_pgtable_tests_init(void=
)
> >>>> =A0=A0=A0=A0=A0 p4d_clear_tests(p4dp);
> >>>> =A0=A0=A0=A0=A0 pgd_clear_tests(mm, pgdp);
> >>>> +=A0=A0=A0 pte_unmap(ptep);
> >>>> +
> >>>
> >>> Now the preemption imbalance via pte_alloc_map() path i.e
> >>>
> >>> pte_alloc_map() -> pte_offset_map() -> kmap_atomic()
> >>>
> >>> Is not this very much powerpc 32 specific or this will be applicabl=
e
> >>> for all platform which uses kmap_XXX() to map high memory ?
> >>>
> >>
> >> See https://elixir.bootlin.com/linux/v5.3-rc8/source/include/linux/h=
ighmem.h#L91
> >>
> >> I think it applies at least to all arches using the generic implemen=
tation.
> >>
> >> Applies also to arm:
> >> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/arm/mm/highmem=
.c#L52
> >>
> >> Applies also to mips:
> >> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/mips/mm/highme=
m.c#L47
> >>
> >> Same on sparc:
> >> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/sparc/mm/highm=
em.c#L52
> >>
> >> Same on x86:
> >> https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/x86/mm/highmem=
_32.c#L34
> >>
> >> I have not checked others, but I guess it is like that for all.
> >>
> >=20
> >=20
> > Seems like I answered too quickly. All kmap_atomic() do preempt_disab=
le(), but not all pte_alloc_map() call kmap_atomic().
> >=20
> > However, for instance ARM does:
> >=20
> > https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/arm/include/asm=
/pgtable.h#L200
> >=20
> > And X86 as well:
> >=20
> > https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/x86/include/asm=
/pgtable_32.h#L51
> >=20
> > Microblaze also:
> >=20
> > https://elixir.bootlin.com/linux/v5.3-rc8/source/arch/microblaze/incl=
ude/asm/pgtable.h#L495
>=20
> All the above platforms checks out to be using k[un]map_atomic(). I am =
wondering whether
> any of the intermediate levels will have similar problems on any these =
32 bit platforms
> or any other platforms which might be using generic k[un]map_atomic().

No. Kernel only allocates pte page table from highmem. All other page
tables are always visible in kernel address space.

--=20
 Kirill A. Shutemov

