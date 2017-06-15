Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6246B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 18:29:07 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n7so5270995wrb.0
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:29:07 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id v17si399349wra.229.2017.06.15.15.29.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 15:29:05 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id m125so11384308wmm.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:29:05 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v5] mm: huge-vmap: fail gracefully on unexpected huge vmap mappings
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
In-Reply-To: <20170615151637.77babb9a1b65c878f4235f65@linux-foundation.org>
Date: Fri, 16 Jun 2017 00:29:03 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <F0D43B2F-6811-4FEA-9152-75BD0792BD83@linaro.org>
References: <20170609082226.26152-1-ard.biesheuvel@linaro.org> <20170615142439.7a431065465c5b4691aed1cc@linux-foundation.org> <BE70CA51-B790-456E-B31C-399632B4DCD1@linaro.org> <20170615151637.77babb9a1b65c878f4235f65@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mhocko@suse.com, zhongjiang@huawei.com, labbott@fedoraproject.org, mark.rutland@arm.com, linux-arm-kernel@lists.infradead.org, dave.hansen@intel.com


> On 16 Jun 2017, at 00:16, Andrew Morton <akpm@linux-foundation.org> wrote:=

>=20
>> On Fri, 16 Jun 2017 00:11:53 +0200 Ard Biesheuvel <ard.biesheuvel@linaro.=
org> wrote:
>>=20
>>=20
>>=20
>>>> On 15 Jun 2017, at 23:24, Andrew Morton <akpm@linux-foundation.org> wro=
te:
>>>>=20
>>>> On Fri,  9 Jun 2017 08:22:26 +0000 Ard Biesheuvel <ard.biesheuvel@linar=
o.org> wrote:
>>>>=20
>>>> Existing code that uses vmalloc_to_page() may assume that any
>>>> address for which is_vmalloc_addr() returns true may be passed
>>>> into vmalloc_to_page() to retrieve the associated struct page.
>>>>=20
>>>> This is not un unreasonable assumption to make, but on architectures
>>>> that have CONFIG_HAVE_ARCH_HUGE_VMAP=3Dy, it no longer holds, and we
>>>> need to ensure that vmalloc_to_page() does not go off into the weeds
>>>> trying to dereference huge PUDs or PMDs as table entries.
>>>>=20
>>>> Given that vmalloc() and vmap() themselves never create huge
>>>> mappings or deal with compound pages at all, there is no correct
>>>> answer in this case, so return NULL instead, and issue a warning.
>>>=20
>>> Is this patch known to fix any current user-visible problem?
>>=20
>> Yes. When reading /proc/kcore on arm64, you will hit an oops as soon as y=
ou hit the huge mappings used for the various segments that make up the mapp=
ing of vmlinux. With this patch applied, you will no longer hit the oops, bu=
t the kcore contents willl be incorrect (these regions will be zeroed out)
>>=20
>> We are fixing this for kcore specifically, so it avoids vread() for  thos=
e regions. At least one other problematic user exists, i.e., /dev/kmem, but t=
hat is currently broken on arm64 for other reasons.
>>=20
>=20
> Do you have any suggestions regarding which kernel version(s) should
> get this patch?
>=20

Good question. v4.6 was the first one to enable the huge vmap feature on arm=
64 iirc, but that does not necessarily mean it needs to be backported at all=
 imo. What is kcore used for? Production grade stuff?=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
