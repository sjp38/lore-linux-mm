Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 72E1D6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 20:57:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so32396778wmr.0
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 17:57:55 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id gr8si1501016wjc.58.2016.06.28.17.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Jun 2016 17:57:54 -0700 (PDT)
From: Dennis Chen <dennis.chen@arm.com>
Subject: [PATCH v5 1/3] mm: memblock enhence the memblock debugfs output
Date: Wed, 29 Jun 2016 08:57:33 +0800
Message-ID: <1467161855-10010-1-git-send-email-dennis.chen@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: nd@arm.com, Dennis Chen <dennis.chen@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Ard
 Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-efi@vger.kernel.org

Current memblock debugfs output doesn't make the debug convenient
enough, for example, lack of the 'flag' of the corresponding memblock
region result in it's difficult to known whether the region has been
mapped to the kernel linear map zone or not. This patch is trying to
ease the dubug effort by adding 'size' and 'flag' output.

The '/sys/kernel/debug/memblock/memory' output looks like before:
   0: 0x0000008000000000..0x0000008001e7ffff
   1: 0x0000008001e80000..0x00000083ff184fff
   2: 0x00000083ff185000..0x00000083ff1c2fff
   3: 0x00000083ff1c3000..0x00000083ff222fff
   4: 0x00000083ff223000..0x00000083ffe42fff
   5: 0x00000083ffe43000..0x00000083ffffffff

After applied:
   0: 0x0000008000000000..0x0000008001e7ffff  0x0000000001e80000  0x4=20
   1: 0x0000008001e80000..0x00000083ff184fff  0x00000003fd305000  0x0=20
   2: 0x00000083ff185000..0x00000083ff1c2fff  0x000000000003e000  0x4=20
   3: 0x00000083ff1c3000..0x00000083ff222fff  0x0000000000060000  0x0=20
   4: 0x00000083ff223000..0x00000083ffe42fff  0x0000000000c20000  0x4=20
   5: 0x00000083ffe43000..0x00000083ffffffff  0x00000000001bd000  0x0=20

Signed-off-by: Dennis Chen <dennis.chen@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Steve Capper <steve.capper@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
Cc: linux-mm@kvack.org
Cc: linux-acpi@vger.kernel.org
Cc: linux-efi@vger.kernel.org
---
 mm/memblock.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index ca09915..0fc0fa1 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1677,13 +1677,15 @@ static int memblock_debug_show(struct seq_file *m, =
void *private)
 =09=09reg =3D &type->regions[i];
 =09=09seq_printf(m, "%4d: ", i);
 =09=09if (sizeof(phys_addr_t) =3D=3D 4)
-=09=09=09seq_printf(m, "0x%08lx..0x%08lx\n",
+=09=09=09seq_printf(m, "0x%08lx..0x%08lx  0x%08lx  0x%lx\n",
 =09=09=09=09   (unsigned long)reg->base,
-=09=09=09=09   (unsigned long)(reg->base + reg->size - 1));
+=09=09=09=09   (unsigned long)(reg->base + reg->size - 1),
+=09=09=09=09   (unsigned long)reg->size, reg->flags);
 =09=09else
-=09=09=09seq_printf(m, "0x%016llx..0x%016llx\n",
+=09=09=09seq_printf(m, "0x%016llx..0x%016llx  0x%016llx  0x%lx\n",
 =09=09=09=09   (unsigned long long)reg->base,
-=09=09=09=09   (unsigned long long)(reg->base + reg->size - 1));
+=09=09=09=09   (unsigned long long)(reg->base + reg->size - 1),
+=09=09=09=09   (unsigned long long)reg->size, reg->flags);
=20
 =09}
 =09return 0;
--=20
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
