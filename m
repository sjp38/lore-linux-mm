Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A120CC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 22:37:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09C9A2173E
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 22:37:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=gmx.net header.i=@gmx.net header.b="XvRR+Yjr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09C9A2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gmx.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BEED6B0284; Mon, 26 Aug 2019 18:37:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46F646B0286; Mon, 26 Aug 2019 18:37:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3848F6B0287; Mon, 26 Aug 2019 18:37:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0247.hostedemail.com [216.40.44.247])
	by kanga.kvack.org (Postfix) with ESMTP id 11BA66B0284
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 18:37:57 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 9A89A82437C9
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 22:37:56 +0000 (UTC)
X-FDA: 75866042952.13.roof86_b0c7eafc3641
X-HE-Tag: roof86_b0c7eafc3641
X-Filterd-Recvd-Size: 7099
Received: from mout.gmx.net (mout.gmx.net [212.227.15.18])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 22:37:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=gmx.net;
	s=badeba3b8450; t=1566859062;
	bh=Pj4uAQaXeIdkvaCK98IbRx1uvJ/X01xMarlBi5RxG2U=;
	h=X-UI-Sender-Class:Subject:To:Cc:References:From:Date:In-Reply-To;
	b=XvRR+Yjrj/lxPKk9HoTw93NPc2fxEA57GnjWJuC9bbXUlad8hyT40BS7HHIy8tWJf
	 HKhXHa5+08OHFjwRDtYFkVp0gn+1SjXZVa56LhxNDbkvaFA5/1SjLkQmHLLevfod3w
	 5gqrRzYlgA3oUOBtXpspo13yWY+5lQ1efwYudJbU=
X-UI-Sender-Class: 01bb95c1-4bf8-414a-932a-4f6e2808ef9c
Received: from [192.168.179.28] ([217.238.204.231]) by mail.gmx.com (mrgmx002
 [212.227.17.190]) with ESMTPSA (Nemesis) id 0MaZWz-1hnB5L0pIX-00K8b7; Tue, 27
 Aug 2019 00:37:42 +0200
Subject: Re: [PATCH RESEND 0/8] Fix mmap base in bottom-up mmap
To: Alexandre Ghiti <alex@ghiti.fr>, Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily Gorbik
 <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190620050328.8942-1-alex@ghiti.fr>
 <abc7ed75-0f51-7f21-5a74-d389f968ee55@ghiti.fr>
From: Helge Deller <deller@gmx.de>
Message-ID: <9639ebd4-7dcb-0ea5-e0a6-adb8eaecd92a@gmx.de>
Date: Tue, 27 Aug 2019 00:37:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <abc7ed75-0f51-7f21-5a74-d389f968ee55@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:RU5C0dBXjxrRCewq0WWznMGgYJRZJCVSduSK741vTuSXvO8YQ3k
 e4ipIkY98zehrL5bn2+bhdKDyYEyZ8Bp5SzGjyBxqCZTsoVramKj/Vyd4ck1V830ylao4wf
 HP5VvjUpOf3gI4uCw2J6OcIgqDuwqloj8mNLmpjVrXYZLCwcKWdSIESQi0IEfnXZU5JrW6G
 PPkeHq2ID2V1aVdIp6hwg==
X-UI-Out-Filterresults: notjunk:1;V03:K0:nmHZZR9ejPA=:6g+P4z9PhbuHnBsl9sJG2S
 uDi9RYwCeGIVcZqCxIaHucXHxXbjrudoYGeoAyPxVpstqJQo8WuyBl2Hrvls9JACsOzymJNCw
 w/AIWUbhS/u2qeDxhCRXF02AHMtN9ow3mtXsGkokAMy3bn1uADS6jsL2EljpHaaNcuzvOZj0v
 Mka7C7Q9/gdCzdH1Q4yjdYcRbngXG0cInx4ZLV5iVc/zV22NhhDKn4ej4pgRQn0tCVmGySf5C
 e30/0aXJ0UoNiTKdMW8C6ufzot97nveLD/3ZsMg/BMvE4s++vXW1ijXywqZfSzwcLZZ2/fMj2
 wtQ9GJ6gOcE90isSkkf2ArTg6SwKx4j/FPifhrcllWWS3ipnH8DtIXRqpIlrWFmtYiN4/4bRB
 VczuL3X8K7zAXhV1p4vcaHk+3O0E7ROTbfhyK2hb3NF4V9QpZO6EQXin43qZVjRON9bgjIfBR
 ei+6kjD2/QCuSBnTLO5D9iGMHlzNkxKwrYHdR5YGQTYlV8jgPn3KQNsFav2wliy11yv2S5QvC
 yO6YWQD4qVm8D5oRRn432HEZRbC7qbSWks0bh1pYWJzrVCkhLl65T8FREjDMvthMVywRsA51C
 qg617CLdN6zj4FWE47uOyksFOZNJcVljV+eRTIe1yLfLmvFyPNmFsmpyBB2EKPFQ+kgQJyhpq
 9ShHmboWZZHKmUxWXN4vt6aPh18o0bPn0LMDk47AhE2ToOsyB2pnoouKh4i3VaV7Li35sqp3H
 4rdAE7v9XfaNN9zRXsVP/6q0WBxEsIzRD+heKik/MWEFRd2OzhxuBsk7doDF1szy2gRlrYCLT
 1hfvsJQ0r7+00rVnAhjqcAxsXYcoCl3ivj9tj8NDTPw1L+839wNrJoecI9R+2NSTzxyNOgb1X
 zLxiBeV9WuKyc3S3YPDDoiEpcSYmWDeIS5fy5vxzjWuRQA/0v/1av/OQ884NBMFW9SqR1T+gm
 +wLUbBR+5ZMDiywLqM7iBON8XtkeUcy5353UqmJ386dSM8clEmUd8rgey4tVffUWnNp7WPaoB
 zZP1g5eY4MN1Gt6frFhILK0drlKfqxHb0Uvi8rKmKT6LpyHp+zmbM500hqT0oP88Qhfx4Evpn
 TfnKClj9EdnErvSOmCvB+3ArYDFuwiWP9x9LQ79XKf3uReDC+OC+N0coj4IPoAESrdjWpZWzc
 1PsgKx/NTOXIyGmKTnJzPfsJXFQ9tK7lrDyVBrTvWDNqjVzQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.08.19 09:34, Alexandre Ghiti wrote:
> On 6/20/19 7:03 AM, Alexandre Ghiti wrote:
>> This series fixes the fallback of the top-down mmap: in case of
>> failure, a bottom-up scheme can be tried as a last resort between
>> the top-down mmap base and the stack, hoping for a large unused stack
>> limit.
>>
>> Lots of architectures and even mm code start this fallback
>> at TASK_UNMAPPED_BASE, which is useless since the top-down scheme
>> already failed on the whole address space: instead, simply use
>> mmap_base.
>>
>> Along the way, it allows to get rid of of mmap_legacy_base and
>> mmap_compat_legacy_base from mm_struct.
>>
>> Note that arm and mips already implement this behaviour.
>>
>> Alexandre Ghiti (8):
>> =C2=A0=C2=A0 s390: Start fallback of top-down mmap at mm->mmap_base
>> =C2=A0=C2=A0 sh: Start fallback of top-down mmap at mm->mmap_base
>> =C2=A0=C2=A0 sparc: Start fallback of top-down mmap at mm->mmap_base
>> =C2=A0=C2=A0 x86, hugetlbpage: Start fallback of top-down mmap at mm->m=
map_base
>> =C2=A0=C2=A0 mm: Start fallback top-down mmap at mm->mmap_base
>> =C2=A0=C2=A0 parisc: Use mmap_base, not mmap_legacy_base, as low_limit =
for
>> =C2=A0=C2=A0=C2=A0=C2=A0 bottom-up mmap
>> =C2=A0=C2=A0 x86: Use mmap_*base, not mmap_*legacy_base, as low_limit f=
or bottom-up
>> =C2=A0=C2=A0=C2=A0=C2=A0 mmap
>> =C2=A0=C2=A0 mm: Remove mmap_legacy_base and mmap_compat_legacy_code fi=
elds from
>> =C2=A0=C2=A0=C2=A0=C2=A0 mm_struct
>>
>> =C2=A0 arch/parisc/kernel/sys_parisc.c=C2=A0 |=C2=A0 8 +++-----
>> =C2=A0 arch/s390/mm/mmap.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 2 +-
>> =C2=A0 arch/sh/mm/mmap.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 2 +-
>> =C2=A0 arch/sparc/kernel/sys_sparc_64.c |=C2=A0 2 +-
>> =C2=A0 arch/sparc/mm/hugetlbpage.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=
=A0 2 +-
>> =C2=A0 arch/x86/include/asm/elf.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=
=C2=A0 2 +-
>> =C2=A0 arch/x86/kernel/sys_x86_64.c=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 4 +=
+--
>> =C2=A0 arch/x86/mm/hugetlbpage.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 |=C2=A0 7 ++++---
>> =C2=A0 arch/x86/mm/mmap.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 20 +++++++++-----------
>> =C2=A0 include/linux/mm_types.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 |=C2=A0 2 --
>> =C2=A0 mm/debug.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 |=C2=A0 4 ++--
>> =C2=A0 mm/mmap.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 |=C2=A0 2 +-
>> =C2=A0 12 files changed, 26 insertions(+), 31 deletions(-)
>>
>
> Any thoughts about that series ? As said before, this is just a preparat=
ory patchset in order to
> merge x86 mmap top down code with the generic version.

I just tested your patch series successfully on the parisc
architeture. You may add:

Tested-by: Helge Deller <deller@gmx.de> # parisc

Thanks!
Helge

