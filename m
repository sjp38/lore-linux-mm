Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C70C6B038B
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 07:37:50 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j5so114820441pfb.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 04:37:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k5si10481871pgh.227.2017.03.03.04.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 04:37:49 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v23CXgWc068998
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 07:37:48 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28xs8ep1tw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Mar 2017 07:37:47 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 3 Mar 2017 22:37:45 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B98E52CE8057
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 23:37:42 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v23CbYZI55050448
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 23:37:42 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v23CbAJ8010394
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 23:37:10 +1100
Subject: Re: [RFC 06/11] mm: remove SWAP_MLOCK in ttu
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-7-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 3 Mar 2017 18:06:38 +0530
MIME-Version: 1.0
In-Reply-To: <1488436765-32350-7-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <54799ea5-005d-939c-de32-bc21af881ab4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On 03/02/2017 12:09 PM, Minchan Kim wrote:
> ttu don't need to return SWAP_MLOCK. Instead, just return SWAP_FAIL
> because it means the page is not-swappable so it should move to
> another LRU list(active or unevictable). putback friends will
> move it to right list depending on the page's LRU flag.

Right, if it cannot be swapped out there is not much difference with
SWAP_FAIL once we change the callers who expected to see a SWAP_MLOCK
return instead.

> 
> A side effect is shrink_page_list accounts unevictable list movement
> by PGACTIVATE but I don't think it corrupts something severe.

Not sure I got that, could you please elaborate on this. We will still
activate the page and put it in an appropriate LRU list if it is marked
mlocked ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
