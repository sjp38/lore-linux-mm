Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 215306B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 21:17:47 -0500 (EST)
Received: by iwn40 with SMTP id 40so319000iwn.14
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:17:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110118174826.4c6d47a3.akpm@linux-foundation.org>
References: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
	<20110118152844.88cfdc2c.akpm@linux-foundation.org>
	<AANLkTimh7jq7HLjfxVX0XKdhOhWEQtDn-faGc+iJ-ykd@mail.gmail.com>
	<20110118174826.4c6d47a3.akpm@linux-foundation.org>
Date: Wed, 19 Jan 2011 11:17:45 +0900
Message-ID: <AANLkTin_LhfABegySQrFxEmMT42xJGgsGR5=CcaOvtHr@mail.gmail.com>
Subject: Re: [PATCH v4] mm: add replace_page_cache_page() function
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 19, 2011 at 10:48 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 19 Jan 2011 10:24:09 +0900 Minchan Kim <minchan.kim@gmail.com> wr=
ote:
>
>> >
>> > This is all pretty ugly and inefficient.
>> >
>> > We call __remove_from_page_cache() which does a radix-tree lookup and
>> > then fiddles a bunch of accounting things.
>> >
>> > Then we immediately do the same radix-tree lookup and then undo the
>> > accounting changes which we just did. __And we do it in an open-coded
>> > fashion, thus giving the kernel yet another code site where various
>> > operations need to be kept in sync.
>> >
>> > Would it not be better to do a single radix_tree_lookup_slot(),
>> > overwrite the pointer therein and just leave all the ancilliary
>> > accounting unaltered?
>>
>> I agree single radix_tree_lookup but accounting still is needed since
>> newpage could be on another zone. What we can remove is just only
>> mapping->nrpages.
>
> Well. =A0We only need to do inc/dec_zone_state if the zones are
> different. =A0Perhaps the zones-equal case is worth optimising for,
> dunno.
>
> Also, the radix_tree_preload() should be unneeded.

Agree.
In summary, optimization points are following as.

1) remove radix_tree_preload
2) single radix_tree_lookup_slot and replace radix tree slot
3) page accounting optimization if both pages are in same zone.

I hope we mm guys optimize the above things with TODO.
(Except freepage issue I mentioned.)
So I want Miklos resend the patch with solving freepage issue and NOTE
of TODO in description or comment.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
