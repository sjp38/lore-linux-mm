Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04D25C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:13:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA15A214AE
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:13:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="cuhllGlp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA15A214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CA896B0005; Fri, 13 Sep 2019 05:13:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37BDB6B0006; Fri, 13 Sep 2019 05:13:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 269CE6B0007; Fri, 13 Sep 2019 05:13:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0234.hostedemail.com [216.40.44.234])
	by kanga.kvack.org (Postfix) with ESMTP id F35516B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 05:13:05 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id AA94C299B3
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:13:05 +0000 (UTC)
X-FDA: 75929333130.18.print37_8f57750e60129
X-HE-Tag: print37_8f57750e60129
X-Filterd-Recvd-Size: 7190
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:13:04 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id z9so26392849edq.8
        for <linux-mm@kvack.org>; Fri, 13 Sep 2019 02:13:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=GEliFawsGnvWaq/wjC8o7X+uw8pCAUzjjDt3si5wKpw=;
        b=cuhllGlp2MOrdGub8Xg9DSnbN4UNbu5MAj+tu2g8/hUaiRvqMMOHfTNwMUyS5pk0Wh
         Cr/5CrT44vV+Lu6MEqICuL5EsXflVt2aB1CYOvw49Ff95R0+EpyudeDA0c1SjKiSBgvJ
         j392DdO8k5wtN6+t0Mq4Pin3skB6EB7fqWabfD22XoO9Zau3MU3BJhMVCPaEwzZDcctL
         3Z1utSLzZkSKBXiuC7y0bwtRfMC6JHyQJ4KI6FWcJD3QstGxSDpCFQt7SWa9ffXb7iM8
         Ka/YoQxle3ll0z8qQj2WsoJL1cViPtFo+jeRDT45DkakRyYbR2vwrsjhDwiP9OSANs1/
         05gQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=GEliFawsGnvWaq/wjC8o7X+uw8pCAUzjjDt3si5wKpw=;
        b=kARpm2OtU1ubuoVXA0Ci85f6ddkrsU8qR6Id2pbOBlR0iBsdr8YxeG+6BJJtd2Vf9B
         aFLoaLJFUrsB51OveTFzz/fhwk+kKvJttFlYJCmIoR9QvkZ6qFGmWlLILv/69PhobatU
         dSPOOgcjxSylT+3TjH37y9jydwU2JedON15f4ZCskudaLKp7ZiUB4yqjfh5i4kvmINJK
         Gf822e9GSci99zIPNM7BIeWU1mwTPlmam1sR/V4DpUTuuishTF1jqERyNtv1nzam2yO2
         5puHIAO4AWMwbaf/SJwBNYvjvuF2tVQh8M8aF83LEeZSQn7xgnRX0fXhY+/z3q+6xPQw
         hmRQ==
X-Gm-Message-State: APjAAAU+kPVxoGUs+6qusL/sFMLlnbPBIYQIvBh9stZ1gE2j1r4uxk9u
	lHz0h+EOyhSTOD3wOYpAqHR2Kw==
X-Google-Smtp-Source: APXvYqz9+Jjoiq6EpEOnNn2ue7LgRH298IcNtOZjCAdMkVz1fw1ulTQ0FfVWoOu1Q7FOQkoJoXJfvw==
X-Received: by 2002:aa7:da59:: with SMTP id w25mr44834467eds.143.1568365983857;
        Fri, 13 Sep 2019 02:13:03 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id oo23sm3092469ejb.64.2019.09.13.02.13.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Sep 2019 02:13:03 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 3271B10160B; Fri, 13 Sep 2019 12:13:05 +0300 (+03)
Date: Fri, 13 Sep 2019 12:13:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Mark Brown <broonie@kernel.org>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Matthew Wilcox <willy@infradead.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vineet Gupta <vgupta@synopsys.com>, James Hogan <jhogan@kernel.org>,
	Paul Burton <paul.burton@mips.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	x86@kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH V2 2/2] mm/pgtable/debug: Add test validating
 architecture page table helpers
Message-ID: <20190913091305.rkds4f3fqv3yjhjy@box>
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
 <1568268173-31302-3-git-send-email-anshuman.khandual@arm.com>
 <ab0ca38b-1e4f-b636-f8b4-007a15903984@c-s.fr>
 <502c497a-9bf1-7d2e-95f2-cfebcd9cf1d9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <502c497a-9bf1-7d2e-95f2-cfebcd9cf1d9@arm.com>
User-Agent: NeoMutt/20180716
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 13, 2019 at 02:32:04PM +0530, Anshuman Khandual wrote:
>=20
> On 09/12/2019 10:44 PM, Christophe Leroy wrote:
> >=20
> >=20
> > Le 12/09/2019 =E0 08:02, Anshuman Khandual a =E9crit=A0:
> >> This adds a test module which will validate architecture page table =
helpers
> >> and accessors regarding compliance with generic MM semantics expecta=
tions.
> >> This will help various architectures in validating changes to the ex=
isting
> >> page table helpers or addition of new ones.
> >>
> >> Test page table and memory pages creating it's entries at various le=
vel are
> >> all allocated from system memory with required alignments. If memory=
 pages
> >> with required size and alignment could not be allocated, then all de=
pending
> >> individual tests are skipped.
> >>
> >=20
> > [...]
> >=20
> >>
> >> Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
> >> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> >> ---
> >> =A0 arch/x86/include/asm/pgtable_64_types.h |=A0=A0 2 +
> >> =A0 mm/Kconfig.debug=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 |=A0 14 +
> >> =A0 mm/Makefile=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 |=A0=A0 1 +
> >> =A0 mm/arch_pgtable_test.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 | 429 ++++++++++++++++++++++++
> >> =A0 4 files changed, 446 insertions(+)
> >> =A0 create mode 100644 mm/arch_pgtable_test.c
> >>
> >> diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/incl=
ude/asm/pgtable_64_types.h
> >> index 52e5f5f2240d..b882792a3999 100644
> >> --- a/arch/x86/include/asm/pgtable_64_types.h
> >> +++ b/arch/x86/include/asm/pgtable_64_types.h
> >> @@ -40,6 +40,8 @@ static inline bool pgtable_l5_enabled(void)
> >> =A0 #define pgtable_l5_enabled() 0
> >> =A0 #endif /* CONFIG_X86_5LEVEL */
> >> =A0 +#define mm_p4d_folded(mm) (!pgtable_l5_enabled())
> >> +
> >=20
> > This is specific to x86, should go in a separate patch.
>=20
> Thought about it but its just a single line. Kirill suggested this in t=
he
> previous version. There is a generic fallback definition but s390 has i=
t's
> own. This change overrides the generic one for x86 probably as a fix or=
 as
> an improvement. Kirill should be able to help classify it in which case=
 it
> can be a separate patch.

I don't think it worth a separate patch.

--=20
 Kirill A. Shutemov

