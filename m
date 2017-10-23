Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 197306B0253
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 23:22:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id z77so797614wmc.16
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 20:22:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z3si246005wre.53.2017.10.22.20.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Oct 2017 20:22:45 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9N3JJhD065445
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 23:22:43 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ds7xd8xtu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 23:22:43 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 23 Oct 2017 04:22:42 +0100
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9N3Mbpe24051748
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 03:22:38 GMT
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9N3Maev011723
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 14:22:37 +1100
Subject: Re: [PATCH] mm/swap: Use page flags to determine LRU list in
 __activate_page()
References: <20171019145657.11199-1-khandual@linux.vnet.ibm.com>
 <20171019153322.c4uqalws7l7fdzcx@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 23 Oct 2017 08:52:34 +0530
MIME-Version: 1.0
In-Reply-To: <20171019153322.c4uqalws7l7fdzcx@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d01827c0-8858-5688-dc16-1e2f597ec55c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, shli@kernel.org

On 10/19/2017 09:03 PM, Michal Hocko wrote:
> On Thu 19-10-17 20:26:57, Anshuman Khandual wrote:
>> Its already assumed that the PageActive flag is clear on the input
>> page, hence page_lru(page) will pick the base LRU for the page. In
>> the same way page_lru(page) will pick active base LRU, once the
>> flag PageActive is set on the page. This change of LRU list should
>> happen implicitly through the page flags instead of being hard
>> coded.
> 
> The patch description tells what but it doesn't explain _why_? Does the
> resulting code is better, more optimized or is this a pure readability
> thing?

Not really. Not only it removes couple of lines of code but it also
makes it look more logical from function flow point of view as well.

> 
> All I can see is that page_lru is more complex and a large part of it
> can be optimized away which has been done manually here. I suspect the
> compiler can deduce the same thing.

Why not ? I mean, that is the essence of the function page_lru() which
should get us the exact LRU list the page should be on and hence we
should not hand craft these manually.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
