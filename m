Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D7AC39000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 04:19:55 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p8S8Jrmf007691
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 01:19:53 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by hpaq6.eem.corp.google.com with ESMTP id p8S8Joip008204
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 01:19:51 -0700
Received: by qyk7 with SMTP id 7so8958228qyk.5
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 01:19:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110928171309.b45c684f.kamezawa.hiroyu@jp.fujitsu.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-7-git-send-email-walken@google.com>
	<20110928171309.b45c684f.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 28 Sep 2011 01:19:50 -0700
Message-ID: <CANN689GFE_hqtndKY6i4ouBBe+gVU_pqOK2HRrc-U1LJMONaXw@mail.gmail.com>
Subject: Re: [PATCH 6/9] kstaled: rate limit pages scanned per second.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Wed, Sep 28, 2011 at 1:13 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 27 Sep 2011 17:49:04 -0700
> Michel Lespinasse <walken@google.com> wrote:
>
>> Scan some number of pages from each node every second, instead of trying to
>> scan the entime memory at once and being idle for the rest of the configured
>> interval.
>>
>> In addition to spreading the CPU usage over the entire scanning interval,
>> this also reduces the jitter between two consecutive scans of the same page.
>>
>>
>> Signed-off-by: Michel Lespinasse <walken@google.com>
>
> Does this scan thread need to be signle thread ?

It tends to perform worse if we try making it multithreaded. What
happens is that the scanning threads call page_referenced() a lot, and
if they both try scanning pages that belong to the same file that
causes the mapping's i_mmap_mutex lock to bounce. Same things happens
if they try scanning pages that belong to the same anon VMA too.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
