Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 8066B6B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 21:25:38 -0400 (EDT)
Message-ID: <4F9DEA0C.8040203@kernel.org>
Date: Mon, 30 Apr 2012 10:25:32 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC] propagate gfp_t to page table alloc functions
References: <1335171318-4838-1-git-send-email-minchan@kernel.org> <4F963742.2030607@jp.fujitsu.com> <4F963B8E.9030105@kernel.org> <CAPa8GCA8q=S9sYx-0rDmecPxYkFs=gATGL-Dz0OYXDkwEECJkg@mail.gmail.com> <4F965413.9010305@kernel.org> <CAPa8GCCwfCFO6yxwUP5Qp9O1HGUqEU2BZrrf50w8TL9FH9vbrA@mail.gmail.com> <20120424143015.99fd8d4a.akpm@linux-foundation.org> <4F973BF2.4080406@jp.fujitsu.com> <CAHGf_=r09BCxXeuE8dSti4_SrT5yahrQCwJh=NrrA3rsUhhu_w@mail.gmail.com> <4F973FB8.6050103@jp.fujitsu.com> <20120424172554.c9c330dd.akpm@linux-foundation.org> <4F98914C.2060505@jp.fujitsu.com> <alpine.DEB.2.00.1204251715420.19452@chino.kir.corp.google.com> <4F9A0360.3030900@kernel.org> <alpine.DEB.2.00.1204270340450.11866@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1204270340450.11866@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@gmail.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/27/2012 07:43 PM, David Rientjes wrote:

> On Fri, 27 Apr 2012, Minchan Kim wrote:
> 
>>> Maybe a per-thread_info variant of gfp_allowed_mask?  So Andrew's 
>>> set_current_gfp() becomes set_current_gfp_allowed() that does
>>>
>>> 	void set_current_gfp_allowed(gfp_t gfp_mask)
>>> 	{
>>> 		current->gfp_allowed = gfp_mask & gfp_allowed_mask;
>>> 	}
>>>
>>> and then the page allocator does
>>>
>>> 	gfp_mask &= current->gfp_allowed;
>>>
>>> rather than how it currently does
>>>
>>> 	gfp_mask &= gfp_allowed_mask;
>>>
>>> and then the caller of set_current_gfp_allowed() cleans up with 
>>> set_current_gfp_allowed(__GFP_BITS_MASK).
>>
> 
> [trimmed the newsgroups from the reply, not sure what the point is?]
> 
>> Caller should restore old gfp_mask instead of __GFP_BITS_MASK in case of
>> nesting.And how do we care of atomic context?
>>
> 
> Eek, I'm hoping these aren't going to be nested but sure that seems 
> appropraite if they are.  (I'm also hoping these will only be either 
> __GFP_HIGH or __GFP_BITS_MASK and no other combinations.)
> 
> Forcing atomic context would just be set_current_gfp_allowed(__GFP_HIGH).


I mean it's not legal to access _current_ in atomic context so that
(gfp_mask &= current->gfp_allowed in page allocator) shouldn't.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
