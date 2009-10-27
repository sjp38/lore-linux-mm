Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EB4586B007B
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 02:55:27 -0400 (EDT)
Received: by yxe10 with SMTP id 10so10553341yxe.12
        for <linux-mm@kvack.org>; Mon, 26 Oct 2009 23:55:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>
References: <hav57c$rso$1@ger.gmane.org> <hb2cfu$r08$2@ger.gmane.org>
	 <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	 <4ADE3121.6090407@gmail.com>
	 <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	 <4AE5CB4E.4090504@gmail.com>
	 <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	 <2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>
	 <20091027153429.b36866c4.minchan.kim@barrios-desktop>
	 <20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 27 Oct 2009 15:55:26 +0900
Message-ID: <28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com>
Subject: Re: Memory overcommit
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 27, 2009 at 3:36 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 27 Oct 2009 15:34:29 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Tue, 27 Oct 2009 15:10:52 +0900
>> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>> > 2009/10/27 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>> > > On Mon, 26 Oct 2009 17:16:14 +0100
>> > > Vedran Fura=C4=8D <vedran.furac@gmail.com> wrote:
>> > >> > =C2=A0- Could you show me /var/log/dmesg and /var/log/messages at=
 OOM ?
>> > >>
>> > >> It was catastrophe. :) X crashed (or killed) with all the programs,=
 but
>> > >> my little program was alive for 20 minutes (see timestamps). And fo=
r
>> > >> that time computer was completely unusable. Couldn't even get the
>> > >> console via ssh. Rally embarrassing for a modern OS to get destroye=
d by
>> > >> a 5 lines of C run as an ordinary user. Luckily screen was still al=
ive,
>> > >> oomk usually kills it also. See for yourself:
>> > >>
>> > >> dmesg: http://pastebin.com/f3f83738a
>> > >> messages: http://pastebin.com/f2091110a
>> > >>
>> > >> (CCing to lklm again... I just want people to see the logs.)
>> > >>
>> > > Thank you for reporting and your patience. It seems something strang=
e
>> > > that your KDE programs are killed. I agree.
>> > >
>> > > I attached a scirpt for checking oom_score of all exisiting process.
>> > > (oom_score is a value used for selecting "bad" processs.")
>> > > please run if you have time.
>> > >
>> > > This is a result of my own desktop(on virtual machine.)
>> > > In this environ (Total memory is 1.6GBytes), mmap(1G) program is run=
ning.
>> > >
>> > > %check_badness.pl | sort -n | tail
>> > > --
>> > > 89924 =C2=A0 3938 =C2=A0 =C2=A0mixer_applet2
>> > > 90210 =C2=A0 3942 =C2=A0 =C2=A0tomboy
>> > > 94753 =C2=A0 3936 =C2=A0 =C2=A0clock-applet
>> > > 101994 =C2=A03919 =C2=A0 =C2=A0pulseaudio
>> > > 113525 =C2=A04028 =C2=A0 =C2=A0gnome-terminal
>> > > 127340 =C2=A01 =C2=A0 =C2=A0 =C2=A0 init
>> > > 128177 =C2=A03871 =C2=A0 =C2=A0nautilus
>> > > 151003 =C2=A011515 =C2=A0 bash
>> > > 256944 =C2=A011653 =C2=A0 mmap
>> > > 425561 =C2=A03829 =C2=A0 =C2=A0gnome-session
>> > > --
>> > > Sigh, gnome-session has twice value of mmap(1G).
>> > > Of course, gnome-session only uses 6M bytes of anon.
>> > > I wonder this is because gnome-session has many children..but need t=
o
>> > > dig more. Does anyone has idea ?
>> > > (CCed kosaki)
>> >
>> > Following output address the issue.
>> > The fact is, modern desktop application linked pretty many library. it
>> > makes bloat VSS size and increase
>> > OOM score.
>> >
>> > Ideally, We shouldn't account evictable file-backed mappings for oom_s=
core.
>> >
>> Hmm.
>> I wonder why we consider VM size for OOM kiling.
>> How about RSS size?
>>
>
> Maybe the current code assumes "Tons of swap have been generated, already=
" if
> oom-kill is invoked. Then, just using mm->anon_rss will not be correct.
>
> Hm, should we count # of swap entries reference from mm ?....

In Vedran case, he didn't use swap. So, Only considering vm is the problem.
I think it would be better to consider both RSS + # of swap entries as
Kosaki mentioned.


>
> Regards,
> -Kame
>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
