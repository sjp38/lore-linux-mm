Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 80E316B00E7
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 04:37:53 -0400 (EDT)
Message-ID: <4F9514BC.3010103@redhat.com>
Date: Mon, 23 Apr 2012 11:37:16 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
References: <1334356721-9009-1-git-send-email-yinghan@google.com> <20120420151143.433c514e.akpm@linux-foundation.org> <4F91E8CC.5080409@redhat.com> <CALWz4iwVhg23X06T6HP49PKa8z2_-KRx6f64vYrvsT+KoaKp8A@mail.gmail.com> <20120421105615.6b0b03640f7553060628d840@gmail.com> <CAGTjWtB_n+40MEHaQNxZuNhQpXJNGsfeV=Rbz3C12Ar9iPkW8Q@mail.gmail.com> <4F93CC65.4060002@redhat.com> <CAG7+5M06N1A6WSRNdwuGN08qv8iF-y6y3XopMc=kb26c7ZhTiA@mail.gmail.com>
In-Reply-To: <CAG7+5M06N1A6WSRNdwuGN08qv8iF-y6y3XopMc=kb26c7ZhTiA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Northup <digitaleric@google.com>
Cc: Mike Waychison <mikew@google.com>, Takuya Yoshikawa <takuya.yoshikawa@gmail.com>, Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>

On 04/22/2012 10:05 PM, Eric Northup wrote:
> On Sun, Apr 22, 2012 at 2:16 AM, Avi Kivity <avi@redhat.com> wrote:
> > On 04/21/2012 05:15 AM, Mike Waychison wrote:
> [...]
> > There is no mmu_list_lock.  Do you mean kvm_lock or kvm->mmu_lock?
> >
> > If the former, then we could easily fix this by dropping kvm_lock while
> > the work is being done.  If the latter, then it's more difficult.
> >
> > (kvm_lock being contended implies that mmu_shrink is called concurrently?)
>
> On a 32-core system experiencing memory pressure, mmu_shrink was often
> being called concurrently (before we turned it off).
>
> With just one, or a small number of VMs on a host, when the
> mmu_shrinker contents on the kvm_lock, that's just a proxy for the
> contention on kvm->mmu_lock.  It is the one that gets reported,
> though, since it gets acquired first.
>
> The contention on mmu_lock would indeed be difficult to remove.  Our
> case was perhaps unusual, because of the use of memory containers.  So
> some cgroups were under memory pressure (thus calling the shrinker)
> but the various VCPU threads (whose guest page tables were being
> evicted by the shrinker) could immediately turn around and
> successfully re-allocate them.  That made the kvm->mmu_lock really
> hot.

There are two flaws at work here: first, kvm doesn't really maintain the
pages in LRU or even approximate LRU order, so a hot page can be
evicted.  Second, the shrinker subsystem has no way to tell whether the
items are recently used or not.  If you're using EPT and the guest is
active, likely all mmu pages are in use.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
