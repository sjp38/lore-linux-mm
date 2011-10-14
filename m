Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 97EBB6B018C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 21:25:12 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p9E1P9Kr006380
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 18:25:10 -0700
Received: from iaen33 (iaen33.prod.google.com [10.12.165.33])
	by wpaz9.hot.corp.google.com with ESMTP id p9E1MdFi027171
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 18:25:09 -0700
Received: by iaen33 with SMTP id n33so3736699iae.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 18:25:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110928175947.d3af52f0.kamezawa.hiroyu@jp.fujitsu.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-7-git-send-email-walken@google.com>
	<20110928171309.b45c684f.kamezawa.hiroyu@jp.fujitsu.com>
	<CANN689GFE_hqtndKY6i4ouBBe+gVU_pqOK2HRrc-U1LJMONaXw@mail.gmail.com>
	<20110928175947.d3af52f0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 13 Oct 2011 18:25:06 -0700
Message-ID: <CANN689HOALiiBKLUHRFuONQEyqp2on0GA1ycEguf0S6WFeuP7w@mail.gmail.com>
Subject: Re: [PATCH 6/9] kstaled: rate limit pages scanned per second.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Wed, Sep 28, 2011 at 1:59 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 28 Sep 2011 01:19:50 -0700
> Michel Lespinasse <walken@google.com> wrote:
>> It tends to perform worse if we try making it multithreaded. What
>> happens is that the scanning threads call page_referenced() a lot, and
>> if they both try scanning pages that belong to the same file that
>> causes the mapping's i_mmap_mutex lock to bounce. Same things happens
>> if they try scanning pages that belong to the same anon VMA too.
>>
>
> Hmm. with brief thinking, if you can scan list of page tables,
> you can set young flags without any locks.
> For inode pages, you can hook page lookup, I think.

It would be possible to avoid taking rmap locks by instead scanning
all page tables, and transferring the pte young bits observed there to
the PageYoung page flag. This is a significant design change, but
would indeed work.

Just to clarify the idea, how would you go about finding all page
tables to scan ? The most straightforward approach would be iterate
over all processes and scan their address spaces, but I don't think we
can afford to hold tasklist_lock (even for reads) for so long, so we'd
have to be a bit smarter than that... I can think of a few different
ways but I'd like to know if you have something specific in mind
first.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
