Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8DCAA6B01F0
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 12:36:12 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o7RGZxqD003186
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 09:36:00 -0700
Received: from qyk12 (qyk12.prod.google.com [10.241.83.140])
	by wpaz33.hot.corp.google.com with ESMTP id o7RGZbD8027423
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 09:35:58 -0700
Received: by qyk12 with SMTP id 12so812791qyk.7
        for <linux-mm@kvack.org>; Fri, 27 Aug 2010 09:35:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTinP_q7S4_O921hdBoedmTp-7gw0+=4DPHZGmysi@mail.gmail.com>
References: <1282867897-31201-1-git-send-email-yinghan@google.com>
	<AANLkTimaLBJa9hmufqQy3jk7GD-mJDbg=Dqkaja0nOMk@mail.gmail.com>
	<AANLkTi=xUMSZ7wX-2BtJ0-+2BYLCTW=VPTAErinb5Zd2@mail.gmail.com>
	<AANLkTinP_q7S4_O921hdBoedmTp-7gw0+=4DPHZGmysi@mail.gmail.com>
Date: Fri, 27 Aug 2010 09:35:58 -0700
Message-ID: <AANLkTin6+nHOowdptW2jaxg9urn3OLf9ArgGzKjWnQLM@mail.gmail.com>
Subject: Re: [PATCH] vmscan: fix missing place to check nr_swap_pages.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 10:00 PM, Minchan Kim <minchan.kim@gmail.com> wrote=
:
>
> On Fri, Aug 27, 2010 at 12:31 PM, Ying Han <yinghan@google.com> wrote:
> > On Thu, Aug 26, 2010 at 6:03 PM, Minchan Kim <minchan.kim@gmail.com> wr=
ote:
> >>
> >> Hello.
> >>
> >> On Fri, Aug 27, 2010 at 9:11 AM, Ying Han <yinghan@google.com> wrote:
> >> > Fix a missed place where checks nr_swap_pages to do shrink_active_li=
st. Make the
> >> > change that moves the check to common function inactive_anon_is_low.
> >> >
> >>
> >> Hmm.. AFAIR, we discussed it at that time but we concluded it's not go=
od.
> >> That's because nr_swap_pages < 0 means both "NO SWAP" and "NOT enough
> >> swap space now". If we have a swap device or file but not enough space
> >> now, we need to aging anon pages to make inactive list enough size.
> >> Otherwise, working set pages would be swapped out more fast before
> >> promotion.
> >
> > We found the problem on one of our workloads where more TLB flush
> > happens without the change. Kswapd seems to be calling
> > shrink_active_list() which eventually clears access bit of those ptes
> > and does TLB flush
> > with ptep_clear_flush_young(). This system does not have swap
> > configured, and why aging the anon lru in that
> > case?
>
> True. I also wanted it but we have to care swap configured but
> non-enabling still yet system as well as non-swap configured system at
> that time.

Agree. =A0In our case, we cares about the case where swap is not enabled
but is configured .
>
> If your system is no swap configured, how about this?
> (It's a not formal proper patch but just quick patch to show the concept)=
