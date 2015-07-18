Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF1228035A
	for <linux-mm@kvack.org>; Sat, 18 Jul 2015 15:11:55 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so60664636wib.1
        for <linux-mm@kvack.org>; Sat, 18 Jul 2015 12:11:54 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id bb4si4302024wib.124.2015.07.18.12.11.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Jul 2015 12:11:53 -0700 (PDT)
Received: by wicmv11 with SMTP id mv11so66106939wic.1
        for <linux-mm@kvack.org>; Sat, 18 Jul 2015 12:11:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1436288623-13007-5-git-send-email-emunson@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com> <1436288623-13007-5-git-send-email-emunson@akamai.com>
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sat, 18 Jul 2015 15:11:23 -0400
Message-ID: <CAP=VYLq5=9DCfncJpQizcSbQt1O7VL2yEdzZNOFK+M3pqLpb3Q@mail.gmail.com>
Subject: Re: [PATCH V3 4/5] mm: mmap: Add mmap flag to request VM_LOCKONFAULT
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arch <linux-arch@vger.kernel.org>, linux-api@vger.kernel.org, cmetcalf@ezchip.com, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>

On Tue, Jul 7, 2015 at 1:03 PM, Eric B Munson <emunson@akamai.com> wrote:
> The cost of faulting in all memory to be locked can be very high when
> working with large mappings.  If only portions of the mapping will be
> used this can incur a high penalty for locking.
>
> Now that we have the new VMA flag for the locked but not present state,
> expose it  as an mmap option like MAP_LOCKED -> VM_LOCKED.

An automatic bisection on arch/tile leads to this commit:

5a5656f2c9b61c74c15f9ef3fa2e6513b6c237bb is the first bad commit
commit 5a5656f2c9b61c74c15f9ef3fa2e6513b6c237bb
Author: Eric B Munson <emunson@akamai.com>
Date:   Thu Jul 16 10:09:22 2015 +1000

    mm: mmap: add mmap flag to request VM_LOCKONFAULT

Fails with:

In file included from arch/tile/mm/init.c:24:
include/linux/mman.h: In function =E2=80=98calc_vm_flag_bits=E2=80=99:
include/linux/mman.h:90: error: =E2=80=98MAP_LOCKONFAULT=E2=80=99 undeclare=
d (first
use in this function)
include/linux/mman.h:90: error: (Each undeclared identifier is
reported only once
include/linux/mman.h:90: error: for each function it appears in.)
In file included from arch/tile/mm/mmap.c:21:
include/linux/mman.h: In function =E2=80=98calc_vm_flag_bits=E2=80=99:
include/linux/mman.h:90: error: =E2=80=98MAP_LOCKONFAULT=E2=80=99 undeclare=
d (first
use in this function)
include/linux/mman.h:90: error: (Each undeclared identifier is
reported only once
include/linux/mman.h:90: error: for each function it appears in.)
In file included from arch/tile/mm/fault.c:24:
include/linux/mman.h: In function =E2=80=98calc_vm_flag_bits=E2=80=99:
include/linux/mman.h:90: error: =E2=80=98MAP_LOCKONFAULT=E2=80=99 undeclare=
d (first
use in this function)
include/linux/mman.h:90: error: (Each undeclared identifier is
reported only once
include/linux/mman.h:90: error: for each function it appears in.)
In file included from arch/tile/mm/hugetlbpage.c:27:
include/linux/mman.h: In function =E2=80=98calc_vm_flag_bits=E2=80=99:
include/linux/mman.h:90: error: =E2=80=98MAP_LOCKONFAULT=E2=80=99 undeclare=
d (first
use in this function)
include/linux/mman.h:90: error: (Each undeclared identifier is
reported only once
include/linux/mman.h:90: error: for each function it appears in.)
make[1]: *** [arch/tile/mm/hugetlbpage.o] Error 1

http://kisskb.ellerman.id.au/kisskb/buildresult/12465365/

Paul.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
