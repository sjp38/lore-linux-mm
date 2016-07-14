Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 211CF6B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 01:44:48 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id c124so28389057ywd.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 22:44:48 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id a81si436605qkg.57.2016.07.13.22.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 22:44:47 -0700 (PDT)
From: Dennis Chen <dennis.chen@arm.com>
Subject: [PATCH v6 0/2] Fix acpi alignment fault with 'mem='
Date: Thu, 14 Jul 2016 13:43:54 +0800
Message-ID: <1468475036-5852-1-git-send-email-dennis.chen@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: nd@arm.com, steve.capper@arm.com, dennis.chen@arm.com, catalin.marinas@arm.com, ard.biesheuvel@linaro.org, akpm@linux-foundation.org, penberg@kernel.org, mgorman@techsingularity.net, tangchen@cn.fujitsu.com, tony.luck@intel.com, mingo@kernel.org, rafael@kernel.org, will.deacon@arm.com, mark.rutland@arm.com, matt@codeblueprint.co.uk, kaly.xin@arm.com, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-efi@vger.kernel.org

An ACPI alignment access fault has been observed on ARM platforms if one=20
boots an ACPI enabled kernel with 'mem=3D' specificed. This was due to
memblock_enforce_memory_limit(.) throwing away NOMAP regions thus causing
acpi_os_ioremap(.) to map them as device memory (rather than normal memory)=
.

This patch series fixes this issue by:=20
 1) Introducing memblock_mem_limit_remove_map(.), which retains the NOMAP
    regions.
 2) Calling this function in arm64.

ChangeLog:
v5->v6:=20
=09- Truncate the reserved regions above the limit as suggested by
=09  Steve Capper.
        - Drop the memblock debug fs related patch from this series since
=09  it's independent logically.=20
=09- CC more relevant persons.
v4->v5:
        Fix a build warning.
v3->v4:
        Address some review comments from Mark Rutland.
v2->v3:
        Only keep the NOMAP regions above the limit while removing all othe=
r
        memblocks as suggested by Ard Biesheuvel.
v1->v2:
        Flag all regions above the limit as NOMAP as suggested by Mark Rutl=
and.

Dennis Chen (2):
  mm:memblock Add new infrastructure to address the mem limit issue
  arm64:acpi Fix the acpi alignment exeception when 'mem=3D' specified

 arch/arm64/mm/init.c     |  2 +-
 include/linux/memblock.h |  1 +
 mm/memblock.c            | 57 +++++++++++++++++++++++++++++++++++++++++++-=
----
 3 files changed, 54 insertions(+), 6 deletions(-)

--=20
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
