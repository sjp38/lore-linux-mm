Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7D6EC4CEC7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 06:32:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9831A206A5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 06:32:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="VJ4CF4p8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9831A206A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 446FC6B0007; Fri, 13 Sep 2019 02:32:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F6C56B0008; Fri, 13 Sep 2019 02:32:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BD7D6B000A; Fri, 13 Sep 2019 02:32:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0008.hostedemail.com [216.40.44.8])
	by kanga.kvack.org (Postfix) with ESMTP id 019166B0007
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 02:32:16 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A2FA88243765
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:32:16 +0000 (UTC)
X-FDA: 75928927872.29.mist47_30e17ba22a032
X-HE-Tag: mist47_30e17ba22a032
X-Filterd-Recvd-Size: 4913
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:32:15 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46V5Qj000Sz9vKGb;
	Fri, 13 Sep 2019 08:32:12 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=VJ4CF4p8; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id tJ-xaM53VrCX; Fri, 13 Sep 2019 08:32:12 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46V5Qh5lbpz9vKGZ;
	Fri, 13 Sep 2019 08:32:12 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568356332; bh=ReBvPV0Z/m9MUram7yhwHTiidcmJNZL+BD+hfnsloLA=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=VJ4CF4p8hg1KKGgIhCeAsV4qMKvXYlzNNehQ7ceZ4a6ZuNVr4zWlfLC2C/d+4Vx6x
	 bOBxjzejDmg2+91ZvpNauetOhqSmZP1lVWbg5kakCMndFFbJsOS+UyolY/r68IIfBa
	 7Uu12tw9w30LmD65sqocpmha8manvmPDWe4ylXUw=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A62D88B7FD;
	Fri, 13 Sep 2019 08:32:13 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id LcWRvZH4vQC7; Fri, 13 Sep 2019 08:32:13 +0200 (CEST)
Received: from [172.25.230.101] (po15451.idsi0.si.c-s.fr [172.25.230.101])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 334838B770;
	Fri, 13 Sep 2019 08:32:13 +0200 (CEST)
Subject: Re: [PATCH V2 0/2] mm/debug: Add tests for architecture exported page
 table helpers
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Vlastimil Babka <vbabka@suse.cz>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Thomas Gleixner <tglx@linutronix.de>, Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Dan Williams <dan.j.williams@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>, Mark Brown <broonie@kernel.org>,
 Steven Price <Steven.Price@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kees Cook <keescook@chromium.org>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Matthew Wilcox <willy@infradead.org>,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Dave Hansen <dave.hansen@intel.com>,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 "David S. Miller" <davem@davemloft.net>, Vineet Gupta <vgupta@synopsys.com>,
 James Hogan <jhogan@kernel.org>, Paul Burton <paul.burton@mips.com>,
 Ralf Baechle <ralf@linux-mips.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 Mike Kravetz <mike.kravetz@oracle.com>, linux-snps-arc@lists.infradead.org,
 linux-mips@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
 <527edfce-c986-de4c-e286-34a70f6a2790@c-s.fr>
 <1b467d7a-0324-eb2c-876a-f04a99b9c596@arm.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <ba2314ff-54c1-0deb-b207-b591647fac9d@c-s.fr>
Date: Fri, 13 Sep 2019 08:32:11 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <1b467d7a-0324-eb2c-876a-f04a99b9c596@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 13/09/2019 =C3=A0 08:24, Anshuman Khandual a =C3=A9crit=C2=A0:
>=20
>=20
> On 09/12/2019 08:12 PM, Christophe Leroy wrote:
>> Hi,
>>
>> I didn't get patch 1 of this series, and it is not on linuxppc-dev pat=
chwork either. Can you resend ?
>=20
> Its there on linux-mm patchwork and copied on linux-kernel@vger.kernel.=
org
> as well. The CC list for the first patch was different than the second =
one.
>=20
> https://patchwork.kernel.org/patch/11142317/
>=20
> Let me know if you can not find it either on MM or LKML list.
>=20

I finaly found it on linux-mm archive, thanks. See my other mails and my=20
fixing patch.

Christophe

