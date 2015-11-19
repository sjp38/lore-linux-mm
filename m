Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A93B96B0038
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 11:44:16 -0500 (EST)
Received: by wmec201 with SMTP id c201so34848397wme.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 08:44:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gd4si12409270wjb.2.2015.11.19.08.44.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 08:44:15 -0800 (PST)
Subject: Re: [PATCH 3/5] mm, page_owner: copy page owner info during migration
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
 <1446649261-27122-4-git-send-email-vbabka@suse.cz>
 <alpine.LSU.2.11.1511081318110.12914@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564DFC5C.2090103@suse.cz>
Date: Thu, 19 Nov 2015 17:44:12 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1511081318110.12914@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On 11/08/2015 10:29 PM, Hugh Dickins wrote:
>
> Would it be possible to move that line into migrate_page_copy()?
>
> I don't think it's wrong where you placed it, but that block is really
> about resetting the old page ready for freeing, and I'd prefer to keep
> all the transference of properties from old to new in migrate_page_copy()
> if we can.

OK, makes sense, will do in v2.

> But check how that behaves in the migrate_misplaced_transhuge_page()
> case: I haven't studied long enough, but I think you may have been missing
> to copy_page_owner in that case;

You're right, I missed that path :/

> but beware of its "fail_putback", which
> for some things nastily entails undoing what's already been done.

Yeah, I think I don't need to reset page owner info in the fail_putback 
path, for the same reason I don't reset it from the old page when 
migration is successful. The page is going to be freed anyway, and if it 
somehow hits a bug before that, we will still have something to print 
(after patch 5).

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
