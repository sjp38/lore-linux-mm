Date: Tue, 5 Apr 2005 18:04:32 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.12-rc2-mm1 compilation failure
Message-Id: <20050405180432.73cacad3.akpm@osdl.org>
In-Reply-To: <4252AAEA.8080202@us.ibm.com>
References: <4252AAEA.8080202@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Janet Morgan <janetmor@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Janet Morgan <janetmor@us.ibm.com> wrote:
>
> I ran into this when trying to build 2.6.12-rc2-mm1:
> 
> arch/i386/kernel/built-in.o(.init.text+0x161f): In function `setup_arch':
> : undefined reference to `acpi_boot_table_init'
> arch/i386/kernel/built-in.o(.init.text+0x1624): In function `setup_arch':
> : undefined reference to `acpi_boot_init'
> make: *** [.tmp_vmlinux1] Error 1

yup.


diff -puN include/linux/acpi.h~no-acpi-build-fix include/linux/acpi.h
--- 25/include/linux/acpi.h~no-acpi-build-fix	2005-04-05 00:14:46.000000000 -0700
+++ 25-akpm/include/linux/acpi.h	2005-04-05 00:23:39.000000000 -0700
@@ -418,16 +418,6 @@ extern int sbf_port ;
 
 #define acpi_mp_config	0
 
-static inline int acpi_boot_init(void)
-{
-	return 0;
-}
-
-static inline int acpi_boot_table_init(void)
-{
-	return 0;
-}
-
 #endif 	/*!CONFIG_ACPI_BOOT*/
 
 unsigned int acpi_register_gsi (u32 gsi, int edge_level, int active_high_low);
@@ -538,5 +528,18 @@ static inline int acpi_get_pxm(acpi_hand
 
 extern int pnpacpi_disabled;
 
+#else	/* CONFIG_ACPI */
+
+static inline int acpi_boot_init(void)
+{
+	return 0;
+}
+
+static inline int acpi_boot_table_init(void)
+{
+	return 0;
+}
+
 #endif	/* CONFIG_ACPI */
+
 #endif	/* _LINUX_ACPI_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
