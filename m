Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6E92A6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 23:31:04 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o7R3V2Dg032368
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 20:31:02 -0700
Received: from qwk4 (qwk4.prod.google.com [10.241.195.132])
	by wpaz24.hot.corp.google.com with ESMTP id o7R3V0CS008255
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 20:31:01 -0700
Received: by qwk4 with SMTP id 4so2155230qwk.9
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 20:31:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTimaLBJa9hmufqQy3jk7GD-mJDbg=Dqkaja0nOMk@mail.gmail.com>
References: <1282867897-31201-1-git-send-email-yinghan@google.com>
	<AANLkTimaLBJa9hmufqQy3jk7GD-mJDbg=Dqkaja0nOMk@mail.gmail.com>
Date: Thu, 26 Aug 2010 20:31:00 -0700
Message-ID: <AANLkTi=xUMSZ7wX-2BtJ0-+2BYLCTW=VPTAErinb5Zd2@mail.gmail.com>
Subject: Re: [PATCH] vmscan: fix missing place to check nr_swap_pages.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 6:03 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
>
> Hello.
>
> On Fri, Aug 27, 2010 at 9:11 AM, Ying Han <yinghan@google.com> wrote:
> > Fix a missed place where checks nr_swap_pages to do shrink_active_list.=
 Make the
> > change that moves the check to common function inactive_anon_is_low.
> >
>
> Hmm.. AFAIR, we discussed it at that time but we concluded it's not good.
> That's because nr_swap_pages < 0 means both "NO SWAP" and "NOT enough
> swap space now". If we have a swap device or file but not enough space
> now, we need to aging anon pages to make inactive list enough size.
> Otherwise, working set pages would be swapped out more fast before
> promotion.

We found the problem on one of our workloads where more TLB flush
happens without the change. Kswapd seems to be calling
shrink_active_list() which eventually clears access bit of those ptes
and does TLB flush
with ptep_clear_flush_young(). This system does not have swap
configured, and why aging the anon lru in that
case?

> That aging is done by kswapd so I think it's not big harmful in the syste=
m.
> But if you want to remove aging completely in non-swap system, we need
> to identify non swap system and not enough swap space. I thought we
> need it for embedded system.

Lots of TLB flush hurts the performance especially on large smp system. So =
does
it make sense if change it to:

+       if (nr_swap_pages =3D=3D 0)
+               return 0;

--Ying


> Thanks.
>
>
> --
> Kind regards,
> Minchan Kim
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
