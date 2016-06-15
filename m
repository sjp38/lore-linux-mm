Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 34B2E6B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:04:52 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id he1so49758083pac.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:04:52 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id u3si954345pfu.244.2016.06.15.13.04.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 13:04:51 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id t190so2361272pfb.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:04:51 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <C1C2579D7BE026428F81F41198ADB17237A8670A@irsmsx110.ger.corp.intel.com>
Date: Wed, 15 Jun 2016 13:04:48 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <613007E2-2A88-4934-9364-A5A66A555305@gmail.com>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com> <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com> <76F6D5F2-6723-441B-BD63-52628731F1FF@gmail.com> <C1C2579D7BE026428F81F41198ADB17237A8670A@irsmsx110.ger.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, "Srinivasappa, Harish" <harish.srinivasappa@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Andrejczuk, Grzegorz" <grzegorz.andrejczuk@intel.com>, "Daniluk, Lukasz" <lukasz.daniluk@intel.com>

Lukasz <lukasz.anaczkowski@intel.com> wrote:

> From: Nadav Amit [mailto:nadav.amit@gmail.com]=20
> Sent: Tuesday, June 14, 2016 8:38 PM
>=20
>>> +	pte_t pte =3D ptep_get_and_clear(mm, addr, ptep);
>>> +
>>> +	if (boot_cpu_has_bug(X86_BUG_PTE_LEAK))
>>> +		fix_pte_leak(mm, addr, ptep);
>>> +	return pte;
>>> }
>>=20
>> I missed it on the previous iteration: ptep_get_and_clear already =
calls=20
>> fix_pte_leak when needed. So do you need to call it again here?
>=20
> You're right, Nadav. Not needing this. Will be removed in next version =
of the patch.

Be careful here. According to the SDM when invalidating a huge-page,
each 4KB page needs to be invalidated separately. In practice, when
Linux invalidates 2MB/1GB pages it performs a full TLB flush. The
full flush may not be required on knights landing, and specifically
for the workaround, but you should check. =20

Regards,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
