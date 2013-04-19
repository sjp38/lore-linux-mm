Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 6099F6B0096
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 04:14:58 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 19 Apr 2013 13:39:02 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 0EC93125804F
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 13:46:16 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3J8Ec8x7864730
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 13:44:39 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3J8EfwD031006
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 18:14:42 +1000
Message-ID: <5170FC47.9050001@linux.vnet.ibm.com>
Date: Fri, 19 Apr 2013 13:41:51 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 00/15][Sorted-buddy] mm: Memory Power Management
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com> <516ED378.2000406@linux.intel.com> <516FC2D1.9020809@linux.vnet.ibm.com> <51700DB2.5090506@linux.intel.com>
In-Reply-To: <51700DB2.5090506@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/18/2013 08:43 PM, Srinivas Pandruvada wrote:
> On 04/18/2013 02:54 AM, Srivatsa S. Bhat wrote:
>> On 04/17/2013 10:23 PM, Srinivas Pandruvada wrote:
>>> On 04/09/2013 02:45 PM, Srivatsa S. Bhat wrote:
>>>> [I know, this cover letter is a little too long, but I wanted to
>>>> clearly
>>>> explain the overall goals and the high-level design of this patchset in
>>>> detail. I hope this helps more than it annoys, and makes it easier for
>>>> reviewers to relate to the background and the goals of this patchset.]
>>>>
>>>>
>>>> Overview of Memory Power Management and its implications to the
>>>> Linux MM
>>>> ========================================================================
>>>>
>>>>
>> [...]
>>> One thing you need to prevent is boot time allocation. You have to make
>>> sure that frequently accessed per node data stored at the end of memory
>>> will keep all ranks of memory active.
>>>
> When I was experimenting I did something like this.

Thanks a lot for sharing this, Srinivas!

Regards,
Srivatsa S. Bhat

> /////////////////////////////////
> 
> 
> +/*
> + * Experimental MPST implemenentation
> + * Copyright (c) 2012, Intel Corporation.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
> License for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License
> along with
> + * this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + */
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/init.h>
> +#include <linux/kthread.h>
> +#include <linux/acpi.h>
> +#include <linux/export.h>
> +#include <linux/bootmem.h>
> +#include <linux/delay.h>
> +#include <linux/pfn.h>
> +#include <linux/suspend.h>
> +#include <linux/acpi.h>
> +#include <linux/memblock.h>
> +#include <linux/mm.h>
> +#include <linux/mmzone.h>
> +#include <linux/migrate.h>
> +#include <linux/mm_inline.h>
> +#include <linux/page-isolation.h>
> +#include <linux/vmalloc.h>
> +#include <linux/compaction.h>
> +#include "internal.h"
> +
> +#define phys_to_pfn(p) ((p) >> PAGE_SHIFT)
> +#define pfn_to_phys(p) ((p) << PAGE_SHIFT)
> +#define MAX_MPST_ZONES 16
> +/* Atleast 4G of non MPST memory. */
> +#define MINIMAL_NON_MPST_MEMORY_PFN (0x100000000 >> PAGE_SHIFT)
> +
> +struct mpst_mem_zone {
> +       phys_addr_t start_addr;
> +       phys_addr_t end_addr;
> +};
> +
> +static struct mpst_mem_zone mpst_zones[MAX_MPST_ZONES];
> +static int mpst_zone_cnt;
> +static unsigned long mpst_start_pfn;
> +static unsigned long mpst_end_pfn;
> +static bool mpst_enabled;
> +
> +/* Minimal parsing for just getting node ranges */
> +static int __init acpi_parse_mpst_table(struct acpi_table_header *table)
> +{
> +       struct acpi_table_mpst *mpst;
> +       struct acpi_mpst_power_node *node;
> +       u16 node_count;
> +       int i;
> +
> +       mpst = (struct acpi_table_mpst *)table;
> +       if (!mpst) {
> +               pr_warn("Unable to map MPST\n");
> +               return -ENODEV;
> +       }
> +       node_count = mpst->power_node_count;
> +       node = (struct acpi_mpst_power_node *)((u8 *)mpst + sizeof(*mpst));
> +
> +       for (i = mpst_zone_cnt; (i < node_count) && (i < MAX_MPST_ZONES);
> + ++i) {
> +               if ((node->flags & ACPI_MPST_ENABLED) &&
> +                       (node->flags & ACPI_MPST_POWER_MANAGED)) {
> +                       mpst_zones[mpst_zone_cnt].start_addr =
> +                               node->range_address;
> +                       mpst_zones[mpst_zone_cnt].end_addr =
> +                               node->range_address + node->range_length;
> +                       ++mpst_zone_cnt;
> +               }
> +               ++node;
> +       }
> +
> +       return 0;
> +}
> +
> +static unsigned long local_ahex_to_long(const char *name)
> +{
> +       unsigned long val = 0;
> +
> +       for (;; name++) {
> +               switch (*name) {
> +               case '0' ... '9':
> +                       val = 16*val+(*name-'0');
> +                       break;
> +               case 'A' ... 'F':
> +                       val = 16*val+(*name-'A'+10);
> +                       break;
> +               case 'a' ... 'f':
> +                       val = 16*val+(*name-'a'+10);
> +                       break;
> +               default:
> +                       return val;
> +               }
> +       }
> +
> +       return val;
> +}
> +
> +/* Specify MPST range by command line for test till ACPI - MPST is
> available */
> +static int __init parse_mpst_opt(char *str)
> +{
> +       char *ptr;
> +       phys_addr_t start_at = 0, end_at = 0;
> +       u64  mem_size = 0;
> +
> +       if (!str)
> +               return -EINVAL;
> +       ptr = str;
> +       while (1) {
> +               if (*str == '-') {
> +                       *str = '\0';
> +                       start_at = local_ahex_to_long(ptr);
> +                       ++str;
> +                       ptr = str;
> +               }
> +               if (start_at && (*str == '\0' || *str == ',' || *str ==
> ' ')) {
> +                       *str = '\0';
> +                       end_at = local_ahex_to_long(ptr);
> +                       mem_size = end_at-start_at;
> +                       ++str;
> +                       ptr = str;
> +                       pr_info("-mpst[%#018Lx-%#018Lx size: %#018Lx]\n",
> +                                               start_at, end_at,
> mem_size);
> +                       if (IS_ALIGNED(phys_to_pfn(start_at),
> +                                       pageblock_nr_pages) &&
> + IS_ALIGNED(phys_to_pfn(end_at),
> +                                       pageblock_nr_pages)) {
> +                               mpst_zones[mpst_zone_cnt].start_addr =
> + start_at;
> +                               mpst_zones[mpst_zone_cnt].end_addr =
> + end_at;
> +                       } else {
> +                               pr_err("mpst invalid range\n");
> +                               return -EINVAL;
> +                       }
> +                       mpst_zone_cnt++;
> +                       start_at = mem_size = end_at = 0;
> +               }
> +               if (*str == '\0')
> +                       break;
> +               else
> +                       ++str;
> +       }
> +
> +       return 0;
> +}
> +early_param("mpst_range", parse_mpst_opt);
> +
> +/* Specify MPST range by command line for test till ACPI - MPST is
> available */
> +static int __init parse_mpst_enable_opt(char *str)
> +{
> +       long value;
> +       if (kstrtol(str, 10, &value))
> +               return -EINVAL;
> +       mpst_enabled = value ? true : false;
> +
> +       return 0;
> +}
> +early_param("mpst_enable", parse_mpst_enable_opt);
> +
> +/* Set the minimum and maximum PFN */
> +static void mpst_set_min_max_pfn(void)
> +{
> +       int i;
> +
> +       if (!mpst_zone_cnt)
> +               return;
> +
> +       mpst_start_pfn = phys_to_pfn(mpst_zones[0].start_addr);
> +       mpst_end_pfn = phys_to_pfn(mpst_zones[0].end_addr);
> +
> +       for (i = 1; i < mpst_zone_cnt; ++i) {
> +               if (mpst_start_pfn > phys_to_pfn(mpst_zones[i].start_addr))
> +                       mpst_start_pfn =
> phys_to_pfn(mpst_zones[i].start_addr);
> +               if (mpst_end_pfn < phys_to_pfn(mpst_zones[i].end_addr))
> +                       mpst_end_pfn = phys_to_pfn(mpst_zones[i].end_addr);
> +       }
> +}
> +
> +/* Change migrate type for the MPST ranges */
> +int mpst_set_migrate_type(void)
> +{
> +       int i;
> +       struct page *page;
> +       unsigned long start_pfn, end_pfn;
> +
> +       if (!mpst_start_pfn || !mpst_end_pfn)
> +               return -EINVAL;
> +       if (!IS_ALIGNED(mpst_start_pfn, pageblock_nr_pages))
> +               return -EINVAL;
> +       if (!IS_ALIGNED(mpst_end_pfn, pageblock_nr_pages))
> +               return -EINVAL;
> +       memblock_free(pfn_to_phys(mpst_start_pfn),
> +               pfn_to_phys(mpst_end_pfn) - pfn_to_phys(mpst_start_pfn));
> +       for (i = 0; i < mpst_zone_cnt; ++i) {
> +               start_pfn = phys_to_pfn(mpst_zones[i].start_addr);
> +               end_pfn = phys_to_pfn(mpst_zones[i].end_addr);
> +               for (; start_pfn < end_pfn; ++start_pfn) {
> +                       page = pfn_to_page(start_pfn);
> +                       if (page)
> +                               set_pageblock_migratetype(page,
> +                                               MIGRATE_LP_MEMORY);
> +               }
> +       }
> +
> +       return 0;
> +}
> +
> +/* Parse ACPI table and find start and end of MPST zone.
> +Assuming zones are contiguous */
> +int mpst_init(void)
> +{
> +       if (!mpst_enabled) {
> +               pr_info("mpst not enabled in command line\n");
> +               return 0;
> +       }
> +
> +       acpi_table_parse(ACPI_SIG_MPST, acpi_parse_mpst_table);
> +       mpst_set_min_max_pfn();
> +       if (mpst_zone_cnt) {
> +
> +               if (mpst_start_pfn < MINIMAL_NON_MPST_MEMORY_PFN) {
> +                       pr_err("Not enough memory: Ignore MPST\n");
> +                       mpst_start_pfn = mpst_end_pfn = 0;
> +                       return -EINVAL;
> +               }
> +               memblock_reserve(pfn_to_phys(mpst_start_pfn),
> +                                       pfn_to_phys(mpst_end_pfn) -
> + pfn_to_phys(mpst_start_pfn));
> +               pr_info("mpst_init memblock limit set to pfn %lu
> 0x%#018lx\n",
> +                       mpst_start_pfn, pfn_to_phys(mpst_start_pfn));
> +       }
> +
> +       return 0;
> +}
> 
> 
> 
> 
> 
> /////////////////////////////

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
