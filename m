Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 773626B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 15:06:23 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id l68so40698763wml.1
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 12:06:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lm2si34404212wjc.202.2016.03.15.12.06.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Mar 2016 12:06:22 -0700 (PDT)
Subject: Re: [PATCH v1 01/19] mm: use put_page to free page instead of
 putback_lru_page
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-2-git-send-email-minchan@kernel.org>
 <56E67AE1.60700@suse.cz> <20160315011656.GD19514@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E85D2D.6050808@suse.cz>
Date: Tue, 15 Mar 2016 20:06:21 +0100
MIME-Version: 1.0
In-Reply-To: <20160315011656.GD19514@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 15.3.2016 2:16, Minchan Kim wrote:
> On Mon, Mar 14, 2016 at 09:48:33AM +0100, Vlastimil Babka wrote:
>> On 03/11/2016 08:30 AM, Minchan Kim wrote:
>>
>> Yeah, and compaction (perhaps also other migration users) has to
>> drain the lru pvec... Getting rid of this stuff is worth even by
>> itself.
> 
> Good note. Although we cannot remove lru pvec draining completely,
> at least, this patch removes a case which should drain pvec for
> returning freed page to buddy.

And this is in fact the only interesting case, right. The migrated page (at its
new target) doesn't concern compaction that much, that can go to lru pvec just
fine. But we do want the freed buddy pages to merge ASAP. I guess that's the
same for CMA, page isolation...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
