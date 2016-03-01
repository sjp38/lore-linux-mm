Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 84CBE6B0254
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 08:36:13 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p65so33771901wmp.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 05:36:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 202si25506828wmy.77.2016.03.01.05.36.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 05:36:12 -0800 (PST)
Subject: Re: [PATCH 1/1] mm: thp: Set THP defrag by default to madvise and add
 a stall-free defrag option
References: <1456503359-4910-1-git-send-email-mgorman@techsingularity.net>
 <56D58E1E.5090708@suse.cz> <20160301133102.GG2854@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D59AC7.1020104@suse.cz>
Date: Tue, 1 Mar 2016 14:36:07 +0100
MIME-Version: 1.0
In-Reply-To: <20160301133102.GG2854@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/01/2016 02:31 PM, Mel Gorman wrote:
> This?
>
> ---8<---
> mm: thp: Set THP defrag by default to madvise and add a stall-free defrag option -fix
>
> The following is a fix to the patch
> mm-thp-set-thp-defrag-by-default-to-madvise-and-add-a-stall-free-defrag-option.patch
> based on feedback from Vlastimil Babka. It removes an unnecessary VM_BUG_ON for tidyness,
> clarifies documentation and adds a check forbidding someone writing "defer" to the enable
> knob for transparent huge pages.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

For the whole patch+fix.
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   Documentation/vm/transhuge.txt | 2 +-
>   mm/huge_memory.c               | 7 ++++---
>   2 files changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> index a19b173cbc57..1943fe051a36 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -129,7 +129,7 @@ available in the near future. It's the responsibility of khugepaged
>   to then install the THP pages later.
>
>   "madvise" will enter direct reclaim like "always" but only for regions
> -that are have used madvise(). This is the default behaviour.
> +that are have used madvise(MADV_HUGEPAGE). This is the default behaviour.
>
>   "never" should be self-explanatory.
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 206f35f06d83..9161b3a83720 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -246,6 +246,8 @@ static ssize_t triple_flag_store(struct kobject *kobj,
>   {
>   	if (!memcmp("defer", buf,
>   		    min(sizeof("defer")-1, count))) {
> +		if (enabled == deferred)
> +			return -EINVAL;
>   		clear_bit(enabled, &transparent_hugepage_flags);
>   		clear_bit(req_madv, &transparent_hugepage_flags);
>   		set_bit(deferred, &transparent_hugepage_flags);
> @@ -273,10 +275,9 @@ static ssize_t triple_flag_store(struct kobject *kobj,
>   static ssize_t enabled_show(struct kobject *kobj,
>   			    struct kobj_attribute *attr, char *buf)
>   {
> -	if (test_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags)) {
> -		VM_BUG_ON(test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags));
> +	if (test_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags))
>   		return sprintf(buf, "[always] madvise never\n");
> -	} else if (test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags))
> +	else if (test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags))
>   		return sprintf(buf, "always [madvise] never\n");
>   	else
>   		return sprintf(buf, "always madvise [never]\n");
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
