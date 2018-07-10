Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C92D6B0006
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 07:21:56 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l13-v6so765182qth.8
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 04:21:56 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u14-v6si1728321qvb.118.2018.07.10.04.21.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 04:21:54 -0700 (PDT)
Date: Tue, 10 Jul 2018 07:21:41 -0400
In-Reply-To: <20180710104910.3xpiniksptpby4fo@kshutemo-mobl1>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com> <20180626142245.82850-14-kirill.shutemov@linux.intel.com> <20180709182055.GI6873@char.US.ORACLE.com> <20180710104910.3xpiniksptpby4fo@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHv4 13/18] x86/mm: Allow to disable MKTME after enumeration
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Message-ID: <82032424-C255-44A5-8C62-9AC883AD875C@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On July 10, 2018 6:49:10 AM EDT, "Kirill A=2E Shutemov" <kirill@shutemov=2E=
name> wrote:
>On Mon, Jul 09, 2018 at 02:20:55PM -0400, Konrad Rzeszutek Wilk wrote:
>> On Tue, Jun 26, 2018 at 05:22:40PM +0300, Kirill A=2E Shutemov wrote:
>> > The new helper mktme_disable() allows to disable MKTME even if it's
>> > enumerated successfully=2E MKTME initialization may fail and this
>> > functionality allows system to boot regardless of the failure=2E
>> >=20
>> > MKTME needs per-KeyID direct mapping=2E It requires a lot more
>virtual
>> > address space which may be a problem in 4-level paging mode=2E If the
>> > system has more physical memory than we can handle with MKTME=2E
>>=20
>> =2E=2E then what should happen?
>
>We fail MKTME initialization and boot the system=2E See next sentence=2E

Perhaps you can then remove the "=2E" and join the sentences=20
>
>> > The feature allows to fail MKTME, but boot the system successfully=2E
>> >=20
>> > Signed-off-by: Kirill A=2E Shutemov <kirill=2Eshutemov@linux=2Eintel=
=2Ecom>
>> > ---
>> >  arch/x86/include/asm/mktme=2Eh | 2 ++
>> >  arch/x86/kernel/cpu/intel=2Ec  | 5 +----
>> >  arch/x86/mm/mktme=2Ec          | 9 +++++++++
>> >  3 files changed, 12 insertions(+), 4 deletions(-)
>> >=20
>> > diff --git a/arch/x86/include/asm/mktme=2Eh
>b/arch/x86/include/asm/mktme=2Eh
>> > index 44409b8bbaca=2E=2Eebbee6a0c495 100644
>> > --- a/arch/x86/include/asm/mktme=2Eh
>> > +++ b/arch/x86/include/asm/mktme=2Eh
>> > @@ -6,6 +6,8 @@
>> > =20
>> >  struct vm_area_struct;
>> > =20
>> > +void mktme_disable(void);
>> > +
>> >  #ifdef CONFIG_X86_INTEL_MKTME
>> >  extern phys_addr_t mktme_keyid_mask;
>> >  extern int mktme_nr_keyids;
>> > diff --git a/arch/x86/kernel/cpu/intel=2Ec
>b/arch/x86/kernel/cpu/intel=2Ec
>> > index efc9e9fc47d4=2E=2E75e3b2602b4a 100644
>> > --- a/arch/x86/kernel/cpu/intel=2Ec
>> > +++ b/arch/x86/kernel/cpu/intel=2Ec
>> > @@ -591,10 +591,7 @@ static void detect_tme(struct cpuinfo_x86 *c)
>> >  		 * Maybe needed if there's inconsistent configuation
>> >  		 * between CPUs=2E
>> >  		 */
>> > -		physical_mask =3D (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
>> > -		mktme_keyid_mask =3D 0;
>> > -		mktme_keyid_shift =3D 0;
>> > -		mktme_nr_keyids =3D 0;
>> > +		mktme_disable();
>> >  	}
>> >  #endif
>> > =20
>> > diff --git a/arch/x86/mm/mktme=2Ec b/arch/x86/mm/mktme=2Ec
>> > index 1194496633ce=2E=2Ebb6210dbcf0e 100644
>> > --- a/arch/x86/mm/mktme=2Ec
>> > +++ b/arch/x86/mm/mktme=2Ec
>> > @@ -13,6 +13,15 @@ static inline bool mktme_enabled(void)
>> >  	return static_branch_unlikely(&mktme_enabled_key);
>> >  }
>> > =20
>> > +void mktme_disable(void)
>> > +{
>> > +	physical_mask =3D (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
>> > +	mktme_keyid_mask =3D 0;
>> > +	mktme_keyid_shift =3D 0;
>> > +	mktme_nr_keyids =3D 0;
>> > +	static_branch_disable(&mktme_enabled_key);
>> > +}
>> > +
>> >  int page_keyid(const struct page *page)
>> >  {
>> >  	if (!mktme_enabled())
>> > --=20
>> > 2=2E18=2E0
>> >=20
>>=20
