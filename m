Received: by wproxy.gmail.com with SMTP id 49so71912wri
        for <linux-mm@kvack.org>; Sun, 27 Mar 2005 22:43:54 -0800 (PST)
Message-ID: <2c1942a70503272243c351eee@mail.gmail.com>
Date: Mon, 28 Mar 2005 09:43:54 +0300
From: Levent Serinol <lserinol@gmail.com>
Reply-To: Levent Serinol <lserinol@gmail.com>
Subject: [RFC][PATCH] tunable zone watermarks
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

===========================================================
--- linux-2.6.11.4/include/linux/sysctl.h.org   2005-03-16
02:09:07.000000000 +0200
+++ linux-2.6.11.4/include/linux/sysctl.h       2005-03-27
20:33:17.000000000 +0300
@@ -169,6 +169,7 @@ enum
        VM_VFS_CACHE_PRESSURE=26, /* dcache/icache reclaim pressure */
        VM_LEGACY_VA_LAYOUT=27, /* legacy/compatibility virtual
address space layout */
        VM_SWAP_TOKEN_TIMEOUT=28, /* default time for token time out */
+       VM_ZONE_WATERMARKS=29, /* zone watermarks */
 };
  
  
--- linux-2.6.11.4/include/linux/mmzone.h.org   2005-03-16
02:09:07.000000000 +0200
+++ linux-2.6.11.4/include/linux/mmzone.h       2005-03-27
20:33:17.000000000 +0300
@@ -27,6 +27,12 @@ struct free_area {
  
 struct pglist_data;
  
+typedef struct zone_watermarks_vals {
+        unsigned long pages_min;
+        unsigned long pages_low;
+        unsigned long pages_high;
+        }zone_watermarks_vals_t;
+
 /*
  * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
  * So add a wild amount of padding here to ensure that they fall into separate
@@ -364,6 +370,8 @@ struct ctl_table;
 struct file;
 int min_free_kbytes_sysctl_handler(struct ctl_table *, int, struct file *,
                                        void __user *, size_t *, loff_t *);
+int zone_watermarks_sysctl_handler(struct ctl_table *, int, struct file *,
+                                        void __user *, size_t *, loff_t *);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int, struct file *,
                                        void __user *, size_t *, loff_t *);
--- linux-2.6.11.4/mm/page_alloc.c.org  2005-03-16 02:09:27.000000000 +0200
+++ linux-2.6.11.4/mm/page_alloc.c      2005-03-27 20:33:53.000000000 +0300
@@ -66,7 +66,11 @@ EXPORT_SYMBOL(zone_table);
  
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
 int min_free_kbytes = 1024;
-
+#ifdef CONFIG_NUMA
+zone_watermarks_vals_t zone_watermarks_sysctl[num_online_nodes() *
MAX_NR_ZONES];
+#else
+zone_watermarks_vals_t zone_watermarks_sysctl[MAX_NUMNODES * MAX_NR_ZONES];
+#endif
 unsigned long __initdata nr_kernel_pages;
 unsigned long __initdata nr_all_pages;
  
@@ -1911,6 +1915,24 @@ void __init page_alloc_init(void)
        hotcpu_notifier(page_alloc_cpu_notify, 0);
 }
  
+static void setup_zone_watermarks_vals(void)
+{
+        pg_data_t *pgdat;
+        unsigned int j,i;
+
+        j=0;
+        for_each_pgdat(pgdat) {
+                for (i = 0; i < MAX_NR_ZONES; i++) {
+                struct zone *zone = pgdat->node_zones + i;
+
+                zone_watermarks_sysctl[j].pages_min = K(zone->pages_min);
+                zone_watermarks_sysctl[j].pages_low = K(zone->pages_low);
+                zone_watermarks_sysctl[j].pages_high = K(zone->pages_high);
+                j++;
+                }
+        }
+}
+
 /*
  * setup_per_zone_lowmem_reserve - called whenever
  *     sysctl_lower_zone_reserve_ratio changes.  Ensures that each zone
@@ -1990,6 +2012,7 @@ static void setup_per_zone_pages_min(voi
                zone->pages_high  = (zone->pages_min * 6) / 4;
                spin_unlock_irqrestore(&zone->lru_lock, flags);
        }
+               setup_zone_watermarks_vals();
 }
  
 /*
@@ -2029,6 +2052,7 @@ static int __init init_per_zone_pages_mi
                min_free_kbytes = 65536;
        setup_per_zone_pages_min();
        setup_per_zone_lowmem_reserve();
+       setup_zone_watermarks_vals();
        return 0;
 }
 module_init(init_per_zone_pages_min)
@@ -2046,6 +2070,66 @@ int min_free_kbytes_sysctl_handler(ctl_t
        return 0;
 }
  
+int zone_watermarks_sysctl_handler(ctl_table *table, int write,
+               struct file *file, void __user *buffer, size_t
*length, loff_t *ppos)
+{
+        unsigned long flags;
+        unsigned long zone_pages = 0;
+        unsigned long lowmem_pages = 0;
+        pg_data_t *pgdat;
+        unsigned int j,i;
+        int err;
+
+
+        err = proc_dointvec(table, write, file, buffer, length, ppos);
+
+        if ((err >= 0) && write) {
+        j=0;
+        for_each_pgdat(pgdat) {
+                for (i = 0; i < MAX_NR_ZONES; i++) {
+                struct zone *zone = pgdat->node_zones + i;
+                if (!is_highmem(zone))
+                        lowmem_pages += zone->present_pages;
+                   }
+        }
+        for_each_pgdat(pgdat) {
+                for (i = 0; i < MAX_NR_ZONES; i++) {
+                struct zone *zone = pgdat->node_zones + i;
+                unsigned long lowmem_min;
+
+                        spin_lock_irqsave(&zone->lru_lock, flags);
+                                zone_pages =
(zone_watermarks_sysctl[j].pages_min >> (PAGE_SHIFT - 10));
+                                if (is_highmem(zone)) {
+                                        if (zone_pages < SWAP_CLUSTER_MAX)
+                                                zone_pages = SWAP_CLUSTER_MAX;
+                                        if (zone_pages >= zone->present_pages)
+                                                zone_pages =
zone->present_pages;
+                                        zone->pages_min = zone_pages;
+
+                                } else {
+                                        lowmem_min = (zone_pages *
zone->present_pages) /
+                                           lowmem_pages;
+                                        if (lowmem_min > zone_pages)
+                                                zone_pages = lowmem_min;
+                                        zone->pages_min = zone_pages;
+                                }
+                                zone_pages =
(zone_watermarks_sysctl[j].pages_low >> (PAGE_SHIFT - 10));
+                                if (zone_pages >= zone->present_pages)
+                                        zone_pages = zone->present_pages;
+                                zone->pages_low = zone_pages;
+                                zone_pages =
(zone_watermarks_sysctl[j].pages_high >> (PAGE_SHIFT - 10));
+                                if (zone_pages >= zone->present_pages)
+                                        zone_pages = zone->present_pages;
+                                zone->pages_high = zone_pages;
+                        spin_unlock_irqrestore(&zone->lru_lock, flags);
+                        j++;
+                }
+        }
+     }
+
+ return 0;
+}
+
 /*
  * lowmem_reserve_ratio_sysctl_handler - just a wrapper around
  *     proc_dointvec() so that we can call setup_per_zone_lowmem_reserve()
--- linux-2.6.11.4/kernel/sysctl.c.org  2005-03-16 02:09:00.000000000 +0200
+++ linux-2.6.11.4/kernel/sysctl.c      2005-03-27 20:33:17.000000000 +0300
@@ -62,6 +62,11 @@ extern char core_pattern[];
 extern int cad_pid;
 extern int pid_max;
 extern int min_free_kbytes;
+#ifdef CONFIG_NUMA
+extern zone_watermarks_vals_t
zone_watermarks_sysctl[num_online_nodes() * MAX_NR_ZONES];
+#else
+extern zone_watermarks_vals_t zone_watermarks_sysctl[MAX_NUMNODES *
MAX_NR_ZONES];
+#endif
 extern int printk_ratelimit_jiffies;
 extern int printk_ratelimit_burst;
 extern int pid_max_min, pid_max_max;
@@ -825,6 +830,15 @@ static ctl_table vm_table[] = {
                .strategy       = &sysctl_jiffies,
        },
 #endif
+        {
+                .ctl_name       = VM_ZONE_WATERMARKS,
+                .procname       = "zone_watermarks",
+                .data           = &zone_watermarks_sysctl,
+                .maxlen         = sizeof(zone_watermarks_sysctl),
+                .mode           = 0644,
+                .proc_handler   = &zone_watermarks_sysctl_handler,
+                .strategy       = &sysctl_intvec,
+       },
        { .ctl_name = 0 }
 };
  
===========================================================



-- 

Stay out of the road, if you want to grow old. 
~ Pink Floyd ~.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
