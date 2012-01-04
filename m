Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 64D406B004D
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 21:19:00 -0500 (EST)
Received: by ghrr18 with SMTP id r18so10851842ghr.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 18:18:59 -0800 (PST)
Message-ID: <4F03B715.4080005@gmail.com>
Date: Tue, 03 Jan 2012 21:19:01 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] sysvshm: SHM_LOCK use lru_add_drain_all_async()
References: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com> <1325403025-22688-2-git-send-email-kosaki.motohiro@gmail.com> <alpine.LSU.2.00.1201031724300.1254@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1201031724300.1254@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

(1/3/12 8:51 PM), Hugh Dickins wrote:
> On Sun, 1 Jan 2012, kosaki.motohiro@gmail.com wrote:
>> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>>
>> shmctl also don't need synchrounous pagevec drain. This patch replace it with
>> lru_add_drain_all_async().
>>
>> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>
> Let me answer this 2/2 first since it's easier.
>
> I'm going to thank you for bringing this lru_add_drain_all()
> to my attention, I had not noticed it; but Nak the patch itself.
>
> The reason being, that particular lru_add_drain_all() serves no
> useful purpose, so let's delete it instead of replacing it.  I believe
> that it serves no purpose for SHM_LOCK and no purpose for SHM_UNLOCK.
>
> I'm dabbling in this area myself, since you so cogently pointed out that
> I'd tried to add a cond_resched() to scan_mapping_unevictable_pages()
> (which is a helper for SHM_UNLOCK here) while it's under spinlock.
>
> In testing my fix for that, I find that there has been no attempt to
> keep the Unevictable count accurate on SysVShm: SHM_LOCK pages get
> marked unevictable lazily later as memory pressure discovers them -
> which perhaps mirrors the way in which SHM_LOCK makes no attempt to
> instantiate pages, unlike mlock.

Ugh, you are right. I'm recovering my remember gradually. Lee 
implemented immediate lru off logic at first and I killed it
to close a race. I completely forgot. So, yes, now SHM_LOCK has no 
attempt to instantiate pages. I'm ashamed.


>
> Since nobody has complained about that in the two years since we've
> had an Unevictable count in /proc/meminfo, I don't see any need to
> add code (it would need more than just your change here; would need
> more even than calling scan_mapping_unevictable_pages() at SHM_LOCK
> time - though perhaps along with your 1/2 that could handle it) and
> overhead to satisfy a need that nobody has.
>
> I'll delete that lru_add_drain_all() in my patch, okay?

Sure thing. :)


> (But in writing this, realize I still don't quite understand why
> the Unevictable count takes a second or two to get back to 0 after
> SHM_UNLOCK: perhaps I've more to discover.)

Interesting. I'm looking at this too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
