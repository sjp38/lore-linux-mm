Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FF57C49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 06:36:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3656920890
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 06:36:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3656920890
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA2A86B0005; Mon, 16 Sep 2019 02:36:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E548D6B0006; Mon, 16 Sep 2019 02:36:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D69B36B0007; Mon, 16 Sep 2019 02:36:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id B5DE06B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 02:36:29 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1B47C181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 06:36:29 +0000 (UTC)
X-FDA: 75939824898.27.error26_72bd42913e038
X-HE-Tag: error26_72bd42913e038
X-Filterd-Recvd-Size: 5779
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 06:36:28 +0000 (UTC)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8G6aRNA009647
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 02:36:27 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2v233s382j-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 02:36:27 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 16 Sep 2019 07:36:20 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 16 Sep 2019 07:36:16 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8G6ZnsG44892632
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 16 Sep 2019 06:35:49 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 58C74AE057;
	Mon, 16 Sep 2019 06:36:15 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 985E4AE051;
	Mon, 16 Sep 2019 06:36:14 +0000 (GMT)
Received: from linux.ibm.com (unknown [9.148.8.160])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 16 Sep 2019 06:36:14 +0000 (GMT)
Date: Mon, 16 Sep 2019 09:36:12 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>,
        Michal Hocko <mhocko@suse.com>, David Hildenbrand <david@redhat.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] mm/hotplug: Reorder memblock_[free|remove]() calls in
 try_remove_memory()
References: <1568612857-10395-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1568612857-10395-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19091606-0008-0000-0000-00000316CAD9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091606-0009-0000-0000-00004A3542B2
Message-Id: <20190916063612.GA1502@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-16_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909160071
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 11:17:37AM +0530, Anshuman Khandual wrote:
> In add_memory_resource() the memory range to be hot added first gets into
> the memblock via memblock_add() before arch_add_memory() is called on it.
> Reverse sequence should be followed during memory hot removal which already
> is being followed in add_memory_resource() error path. This now ensures
> required re-order between memblock_[free|remove]() and arch_remove_memory()
> during memory hot-remove.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> Original patch https://lkml.org/lkml/2019/9/3/327
> 
> Memory hot remove now works on arm64 without this because a recent commit
> 60bb462fc7ad ("drivers/base/node.c: simplify unregister_memory_block_under_nodes()").
> 
> David mentioned that re-ordering should still make sense for consistency
> purpose (removing stuff in the reverse order they were added). This patch
> is now detached from arm64 hot-remove series.
> 
> https://lkml.org/lkml/2019/9/3/326
> 
>  mm/memory_hotplug.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c73f09913165..355c466e0621 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1770,13 +1770,13 @@ static int __ref try_remove_memory(int nid, u64 start, u64 size)
> 
>  	/* remove memmap entry */
>  	firmware_map_remove(start, start + size, "System RAM");
> -	memblock_free(start, size);
> -	memblock_remove(start, size);
> 
>  	/* remove memory block devices before removing memory */
>  	remove_memory_block_devices(start, size);
> 
>  	arch_remove_memory(nid, start, size, NULL);
> +	memblock_free(start, size);

I don't see memblock_reserve() anywhere in memory_hotplug.c, so the
memblock_free() call here seems superfluous. I think it can be simply
dropped.

> +	memblock_remove(start, size);
>  	__release_memory_resource(start, size);
> 
>  	try_offline_node(nid);
> -- 
> 2.20.1
> 
> 

-- 
Sincerely yours,
Mike.


