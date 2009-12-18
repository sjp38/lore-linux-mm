Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A94266B007E
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 12:43:50 -0500 (EST)
Message-ID: <4B2BBF44.2090104@redhat.com>
Date: Fri, 18 Dec 2009 12:43:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: FWD:  [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091211164651.036f5340@annuminas.surriel.com> <1260810481.6666.13.camel@dhcp-100-19-198.bos.redhat.com> <20091217193818.9FA9.A69D9226@jp.fujitsu.com> <4B2A22C0.8080001@redhat.com> <4B2A8CA8.6090704@redhat.com> <Pine.LNX.4.64.0912172055570.15788@sister.anvils> <20091218162332.GR29790@random.random>
In-Reply-To: <20091218162332.GR29790@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, lwoodman@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 12/18/2009 11:23 AM, Andrea Arcangeli wrote:
> On Thu, Dec 17, 2009 at 09:05:23PM +0000, Hugh Dickins wrote:

>> An rwlock there has been proposed on several occasions, but
>> we resist because that change benefits this case but performs
>> worse on more common cases (I believe: no numbers to back that up).
>
> I think rwlock for anon_vma is a must. Whatever higher overhead of the
> fast path with no contention is practically zero, and in large smp it
> allows rmap on long chains to run in parallel, so very much worth it
> because downside is practically zero and upside may be measurable
> instead in certain corner cases. I don't think it'll be enough, but I
> definitely like it.

I agree, changing the anon_vma lock to an rwlock should
work a lot better than what we have today.  The tradeoff
is a tiny slowdown in medium contention cases, at the
benefit of avoiding catastrophic slowdown in some cases.

With Nick Piggin's fair rwlocks, there should be no issue
at all.

> Rik suggested to me to have a cowed newly allocated page to use its
> own anon_vma. Conceptually Rik's idea is fine one, but the only
> complication then is how to chain the same vma into multiple anon_vma
> (in practice insert/removal will be slower and more metadata will be
> needed for additional anon_vmas and vams queued in more than
> anon_vma). But this only will help if the mapcount of the page is 1,
> if the mapcount is 10000 no change to anon_vma or prio_tree will solve
> this,

It's even more complex than this for anonymous pages.

Anonymous pages get COW copied in child (and parent)
processes, potentially resulting in one page, at each
offset into the anon_vma, for every process attached
to the anon_vma.

As a result, with 10000 child processes, page_referenced
can end up searching through 10000 VMAs even for pages
with a mapcount of 1!

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
