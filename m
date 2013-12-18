Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 43FB96B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 23:12:23 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so7810336pbc.5
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 20:12:22 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id cz3si13230880pbc.243.2013.12.17.20.12.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 20:12:21 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Dec 2013 14:12:16 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 923692BB0058
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 15:12:13 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBI3riUX3473890
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:53:44 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBI4CCG3008245
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 15:12:13 +1100
Date: Wed, 18 Dec 2013 12:12:10 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
Message-ID: <52b120a5.a3b2440a.3acf.ffffd7c3SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>
 <20131218032329.GA6044@hacker.(null)>
 <52B11765.8030005@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
Content-Disposition: inline
In-Reply-To: <52B11765.8030005@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, npiggin@suse.de, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Sasha,
On Tue, Dec 17, 2013 at 10:32:53PM -0500, Sasha Levin wrote:
>On 12/17/2013 10:23 PM, Wanpeng Li wrote:
>>-			mlock_vma_page(page);   /* no-op if already mlocked */
>>-			if (page == check_page)
>>+			if (page != check_page && trylock_page(page)) {
>>+				mlock_vma_page(page);   /* no-op if already mlocked */
>>+				unlock_page(page);
>>+			} else if (page == check_page) {
>>+				mlock_vma_page(page);  /* no-op if already mlocked */
>>  				ret = SWAP_MLOCK;
>>+			}
>
>Previously, if page != check_page and the page was locked, we'd call mlock_vma_page()
>anyways. With this change, we don't. In fact, we'll just skip that entire block not doing
>anything.

Thanks for pointing out. ;-)

>
>If that's something that's never supposed to happen, can we add a
>
>	VM_BUG_ON(page != check_page && PageLocked(page))
>
>Just to cover this new code path?
>

How about this one? 


--J/dobhs11T7y2rNN
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-3.patch"


--J/dobhs11T7y2rNN--
