Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3118D6B009C
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 18:51:48 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so102506925pac.13
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 15:51:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id db9si68143pad.31.2015.02.03.15.51.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 15:51:47 -0800 (PST)
Date: Tue, 3 Feb 2015 15:51:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v11 18/19] module: fix types of device tables aliases
Message-Id: <20150203155145.632f352695fc558083d8c054@linux-foundation.org>
In-Reply-To: <1422985392-28652-19-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
	<1422985392-28652-19-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>, James Bottomley <James.Bottomley@HansenPartnership.com>

On Tue, 03 Feb 2015 20:43:11 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> MODULE_DEVICE_TABLE() macro used to create aliases to device tables.
> Normally alias should have the same type as aliased symbol.
> 
> Device tables are arrays, so they have 'struct type##_device_id[x]'
> types. Alias created by MODULE_DEVICE_TABLE() will have non-array type -
> 	'struct type##_device_id'.
> 
> This inconsistency confuses compiler, it could make a wrong
> assumption about variable's size which leads KASan to
> produce a false positive report about out of bounds access.
> 
> For every global variable compiler calls __asan_register_globals()
> passing information about global variable (address, size, size with
> redzone, name ...) __asan_register_globals() poison symbols
> redzone to detect possible out of bounds accesses.
> 
> When symbol has an alias __asan_register_globals() will be called
> as for symbol so for alias. Compiler determines size of variable by
> size of variable's type. Alias and symbol have the same address,
> so if alias have the wrong size part of memory that actually belongs
> to the symbol could be poisoned as redzone of alias symbol.
> 
> By fixing type of alias symbol we will fix size of it, so
> __asan_register_globals() will not poison valid memory.
> 
> ...
>
> --- a/include/linux/module.h
> +++ b/include/linux/module.h
> @@ -135,7 +135,7 @@ void trim_init_extable(struct module *m);
>  #ifdef MODULE
>  /* Creates an alias so file2alias.c can find device table. */
>  #define MODULE_DEVICE_TABLE(type, name)					\
> -  extern const struct type##_device_id __mod_##type##__##name##_device_table \
> +extern const typeof(name) __mod_##type##__##name##_device_table		\
>    __attribute__ ((unused, alias(__stringify(name))))
>  #else  /* !MODULE */
>  #define MODULE_DEVICE_TABLE(type, name)

This newly requires that `name' has been defined at the
MODULE_DEVICE_TABLE expansion site.

So drivers/scsi/be2iscsi/be_main.c explodes because we converted

extern const struct pci_device_id __mod_pci__beiscsi_pci_id_table_device_table __attribute__ ((unused, alias("beiscsi_pci_id_table")));

into

extern const typeof(beiscsi_pci_id_table) __mod_pci__beiscsi_pci_id_table_device_table __attribute__ ((unused, alias("beiscsi_pci_id_table")));

before beiscsi_pci_id_table was defined.


There are probably others, so I'll start accumulating the fixes.



From: Andrew Morton <akpm@linux-foundation.org>
Subject: MODULE_DEVICE_TABLE: fix some callsites

The patch "module: fix types of device tables aliases" newly requires that
invokations of

MODULE_DEVICE_TABLE(type, name);

come *after* the definition of `name'.  That is reasonable, but some
drivers weren't doing this.  Fix them.

Cc: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/scsi/be2iscsi/be_main.c |    1 -
 1 file changed, 1 deletion(-)

diff -puN drivers/scsi/be2iscsi/be_main.c~module_device_table-fix-some-callsites drivers/scsi/be2iscsi/be_main.c
--- a/drivers/scsi/be2iscsi/be_main.c~module_device_table-fix-some-callsites
+++ a/drivers/scsi/be2iscsi/be_main.c
@@ -48,7 +48,6 @@ static unsigned int be_iopoll_budget = 1
 static unsigned int be_max_phys_size = 64;
 static unsigned int enable_msix = 1;
 
-MODULE_DEVICE_TABLE(pci, beiscsi_pci_id_table);
 MODULE_DESCRIPTION(DRV_DESC " " BUILD_STR);
 MODULE_VERSION(BUILD_STR);
 MODULE_AUTHOR("Emulex Corporation");
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
