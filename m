Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C35F96B26F0
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 13:16:07 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a9so9615773pla.2
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 10:16:07 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 37si483587plv.243.2018.11.21.10.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 10:16:06 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wALI9K3T097635
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 13:16:05 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nwbscsnju-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 13:16:05 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 21 Nov 2018 18:16:03 -0000
Date: Wed, 21 Nov 2018 19:15:57 +0100
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [mmotm:master 47/137] htmldocs: mm/memblock.c:1261: warning:
 Function parameter or member 'out_spfn' not described in
 '__next_mem_pfn_range_in_zone'
References: <201811171022.9O8KA7ol%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201811171022.9O8KA7ol%fengguang.wu@intel.com>
Message-Id: <20181121181556.GD5704@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Alex,

On Sat, Nov 17, 2018 at 10:26:25AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   4de8d18fa38298433f161f8780b5e1b0f01a8c17
> commit: 711bb3ee3832a764cb2ea03e97b7183b938e1f6c [47/137] mm: implement new zone specific memblock iterator
> reproduce: make htmldocs
> 
> All warnings (new ones prefixed by >>):
> 
>    WARNING: convert(1) not found, for SVG to PDF conversion install ImageMagick (https://www.imagemagick.org)
>    mm/memblock.c:1261: warning: Excess function parameter 'out_start' description in '__next_mem_pfn_range_in_zone'
>    mm/memblock.c:1261: warning: Excess function parameter 'out_end' description in '__next_mem_pfn_range_in_zone'
> >> mm/memblock.c:1261: warning: Function parameter or member 'out_spfn' not described in '__next_mem_pfn_range_in_zone'
> >> mm/memblock.c:1261: warning: Function parameter or member 'out_epfn' not described in '__next_mem_pfn_range_in_zone'
>    mm/memblock.c:1261: warning: Excess function parameter 'out_start' description in '__next_mem_pfn_range_in_zone'
>    mm/memblock.c:1261: warning: Excess function parameter 'out_end' description in '__next_mem_pfn_range_in_zone'

Can you please fix those?
 
> vim +1261 mm/memblock.c
> 
>   1211	
>   1212	/**
>   1213	 * memblock_set_node - set node ID on memblock regions
>   1214	 * @base: base of area to set node ID for
>   1215	 * @size: size of area to set node ID for
>   1216	 * @type: memblock type to set node ID for
>   1217	 * @nid: node ID to set
>   1218	 *
>   1219	 * Set the nid of memblock @type regions in [@base, @base + @size) to @nid.
>   1220	 * Regions which cross the area boundaries are split as necessary.
>   1221	 *
>   1222	 * Return:
>   1223	 * 0 on success, -errno on failure.
>   1224	 */
>   1225	int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>   1226					      struct memblock_type *type, int nid)
>   1227	{
>   1228		int start_rgn, end_rgn;
>   1229		int i, ret;
>   1230	
>   1231		ret = memblock_isolate_range(type, base, size, &start_rgn, &end_rgn);
>   1232		if (ret)
>   1233			return ret;
>   1234	
>   1235		for (i = start_rgn; i < end_rgn; i++)
>   1236			memblock_set_region_node(&type->regions[i], nid);
>   1237	
>   1238		memblock_merge_regions(type);
>   1239		return 0;
>   1240	}
>   1241	#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>   1242	#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>   1243	/**
>   1244	 * __next_mem_pfn_range_in_zone - iterator for for_each_*_range_in_zone()
>   1245	 *
>   1246	 * @idx: pointer to u64 loop variable
>   1247	 * @zone: zone in which all of the memory blocks reside
>   1248	 * @out_start: ptr to ulong for start pfn of the range, can be %NULL
>   1249	 * @out_end: ptr to ulong for end pfn of the range, can be %NULL
>   1250	 *
>   1251	 * This function is meant to be a zone/pfn specific wrapper for the
>   1252	 * for_each_mem_range type iterators. Specifically they are used in the
>   1253	 * deferred memory init routines and as such we were duplicating much of
>   1254	 * this logic throughout the code. So instead of having it in multiple
>   1255	 * locations it seemed like it would make more sense to centralize this to
>   1256	 * one new iterator that does everything they need.
>   1257	 */
>   1258	void __init_memblock
>   1259	__next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
>   1260				     unsigned long *out_spfn, unsigned long *out_epfn)
> > 1261	{
>   1262		int zone_nid = zone_to_nid(zone);
>   1263		phys_addr_t spa, epa;
>   1264		int nid;
>   1265	
>   1266		__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
>   1267				 &memblock.memory, &memblock.reserved,
>   1268				 &spa, &epa, &nid);
>   1269	
>   1270		while (*idx != ULLONG_MAX) {
>   1271			unsigned long epfn = PFN_DOWN(epa);
>   1272			unsigned long spfn = PFN_UP(spa);
>   1273	
>   1274			/*
>   1275			 * Verify the end is at least past the start of the zone and
>   1276			 * that we have at least one PFN to initialize.
>   1277			 */
>   1278			if (zone->zone_start_pfn < epfn && spfn < epfn) {
>   1279				/* if we went too far just stop searching */
>   1280				if (zone_end_pfn(zone) <= spfn)
>   1281					break;
>   1282	
>   1283				if (out_spfn)
>   1284					*out_spfn = max(zone->zone_start_pfn, spfn);
>   1285				if (out_epfn)
>   1286					*out_epfn = min(zone_end_pfn(zone), epfn);
>   1287	
>   1288				return;
>   1289			}
>   1290	
>   1291			__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
>   1292					 &memblock.memory, &memblock.reserved,
>   1293					 &spa, &epa, &nid);
>   1294		}
>   1295	
>   1296		/* signal end of iteration */
>   1297		*idx = ULLONG_MAX;
>   1298		if (out_spfn)
>   1299			*out_spfn = ULONG_MAX;
>   1300		if (out_epfn)
>   1301			*out_epfn = 0;
>   1302	}
>   1303	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation



-- 
Sincerely yours,
Mike.
