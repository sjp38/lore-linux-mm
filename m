Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 4126F6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 22:29:39 -0400 (EDT)
Received: by dakh32 with SMTP id h32so14582458dak.9
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 19:29:38 -0700 (PDT)
Date: Sat, 21 Apr 2012 11:29:32 +0900
From: Takuya Yoshikawa <takuya.yoshikawa@gmail.com>
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
Message-Id: <20120421112932.3e4bd031d1defc8fe7915ade@gmail.com>
In-Reply-To: <CAGTjWtB_n+40MEHaQNxZuNhQpXJNGsfeV=Rbz3C12Ar9iPkW8Q@mail.gmail.com>
References: <1334356721-9009-1-git-send-email-yinghan@google.com>
	<20120420151143.433c514e.akpm@linux-foundation.org>
	<4F91E8CC.5080409@redhat.com>
	<CALWz4iwVhg23X06T6HP49PKa8z2_-KRx6f64vYrvsT+KoaKp8A@mail.gmail.com>
	<20120421105615.6b0b03640f7553060628d840@gmail.com>
	<CAGTjWtB_n+40MEHaQNxZuNhQpXJNGsfeV=Rbz3C12Ar9iPkW8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Waychison <mikew@google.com>
Cc: Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Eric Northup <digitaleric@google.com>

On Fri, 20 Apr 2012 19:15:24 -0700
Mike Waychison <mikew@google.com> wrote:

> In our situation, we simple disable the shrinker altogether.  My
> understanding is that we EPT or NPT, the amount of memory used by
> these tables is bounded by the size of guest physical memory, whereas
> with software shadowed tables, it is bounded by the addresses spaces
> in the guest.  This bound makes it reasonable to not do any reclaim
> and charge it as a "system overhead tax".

IIRC, KVM's mmu_shrink is mainly for protecting the host from pathological
guest without EPT or NPT.

You can see Avi's summary: -- http://www.spinics.net/lists/kvm/msg65671.html
===
We should aim for the following:
- normal operation causes very little shrinks (some are okay)
- high pressure mostly due to kvm results in kvm being shrunk (this is a
pathological case caused by a starting a guest with a huge amount of
memory, and mapping it all to /dev/zero (or ksm), and getting the guest
the create shadow mappings for all of it)
- general high pressure is shared among other caches like dcache and icache

The cost of reestablishing an mmu page can be as high as half a
millisecond of cpu time, which is the reason I want to be conservative.
===

Thanks,
	Takuya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
