Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89A646B02F4
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 04:38:18 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k93so25532410ioi.1
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 01:38:18 -0700 (PDT)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id m10si1563514ioa.287.2017.06.16.01.38.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 01:38:17 -0700 (PDT)
Received: by mail-io0-x22f.google.com with SMTP id i7so26380700ioe.1
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 01:38:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <F0D43B2F-6811-4FEA-9152-75BD0792BD83@linaro.org>
References: <20170609082226.26152-1-ard.biesheuvel@linaro.org>
 <20170615142439.7a431065465c5b4691aed1cc@linux-foundation.org>
 <BE70CA51-B790-456E-B31C-399632B4DCD1@linaro.org> <20170615151637.77babb9a1b65c878f4235f65@linux-foundation.org>
 <F0D43B2F-6811-4FEA-9152-75BD0792BD83@linaro.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 16 Jun 2017 10:38:12 +0200
Message-ID: <CAKv+Gu_Uhrh_bE4aWKEkyJNsbH693d77tTi+fQYysof_oMzYEw@mail.gmail.com>
Subject: Re: [PATCH v5] mm: huge-vmap: fail gracefully on unexpected huge vmap mappings
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Zhong Jiang <zhongjiang@huawei.com>, Laura Abbott <labbott@fedoraproject.org>, Mark Rutland <mark.rutland@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Dave Hansen <dave.hansen@intel.com>

On 16 June 2017 at 00:29, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>
>> On 16 Jun 2017, at 00:16, Andrew Morton <akpm@linux-foundation.org> wrot=
e:
>>
>>> On Fri, 16 Jun 2017 00:11:53 +0200 Ard Biesheuvel <ard.biesheuvel@linar=
o.org> wrote:
>>>
>>>
>>>
>>>>> On 15 Jun 2017, at 23:24, Andrew Morton <akpm@linux-foundation.org> w=
rote:
>>>>>
>>>>> On Fri,  9 Jun 2017 08:22:26 +0000 Ard Biesheuvel <ard.biesheuvel@lin=
aro.org> wrote:
>>>>>
>>>>> Existing code that uses vmalloc_to_page() may assume that any
>>>>> address for which is_vmalloc_addr() returns true may be passed
>>>>> into vmalloc_to_page() to retrieve the associated struct page.
>>>>>
>>>>> This is not un unreasonable assumption to make, but on architectures
>>>>> that have CONFIG_HAVE_ARCH_HUGE_VMAP=3Dy, it no longer holds, and we
>>>>> need to ensure that vmalloc_to_page() does not go off into the weeds
>>>>> trying to dereference huge PUDs or PMDs as table entries.
>>>>>
>>>>> Given that vmalloc() and vmap() themselves never create huge
>>>>> mappings or deal with compound pages at all, there is no correct
>>>>> answer in this case, so return NULL instead, and issue a warning.
>>>>
>>>> Is this patch known to fix any current user-visible problem?
>>>
>>> Yes. When reading /proc/kcore on arm64, you will hit an oops as soon as=
 you hit the huge mappings used for the various segments that make up the m=
apping of vmlinux. With this patch applied, you will no longer hit the oops=
, but the kcore contents willl be incorrect (these regions will be zeroed o=
ut)
>>>
>>> We are fixing this for kcore specifically, so it avoids vread() for  th=
ose regions. At least one other problematic user exists, i.e., /dev/kmem, b=
ut that is currently broken on arm64 for other reasons.
>>>
>>
>> Do you have any suggestions regarding which kernel version(s) should
>> get this patch?
>>
>
> Good question. v4.6 was the first one to enable the huge vmap feature on =
arm64 iirc, but that does not necessarily mean it needs to be backported at=
 all imo. What is kcore used for? Production grade stuff?

In any case, could you perhaps simply queue it for v4.13? If it needs
to go into -stable, we can always do it later.

Thanks,
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
