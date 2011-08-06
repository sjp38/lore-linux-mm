Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6409E6B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 23:59:55 -0400 (EDT)
Received: by wyi11 with SMTP id 11so56140wyi.14
        for <linux-mm@kvack.org>; Fri, 05 Aug 2011 20:59:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2d2a3645-83e4-4701-b49a-92b3cbe57880@default>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-2-git-send-email-lliubbo@gmail.com>
	<20110804075730.GF31039@tiehlicka.suse.cz>
	<20110804090017.GI31039@tiehlicka.suse.cz>
	<CAA_GA1f8B9uPszGecYd=DiuAOCqo0AXkFca_=5jEGRczGia5ZA@mail.gmail.com>
	<CAA_GA1cQBZ+3qyJeVgU6UcHax5TCGwNtjEnoWhq9w+LFnM9C7w@mail.gmail.com>
	<2d2a3645-83e4-4701-b49a-92b3cbe57880@default>
Date: Sat, 6 Aug 2011 11:59:51 +0800
Message-ID: <CAA_GA1eN16oo2G3vuYfjF_nL6+tuOO5AZmV0zBQSiT7Fdk5ftQ@mail.gmail.com>
Subject: Re: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com

On Sat, Aug 6, 2011 at 2:13 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> From: Bob Liu [mailto:lliubbo@gmail.com]
>> Subject: Re: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
>>
>> On Fri, Aug 5, 2011 at 10:45 AM, Dan Magenheimer
>> <dan.magenheimer@oracle.com> wrote:
>> >> > I am fairly sure that the failed allocation is handled gracefully
>> >> > through the remainder of the frontswap code, but will re-audit to
>> >> > confirm. =C2=A0A warning might be nice though.
>> >>
>> >> There is a place i think maybe have problem.
>> >> function __frontswap_flush_area() in file frontswap.c called
>> >> memset(sis->frontswap_map, .., ..);
>> >> But if frontswap_map allocation fail there is a null pointer access ?
>> >
>> > Good catch!
>> >
>> > I'll fix that when I submit a frontswap update in a few days.
>>
>> Would you please add current patch to you frontswap update series ?
>> So I needn't to send a Version 2 separately with only drop the
>> allocation failed handler.
>> Thanks.
>> Regards,
>> --Bob
>
> Hi Bob --
>
> I'm not an expert here, so you or others can feel free to correct me if I=
've
> got this wrong or if I misunderstood you, but I don't think that's the wa=
y
> patchsets are supposed to be done, at least until they are merged into Li=
nus'
> tree. =C2=A0I think you are asking me to add a fifth patch in the frontsw=
ap
> patch series that fixes this bug, rather than incorporate the fix into
> the next posted version of the frontswap patchset. =C2=A0However, I expec=
t
> to post V5 soon with some additional (minor syntactic) changes to the
> patchset from Konrad Wilk's very thorough review. =C2=A0Then this V5 will
> replace the current version in linux-next soon thereafter (and hopefully
> then into linux-3.2.) =C2=A0So I think it would be the correct process fo=
r me
> to include your bugfix (with an acknowledgement in the commit log) in
> that posted V5.
>

Yes, but current patch "frontswap: using vzalloc instead of vmalloc"
has the error handler
which is unneeded.
+               if (!frontswap_map)
+                       goto bad_swap;

If you want to include it into your series you must delete it by
yourself(or I send an new one) and then add an
extra patch which fix the frontswap_map null pointer bug into your series t=
oo.

That's what I want. Sorry for the noise :).

> That said, if you are using frontswap V4 (the version currently in
> linux-next), the bug fix we've discussed needs to be fixed but is
> exceedingly unlikely to occur in the real world because it would
> require the malloc of swap_map to succeed (which is 8 bits per swap page
> in the swapon'ed swap device) but the malloc of frontswap_map immediately
> thereafter to fail (which is 1 bit per swap page in the swapon'ed swap
> device). =C2=A0(And also this is not a problem for the vast majority of
> kernel developers... it's only possible for frontswap users like you that
> have enabled zcache or tmem or RAMster via a kernel boot option.)
>
> Thanks,
> Dan
>

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
