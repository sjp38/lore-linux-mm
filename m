Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 408F76B004D
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 03:35:03 -0500 (EST)
Received: by yenq10 with SMTP id q10so11035890yen.14
        for <linux-mm@kvack.org>; Wed, 04 Jan 2012 00:35:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1201032103580.1522@eggly.anvils>
References: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com>
 <1325403025-22688-2-git-send-email-kosaki.motohiro@gmail.com>
 <alpine.LSU.2.00.1201031724300.1254@eggly.anvils> <4F03B715.4080005@gmail.com>
 <alpine.LSU.2.00.1201032103580.1522@eggly.anvils>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 4 Jan 2012 03:34:40 -0500
Message-ID: <CAHGf_=rKjz40Oq--M3QB74WJ7uDYSC+mM+DO53XdX2Pq_nFzkQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] sysvshm: SHM_LOCK use lru_add_drain_all_async()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>

2012/1/4 Hugh Dickins <hughd@google.com>:
> On Tue, 3 Jan 2012, KOSAKI Motohiro wrote:
>> (1/3/12 8:51 PM), Hugh Dickins wrote:
>> >
>> > In testing my fix for that, I find that there has been no attempt to
>> > keep the Unevictable count accurate on SysVShm: SHM_LOCK pages get
>> > marked unevictable lazily later as memory pressure discovers them -
>> > which perhaps mirrors the way in which SHM_LOCK makes no attempt to
>> > instantiate pages, unlike mlock.
>>
>> Ugh, you are right. I'm recovering my remember gradually. Lee implemente=
d
>> immediate lru off logic at first and I killed it
>> to close a race. I completely forgot. So, yes, now SHM_LOCK has no attem=
pt to
>> instantiate pages. I'm ashamed.
>
> Why ashamed? =A0The shmctl man-page documents "The caller must fault in a=
ny
> pages that are required to be present after locking is enabled." =A0That'=
s
> just how it behaves.

hehe, I have big bad reputation about for bad remember capabilities from
my friends. I should have remembered what i implemented. ;-)



>> > (But in writing this, realize I still don't quite understand why
>> > the Unevictable count takes a second or two to get back to 0 after
>> > SHM_UNLOCK: perhaps I've more to discover.)
>>
>> Interesting. I'm looking at this too.
>
> In case you got distracted before you found it, mm/vmstat.c's
>
> static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
> int sysctl_stat_interval __read_mostly =3D HZ;
>
> static void vmstat_update(struct work_struct *w)
> {
> =A0 =A0 =A0 =A0refresh_cpu_vm_stats(smp_processor_id());
> =A0 =A0 =A0 =A0schedule_delayed_work(&__get_cpu_var(vmstat_work),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0round_jiffies_relative(sysctl_stat_interva=
l));
> }
>
> would be why, I think. =A0And that implies to me that your
> lru_add_drain_all_async() is not necessary, you'd get just as good
> an effect, more cheaply, by doing a local lru_add_drain() before the
> refresh in vmstat_update().

When, I implement lru_add_drain_all_async(), I thought this idea. I don't
dislike both. But if we take vmstat_update() one, I think we need more tric=
ks.
pcp draining in refresh_cpu_vm_stats() delays up to 3 seconds. Why?
round_jiffies_relative() don't silly round to HZ boundary. Instead of, it a=
dds
a few unique offset per each cpus. thus, 3 seconds mean max 3000cpus
don't make zone_{lru_}lock contention. pagevec draining also need same
trick for rescue SGI UV. It might be too pessimistic concern. but
vmstat_update() shouldn't make obsevable lock contention.


> But it would still require your changes to ____pagevec_lru_add_fn(),
> if those turn out to help more than they hurt.

I agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
