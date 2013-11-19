Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 22C5C6B0036
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 16:27:49 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so2496861pbc.35
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 13:27:48 -0800 (PST)
Received: from psmtp.com ([74.125.245.176])
        by mx.google.com with SMTP id vs7si12497139pbc.235.2013.11.19.13.27.46
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 13:27:47 -0800 (PST)
Message-ID: <528BD7BC.4010205@oracle.com>
Date: Tue, 19 Nov 2013 14:27:24 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: tail page refcounting optimization for slab and
 hugetlbfs
References: <1384537668-10283-1-git-send-email-aarcange@redhat.com> <1384537668-10283-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1384537668-10283-4-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/15/2013 10:47 AM, Andrea Arcangeli wrote:
> This skips the _mapcount mangling for slab and hugetlbfs pages.
>
> The main trouble in doing this is to guarantee that PageSlab and
> PageHeadHuge remains constant for all get_page/put_page run on the
> tail of slab or hugetlbfs compound pages. Otherwise if they're set
> during get_page but not set during put_page, the _mapcount of the tail
> page would underflow.
>
> PageHeadHuge will remain true until the compound page is released and
> enters the buddy allocator so it won't risk to change even if the tail
> page is the last reference left on the page.
>
> PG_slab instead is cleared before the slab frees the head page with
> put_page, so if the tail pin is released after the slab freed the
> page, we would have a problem. But in the slab case the tail pin
> cannot be the last reference left on the page. This is because the
> slab code is free to reuse the compound page after a
> kfree/kmem_cache_free without having to check if there's any tail pin
> left. In turn all tail pins must be always released while the head is
> still pinned by the slab code and so we know PG_slab will be still set
> too.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
