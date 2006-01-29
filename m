Date: Sun, 29 Jan 2006 15:59:24 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Compile error on x86 with hotplug but no highmem
In-Reply-To: <1138392149.19801.53.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.58.0601291556470.18044@skynet>
References: <Pine.LNX.4.58.0601271014090.25836@skynet>
 <1138392149.19801.53.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jan 2006, Dave Hansen wrote:

> On Fri, 2006-01-27 at 10:17 +0000, Mel Gorman wrote:
> > Memory hotplug without highmem is meaningless but it is still an allowed
> > configuration. This is one possible fix. Another is to not allow memory
> > hotplug without high memory being available. Another is to take
> > online_page() outside of the #ifdef CONFIG_HIGHMEM block in init.c .
>
> If it is meaningless, then we should probably fix it in the Kconfig
> file, not just work around it at runtime.
>
> What we really want is something to tell us that the architecture
> _supports_ highmem and isn't using it.  Maybe something like this?
>
> in mm/Kconfig:
>
> config MEMORY_HOTPLUG
> 	depends on ... && !ARCH_HAS_DISABLED_HIGHMEM
>
> in arch/i386/Kconfig:
>
> config ARCH_HAS_DISABLED_HIGHMEM
> 	def_bool n
> 	depends on !HIGHMEM
>

As HIGHMEM is not a requirement for hotplug on all architectures, I
changed the idea slightly to have the arch say when it does not have a
zone suitable for hotplug. How does this look?

diff -rup -X /usr/src/patchset-0.5/bin//dontdiff linux-2.6.16-rc1-mm3-clean/arch/i386/Kconfig linux-2.6.16-rc1-mm3-nohotplug/arch/i386/Kconfig
--- linux-2.6.16-rc1-mm3-clean/arch/i386/Kconfig	2006-01-29 15:08:27.000000000 +0000
+++ linux-2.6.16-rc1-mm3-nohotplug/arch/i386/Kconfig	2006-01-29 15:38:55.000000000 +0000
@@ -446,6 +446,10 @@ config HIGHMEM64G
 	  Select this if you have a 32-bit processor and more than 4
 	  gigabytes of physical RAM.

+config ARCH_HAS_NO_HOTPLUG_ZONE
+	def_bool y
+	depends on NOHIGHMEM
+
 endchoice

 choice
diff -rup -X /usr/src/patchset-0.5/bin//dontdiff linux-2.6.16-rc1-mm3-clean/mm/Kconfig linux-2.6.16-rc1-mm3-nohotplug/mm/Kconfig
--- linux-2.6.16-rc1-mm3-clean/mm/Kconfig	2006-01-17 07:44:47.000000000 +0000
+++ linux-2.6.16-rc1-mm3-nohotplug/mm/Kconfig	2006-01-29 15:37:16.000000000 +0000
@@ -115,7 +115,7 @@ config SPARSEMEM_EXTREME
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
-	depends on SPARSEMEM && HOTPLUG && !SOFTWARE_SUSPEND
+	depends on SPARSEMEM && HOTPLUG && !SOFTWARE_SUSPEND && !ARCH_HAS_NO_HOTPLUG_ZONE

 comment "Memory hotplug is currently incompatible with Software Suspend"
 	depends on SPARSEMEM && HOTPLUG && SOFTWARE_SUSPEND

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
