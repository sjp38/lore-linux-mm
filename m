Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 193D16B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 14:14:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <2d2a3645-83e4-4701-b49a-92b3cbe57880@default>
Date: Fri, 5 Aug 2011 11:13:56 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
 <20110804075730.GF31039@tiehlicka.suse.cz>
 <20110804090017.GI31039@tiehlicka.suse.cz>
 <CAA_GA1f8B9uPszGecYd=DiuAOCqo0AXkFca_=5jEGRczGia5ZA@mail.gmail.com>
 <d0584e86-34f6-46cc-a78e-c1e31ed7cb9f@default
 CAA_GA1cQBZ+3qyJeVgU6UcHax5TCGwNtjEnoWhq9w+LFnM9C7w@mail.gmail.com>
In-Reply-To: <CAA_GA1cQBZ+3qyJeVgU6UcHax5TCGwNtjEnoWhq9w+LFnM9C7w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com

> From: Bob Liu [mailto:lliubbo@gmail.com]
> Subject: Re: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
>=20
> On Fri, Aug 5, 2011 at 10:45 AM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
> >> > I am fairly sure that the failed allocation is handled gracefully
> >> > through the remainder of the frontswap code, but will re-audit to
> >> > confirm. =C2=A0A warning might be nice though.
> >>
> >> There is a place i think maybe have problem.
> >> function __frontswap_flush_area() in file frontswap.c called
> >> memset(sis->frontswap_map, .., ..);
> >> But if frontswap_map allocation fail there is a null pointer access ?
> >
> > Good catch!
> >
> > I'll fix that when I submit a frontswap update in a few days.
>=20
> Would you please add current patch to you frontswap update series ?
> So I needn't to send a Version 2 separately with only drop the
> allocation failed handler.
> Thanks.
> Regards,
> --Bob

Hi Bob --

I'm not an expert here, so you or others can feel free to correct me if I'v=
e
got this wrong or if I misunderstood you, but I don't think that's the way
patchsets are supposed to be done, at least until they are merged into Linu=
s'
tree.  I think you are asking me to add a fifth patch in the frontswap
patch series that fixes this bug, rather than incorporate the fix into
the next posted version of the frontswap patchset.  However, I expect
to post V5 soon with some additional (minor syntactic) changes to the
patchset from Konrad Wilk's very thorough review.  Then this V5 will
replace the current version in linux-next soon thereafter (and hopefully
then into linux-3.2.)  So I think it would be the correct process for me
to include your bugfix (with an acknowledgement in the commit log) in
that posted V5.

That said, if you are using frontswap V4 (the version currently in
linux-next), the bug fix we've discussed needs to be fixed but is
exceedingly unlikely to occur in the real world because it would
require the malloc of swap_map to succeed (which is 8 bits per swap page
in the swapon'ed swap device) but the malloc of frontswap_map immediately
thereafter to fail (which is 1 bit per swap page in the swapon'ed swap
device).  (And also this is not a problem for the vast majority of
kernel developers... it's only possible for frontswap users like you that
have enabled zcache or tmem or RAMster via a kernel boot option.)

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
