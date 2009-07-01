Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 753106B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 11:42:08 -0400 (EDT)
Message-ID: <4A4B8486.3020307@redhat.com>
Date: Wed, 01 Jul 2009 18:45:10 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] ZERO PAGE again
References: <20090701185759.18634360.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090701185759.18634360.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On 07/01/2009 12:57 PM, KAMEZAWA Hiroyuki wrote:
> ZERO PAGE was removed in 2.6.24 (=>  http://lkml.org/lkml/2007/10/9/112)
> and I had no objections.
>
> In these days, at user support jobs, I noticed a few of customers
> are making use of ZERO_PAGE intentionally...brutal mmap and scan, etc. They are
> using RHEL4-5(before 2.6.18) then they don't notice that ZERO_PAGE
> is gone, yet.
> yes, I can say  "ZERO PAGE is gone" to them in next generation distro.
>
> Recently, a question comes to lkml (http://lkml.org/lkml/2009/6/4/383
>
> Maybe there are some users of ZERO_PAGE other than my customers.
> So, can't we use ZERO_PAGE again ?
>
> IIUC, the problem of ZERO_PAGE was
>    - reference count cache ping-pong
>    - complicated handling.
>    - the behavior page-fault-twice can make applications slow.
>
> This patch is a trial to de-refcounted ZERO_PAGE.
> Any comments are welcome. I'm sorry for digging grave...
>    

kvm could use this.  There's a fairly involved scenario where the lack 
of zero page hits us:

- a guest is started
- either it doesn't touch all of its memory, or it balloons some of its 
memory away, so its resident set size is smaller than the total amount 
of memory it has
- the guest is live migrated to another host; this involves reading all 
of the guest memory

If we don't have zero page, all of the not-present pages are faulted in 
and the resident set size increases; this increases memory pressure, 
which is what we're trying to avoid (one of the reasons to live migrate 
is to free memory).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
