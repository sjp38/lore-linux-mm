Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 1CC306B00ED
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 19:07:44 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so2672445lbb.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 16:07:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F91E8CC.5080409@redhat.com>
References: <1334356721-9009-1-git-send-email-yinghan@google.com>
	<20120420151143.433c514e.akpm@linux-foundation.org>
	<4F91E8CC.5080409@redhat.com>
Date: Fri, 20 Apr 2012 16:07:41 -0700
Message-ID: <CALWz4iwVhg23X06T6HP49PKa8z2_-KRx6f64vYrvsT+KoaKp8A@mail.gmail.com>
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Mike Waychison <mikew@google.com>

On Fri, Apr 20, 2012 at 3:53 PM, Rik van Riel <riel@redhat.com> wrote:
> On 04/20/2012 06:11 PM, Andrew Morton wrote:
>>
>> On Fri, 13 Apr 2012 15:38:41 -0700
>> Ying Han<yinghan@google.com> =A0wrote:
>>
>>> The mmu_shrink() is heavy by itself by iterating all kvms and holding
>>> the kvm_lock. spotted the code w/ Rik during LSF, and it turns out we
>>> don't need to call the shrinker if nothing to shrink.
>
>
>>> @@ -3900,6 +3905,9 @@ static int mmu_shrink(struct shrinker *shrink,
>>> struct shrink_control *sc)
>>> =A0 =A0 =A0 =A0if (nr_to_scan =3D=3D 0)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>>>
>>> + =A0 =A0 =A0 if (!get_kvm_total_used_mmu_pages())
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>> +
>
>
>> Do we actually know that this patch helps anything? =A0Any measurements?=
 Is
>> kvm_total_used_mmu_pages=3D=3D0 at all common?
>>
>
> On re-reading mmu.c, it looks like even with EPT or NPT,
> we end up creating mmu pages for the nested page tables.

I think you are right here. So the patch doesn't help the real pain.

My understanding of the real pain is the poor implementation of the
mmu_shrinker. It iterates all the registered mmu_shrink callbacks for
each kvm and only does little work at a time while holding two big
locks. I learned from mikew@ (also ++cc-ed) that is causing latency
spikes and unfairness among kvm instance in some of the experiment
we've seen.

Mike might tell more on that.

--Ying

>
> I have not had the time to look into it more, but it would
> be nice to know if the patch has any effect at all.
>
> --
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
