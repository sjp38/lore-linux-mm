Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64A5328089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 22:16:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f144so216245003pfa.3
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 19:16:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d34si8863070pld.4.2017.02.08.19.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 19:16:47 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1939Pw7036028
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 22:16:47 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28gbgmhurg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 22:16:46 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 9 Feb 2017 08:46:44 +0530
Received: from d28relay07.in.ibm.com (d28relay07.in.ibm.com [9.184.220.158])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 7059A1258017
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 08:48:31 +0530 (IST)
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v193FfD218284678
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 08:45:41 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v193GdIf021602
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 08:46:39 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm/autonuma: Let architecture override how the write bit should be stashed in a protnone pte.
In-Reply-To: <1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Thu, 09 Feb 2017 08:46:33 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <8737foqcj2.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Autonuma preserves the write permission across numa fault to avoid taking
> a writefault after a numa fault (Commit: b191f9b106ea " mm: numa: preserve PTE
> write permissions across a NUMA hinting fault"). Architecture can implement
> protnone in different ways and some may choose to implement that by clearing Read/
> Write/Exec bit of pte. Setting the write bit on such pte can result in wrong
> behaviour. Fix this up by allowing arch to override how to save the write bit
> on a protnone pte.
>

The problem we are trying to fix here is w.r.t autnuma related thp
migration. migrate_misplaced_transhuge_page() cannot deal with
concurrent modification of the page. It does a page copy without
following the migration pte sequence. IIUC, this was done to keep the
migration simpler and at the time of implemenation we didn't had THP
page cache which would have required a more elaborate migration scheme.
[1]. That means thp autonuma migration expect the protnone
with saved write to be done such that both kernel and user cannot update
the page content. This patch series enables archs like ppc64 to do that.
We are good with the hash translation mode with the current code,
because we never create a hardware page table entry for a protnone pte. 


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
