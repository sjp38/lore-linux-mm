Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 445FD6B0062
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 17:39:38 -0400 (EDT)
Date: Tue, 9 Oct 2012 14:39:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: memory-hotplug : suppres
 "Trying to free nonexistent resource <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>"
 warning
Message-Id: <20121009143936.1f74a7fb.akpm@linux-foundation.org>
In-Reply-To: <5073913A.3080103@jp.fujitsu.com>
References: <506D1F1D.9000301@jp.fujitsu.com>
	<20121005140938.e3e1e196.akpm@linux-foundation.org>
	<5073913A.3080103@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com, dave@linux.vnet.ibm.com

On Tue, 9 Oct 2012 11:51:38 +0900
Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:

> > Anyway, please have a think, and see if we can come up with the best
> > and most accurate choice of types and identifiers in this code.
> 
> Your concern is right. Overflow bug may occur in the future.
> So I changed type of "i" and "sections_to_remove" to "unsigned long".
> Please merge it into your tree instead of previous patch.

Too late, the original patch was merged.  So I generated the delta.

I remain allergic to the `i' identifier so I renamed it to `section'. 
That's not 100% accurate, but it is better.

> __remove_pages() also has same concern. So I'll fix it.

Thanks.



From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Subject: arch/powerpc/platforms/pseries/hotplug-memory.c: section removal cleanups

Followups to d760afd4d25 ("memory-hotplug: suppress "Trying to free
nonexistent resource <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>" warning").

- use unsigned long type, as overflows are conceivable

- rename `i' to the less-misleading and more informative `section'

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/powerpc/platforms/pseries/hotplug-memory.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff -puN arch/powerpc/platforms/pseries/hotplug-memory.c~arch-powerpc-platforms-pseries-hotplug-memoryc-section-removal-cleanups arch/powerpc/platforms/pseries/hotplug-memory.c
--- a/arch/powerpc/platforms/pseries/hotplug-memory.c~arch-powerpc-platforms-pseries-hotplug-memoryc-section-removal-cleanups
+++ a/arch/powerpc/platforms/pseries/hotplug-memory.c
@@ -77,8 +77,9 @@ static int pseries_remove_memblock(unsig
 {
 	unsigned long start, start_pfn;
 	struct zone *zone;
-	int i, ret;
-	int sections_to_remove;
+	int ret;
+	unsigned long section;
+	unsigned long sections_to_remove;
 
 	start_pfn = base >> PAGE_SHIFT;
 
@@ -99,8 +100,8 @@ static int pseries_remove_memblock(unsig
 	 * while writing to it. So we have to defer it to here.
 	 */
 	sections_to_remove = (memblock_size >> PAGE_SHIFT) / PAGES_PER_SECTION;
-	for (i = 0; i < sections_to_remove; i++) {
-		unsigned long pfn = start_pfn + i * PAGES_PER_SECTION;
+	for (section = 0; section < sections_to_remove; section++) {
+		unsigned long pfn = start_pfn + section * PAGES_PER_SECTION;
 		ret = __remove_pages(zone, start_pfn,  PAGES_PER_SECTION);
 		if (ret)
 			return ret;
diff -puN mm/memory_hotplug.c~arch-powerpc-platforms-pseries-hotplug-memoryc-section-removal-cleanups mm/memory_hotplug.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
