Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id E7E348D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 05:01:26 -0400 (EDT)
Message-ID: <4FACD573.4060103@kernel.org>
Date: Fri, 11 May 2012 18:01:39 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: raise MemFree by reverting percpu_pagelist_fraction
 to 0
References: <alpine.LSU.2.00.1205110054520.2801@eggly.anvils> <CA+1xoqcChazS=TRt6-7GjJAzQNFLFXmO623rWwjRkdD5x3k=iw@mail.gmail.com> <4FACD00D.4060003@kernel.org>
In-Reply-To: <4FACD00D.4060003@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/11/2012 05:38 PM, Minchan Kim wrote:

> On 05/11/2012 05:30 PM, Sasha Levin wrote:
> 
>> On Fri, May 11, 2012 at 10:00 AM, Hugh Dickins <hughd@google.com> wrote:
>>> Commit 93278814d359 "mm: fix division by 0 in percpu_pagelist_fraction()"
>>> mistakenly initialized percpu_pagelist_fraction to the sysctl's minimum 8,
>>> which leaves 1/8th of memory on percpu lists (on each cpu??); but most of
>>> us expect it to be left unset at 0 (and it's not then used as a divisor).
>>
>> I'm a bit confused about this, does it mean that once you set
>> percpu_pagelist_fraction to a value above the minimum, you can no
>> longer set it back to being 0?
> 
> 
> Unfortunately, Yes. :(
> It's rather awkward and need fix.



I didn't have a time so made quick patch to show just concept.
Not tested and Not consider carefully.
If anyone doesn't oppose, I will send formal patch which will have more beauty code.

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f487f25..fabc52c 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -132,7 +132,6 @@ static unsigned long dirty_bytes_min = 2 * PAGE_SIZE;
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
 static int minolduid;
-static int min_percpu_pagelist_fract = 8;
 
 static int ngroups_max = NGROUPS_MAX;
 static const int cap_last_cap = CAP_LAST_CAP;
@@ -1214,7 +1213,6 @@ static struct ctl_table vm_table[] = {
                .maxlen         = sizeof(percpu_pagelist_fraction),
                .mode           = 0644,
                .proc_handler   = percpu_pagelist_fraction_sysctl_handler,
-               .extra1         = &min_percpu_pagelist_fract,
        },
 #ifdef CONFIG_MMU
        {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a13ded1..cc2353a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5161,12 +5161,30 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
        ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
        if (!write || (ret == -EINVAL))
                return ret;
-       for_each_populated_zone(zone) {
-               for_each_possible_cpu(cpu) {
-                       unsigned long  high;
-                       high = zone->present_pages / percpu_pagelist_fraction;
-                       setup_pagelist_highmark(
-                               per_cpu_ptr(zone->pageset, cpu), high);
+
+       if (percpu_pagelist_fraction < 8 && percpu_pagelist_fraction != 0)
+               return -EINVAL;
+
+       if (percpu_pagelist_fraction != 0) {
+               for_each_populated_zone(zone) {
+                       for_each_possible_cpu(cpu) {
+                               unsigned long  high;
+                               high = zone->present_pages / percpu_pagelist_fraction;
+                               setup_pagelist_highmark(
+                                       per_cpu_ptr(zone->pageset, cpu), high);
+                       }
+               }
+       }
+       else {
+               for_each_populated_zone(zone) {
+                       for_each_possible_cpu(cpu) {
+                               struct per_cpu_pageset *p = per_cpu_ptr(zone->pageset, cpu);
+                               unsigned long batch = zone_batchsize(zone);
+                               struct per_cpu_pages *pcp;
+                               pcp = &p->pcp;
+                               pcp->high = 6 * batch;
+                               pcp->batch = max(1UL, 1 * batch);
+                       }
                }
        }
        return 0;


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
