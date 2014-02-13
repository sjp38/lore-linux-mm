Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB8C6B0039
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 11:27:14 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hi5so3512805wib.1
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 08:27:14 -0800 (PST)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id ck5si1608807wjc.84.2014.02.13.08.27.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 08:27:13 -0800 (PST)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ehrhardt@linux.vnet.ibm.com>;
	Thu, 13 Feb 2014 16:27:13 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id F202917D805C
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:27:36 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1DGQvF764880756
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:26:57 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1DGR9XS027926
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 09:27:09 -0700
Message-ID: <52FCF25C.9010802@linux.vnet.ibm.com>
Date: Thu, 13 Feb 2014 17:27:08 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Reply-To: 20140213104231.GX6732@suse.de
MIME-Version: 1.0
Subject: Re: [PATCH] mm: swap: Use swapfiles in priority order
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de

Hi,
first of all I hope this patching in of the Mesage-ID works for threaded 
views :-)

On 13/02/14 10:42:31, Mel Gorman wrote:
 >
 >
 > [prev in list] [next in list] [prev in thread] [next in thread]
 >
 > List:       linux-mm
 > Subject:    [PATCH] mm: swap: Use swapfiles in priority order
 > From:       Mel Gorman <mgorman () suse ! de>
 > Date:       2014-02-13 10:42:31
 > Message-ID: 20140213104231.GX6732 () suse ! de
 > [Download message RAW]
 >
 > According to the swapon documentation
 >
 > 	Swap  pages  are  allocated  from  areas  in priority order,
 > 	highest priority first.  For areas with different priorities, a
 > 	higher-priority area is exhausted before using a lower-priority area.
 >
 > A user reported

That was me and I can confirm that for all my setup were we encountered 
the issue is fixed with the new patch.

On top of that it also fixed a long running issue that swap gets slower 
the more swap targets you have - which was formerly discussed in detail 
here http://www.spinics.net/lists/linux-mm/msg68624.html

 > that the reality is different. When multiple swap files
 > are enabled and a memory consumer started, the swap files are consumed in
 > pairs after the highest priority file is exhausted. Early in the lifetime
 > of the test, swapfile consumptions looks like
 >
[...]
 >
 > Signed-off-by: Mel Gorman <mgorman@suse.de>
 > ---
 >  mm/swapfile.c | 2 +-
 >  1 file changed, 1 insertion(+), 1 deletion(-)
 >
 > diff --git a/mm/swapfile.c b/mm/swapfile.c
 > index 4a7f7e6..6d0ac2b 100644
 > --- a/mm/swapfile.c
 > +++ b/mm/swapfile.c
 > @@ -651,7 +651,7 @@ swp_entry_t get_swap_page(void)
 >  		goto noswap;
 >  	atomic_long_dec(&nr_swap_pages);
 >
 > -	for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
 > +	for (type = swap_list.head; type >= 0 && wrapped < 2; type = next) {
 >  		hp_index = atomic_xchg(&highest_priority_index, -1);
 >  		/*
 >  		 * highest_priority_index records current highest priority swap


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
