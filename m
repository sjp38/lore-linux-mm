Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 049C26B00AF
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 23:42:20 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 30 Apr 2013 09:08:49 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 1FC1A394002D
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 09:12:13 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3U3g5N35571014
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 09:12:06 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3U3gB3R010298
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 13:42:12 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 01/18] mm/THP: HPAGE_SHIFT is not a #define on some arch
In-Reply-To: <20130430022149.GU20202@truffula.fritz.box>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1367177859-7893-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130430022149.GU20202@truffula.fritz.box>
Date: Tue, 30 Apr 2013 09:12:09 +0530
Message-ID: <871u9sfzvy.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

David Gibson <dwg@au1.ibm.com> writes:

> On Mon, Apr 29, 2013 at 01:07:22AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> On archs like powerpc that support different hugepage sizes, HPAGE_SHIFT
>> and other derived values like HPAGE_PMD_ORDER are not constants. So move
>> that to hugepage_init
>
> These seems to miss the point.  Those variables may be defined in
> terms of HPAGE_SHIFT right now, but that is of itself kind of broken.
> The transparent hugepage mechanism only works if the hugepage size is
> equal to the PMD size - and PMD_SHIFT remains a compile time constant.
>
> There's no reason having transparent hugepage should force the PMD
> size of hugepage to be the default for other purposes - it should be
> possible to do THP as long as PMD-sized is a possible hugepage size.
>

THP code does

#define HPAGE_PMD_SHIFT HPAGE_SHIFT
#define HPAGE_PMD_MASK HPAGE_MASK
#define HPAGE_PMD_SIZE HPAGE_SIZE

I had two options, one to move all those in terms of PMD_SHIFT or switch
ppc64 to not use HPAGE_SHIFT the way it use now. Both would involve large
code changes. Hence I end up moving some of the checks to runtime
checks. Actual HPAGE_SHIFT == PMD_SHIFT check happens in the has_transparent_hugepage() 

https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-April/106002.html

IMHO what the patch is checking is that, HPAGE_SHIFT
value is not resulting in a page order higher than MAX_ORDER. 

Related to Reviewed-by: that came from V5 patchset 
https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-April/105299.html

Your review suggestion to move that runtime check back to macro happened
in V6. I missed dropping reviewed-by after that. 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
