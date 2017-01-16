Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 307166B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 03:15:04 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id y196so135452234ity.1
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 00:15:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s8si8972868itd.7.2017.01.16.00.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 00:15:03 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0G8ET7g035838
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 03:15:02 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 280t0ds6h7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 03:15:02 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 16 Jan 2017 18:15:00 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 528213578053
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:14:57 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0G8EvnP54198402
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:14:57 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0G8Euse023823
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:14:56 +1100
Subject: Re: [PATCH] mm, page_alloc: don't check cpuset allowed twice in
 fast-path
References: <20170106081805.26132-1-vbabka@suse.cz>
 <20170106104048.GB5561@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 16 Jan 2017 13:44:52 +0530
MIME-Version: 1.0
In-Reply-To: <20170106104048.GB5561@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <733b937d-009a-e8fb-2257-2bb59314cd03@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/06/2017 04:10 PM, Michal Hocko wrote:
> On Fri 06-01-17 09:18:05, Vlastimil Babka wrote:
>> Since commit 682a3385e773 ("mm, page_alloc: inline the fast path of the
>> zonelist iterator") we replace a NULL nodemask with cpuset_current_mems_allowed
>> in the fast path, so that get_page_from_freelist() filters nodes allowed by the
>> cpuset via for_next_zone_zonelist_nodemask(). In that case it's pointless to
>> also check __cpuset_zone_allowed(), which we can avoid by not using
>> ALLOC_CPUSET in that scenario.
> 
> OK, this seems to be really worth it as most allocations go via
> __alloc_pages so we can save __cpuset_zone_allowed in the fast path.
> 
> I was about to object how fragile this might be wrt. other ALLOC_CPUSET
> checks but then I've realized this is only for the hotpath as the
> slowpath goes through gfp_to_alloc_flags() which sets it back on.
> 
> Maybe all that could be added to the changelog?

Agreed, all these should be added into the change log as the effect
of cpuset based nodemask during fast path and slow path is little
bit confusing.

>  
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
