Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B1BF16B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 02:35:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so379997710pfg.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 23:35:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id lz7si7309101pab.147.2016.08.02.23.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 23:35:57 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u736Y0VQ046880
	for <linux-mm@kvack.org>; Wed, 3 Aug 2016 02:35:57 -0400
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24k0bp5n0f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Aug 2016 02:35:57 -0400
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 3 Aug 2016 12:05:54 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id A6CAEE0060
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 12:10:09 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u736ZmMk42074136
	for <linux-mm@kvack.org>; Wed, 3 Aug 2016 12:05:48 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u736ZiHU030540
	for <linux-mm@kvack.org>; Wed, 3 Aug 2016 12:05:47 +0530
Date: Wed, 3 Aug 2016 12:05:38 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] fadump: Disable deferred page struct initialisation
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1470143947-24443-3-git-send-email-srikar@linux.vnet.ibm.com>
 <1470201642.5034.3.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1470201642.5034.3.camel@gmail.com>
Message-Id: <20160803063538.GH6310@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, mahesh@linux.vnet.ibm.com

* Balbir Singh <bsingharora@gmail.com> [2016-08-03 15:20:42]:

> On Tue, 2016-08-02 at 18:49 +0530, Srikar Dronamraju wrote:
> > Fadump kernel reserves significant number of memory blocks. On a multi-node
> > machine, with CONFIG_DEFFERRED_STRUCT_PAGE support, fadump kernel fails to
> > boot. Fix this by disabling deferred page struct initialisation.
> > 
>
> How much memory does a fadump kernel need? Can we bump up the limits depending
> on the config. I presume when you say fadump kernel you mean kernel with
> FADUMP in the config?

On a regular kernel with CONFIG_FADUMP and fadump configured, 5% of the
total memory is reserved for booting the kernel on crash.  On crash,
fadump kernel reserves the 95% memory and boots into the 5% memory that
was reserved for it. It then parses the reserved 95% memory to collect
the dump.

The problem is not about the amount of memory thats reserved for fadump
kernel. Even if we increase/decrease, we will still end up with the same
issue.

> BTW, I would much rather prefer a config based solution that does not select
> DEFERRED_INIT if FADUMP is enabled.

As Vlastimil rightly pointed out, for fadump, the same kernel is booted
back at a different location when we crash. So we cannot have a config
based solution.

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
