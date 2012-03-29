Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 804806B011F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:01:37 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1287619qcs.14
        for <linux-mm@kvack.org>; Wed, 28 Mar 2012 17:01:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1332952945-15909-1-git-send-email-glommer@parallels.com>
References: <1332952945-15909-1-git-send-email-glommer@parallels.com>
Date: Wed, 28 Mar 2012 17:01:36 -0700
Message-ID: <CABCjUKDVK2wpCXBxK-J=s9BL+Gaa_E=qA=R_YZhY0xujwf-4Tg@mail.gmail.com>
Subject: Re: [RFC] simple system for enable/disable slabs being tracked by memcg.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

Hi Glauber,

On Wed, Mar 28, 2012 at 9:42 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> Hi.
>
> This is a proposal I've got for how to finally settle down the
> question of which slabs should be tracked. The patch I am providing
> is for discussion only, and should apply ontop of Suleiman's latest
> version posted to the list.
>
> The idea is to create a new file, memory.kmem.slabs_allowed.
> I decided not to overload the slabinfo file for that, but I can,
> if you ultimately want to. I just think it is cleaner this way.
> As a small rationale, I'd like to somehow show which caches are
> available but disabled. And yet, keep the format compatible with
> /proc/slabinfo.
>
> Reading from this file will provide this information
> Writers should write a string:
> =A0[+-]cache_name
>
> The wild card * is accepted, but only that. I am leaving
> any complex processing to userspace.
>
> The * wildcard, though, is nice. It allows us to do:
> =A0-* (disable all)
> =A0+cache1
> =A0+cache2
>
> and so on.
>
> Part of this patch is actually converting the slab pointers in memcg
> to a complex memcg-specific structure that can hold a disabled pointer.
>
> We could actually store it in a free bit in the address, but that is
> a first version. Let me know if this is how you would like me to tackle
> this.
>
> With a system like this (either this, or something alike), my opposition
> to Suleiman's idea of tracking everything under the sun basically vanishe=
s,
> since I can then selectively disable most of them.
>
> I still prefer a special kmalloc call than a GFP flag, though.

How would something like this interact with slab types that will have
a per-memcg shrinker?
Only do memcg shrinking for a slab type if it's not disabled?

While I like the idea of making it configurable by the user, I wonder
if we should be adding even more complexity to an already large
patchset, at this point.
I am also afraid that we might make this too hard setup correctly and use.

If it's ok, I'd prefer to keep going with a slab flag being passed to
kmem_cache_create, to determine if a slab type should be accounted or
not (opt-in), for now.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
