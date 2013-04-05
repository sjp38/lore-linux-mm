Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 957166B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 20:17:07 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl13so1750109pab.32
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 17:17:06 -0700 (PDT)
Message-ID: <515E17FC.9050008@gmail.com>
Date: Fri, 05 Apr 2013 08:17:00 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
References: <20130122065341.GA1850@kernel.org> <20130123075808.GH2723@blaptop>
In-Reply-To: <20130123075808.GH2723@blaptop>
Content-Type: multipart/alternative;
 boundary="------------090906050906080805000905"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

This is a multi-part message in MIME format.
--------------090906050906080805000905
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Minchan,
On 01/23/2013 03:58 PM, Minchan Kim wrote:
> On Tue, Jan 22, 2013 at 02:53:41PM +0800, Shaohua Li wrote:
>> Hi,
>>
>> Because of high density, low power and low price, flash storage (SSD) is a good
>> candidate to partially replace DRAM. A quick answer for this is using SSD as
>> swap. But Linux swap is designed for slow hard disk storage. There are a lot of
>> challenges to efficiently use SSD for swap:
> Many of below item could be applied in in-memory swap like zram, zcache.
>
>> 1. Lock contentions (swap_lock, anon_vma mutex, swap address space lock)
>> 2. TLB flush overhead. To reclaim one page, we need at least 2 TLB flush. This
>> overhead is very high even in a normal 2-socket machine.
>> 3. Better swap IO pattern. Both direct and kswapd page reclaim can do swap,
>> which makes swap IO pattern is interleave. Block layer isn't always efficient
>> to do request merge. Such IO pattern also makes swap prefetch hard.
> Agreed.
>
>> 4. Swap map scan overhead. Swap in-memory map scan scans an array, which is
>> very inefficient, especially if swap storage is fast.
> Agreed.
>
>> 5. SSD related optimization, mainly discard support
>> 6. Better swap prefetch algorithm. Besides item 3, sequentially accessed pages
>> aren't always in LRU list adjacently, so page reclaim will not swap such pages
>> in adjacent storage sectors. This makes swap prefetch hard.
> One of problem is LRU churning and I wanted to try to fix it.
> http://marc.info/?l=linux-mm&m=130978831028952&w=4

I'm interested in this feature, why it didn't merged? what's the fatal 
issue in your patchset?
http://lwn.net/Articles/449866/
You mentioned test script and all-at-once patch, but I can't get them 
from the URL, could you tell me how to get it?

>
>> 7. Alternative page reclaim policy to bias reclaiming anonymous page.
>> Currently reclaim anonymous page is considering harder than reclaim file pages,
>> so we bias reclaiming file pages. If there are high speed swap storage, we are
>> considering doing swap more aggressively.
> Yeb. We need it. I tried it with extending vm_swappiness to 200.
>
> From: Minchan Kim <minchan@kernel.org>
> Date: Mon, 3 Dec 2012 16:21:00 +0900
> Subject: [PATCH] mm: increase swappiness to 200
>
> We have thought swap out cost is very high but it's not true
> if we use fast device like swap-over-zram. Nonetheless, we can
> swap out 1:1 ratio of anon and page cache at most.
> It's not enough to use swap device fully so we encounter OOM kill
> while there are many free space in zram swap device. It's never
> what we want.
>
> This patch makes swap out aggressively.
>
> Cc: Luigi Semenzato <semenzato@google.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   kernel/sysctl.c |    3 ++-
>   mm/vmscan.c     |    6 ++++--
>   2 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 693e0ed..f1dbd9d 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -130,6 +130,7 @@ static int __maybe_unused two = 2;
>   static int __maybe_unused three = 3;
>   static unsigned long one_ul = 1;
>   static int one_hundred = 100;
> +extern int max_swappiness;
>   #ifdef CONFIG_PRINTK
>   static int ten_thousand = 10000;
>   #endif
> @@ -1157,7 +1158,7 @@ static struct ctl_table vm_table[] = {
>                  .mode           = 0644,
>                  .proc_handler   = proc_dointvec_minmax,
>                  .extra1         = &zero,
> -               .extra2         = &one_hundred,
> +               .extra2         = &max_swappiness,
>          },
>   #ifdef CONFIG_HUGETLB_PAGE
>          {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 53dcde9..64f3c21 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -53,6 +53,8 @@
>   #define CREATE_TRACE_POINTS
>   #include <trace/events/vmscan.h>
>   
> +int max_swappiness = 200;
> +
>   struct scan_control {
>          /* Incremented by the number of inactive pages that were scanned */
>          unsigned long nr_scanned;
> @@ -1626,6 +1628,7 @@ static int vmscan_swappiness(struct scan_control *sc)
>          return mem_cgroup_swappiness(sc->target_mem_cgroup);
>   }
>   
> +
>   /*
>    * Determine how aggressively the anon and file LRU lists should be
>    * scanned.  The relative value of each set of LRU lists is determined
> @@ -1701,11 +1704,10 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>          }
>   
>          /*
> -        * With swappiness at 100, anonymous and file have the same priority.
>           * This scanning priority is essentially the inverse of IO cost.
>           */
>          anon_prio = vmscan_swappiness(sc);
> -       file_prio = 200 - anon_prio;
> +       file_prio = max_swappiness - anon_prio;
>   
>          /*
>           * OK, so we have swap space and a fair amount of page cache


--------------090906050906080805000905
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">Hi Minchan,<br>
      On 01/23/2013 03:58 PM, Minchan Kim wrote:<br>
    </div>
    <blockquote cite="mid:20130123075808.GH2723@blaptop" type="cite">
      <pre wrap="">On Tue, Jan 22, 2013 at 02:53:41PM +0800, Shaohua Li wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">Hi,

Because of high density, low power and low price, flash storage (SSD) is a good
candidate to partially replace DRAM. A quick answer for this is using SSD as
swap. But Linux swap is designed for slow hard disk storage. There are a lot of
challenges to efficiently use SSD for swap:
</pre>
      </blockquote>
      <pre wrap="">
Many of below item could be applied in in-memory swap like zram, zcache.

</pre>
      <blockquote type="cite">
        <pre wrap="">
1. Lock contentions (swap_lock, anon_vma mutex, swap address space lock)
2. TLB flush overhead. To reclaim one page, we need at least 2 TLB flush. This
overhead is very high even in a normal 2-socket machine.
3. Better swap IO pattern. Both direct and kswapd page reclaim can do swap,
which makes swap IO pattern is interleave. Block layer isn't always efficient
to do request merge. Such IO pattern also makes swap prefetch hard.
</pre>
      </blockquote>
      <pre wrap="">
Agreed.

</pre>
      <blockquote type="cite">
        <pre wrap="">4. Swap map scan overhead. Swap in-memory map scan scans an array, which is
very inefficient, especially if swap storage is fast.
</pre>
      </blockquote>
      <pre wrap="">
Agreed.

</pre>
      <blockquote type="cite">
        <pre wrap="">5. SSD related optimization, mainly discard support
6. Better swap prefetch algorithm. Besides item 3, sequentially accessed pages
aren't always in LRU list adjacently, so page reclaim will not swap such pages
in adjacent storage sectors. This makes swap prefetch hard.
</pre>
      </blockquote>
      <pre wrap="">
One of problem is LRU churning and I wanted to try to fix it.
<a class="moz-txt-link-freetext" href="http://marc.info/?l=linux-mm&amp;m=130978831028952&amp;w=4">http://marc.info/?l=linux-mm&amp;m=130978831028952&amp;w=4</a></pre>
    </blockquote>
    <br>
    I'm interested in this feature, why it didn't merged? what's the
    fatal issue in your patchset? <br>
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    <a href="http://lwn.net/Articles/449866/">http://lwn.net/Articles/449866/</a><br>
    You mentioned test script and all-at-once patch, but I can't get
    them from the URL, could you tell me how to get it?<br>
    <br>
    <blockquote cite="mid:20130123075808.GH2723@blaptop" type="cite">
      <pre wrap="">

</pre>
      <blockquote type="cite">
        <pre wrap="">7. Alternative page reclaim policy to bias reclaiming anonymous page.
Currently reclaim anonymous page is considering harder than reclaim file pages,
so we bias reclaiming file pages. If there are high speed swap storage, we are
considering doing swap more aggressively.
</pre>
      </blockquote>
      <pre wrap="">
Yeb. We need it. I tried it with extending vm_swappiness to 200.

From: Minchan Kim <a class="moz-txt-link-rfc2396E" href="mailto:minchan@kernel.org">&lt;minchan@kernel.org&gt;</a>
Date: Mon, 3 Dec 2012 16:21:00 +0900
Subject: [PATCH] mm: increase swappiness to 200

We have thought swap out cost is very high but it's not true
if we use fast device like swap-over-zram. Nonetheless, we can
swap out 1:1 ratio of anon and page cache at most.
It's not enough to use swap device fully so we encounter OOM kill
while there are many free space in zram swap device. It's never
what we want.

This patch makes swap out aggressively.

Cc: Luigi Semenzato <a class="moz-txt-link-rfc2396E" href="mailto:semenzato@google.com">&lt;semenzato@google.com&gt;</a>
Signed-off-by: Minchan Kim <a class="moz-txt-link-rfc2396E" href="mailto:minchan@kernel.org">&lt;minchan@kernel.org&gt;</a>
---
 kernel/sysctl.c |    3 ++-
 mm/vmscan.c     |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 693e0ed..f1dbd9d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -130,6 +130,7 @@ static int __maybe_unused two = 2;
 static int __maybe_unused three = 3;
 static unsigned long one_ul = 1;
 static int one_hundred = 100;
+extern int max_swappiness;
 #ifdef CONFIG_PRINTK
 static int ten_thousand = 10000;
 #endif
@@ -1157,7 +1158,7 @@ static struct ctl_table vm_table[] = {
                .mode           = 0644,
                .proc_handler   = proc_dointvec_minmax,
                .extra1         = &amp;zero,
-               .extra2         = &amp;one_hundred,
+               .extra2         = &amp;max_swappiness,
        },
 #ifdef CONFIG_HUGETLB_PAGE
        {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 53dcde9..64f3c21 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -53,6 +53,8 @@
 #define CREATE_TRACE_POINTS
 #include &lt;trace/events/vmscan.h&gt;
 
+int max_swappiness = 200;
+
 struct scan_control {
        /* Incremented by the number of inactive pages that were scanned */
        unsigned long nr_scanned;
@@ -1626,6 +1628,7 @@ static int vmscan_swappiness(struct scan_control *sc)
        return mem_cgroup_swappiness(sc-&gt;target_mem_cgroup);
 }
 
+
 /*
  * Determine how aggressively the anon and file LRU lists should be
  * scanned.  The relative value of each set of LRU lists is determined
@@ -1701,11 +1704,10 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
        }
 
        /*
-        * With swappiness at 100, anonymous and file have the same priority.
         * This scanning priority is essentially the inverse of IO cost.
         */
        anon_prio = vmscan_swappiness(sc);
-       file_prio = 200 - anon_prio;
+       file_prio = max_swappiness - anon_prio;
 
        /*
         * OK, so we have swap space and a fair amount of page cache
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------090906050906080805000905--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
