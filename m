Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85EFB6B025E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 07:31:59 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id k62so39710708vkb.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:31:59 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id t27si5289613qtt.28.2016.06.23.04.31.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 04:31:58 -0700 (PDT)
From: Dennis Chen <dennis.chen@arm.com>
Subject: [PATCH 2/2] arm64:acpi Fix the acpi alignment exeception when 'mem=' specified
Date: Thu, 23 Jun 2016 19:30:15 +0800
Message-ID: <1466681415-8058-2-git-send-email-dennis.chen@arm.com>
In-Reply-To: <1466681415-8058-1-git-send-email-dennis.chen@arm.com>
References: <1466681415-8058-1-git-send-email-dennis.chen@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: nd@arm.com, Dennis Chen <dennis.chen@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Ard
 Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-efi@vger.kernel.org

This is a rework patch based on [1]. According to the proposal from
Mark Rutland, when applying the system memory limit through 'mem=3Dx'
kernel command line, don't remove the rest memory regions above the
limit from the memblock, instead marking them as MEMBLOCK_NOMAP region,
which will preserve the ability to identify regions as normal memory
while not using them for allocation and the linear map.

Without this patch, the ACPI core will map those acpi data regions(if
they are above the limit) as device type memory, which will result in
the alignment exception when ACPI core parses the AML data stream=20
since the parsing will produce some non-alignment accesses.

[1]:http://lists.infradead.org/pipermail/linux-arm-kernel/2016-June/438443.=
html

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
 arch/arm64/mm/init.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index d45f862..e509e24 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -222,12 +222,14 @@ void __init arm64_memblock_init(void)
=20
 =09/*
 =09 * Apply the memory limit if it was set. Since the kernel may be loaded
-=09 * high up in memory, add back the kernel region that must be accessibl=
e
-=09 * via the linear mapping.
+=09 * in the memory regions above the limit, so we need to clear the
+=09 * MEMBLOCK_NOMAP flag of this region to make it can be accessible via
+=09 * the linear mapping.
 =09 */
 =09if (memory_limit !=3D (phys_addr_t)ULLONG_MAX) {
-=09=09memblock_enforce_memory_limit(memory_limit);
-=09=09memblock_add(__pa(_text), (u64)(_end - _text));
+=09=09memblock_mem_limit_mark_nomap(memory_limit);
+=09=09if (!memblock_is_map_memory(__pa(_text)))
+=09=09=09memblock_clear_nomap(__pa(_text), (u64)(_end - _text));
 =09}
=20
 =09if (IS_ENABLED(CONFIG_BLK_DEV_INITRD) && initrd_start) {
--=20
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
