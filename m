Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 239626B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 22:49:11 -0400 (EDT)
Received: by obbeh20 with SMTP id eh20so10802931obb.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 19:49:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120421112932.3e4bd031d1defc8fe7915ade@gmail.com>
References: <1334356721-9009-1-git-send-email-yinghan@google.com>
 <20120420151143.433c514e.akpm@linux-foundation.org> <4F91E8CC.5080409@redhat.com>
 <CALWz4iwVhg23X06T6HP49PKa8z2_-KRx6f64vYrvsT+KoaKp8A@mail.gmail.com>
 <20120421105615.6b0b03640f7553060628d840@gmail.com> <CAGTjWtB_n+40MEHaQNxZuNhQpXJNGsfeV=Rbz3C12Ar9iPkW8Q@mail.gmail.com>
 <20120421112932.3e4bd031d1defc8fe7915ade@gmail.com>
From: Mike Waychison <mikew@google.com>
Date: Fri, 20 Apr 2012 19:48:49 -0700
Message-ID: <CAGTjWtBXp60hfeFjFHvpj045cRG4nowanS7+U8NcAbE3sdCiaA@mail.gmail.com>
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Takuya Yoshikawa <takuya.yoshikawa@gmail.com>
Cc: Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Eric Northup <digitaleric@google.com>

On Fri, Apr 20, 2012 at 7:29 PM, Takuya Yoshikawa
<takuya.yoshikawa@gmail.com> wrote:
> On Fri, 20 Apr 2012 19:15:24 -0700
> Mike Waychison <mikew@google.com> wrote:
>
>> In our situation, we simple disable the shrinker altogether. =A0My
>> understanding is that we EPT or NPT, the amount of memory used by
>> these tables is bounded by the size of guest physical memory, whereas
>> with software shadowed tables, it is bounded by the addresses spaces
>> in the guest. =A0This bound makes it reasonable to not do any reclaim
>> and charge it as a "system overhead tax".
>
> IIRC, KVM's mmu_shrink is mainly for protecting the host from pathologica=
l
> guest without EPT or NPT.
>
> You can see Avi's summary: -- http://www.spinics.net/lists/kvm/msg65671.h=
tml
> =3D=3D=3D
> We should aim for the following:
> - normal operation causes very little shrinks (some are okay)
> - high pressure mostly due to kvm results in kvm being shrunk (this is a
> pathological case caused by a starting a guest with a huge amount of
> memory, and mapping it all to /dev/zero (or ksm), and getting the guest
> the create shadow mappings for all of it)
> - general high pressure is shared among other caches like dcache and icac=
he
>
> The cost of reestablishing an mmu page can be as high as half a
> millisecond of cpu time, which is the reason I want to be conservative.

To add to that, on these systems (32-way), the fault itself isn't as
heavy-handed as a global lock in everyone's reclaim path :)

I'd be very happy if this stuff was memcg aware, but until that
happens, this code is disabled in our production builds.  30% of CPU
time lost to a spinlock when mixing VMs with IO is worth paying the <
1% of system ram these pages cost if it means
tighter/more-deterministic service latencies.

> =3D=3D=3D
>
> Thanks,
> =A0 =A0 =A0 =A0Takuya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
