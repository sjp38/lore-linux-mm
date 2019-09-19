Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80FC7C4CEC4
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 04:56:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 191AC20578
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 04:56:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 191AC20578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FD0A6B0334; Thu, 19 Sep 2019 00:56:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 888A96B0335; Thu, 19 Sep 2019 00:56:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74E536B0336; Thu, 19 Sep 2019 00:56:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id 39CCE6B0334
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 00:56:04 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B2AB31F207
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 04:56:03 +0000 (UTC)
X-FDA: 75950458206.01.tin41_8c10e5d327751
X-HE-Tag: tin41_8c10e5d327751
X-Filterd-Recvd-Size: 13437
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 04:56:02 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2E38C337;
	Wed, 18 Sep 2019 21:56:01 -0700 (PDT)
Received: from [10.162.40.65] (p8cg001049571a15.blr.arm.com [10.162.40.65])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 452E53F67D;
	Wed, 18 Sep 2019 21:55:50 -0700 (PDT)
Subject: Re: [PATCH V2 2/2] mm/pgtable/debug: Add test validating architecture
 page table helpers
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org
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
 linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 linux-kernel@vger.kernel.org
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
 <1568268173-31302-3-git-send-email-anshuman.khandual@arm.com>
 <ab0ca38b-1e4f-b636-f8b4-007a15903984@c-s.fr>
 <502c497a-9bf1-7d2e-95f2-cfebcd9cf1d9@arm.com>
 <95ed9d92-dd43-4c45-2e52-738aed7f2fb5@c-s.fr>
 <f872e6f4-a5cb-069d-2034-78961930cb9f@arm.com>
 <64504101-d9dd-f273-02f9-e9a8b178eecc@c-s.fr>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <955491d9-d8aa-0a93-4fb9-3d15acfbcbf8@arm.com>
Date: Thu, 19 Sep 2019 10:26:05 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <64504101-d9dd-f273-02f9-e9a8b178eecc@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09/18/2019 09:56 PM, Christophe Leroy wrote:
>=20
>=20
> Le 18/09/2019 =C3=A0 07:04, Anshuman Khandual a =C3=A9crit=C2=A0:
>>
>>
>> On 09/13/2019 03:31 PM, Christophe Leroy wrote:
>>>
>>>
>>> Le 13/09/2019 =C3=A0 11:02, Anshuman Khandual a =C3=A9crit=C2=A0:
>>>>
>>>>>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVE=
L_HACK)
>>>>>
>>>>> #ifdefs have to be avoided as much as possible, see below
>>>>
>>>> Yeah but it has been bit difficult to avoid all these $ifdef because=
 of the
>>>> availability (or lack of it) for all these pgtable helpers in variou=
s config
>>>> combinations on all platforms.
>>>
>>> As far as I can see these pgtable helpers should exist everywhere at =
least via asm-generic/ files.
>>
>> But they might not actually do the right thing.
>>
>>>
>>> Can you spot a particular config which fails ?
>>
>> Lets consider the following example (after removing the $ifdefs around=
 it)
>> which though builds successfully but fails to pass the intended test. =
This
>> is with arm64 config 4K pages sizes with 39 bits VA space which ends u=
p
>> with a 3 level page table arrangement.
>>
>> static void __init p4d_clear_tests(p4d_t *p4dp)
>> {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p4d_t p4d =3D READ_ON=
CE(*p4dp);
>=20
> My suggestion was not to completely drop the #ifdef but to do like you =
did in pgd_clear_tests() for instance, ie to add the following test on to=
p of the function:
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0if (mm_pud_folded(mm) || is_defined(__ARCH_HAS_=
5LEVEL_HACK))
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>=20

Sometimes this does not really work. On some platforms, combination of
__PAGETABLE_PUD_FOLDED and __ARCH_HAS_5LEVEL_HACK decide whether the
helpers such as __pud() or __pgd() is even available for that platform.
Ideally it should have been through generic falls backs in include/*/
but I guess there might be bugs on the platform or it has not been
changed to adopt 5 level page table framework with required folding
macros etc.

>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p4d =3D __p4d(p4d_val=
(p4d) | RANDOM_ORVALUE);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 WRITE_ONCE(*p4dp, p4d=
);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p4d_clear(p4dp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p4d =3D READ_ONCE(*p4=
dp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 WARN_ON(!p4d_none(p4d=
));
>> }
>>
>> The following test hits an error at WARN_ON(!p4d_none(p4d))
>>
>> [=C2=A0=C2=A0 16.757333] ------------[ cut here ]------------
>> [=C2=A0=C2=A0 16.758019] WARNING: CPU: 11 PID: 1 at mm/arch_pgtable_te=
st.c:187 arch_pgtable_tests_init+0x24c/0x474
>> [=C2=A0=C2=A0 16.759455] Modules linked in:
>> [=C2=A0=C2=A0 16.759952] CPU: 11 PID: 1 Comm: swapper/0 Not tainted 5.=
3.0-next-20190916-00005-g61c218153bb8-dirty #222
>> [=C2=A0=C2=A0 16.761449] Hardware name: linux,dummy-virt (DT)
>> [=C2=A0=C2=A0 16.762185] pstate: 00400005 (nzcv daif +PAN -UAO)
>> [=C2=A0=C2=A0 16.762964] pc : arch_pgtable_tests_init+0x24c/0x474
>> [=C2=A0=C2=A0 16.763750] lr : arch_pgtable_tests_init+0x174/0x474
>> [=C2=A0=C2=A0 16.764534] sp : ffffffc011d7bd50
>> [=C2=A0=C2=A0 16.765065] x29: ffffffc011d7bd50 x28: ffffffff1756bac0
>> [=C2=A0=C2=A0 16.765908] x27: ffffff85ddaf3000 x26: 00000000000002e8
>> [=C2=A0=C2=A0 16.766767] x25: ffffffc0111ce000 x24: ffffff85ddaf32e8
>> [=C2=A0=C2=A0 16.767606] x23: ffffff85ddaef278 x22: 00000045cc844000
>> [=C2=A0=C2=A0 16.768445] x21: 000000065daef003 x20: ffffffff17540000
>> [=C2=A0=C2=A0 16.769283] x19: ffffff85ddb60000 x18: 0000000000000014
>> [=C2=A0=C2=A0 16.770122] x17: 00000000980426bb x16: 00000000698594c6
>> [=C2=A0=C2=A0 16.770976] x15: 0000000066e25a88 x14: 0000000000000000
>> [=C2=A0=C2=A0 16.771813] x13: ffffffff17540000 x12: 000000000000000a
>> [=C2=A0=C2=A0 16.772651] x11: ffffff85fcfd0a40 x10: 0000000000000001
>> [=C2=A0=C2=A0 16.773488] x9 : 0000000000000008 x8 : ffffffc01143ab26
>> [=C2=A0=C2=A0 16.774336] x7 : 0000000000000000 x6 : 0000000000000000
>> [=C2=A0=C2=A0 16.775180] x5 : 0000000000000000 x4 : 0000000000000000
>> [=C2=A0=C2=A0 16.776018] x3 : ffffffff1756bbe8 x2 : 000000065daeb003
>> [=C2=A0=C2=A0 16.776856] x1 : 000000000065daeb x0 : fffffffffffff000
>> [=C2=A0=C2=A0 16.777693] Call trace:
>> [=C2=A0=C2=A0 16.778092]=C2=A0 arch_pgtable_tests_init+0x24c/0x474
>> [=C2=A0=C2=A0 16.778843]=C2=A0 do_one_initcall+0x74/0x1b0
>> [=C2=A0=C2=A0 16.779458]=C2=A0 kernel_init_freeable+0x1cc/0x290
>> [=C2=A0=C2=A0 16.780151]=C2=A0 kernel_init+0x10/0x100
>> [=C2=A0=C2=A0 16.780710]=C2=A0 ret_from_fork+0x10/0x18
>> [=C2=A0=C2=A0 16.781282] ---[ end trace 042e6c40c0a3b038 ]---
>>
>> On arm64 (4K page size|39 bits VA|3 level page table)
>>
>> #elif CONFIG_PGTABLE_LEVELS =3D=3D 3=C2=A0=C2=A0=C2=A0 /* Applicable h=
ere */
>> #define __ARCH_USE_5LEVEL_HACK
>> #include <asm-generic/pgtable-nopud.h>
>>
>> Which pulls in
>>
>> #include <asm-generic/pgtable-nop4d-hack.h>
>>
>> which pulls in
>>
>> #include <asm-generic/5level-fixup.h>
>>
>> which defines
>>
>> static inline int p4d_none(p4d_t p4d)
>> {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
>> }
>>
>> which will invariably trigger WARN_ON(!p4d_none(p4d)).
>>
>> Similarly for next test p4d_populate_tests() which will always be
>> successful because p4d_bad() invariably returns negative.
>>
>> static inline int p4d_bad(p4d_t p4d)
>> {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
>> }
>>
>> static void __init p4d_populate_tests(struct mm_struct *mm, p4d_t *p4d=
p,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 pud_t *pudp)
>> {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p4d_t p4d;
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /*
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * This entry po=
ints to next level page table page.
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * Hence this mu=
st not qualify as p4d_bad().
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 */
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pud_clear(pudp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p4d_clear(p4dp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p4d_populate(mm, p4dp=
, pudp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p4d =3D READ_ONCE(*p4=
dp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 WARN_ON(p4d_bad(p4d))=
;
>> }
>>
>> We should not run these tests for the above config because they are
>> not applicable and will invariably produce same result.
>>
>>>
>>>>
>>>>>
>>>
>>> [...]
>>>
>>>>>> +#if !defined(__PAGETABLE_PUD_FOLDED) && !defined(__ARCH_HAS_5LEVE=
L_HACK)
>>>>>
>>>>> The same can be done here.
>>>>
>>>> IIRC not only the page table helpers but there are data types (pxx_t=
) which
>>>> were not present on various configs and these wrappers help prevent =
build
>>>> failures. Any ways will try and see if this can be improved further.=
 But
>>>> meanwhile if you have some suggestions, please do let me know.
>>>
>>> pgt_t and pmd_t are everywhere I guess.
>>> then pud_t and p4d_t have fallbacks in asm-generic files.
>>
>> Lets take another example where it fails to compile. On arm64 with 16K
>> page size, 48 bits VA, 4 level page table arrangement in the following
>> test, pgd_populate() does not have the required signature.
>>
>> static void pgd_populate_tests(struct mm_struct *mm, pgd_t *pgdp, p4d_=
t *p4dp)
>> {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pgd_t pgd;
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (mm_p4d_folded(mm)=
)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 return;
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /*
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * This entry po=
ints to next level page table page.
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * Hence this mu=
st not qualify as pgd_bad().
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 */
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 p4d_clear(p4dp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pgd_clear(pgdp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pgd_populate(mm, pgdp=
, p4dp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pgd =3D READ_ONCE(*pg=
dp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 WARN_ON(pgd_bad(pgd))=
;
>> }
>>
>> mm/arch_pgtable_test.c: In function =E2=80=98pgd_populate_tests=E2=80=99=
:
>> mm/arch_pgtable_test.c:254:25: error: passing argument 3 of =E2=80=98p=
gd_populate=E2=80=99 from incompatible pointer type [-Werror=3Dincompatib=
le-pointer-types]
>> =C2=A0=C2=A0 pgd_populate(mm, pgdp, p4dp);
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 ^~~~
>> In file included from mm/arch_pgtable_test.c:27:0:
>> ./arch/arm64/include/asm/pgalloc.h:81:20: note: expected =E2=80=98pud_=
t * {aka struct <anonymous> *}=E2=80=99 but argument is of type =E2=80=98=
pgd_t * {aka struct <anonymous> *}=E2=80=99
>> =C2=A0 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pg=
dp, pud_t *pudp)
>>
>> The build failure is because p4d_t * maps to pgd_t * but the applicabl=
e
>> (it does not fallback on generic ones) pgd_populate() expects a pud_t =
*.
>>
>> Except for archs which have 5 level page able, pgd_populate() always a=
ccepts
>> lower level page table pointers as the last argument as they dont have=
 that
>> many levels.
>>
>> arch/x86/include/asm/pgalloc.h:static inline void pgd_populate(struct =
mm_struct *mm, pgd_t *pgd, p4d_t *p4d)
>> arch/s390/include/asm/pgalloc.h:static inline void pgd_populate(struct=
 mm_struct *mm, pgd_t *pgd, p4d_t *p4d)
>>
>> But others
>>
>> arch/arm64/include/asm/pgalloc.h:static inline void pgd_populate(struc=
t mm_struct *mm, pgd_t *pgdp, pud_t *pudp)
>> arch/m68k/include/asm/motorola_pgalloc.h:static inline void pgd_popula=
te(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmd)
>> arch/mips/include/asm/pgalloc.h:static inline void pgd_populate(struct=
 mm_struct *mm, pgd_t *pgd, pud_t *pud)
>> arch/powerpc/include/asm/book3s/64/pgalloc.h:static inline void pgd_po=
pulate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
>>
>> I remember going through all these combinations before arriving at the
>> current state of #ifdef exclusions. Probably, to solved this all platf=
orms
>> have to define pxx_populate() helpers assuming they support 5 level pa=
ge
>> table.
>>
>>>
>>> So it shouldn't be an issue. Maybe if a couple of arches miss them, t=
he best would be to fix the arches, since that's the purpose of your test=
suite isn't it ?
>>
>> The run time failures as explained previously is because of the foldin=
g which
>> needs to be protected as they are not even applicable. The compile tim=
e
>> failures are because pxx_populate() signatures are platform specific d=
epending
>> on how many page table levels they really support.
>>
>=20
> So IIUC, the compiletime problem is around __ARCH_HAS_5LEVEL_HACK. For =
all #if !defined(__PAGETABLE_PXX_FOLDED), something equivalent to the fol=
lowing should make the trick.
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0if (mm_pxx_folded())
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>=20
>=20
> For the __ARCH_HAS_5LEVEL_HACK stuff, I think we should be able to regr=
oup all impacted functions inside a single #ifdef __ARCH_HAS_5LEVEL_HACK

I was wondering if it will be better to

1) Minimize all #ifdefs in the code which might fail on some platforms
2) Restrict proposed test module to platforms where it builds and runs
3) Enable other platforms afterwards after fixing their build problems or=
 other requirements

Would that be a better approach instead ?

