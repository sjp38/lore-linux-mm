Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4497D6B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 02:43:26 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fg1so234161181pad.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 23:43:26 -0700 (PDT)
Received: from prv-mh.provo.novell.com (prv-mh.provo.novell.com. [137.65.248.74])
        by mx.google.com with ESMTPS id or6si3691548pac.233.2016.06.06.23.43.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 23:43:25 -0700 (PDT)
Message-Id: <5756892902000078000F26C3@prv-mh.provo.novell.com>
Date: Tue, 07 Jun 2016 00:43:21 -0600
From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Bug 119641] New: hugetlbfs: disabling because there are
 no supported hugepage sizes
References: <bug-119641-27@https.bugzilla.kernel.org/>
 <20160606140123.bbc4b06d0f9d8b974f7b323f@linux-foundation.org>
In-Reply-To: <20160606140123.bbc4b06d0f9d8b974f7b323f@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jp.pozzi@izzop.net, Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org

>>> On 06.06.16 at 23:01, <akpm@linux-foundation.org> wrote:
> Does anyone have any theories about this?  I went through the
> 4.5.2->4.5.5 changelog searching for "huget" but came up blank..

Well, the original report (still quoted below) doesn't say whether
that's a PV or HVM guest under Xen (not that from the .config one
cannot tell). In the former case, observed behavior is the intended
effect of commit 103f6112f2: There simply are no huge pages
available in that environment. In the latter case I can't see where
the problem would be coming from.

Jan

> I'm suspiciously staring at Ingo's change
>=20
> commit b2eafe890d4a09bfa63ab31ff018d7d6bb8cfefc
> Merge: abfb949 ea5dfb5
> Author:     Ingo Molnar <mingo@kernel.org>
> AuthorDate: Fri Apr 22 10:12:19 2016 +0200
> Commit:     Ingo Molnar <mingo@kernel.org>
> CommitDate: Fri Apr 22 10:13:53 2016 +0200
>=20
>     Merge branch 'x86/urgent' into x86/asm, to fix semantic conflict
>    =20
>     'cpu_has_pse' has changed to boot_cpu_has(X86_FEATURE_PSE), fix this
>     up in the merge commit when merging the x86/urgent tree that =
includes
>     the following commit:
>    =20
>       103f6112f253 ("x86/mm/xen: Suppress hugetlbfs in PV guests")
>    =20
>     Signed-off-by: Ingo Molnar <mingo@kernel.org>
>=20
> --- a/arch/x86/include/asm/hugetlb.h
> +++ b/arch/x86/include/asm/hugetlb.h
> @@@ -4,6 -4,7 +4,7 @@@
>   #include <asm/page.h>
>   #include <asm-generic/hugetlb.h>
>  =20
>  -#define hugepages_supported() cpu_has_pse
> ++#define hugepages_supported() boot_cpu_has(X86_FEATURE_PSE)
>  =20
>   static inline int is_hugepage_only_range(struct mm_struct *mm,
>                                          unsigned long addr,
>=20
>=20
> Which is a followon to Jan's
>=20
> y:/usr/src/git26> gitshow 103f6112f253
> commit 103f6112f253017d7062cd74d17f4a514ed4485c
> Author:     Jan Beulich <JBeulich@suse.com>
> AuthorDate: Thu Apr 21 00:27:04 2016 -0600
> Commit:     Ingo Molnar <mingo@kernel.org>
> CommitDate: Fri Apr 22 10:05:00 2016 +0200
>=20
>     x86/mm/xen: Suppress hugetlbfs in PV guests
>    =20
>     Huge pages are not normally available to PV guests. Not suppressing
>     hugetlbfs use results in an endless loop of page faults when user =
mode
>     code tries to access a hugetlbfs mapped area (since the hypervisor
>     denies such PTEs to be created, but error indications can't be
>     propagated out of xen_set_pte_at(), just like for various of its
>     siblings), and - once killed in an oops like this:
>=20
>=20
> On Sat, 04 Jun 2016 17:08:36 +0000 bugzilla-daemon@bugzilla.kernel.org =
wrote:
>=20
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D119641=20
>>=20
>>             Bug ID: 119641
>>            Summary: hugetlbfs: disabling because there are no supported
>>                     hugepage sizes
>>            Product: Memory Management
>>            Version: 2.5
>>     Kernel Version: 3.6.1
>>           Hardware: Intel
>>                 OS: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Other
>>           Assignee: akpm@linux-foundation.org=20
>>           Reporter: jp.pozzi@izzop.net=20
>>         Regression: No
>>=20
>> Created attachment 219011
>>   --> https://bugzilla.kernel.org/attachment.cgi?id=3D219011&action=3Ded=
it=20
>> .config for 4.6.1 kernel
>>=20
>> Hello,
>>=20
>> I get a message while starting the 4.6.1 kernel under Xen :
>> hugetlbfs: disabling because there are no supported hugepage sizes
>>=20
>> And after grepping /proc/meminfo for Huge I get only :
>> grep -i huge /proc/meminfo=20
>> AnonHugePages:         0 kB
>>=20
>> I get this message only when starting the kernel under Xen, when =
starting
>> kernel alone All is OK and I get the "normal" hugepages list.
>>=20
>> I test some previous kernels versions :
>> 4.5.2   OK
>> 4.5.5   KO
>> 4.6.0   KO
>>=20
>> My system is=20
>> CPU     Intel Core I7 6700
>> MEM     32Go
>> Disks   some ...
>> System  Debian unstable up to date
>>=20
>> I enclose the .config file.
>>=20
>> Regards
>>=20
>> JP P
>>=20
>> --=20
>> You are receiving this mail because:
>> You are the assignee for the bug.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
