Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id F30AC6B0034
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 19:48:10 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 16 Aug 2013 05:07:18 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 8A3161258043
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 05:17:45 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7FNnTsI36306986
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 05:19:29 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7FNm2dX016047
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 05:18:03 +0530
Date: Fri, 16 Aug 2013 07:47:57 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] mm/pgtable: Fix continue to preallocate pmds even if
 failure occurrence
Message-ID: <20130815234757.GA9879@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1376526703-2081-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <520D160A.10405@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520D160A.10405@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Dave,
On Thu, Aug 15, 2013 at 10:55:22AM -0700, Dave Hansen wrote:
>On 08/14/2013 05:31 PM, Wanpeng Li wrote:
>> preallocate_pmds will continue to preallocate pmds even if failure 
>> occurrence, and then free all the preallocate pmds if there is 
>> failure, this patch fix it by stop preallocate if failure occurrence
>> and go to free path.
>
>I guess there are a billion ways to do this, but I'm not sure we even
>need 'failed':
>
>--- arch/x86/mm/pgtable.c.orig	2013-08-15 10:52:15.145615027 -0700
>+++ arch/x86/mm/pgtable.c	2013-08-15 10:52:47.509614081 -0700
>@@ -196,21 +196,18 @@
> static int preallocate_pmds(pmd_t *pmds[])
> {
> 	int i;
>-	bool failed = false;
>
> 	for(i = 0; i < PREALLOCATED_PMDS; i++) {
> 		pmd_t *pmd = (pmd_t *)__get_free_page(PGALLOC_GFP);
> 		if (pmd == NULL)
>-			failed = true;
>+			goto err;
> 		pmds[i] = pmd;
> 	}
>
>-	if (failed) {
>-		free_pmds(pmds);
>-		return -ENOMEM;
>-	}
>-
> 	return 0;
>+err:
>+	free_pmds(pmds);
>+	return -ENOMEM;
> }
>

Thanks for your review, I will fold above to my patch. ;-)

Regards,
Wanpeng Li 

>I don't have a problem with what you have, though.  It's better than
>what was there, so:
>
>Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
