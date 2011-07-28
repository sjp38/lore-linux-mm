Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3335F6B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 04:58:52 -0400 (EDT)
Received: by vws14 with SMTP id 14so1930998vws.9
        for <linux-mm@kvack.org>; Thu, 28 Jul 2011 01:58:49 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 28 Jul 2011 14:28:48 +0530
Message-ID: <CAFPAmTSDrQd53NsaWZfm9GFfUj4fHt9kUGACDkM33=2UxP212w@mail.gmail.com>
Subject: Crashes on ARM platform when sparsemem enabled in linux-2.6.35.13 due
 to pfn_valid() and pfn_valid_within().
From: ck ck <consul.kautuk@gmail.com>
Content-Type: multipart/alternative; boundary=bcaec547ca458b5b1b04a91d5f75
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: yad.naveen@gmail.com, linux-arm-kernel-request@lists.arm.linux.org.uk

--bcaec547ca458b5b1b04a91d5f75
Content-Type: text/plain; charset=ISO-8859-1

Hi,

On my ARM machine, the total kernel memory is not aligned to the section
size SECTION_SIZE_BITS.

I observe kernel crashes in the following 3 scenarios:
i)    When we do a "cat /proc/pagetypeinfo": This happens because the
pfn_valid() macro is not able to detect invalid PFNs in the loop in

vmstat.c: pagetypeinfo_showblockcount_print().
ii)    When we do "echo xxxx > /proc/vm/sys/min_free_kbytes": This happens
because the pfn_valid() macro is not able to detect invalid PFNs in

                                    page_alloc.c:
setup_zone_migrate_reserve().
iii)   When I try to copy a really huge file form one directory to another:
This happens because the CONFIG_HOLES_IN_ZONE config option is not set.

                                                So,
the code in move_freepages() crashes.

I did find one patch somewhat related to this problem at:
https://patchwork.kernel.org/patch/793862/
However, this patch is not suitable for my version of linux-2.6.35.13
because this uses memblock_*() functionality and
CONFIG_HAVE_MEMBLOCK is not enabled for my platform. Also, I am not sure
whether this will solve point iii) above, as pfn_valid_within()
will continue to return 1 back to the caller when it should be calling
pfn_vald() instead.

I created a solution patch for this and would appreciate it if anyone in
these mailing lists could review this patch and tell me whether:
i)  There is a better way to do this or,
ii)  There is already a more suitable patch for the configuration I am
mentioning above.

Patch:

--- linux-2.6.35.11.p29-FR/arch/arm/Kconfig 2011-07-27 10:27:02.243936001
+0530

+++ linux-2.6.35.11.p29-FR.new/arch/arm/Kconfig 2011-07-27
09:54:00.823935866 +0530

@@ -581,6 +581,16 @@ config OABI_COMPAT

config ARCH_HAS_HOLES_MEMORYMODEL

bool

+config ARCH_HAS_PFN_VALID

+ bool

+ depends on SPARSEMEM

+ default y

+

+config HOLES_IN_ZONE

+ bool

+ depends on SPARSEMEM

+ default y

+

# Discontigmem is deprecated

config ARCH_DISCONTIGMEM_ENABLE

bool

--- linux-2.6.35.9/arch/arm/mm/init.c 2011-06-13 15:18:47.921796999 +0530

+++ linux-2.6.35.9.new/arch/arm/mm/init.c 2011-06-13 11:59:47.236796983
+0530

@@ -350,6 +350,27 @@ static void arm_memory_present(struct me

{

}

#else

+#ifdef CONFIG_ARCH_HAS_PFN_VALID

+int arch_pfn_valid(unsigned long pfn)

+{

+ struct meminfo *mi = &meminfo;

+ unsigned int left = 0, right = mi->nr_banks;

+

+ do {

+ unsigned int mid = (right + left) / 2;

+ struct membank *bank = &mi->bank[mid];

+

+ if (pfn < bank_pfn_start(bank))

+ right = mid;

+ else if (pfn >= bank_pfn_end(bank))

+ left = mid + 1;

+ else

+ return 1;

+ } while (left < right);

+ return 0;

+}

+#endif

+

static void arm_memory_present(struct meminfo *mi, int node)

{

int i;

--- linux-2.6.35.9/include/linux/mmzone.h 2010-11-23 00:31:26.000000000
+0530

+++ linux-2.6.35.9.new/include/linux/mmzone.h 2011-06-13 12:32:37.182796701
+0530

@@ -1062,10 +1062,20 @@ static inline struct mem_section *__pfn_

return __nr_to_section(pfn_to_section_nr(pfn));

}

+#ifdef CONFIG_ARCH_HAS_PFN_VALID

+int arch_pfn_valid(unsigned long) ;

+#endif

+

static inline int pfn_valid(unsigned long pfn)

{

if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)

return 0;

+

+#ifdef CONFIG_ARCH_HAS_PFN_VALID

+ if (!arch_pfn_valid(pfn))

+ return 0 ;

+#endif

+

return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));

}

@@ -1073,6 +1083,12 @@ static inline int pfn_present(unsigned l

{

if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)

return 0;

+

+#ifdef CONFIG_ARCH_HAS_PFN_VALID

+ if (!arch_pfn_valid(pfn))

+ return 0 ;

+#endif

+

return present_section(__nr_to_section(pfn_to_section_nr(pfn)));

}


Thanks,
Kautuk.

--bcaec547ca458b5b1b04a91d5f75
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,<br>=A0<br>On my ARM machine, the total kernel memory is not aligned to =
the section size SECTION_SIZE_BITS.<br>=A0<br>I observe kernel crashes in t=
he following 3 scenarios:<br>i)=A0=A0=A0 When we do a &quot;cat /proc/paget=
ypeinfo&quot;: This happens because the pfn_valid() macro is not able to de=
tect invalid PFNs in the loop in<br>
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 vmsta=
t.c: pagetypeinfo_showblockcount_print().<br>ii)=A0=A0=A0 When we do &quot;=
echo xxxx &gt; /proc/vm/sys/min_free_kbytes&quot;: This happens because the=
 pfn_valid() macro is not able to detect invalid PFNs in<br>
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0page_alloc.c: setup_zone_migrate_reserve().<br>iii)=A0=
=A0 When I try to copy a really huge file form one directory to another: Th=
is happens because the CONFIG_HOLES_IN_ZONE config option is not set.<br>
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0So, the code in mo=
ve_freepages() crashes.<br>=A0<br>I did find one patch somewhat related to =
this problem at: <a href=3D"https://patchwork.kernel.org/patch/793862/">htt=
ps://patchwork.kernel.org/patch/793862/</a><br>
However, this patch is not suitable for my version of linux-2.6.35.13 becau=
se this uses memblock_*() functionality and<br>CONFIG_HAVE_MEMBLOCK is not =
enabled for my platform. Also, I am not sure whether this will solve point =
iii) above, as pfn_valid_within()<br>
will continue to return 1 back to the caller when it should be calling pfn_=
vald() instead.<br>=A0<br>I created a solution patch for this and would app=
reciate it if anyone in these mailing lists could review this patch and tel=
l me whether:<br>
i)=A0 There is a better way to do this or,<br>ii)=A0 There is already a mor=
e suitable patch for the configuration I am mentioning above.<br>=A0<br>Pat=
ch:<br><br>--- linux-2.6.35.11.p29-FR/arch/arm/Kconfig 2011-07-27 10:27:02.=
243936001 +0530<br>
<br>+++ linux-2.6.35.11.p29-FR.new/arch/arm/Kconfig 2011-07-27 09:54:00.823=
935866 +0530<br><br>@@ -581,6 +581,16 @@ config OABI_COMPAT<br><br>config A=
RCH_HAS_HOLES_MEMORYMODEL<br><br>bool<br><br>+config ARCH_HAS_PFN_VALID<br>
<br>+ bool<br><br>+ depends on SPARSEMEM<br><br>+ default y<br><br>+<br><br=
>+config HOLES_IN_ZONE<br><br>+ bool<br><br>+ depends on SPARSEMEM<br><br>+=
 default y<br><br>+<br><br># Discontigmem is deprecated<br><br>config ARCH_=
DISCONTIGMEM_ENABLE<br>
<br>bool<br><br>--- linux-2.6.35.9/arch/arm/mm/init.c 2011-06-13 15:18:47.9=
21796999 +0530<br><br>+++ linux-2.6.35.9.new/arch/arm/mm/init.c 2011-06-13 =
11:59:47.236796983 +0530<br><br>@@ -350,6 +350,27 @@ static void arm_memory=
_present(struct me<br>
<br>{<br><br>}<br><br>#else<br><br>+#ifdef CONFIG_ARCH_HAS_PFN_VALID<br><br=
>+int arch_pfn_valid(unsigned long pfn)<br><br>+{<br><br>+ struct meminfo *=
mi =3D &amp;meminfo;<br><br>+ unsigned int left =3D 0, right =3D mi-&gt;nr_=
banks;<br>
<br>+<br><br>+ do {<br><br>+ unsigned int mid =3D (right + left) / 2;<br><b=
r>+ struct membank *bank =3D &amp;mi-&gt;bank[mid];<br><br>+<br><br>+ if (p=
fn &lt; bank_pfn_start(bank))<br><br>+ right =3D mid;<br><br>+ else if (pfn=
 &gt;=3D bank_pfn_end(bank))<br>
<br>+ left =3D mid + 1;<br><br>+ else<br><br>+ return 1;<br><br>+ } while (=
left &lt; right);<br><br>+ return 0;<br><br>+}<br><br>+#endif<br><br>+<br><=
br>static void arm_memory_present(struct meminfo *mi, int node)<br><br>{<br=
>
<br>int i;<br><br>--- linux-2.6.35.9/include/linux/mmzone.h 2010-11-23 00:3=
1:26.000000000 +0530<br><br>+++ linux-2.6.35.9.new/include/linux/mmzone.h 2=
011-06-13 12:32:37.182796701 +0530<br><br>@@ -1062,10 +1062,20 @@ static in=
line struct mem_section *__pfn_<br>
<br>return __nr_to_section(pfn_to_section_nr(pfn));<br><br>}<br><br>+#ifdef=
 CONFIG_ARCH_HAS_PFN_VALID<br><br>+int arch_pfn_valid(unsigned long) ;<br><=
br>+#endif<br><br>+<br><br>static inline int pfn_valid(unsigned long pfn)<b=
r>
<br>{<br><br>if (pfn_to_section_nr(pfn) &gt;=3D NR_MEM_SECTIONS)<br><br>ret=
urn 0;<br><br>+<br><br>+#ifdef CONFIG_ARCH_HAS_PFN_VALID<br><br>+ if (!arch=
_pfn_valid(pfn))<br><br>+ return 0 ;<br><br>+#endif<br><br>+<br><br>return =
valid_section(__nr_to_section(pfn_to_section_nr(pfn)));<br>
<br>}<br><br>@@ -1073,6 +1083,12 @@ static inline int pfn_present(unsigned =
l<br><br>{<br><br>if (pfn_to_section_nr(pfn) &gt;=3D NR_MEM_SECTIONS)<br><b=
r>return 0;<br><br>+<br><br>+#ifdef CONFIG_ARCH_HAS_PFN_VALID<br><br>+ if (=
!arch_pfn_valid(pfn))<br>
<br>+ return 0 ;<br><br>+#endif<br><br>+<br><br>return present_section(__nr=
_to_section(pfn_to_section_nr(pfn)));<br><br>}<br><br>=A0<br>Thanks,<br>Kau=
tuk.

--bcaec547ca458b5b1b04a91d5f75--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
