Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BE55C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08AEF20645
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="ASMcB1iC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08AEF20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 238B58E0009; Thu, 13 Jun 2019 13:58:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BF788E0007; Thu, 13 Jun 2019 13:58:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 038AD8E0009; Thu, 13 Jun 2019 13:58:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BAE288E0007
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:58:14 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j21so14969562pff.12
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:newsgroups
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=7vsKZOajkij+PgQEVsXwjEhf+OtujcKPqsyxcDgiZDo=;
        b=gJSSKDCakGWg1MJ5sfQonGMT396xt5DiFQpdeQDck2WOWdtCs5H/DTrUG3tPcI50Qa
         xx8DXfy2ddBECzpx3OBrAsj+hEjaG+xb+DAmm0VyjTEIFu4o275XHxXOj+/tkqkSXzyp
         qY5IY6oVKQ3TdpgTC2hQcEbzg8XpKMvR7t9PnxKFcXwJ/TYZpV/PJCyP9nS9Puqfcsna
         KAfhOvrcA4HgOFoU7BBQhPLUPIWY8PdVkveU+te6nhLCYpCrTaklQKo4HPdAT0WJ/wjh
         eR+tGpdoZQwl0Xbi3pGudfdpQTNCzPhtE9apCBpSOt5nDzOdD1K26sTsPtQwtnnTHxpX
         IRQA==
X-Gm-Message-State: APjAAAV3vW0X0mppZ7wp0vy7aULw3IU5PSaQ43yD4jt0y+8QRcDL4fCc
	uc4RG86LNg77B1TUvw8+BvCSll9lUxt7iyFKEYto+zMWKZLGH2/nxwTNUIO9vWHF2jrkrACgdVq
	apXD/PG+8Gf0tSI7pCSfMGco2yATLiLAS6d6X1OjxBOoCaqPzBdHMU41WJ6DflDMOsg==
X-Received: by 2002:a17:90a:376f:: with SMTP id u102mr6868222pjb.5.1560448694443;
        Thu, 13 Jun 2019 10:58:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6tIR/TaInXyZUTTa1VCHibm3+N+Bu4oXUyPHOP2+I4FN2nLs8YjOWq3tiCgtBiq31Duu5
X-Received: by 2002:a17:90a:376f:: with SMTP id u102mr6868161pjb.5.1560448693549;
        Thu, 13 Jun 2019 10:58:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560448693; cv=none;
        d=google.com; s=arc-20160816;
        b=CGiyvGUvefLchX2C2SEfaFq90IcEg0M22QpfO+FXtLdZt3ONjD+hHqmUOfchmla70x
         cI7eAaWN8h1mSsXXtyO7OQT3Mfez5zjsyFMaX5fZl5/sUGEjwQtHZgP3emHzue4seb8w
         WShZl9HZYuksPpaxFRnPrY/UI+5I+IXENWHd5HTnCbztku9or73yKd5Wgyhn5uBLTevG
         CnFEmZFyw6pRr9LnbNZtLRdaVdBXnkg5+wSA3OxuFXt4+DpRN+nxItJPmoQWMvqGN5Rc
         TWbGcF4jD6v51Ite5b11qBWGOO9svnQX5Yd3Bn8lcBgtrauC3f/4gAtrWj28dG5drfcE
         Lw9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references
         :newsgroups:cc:to:subject:dkim-signature;
        bh=7vsKZOajkij+PgQEVsXwjEhf+OtujcKPqsyxcDgiZDo=;
        b=UvDThroHN0z+yK5mFDq9VCVrlr2IAYdiS3brt+xjxNBc3UyNCXwH4ioVD1ODhNA5fi
         UAsh1EjrzAQ5FoZijlRdkHZ8/+nQgr4C7x3XAeZC1kMiJRP64ni7pVWXXR+xWsr/9C2V
         w4lRoGYW+Bh4IKju59js7yOgcTyjMmaukG573S+4Pc8C/Uyod5HlkJj+14VVDvSDtwu8
         SHEohtEh3irs9ouFp02akI6XfJEDtoiU/7c84yELpvXUq04noWw2eYCen99dnsVPeSFW
         p+T/AEJ/b+tSRiUf3SUb15eslnQKAMce0NPy/sA5OvgHZomf3p5nGfovIgwyRXUbU8z0
         DVgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=ASMcB1iC;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.102 as permitted sender) smtp.mailfrom=Vineet.Gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay-out1.synopsys.com (dc8-smtprelay2.synopsys.com. [198.182.47.102])
        by mx.google.com with ESMTPS id k16si212650pfk.68.2019.06.13.10.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 10:58:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.102 as permitted sender) client-ip=198.182.47.102;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=ASMcB1iC;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.102 as permitted sender) smtp.mailfrom=Vineet.Gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (dc2-mailhost2.synopsys.com [10.12.135.162])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay-out1.synopsys.com (Postfix) with ESMTPS id 0CD24C219B;
	Thu, 13 Jun 2019 17:58:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1560448693; bh=LJavSY8Csb6IKvT6GApPq2LFdmFwqvpDZcp/Rfd3GmE=;
	h=Subject:To:CC:References:From:Date:In-Reply-To:From;
	b=ASMcB1iCalm/RZa3MaAXMR3twsH8ZyJX6rfqatmxk3+7QCBhu85f5UBmILxUHCbfl
	 uaE0sw7etwQiMKS9V7YJZrEhAHXz66TINoKz78+fISnDKduWEBYv7lRoaFn8scBZQN
	 VnR5njjFVu134X4pAirp28InXohyxznUpt6PClsf/ZGUBvR85M/NdUObLRHuVPx/s6
	 AsnMMHJCWD6SKCrUlSF4srkQSWO2mCgHlmvDKP56rZWx5kEJf6CChlJU1Ik4gWIkvk
	 ihOI5ATSCNUHXOusPC1leckbpnXMxaNDbZMYmb4MGji+oLb6Crx+Zh17SLDN+aiIJM
	 Mp08sJpYv2sig==
Received: from US01WXQAHTC1.internal.synopsys.com (us01wxqahtc1.internal.synopsys.com [10.12.238.230])
	(using TLSv1.2 with cipher AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	by mailhost.synopsys.com (Postfix) with ESMTPS id AC3A5A009A;
	Thu, 13 Jun 2019 17:58:00 +0000 (UTC)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WXQAHTC1.internal.synopsys.com (10.12.238.230) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 13 Jun 2019 10:58:00 -0700
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 13 Jun 2019 23:28:11 +0530
Received: from [10.10.161.35] (10.10.161.35) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 13 Jun 2019 23:28:10 +0530
Subject: Re: [PATCH] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Anshuman Khandual <anshuman.khandual@arm.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
CC: Mark Rutland <mark.rutland@arm.com>,
	Michal Hocko <mhocko@suse.com>, <linux-ia64@vger.kernel.org>,
	<linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	"Dave  Hansen" <dave.hansen@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>, Paul Mackerras <paulus@samba.org>,
	<sparclinux@vger.kernel.org>,
	"Stephen  Rothwell" <sfr@canb.auug.org.au>,
	<linux-s390@vger.kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Michael Ellerman <mpe@ellerman.id.au>, <x86@kernel.org>,
	Russell King <linux@armlinux.org.uk>,
	Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>,
	James Hogan <jhogan@kernel.org>,
	<linux-snps-arc@lists.infradead.org>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	"Andy  Lutomirski" <luto@kernel.org>,
	Thomas Gleixner <tglx@synopsys.com>,
	"Masami  Hiramatsu" <masami.hiramatsu.pt@hitachi.com>
Newsgroups: gmane.linux.ports.arm.kernel,gmane.linux.kernel.mm,gmane.linux.kernel,gmane.linux.ports.ia64,gmane.linux.ports.sh.devel,gmane.linux.ports.sparc,gmane.linux.kernel.arc,gmane.linux.ports.mips,gmane.linux.ports.ppc64.devel
References: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Openpgp: preference=signencrypt
Autocrypt: addr=vgupta@synopsys.com; keydata=
 mQINBFEffBMBEADIXSn0fEQcM8GPYFZyvBrY8456hGplRnLLFimPi/BBGFA24IR+B/Vh/EFk
 B5LAyKuPEEbR3WSVB1x7TovwEErPWKmhHFbyugdCKDv7qWVj7pOB+vqycTG3i16eixB69row
 lDkZ2RQyy1i/wOtHt8Kr69V9aMOIVIlBNjx5vNOjxfOLux3C0SRl1veA8sdkoSACY3McOqJ8
 zR8q1mZDRHCfz+aNxgmVIVFN2JY29zBNOeCzNL1b6ndjU73whH/1hd9YMx2Sp149T8MBpkuQ
 cFYUPYm8Mn0dQ5PHAide+D3iKCHMupX0ux1Y6g7Ym9jhVtxq3OdUI5I5vsED7NgV9c8++baM
 7j7ext5v0l8UeulHfj4LglTaJIvwbUrCGgtyS9haKlUHbmey/af1j0sTrGxZs1ky1cTX7yeF
 nSYs12GRiVZkh/Pf3nRLkjV+kH++ZtR1GZLqwamiYZhAHjo1Vzyl50JT9EuX07/XTyq/Bx6E
 dcJWr79ZphJ+mR2HrMdvZo3VSpXEgjROpYlD4GKUApFxW6RrZkvMzuR2bqi48FThXKhFXJBd
 JiTfiO8tpXaHg/yh/V9vNQqdu7KmZIuZ0EdeZHoXe+8lxoNyQPcPSj7LcmE6gONJR8ZqAzyk
 F5voeRIy005ZmJJ3VOH3Gw6Gz49LVy7Kz72yo1IPHZJNpSV5xwARAQABtCpWaW5lZXQgR3Vw
 dGEgKGFsaWFzKSA8dmd1cHRhQHN5bm9wc3lzLmNvbT6JAj4EEwECACgCGwMGCwkIBwMCBhUI
 AgkKCwQWAgMBAh4BAheABQJbBYpwBQkLx0HcAAoJEGnX8d3iisJeChAQAMR2UVbJyydOv3aV
 jmqP47gVFq4Qml1weP5z6czl1I8n37bIhdW0/lV2Zll+yU1YGpMgdDTHiDqnGWi4pJeu4+c5
 xsI/VqkH6WWXpfruhDsbJ3IJQ46//jb79ogjm6VVeGlOOYxx/G/RUUXZ12+CMPQo7Bv+Jb+t
 NJnYXYMND2Dlr2TiRahFeeQo8uFbeEdJGDsSIbkOV0jzrYUAPeBwdN8N0eOB19KUgPqPAC4W
 HCg2LJ/o6/BImN7bhEFDFu7gTT0nqFVZNXlOw4UcGGpM3dq/qu8ZgRE0turY9SsjKsJYKvg4
 djAaOh7H9NJK72JOjUhXY/sMBwW5vnNwFyXCB5t4ZcNxStoxrMtyf35synJVinFy6wCzH3eJ
 XYNfFsv4gjF3l9VYmGEJeI8JG/ljYQVjsQxcrU1lf8lfARuNkleUL8Y3rtxn6eZVtAlJE8q2
 hBgu/RUj79BKnWEPFmxfKsaj8of+5wubTkP0I5tXh0akKZlVwQ3lbDdHxznejcVCwyjXBSny
 d0+qKIXX1eMh0/5sDYM06/B34rQyq9HZVVPRHdvsfwCU0s3G+5Fai02mK68okr8TECOzqZtG
 cuQmkAeegdY70Bpzfbwxo45WWQq8dSRURA7KDeY5LutMphQPIP2syqgIaiEatHgwetyVCOt6
 tf3ClCidHNaGky9KcNSQ
Message-ID: <e5f45089-c3aa-4d78-2c8d-ed22f863d9ee@synopsys.com>
Date: Thu, 13 Jun 2019 10:57:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.10.161.35]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+CC Masami San

On 6/13/19 3:07 AM, Anshuman Khandual wrote:
> Questions:
> 
> AFAICT there is no equivalent of erstwhile notify_page_fault() during page
> fault handling in arc and mips archs which can call this generic function.
> Please let me know if that is not the case.

For ARC do_page_fault() is entered for MMU exceptions (TLB Miss, access violations
r/w/x etc). kprobes uses a combination of UNIMP_S and TRAP_S instructions which
don't funnel into do_page_fault().

UINMP_S leads to

instr_service
   do_insterror_or_kprobe
      notify_die(DIE_IERR)
         kprobe_exceptions_notify
            arc_kprobe_handler


TRAP_S 2 leads to

EV_Trap
   do_non_swi_trap
      trap_is_kprobe
         notify_die(DIE_TRAP)
            kprobe_exceptions_notify
               arc_post_kprobe_handler

But indeed we are *not* calling into kprobe_fault_handler() - from eithet of those
paths and not sure if the existing arc*_kprobe_handler() combination does the
equivalent in tandem.

-Vineet

