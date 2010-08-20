Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 42F5D6B0320
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 06:30:18 -0400 (EDT)
Received: by iwn33 with SMTP id 33so925371iwn.14
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 03:30:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100820093558.GG19797@csn.ul.ie>
References: <325E0A25FE724BA18190186F058FF37E@rainbow>
	<20100817111018.GQ19797@csn.ul.ie>
	<4385155269B445AEAF27DC8639A953D7@rainbow>
	<20100818154130.GC9431@localhost>
	<565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
	<20100819160006.GG6805@barrios-desktop>
	<AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
	<20100820053447.GA13406@localhost>
	<20100820093558.GG19797@csn.ul.ie>
Date: Fri, 20 Aug 2010 19:22:16 +0900
Message-ID: <AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com>
Subject: Re: compaction: trying to understand the code
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Iram Shahzad <iram.shahzad@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 6:35 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Fri, Aug 20, 2010 at 01:34:47PM +0800, Wu Fengguang wrote:
>> You do run lots of tasks: kernel_stack=3D1880kB.
>>
>> And you have lots of free memory, page reclaim has never run, so
>> inactive_anon=3D0. This is where compaction is different from vmscan.
>> In vmscan, inactive_anon is reasonably large, and will only be
>> compared directly with isolated_anon.
>>
>
> True, the key observation here was that compaction is being run via the
> proc trigger. Normally it would be run as part of the direct reclaim
> path when kswapd would already be awake. too_many_isolated() needs to be
> different for compaction to take the whole system into account. What
> would be the best alternative? Here is one possibility. A reasonable
> alternative would be that when inactive < active that isolated can't be
> more than num_online_cpus() * 2 (i.e. one compactor per online cpu).
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 94cce51..1e000b7 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -215,14 +215,16 @@ static void acct_isolated(struct zone *zone, struct=
 compact_control *cc)
> =A0static bool too_many_isolated(struct zone *zone)
> =A0{
>
> - =A0 =A0 =A0 unsigned long inactive, isolated;
> + =A0 =A0 =A0 unsigned long active, inactive, isolated;
>
> + =A0 =A0 =A0 active =3D zone_page_state(zone, NR_ACTIVE_FILE) +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 zone_page_state(zone, NR_INACTIVE_ANON);
> =A0 =A0 =A0 =A0inactive =3D zone_page_state(zone, NR_INACTIVE_FILE) +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0zone_page_state(zone, NR_INACTIVE_ANON);
> =A0 =A0 =A0 =A0isolated =3D zone_page_state(zone, NR_ISOLATED_FILE) +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0zone_page_state(zone, NR_ISOLATED_ANON);
>
> - =A0 =A0 =A0 return isolated > inactive;
> + =A0 =A0 =A0 return (inactive > active) ? isolated > inactive : false;
> =A0}
>
> =A0/*
>

1. active : 1000 inactive : 1000
2. parallel reclaiming -> active : 1000 inactive : 500 isolated : 500
3. too_many_isolated return false.

But in this  case, there are already many isolated pages. So it should
return true.

How about this?
too_many_isolated()
{
      return (isolated > nr_zones * nr_nodes * nr_online_cpu *
SWAP_CLUSTER_MAX);
}
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
