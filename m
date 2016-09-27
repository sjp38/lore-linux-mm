Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id BFE4628025A
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 16:05:49 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id bv10so42652754pad.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:05:49 -0700 (PDT)
Received: from mx0a-000cda01.pphosted.com (mx0a-00003501.pphosted.com. [67.231.144.15])
        by mx.google.com with ESMTPS id oo5si4072062pac.274.2016.09.27.13.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 13:05:48 -0700 (PDT)
Received: from pps.filterd (m0075554.ppops.net [127.0.0.1])
	by mx0a-000cda01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8RK46lg020433
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 16:05:48 -0400
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by mx0a-000cda01.pphosted.com with ESMTP id 25qv27hewy-10
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 16:05:47 -0400
Received: by mail-yw0-f197.google.com with SMTP id k17so9003487ywe.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:05:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160927160529.GJ4618@redhat.com>
References: <CAJ48U8XgWQZBFuWt2Gk_5JAXz3wONgd15OmBY0M-Urq+_VGe9A@mail.gmail.com>
 <20160927160529.GJ4618@redhat.com>
From: Shaun Tancheff <shaun.tancheff@seagate.com>
Date: Tue, 27 Sep 2016 15:05:26 -0500
Message-ID: <CAJVOszADPn=H4Mgk-kTPh08X18ppxu5zix9b22CstG5KQSwMCw@mail.gmail.com>
Subject: Re: BUG Re: mm: vma_merge: fix vm_page_prot SMP race condition
 against rmap_walk
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Shaun Tancheff <shaun@tancheff.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mgorman@techsingularity.net>, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Confirmed:
  - Removing DEBUG_VM_RB fixes the hang.

Also confirmed:
 - Above patch fixes the hang when DEBUG_VM_RB is re-enabled.

Thanks!



On Tue, Sep 27, 2016 at 11:05 AM, Andrea Arcangeli <aarcange@redhat.com> wr=
ote:
> Hello,
>
> On Tue, Sep 27, 2016 at 05:16:15AM -0500, Shaun Tancheff wrote:
>> git bisect points at commit  c9634dcf00c9c93b ("mm: vma_merge: fix
>> vm_page_prot SMP race condition against rmap_walk")
>
> I assume linux-next? But I can't find the commit, but I should know
> what this is.
>
>>
>> Last lines to console are [transcribed]:
>>
>> vma ffff8c3d989a7c78 start 00007fe02ed4c000 end 00007fe02ed52000
>> next ffff8c3d96de0c38 prev ffff8c3d989a6e40 mm ffff8c3d071cbac0
>> prot 8000000000000025 anon_vma ffff8c3d96fc9b28 vm_ops           (null)
>> pgoff 7fe02ed4c file           (null) private_data           (null)
>> flags: 0x8100073(read|write|mayread|maywrite|mayexec|account|softdirty)
>
> It's a false positive, you have DEBUG_VM_RB=3Dy, you can disable it or
> cherry-pick the fix:
>
> https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__git.kernel.org_cgi=
t_linux_kernel_git_andrea_aa.git_commit_-3Fid-3D74d8b44224f31153e23ca8a7f7f=
0700091f5a9b2&d=3DDQIBAg&c=3DIGDlg0lD0b-nebmJJ0Kp8A&r=3DWg5NqlNlVTT7Ugl8V50=
qIHLe856QW0qfG3WVYGOrWzA&m=3DmhyVFRknYnKxpypFw43nt0xMGGZX0r4k-qe6PIyp5ew&s=
=3DQjS2W4fUFnnJl4YxCk4WB30v5281AC4B7bAQeP8KWlQ&e=3D
>
> The assumption validate_mm_rb did isn't valid anymore on the new code
> during __vma_unlink, the validation code must be updated to skip the
> next vma instead of the current one after this change. It's a bug in
> DEBUG_VM_RB=3Dy, if you keep DEBUG_VM_RB=3Dn there's no bug.
>
>> Reproducer is an Ubuntu 16.04.1 LTS x86_64 running on a VM (VirtualBox).
>> Symptom is a solid hang after boot and switch to starting gnome session.
>>
>> Hang at about 35s.
>>
>> kdbg traceback is all null entries.
>>
>> Let me know what additional information I can provide.
>
> I already submitted the fix to Andrew last week:
>
> https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__marc.info_-3Fl-3Dl=
inux-2Dmm-26m-3D147449253801920-26w-3D2&d=3DDQIBAg&c=3DIGDlg0lD0b-nebmJJ0Kp=
8A&r=3DWg5NqlNlVTT7Ugl8V50qIHLe856QW0qfG3WVYGOrWzA&m=3DmhyVFRknYnKxpypFw43n=
t0xMGGZX0r4k-qe6PIyp5ew&s=3DEIo2P9JsNNIZSPoTgxO2vC5DJE4p6-HeOznwL1qhowo&e=
=3D
>
> I assume it's pending for merging in -mm.
>
> If you can test this patch and confirm the problem goes away with
> DEBUG_VM_RB=3Dy it'd be great.
>
> Thanks,
> Andrea



--=20
Shaun Tancheff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
