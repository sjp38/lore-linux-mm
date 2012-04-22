Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id C5BFD6B004D
	for <linux-mm@kvack.org>; Sun, 22 Apr 2012 05:16:56 -0400 (EDT)
Message-ID: <4F93CC65.4060002@redhat.com>
Date: Sun, 22 Apr 2012 12:16:21 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
References: <1334356721-9009-1-git-send-email-yinghan@google.com> <20120420151143.433c514e.akpm@linux-foundation.org> <4F91E8CC.5080409@redhat.com> <CALWz4iwVhg23X06T6HP49PKa8z2_-KRx6f64vYrvsT+KoaKp8A@mail.gmail.com> <20120421105615.6b0b03640f7553060628d840@gmail.com> <CAGTjWtB_n+40MEHaQNxZuNhQpXJNGsfeV=Rbz3C12Ar9iPkW8Q@mail.gmail.com>
In-Reply-To: <CAGTjWtB_n+40MEHaQNxZuNhQpXJNGsfeV=Rbz3C12Ar9iPkW8Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Waychison <mikew@google.com>
Cc: Takuya Yoshikawa <takuya.yoshikawa@gmail.com>, Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Eric Northup <digitaleric@google.com>

On 04/21/2012 05:15 AM, Mike Waychison wrote:
> On Fri, Apr 20, 2012 at 6:56 PM, Takuya Yoshikawa
> <takuya.yoshikawa@gmail.com> wrote:
> > On Fri, 20 Apr 2012 16:07:41 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> >> My understanding of the real pain is the poor implementation of the
> >> mmu_shrinker. It iterates all the registered mmu_shrink callbacks for
> >> each kvm and only does little work at a time while holding two big
> >> locks. I learned from mikew@ (also ++cc-ed) that is causing latency
> >> spikes and unfairness among kvm instance in some of the experiment
> >> we've seen.
>
> The pains we have with mmu_shrink are twofold:
>
>  - Memory pressure against the shinker applies globally.  Any task can
> cause pressure within their own environment (using numa or memcg) and
> cause the global shrinker to shrink all shadowed tables on the system
> (regardless of how memory is isolated between tasks).
>  - Massive lock contention when all these CPUs are hitting the global
> lock (which backs everybody on the system up).
>
> In our situation, we simple disable the shrinker altogether.  My
> understanding is that we EPT or NPT, the amount of memory used by
> these tables is bounded by the size of guest physical memory, whereas
> with software shadowed tables, it is bounded by the addresses spaces
> in the guest.  

There is also a 2% (default) bound enforced on a per-vm basis.

> This bound makes it reasonable to not do any reclaim
> and charge it as a "system overhead tax".



>
> As for data, the most impressive result was a massive improvement in
> round-trip latency to a webserver running in a guest while another
> process on the system was thrashing through page-cache (on a dozen or
> so spinning disks iirc).  We were using fake-numa, and would otherwise
> not expect the antagonist to drastrically affect the latency-sensitive
> task (as per a lot of effort into making that work).  Unfortunately,
> we saw the 99th%ile latency riding at the 140ms timeout cut-off (they
> were likely tailing out much longer), with the 95%ile at over 40ms.
> With the mmu_shrinker disabled, the 99th%ile latency quickly dropped
> down to about 20ms.
>
> CPU profiles were showing 30% of cpu time wasted on spinlocks, all the
> mmu_list_lock iirc.
>
> In our case, I'm much happier just disabling the damned thing altogether.
>

There is no mmu_list_lock.  Do you mean kvm_lock or kvm->mmu_lock?

If the former, then we could easily fix this by dropping kvm_lock while
the work is being done.  If the latter, then it's more difficult.

(kvm_lock being contended implies that mmu_shrink is called concurrently?)

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
