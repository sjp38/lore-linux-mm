Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1F9D6B02B4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 08:39:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id m5so14041216pfc.1
        for <linux-mm@kvack.org>; Wed, 31 May 2017 05:39:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p7si16281986pgn.150.2017.05.31.05.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 05:39:36 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4VCdQCn041656
	for <linux-mm@kvack.org>; Wed, 31 May 2017 08:39:35 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2asj42wba9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 May 2017 08:39:34 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 31 May 2017 13:39:29 +0100
Date: Wed, 31 May 2017 15:39:22 +0300
In-Reply-To: <20170531120822.GL27783@dhcp22.suse.cz>
References: <c59a0893-d370-130b-5c33-d567a4621903@suse.cz> <20170524103947.GC3063@rapoport-lnx> <20170524111800.GD14733@dhcp22.suse.cz> <20170524142735.GF3063@rapoport-lnx> <20170530074408.GA7969@dhcp22.suse.cz> <20170530101921.GA25738@rapoport-lnx> <20170530103930.GB7969@dhcp22.suse.cz> <20170530140456.GA8412@redhat.com> <20170530143941.GK7969@dhcp22.suse.cz> <20170530154326.GB8412@redhat.com> <20170531120822.GL27783@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
From: Mike Rapoprt <rppt@linux.vnet.ibm.com>
Message-Id: <8FA5E4C2-D289-4AF5-AA09-6C199E58F9A5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>



On May 31, 2017 3:08:22 PM GMT+03:00, Michal Hocko <mhocko@kernel=2Eorg> w=
rote:
>On Tue 30-05-17 17:43:26, Andrea Arcangeli wrote:
>> On Tue, May 30, 2017 at 04:39:41PM +0200, Michal Hocko wrote:
>> > I sysctl for the mapcount can be increased, right? I also assume
>that
>> > those vmas will get merged after the post copy is done=2E
>>=20
>> Assuming you enlarge the sysctl to the worst possible case, with
>64bit
>> address space you can have billions of VMAs if you're migrating 4T of
>> RAM and you're unlucky and the address space gets fragmented=2E The
>> unswappable kernel memory overhead would be relatively large
>> (i=2Ee=2E dozen gigabytes of RAM in vm_area_struct slab), and each
>> find_vma operation would need to walk ~40 steps across that large vma
>> rbtree=2E There's a reason the sysctl exist=2E Not to tell all those
>> unnecessary vma mangling operations would be protected by the
>mmap_sem
>> for writing=2E
>>=20
>> Not creating a ton of vmas and enabling vma-less pte mangling with a
>> single large vma and only using mmap_sem for reading during all the
>> pte mangling, is one of the primary design motivations for
>> userfaultfd=2E
>
>Yes, I am aware of fallouts of too many vmas=2E I was asking merely to
>learn whether this will really happen under the the specific usecase
>Mike is after=2E

That depends on the application access pattern in the period between the p=
re-dump is finished and the application is frozen=2E If the accesses are ra=
ndom enough, the dirty pages that would be post copied could get spread all=
 over the address space=2E

>> > I understand that part but it sounds awfully one purpose thing to
>me=2E
>> > Are we going to add other MADVISE_RESET_$FOO to clear other flags
>just
>> > because we can race in this specific use case?
>>=20
>> Those already exists, see for example MADV_NORMAL, clearing
>> ~VM_RAND_READ & ~VM_SEQ_READ after calling MADV_SEQUENTIAL or
>> MADV_RANDOM=2E
>
>I would argue that MADV_NORMAL is everything but a clear madvise
>command=2E Why doesn't it clear all the sticky MADV* flags?

That would be helpful :)
Still, the problem here is more with the naming that with the action=2E If=
 it was called MADV_DEFAULT_READ or something, it would be fine, wouldn't i=
t?

>> Or MADV_DOFORK after MADV_DONTFORK=2E MADV_DONTDUMP after MADV_DODUMP=
=2E
>Etc=2E=2E
>>
>> > But we already have MADV_HUGEPAGE, MADV_NOHUGEPAGE and prctl to
>> > enable/disable thp=2E Doesn't that sound little bit too much for a
>single
>> > feature to you?
>>=20
>> MADV_NOHUGEPAGE doesn't mean clearing the flag set with
>> MADV_HUGEPAGE=2E MADV_NOHUGEPAGE disables THP on the region if the
>> global sysfs "enabled" tune is set to "always"=2E MADV_HUGEPAGE enables
>> THP if the global "enabled" sysfs tune is set to "madvise"=2E The two
>> MADV_NOHUGEPAGE and MADV_HUGEPAGE are needed to leverage the
>three-way
>> setting of "never" "madvise" "always" of the global tune=2E
>>=20
>> The "madvise" global tune exists if you want to save RAM and you
>don't
>> care much about performance but still allowing apps like QEMU where
>no
>> memory is lost by enabling THP, to use THP=2E
>>=20
>> There's no way to clear either of those two flags and bring back the
>> default behavior of the global sysfs tune, so it's not redundant at
>> the very least=2E
>
>Yes I am not a huge fan of the current MADV*HUGEPAGE semantic but I
>would really like to see a strong usecase for adding another command on
>top=2E=20

Well, another command makes the semantic a bit better, IMHO=2E=2E=2E

> From what Mike said a global disable THP for the whole process
>while the post-copy is in progress is a better solution anyway=2E

For the CRIU usecase, disabling THP for a while and re-enabling it back wi=
ll do the trick, provided VMAs flags are not affected, like in the patch yo=
u've sent=2E
Moreover, we may even get away with ioctl(UFFDIO_COPY) if it's overhead sh=
ows to be negligible=E2=80=8B=2E
Still, I believe that MADV_RESET_HUGEPAGE (or some better named) command h=
as the value on its own=2E
--
Sincerely yours,
Mike=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
