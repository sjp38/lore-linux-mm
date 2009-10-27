Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 098256B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 02:39:01 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9R6cxVI002126
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Oct 2009 15:38:59 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 390F045DE4F
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 15:38:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EF4245DE4E
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 15:38:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EA85B1DB803A
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 15:38:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 886C31DB803F
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 15:38:55 +0900 (JST)
Date: Tue, 27 Oct 2009 15:36:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091027153429.b36866c4.minchan.kim@barrios-desktop>
References: <hav57c$rso$1@ger.gmane.org>
	<20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>
	<hb2cfu$r08$2@ger.gmane.org>
	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	<4ADE3121.6090407@gmail.com>
	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	<4AE5CB4E.4090504@gmail.com>
	<20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>
	<20091027153429.b36866c4.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009 15:34:29 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, 27 Oct 2009 15:10:52 +0900
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > 2009/10/27 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> > > On Mon, 26 Oct 2009 17:16:14 +0100
> > > Vedran FuraA? <vedran.furac@gmail.com> wrote:
> > >> > A - Could you show me /var/log/dmesg and /var/log/messages at OOM ?
> > >>
> > >> It was catastrophe. :) X crashed (or killed) with all the programs, but
> > >> my little program was alive for 20 minutes (see timestamps). And for
> > >> that time computer was completely unusable. Couldn't even get the
> > >> console via ssh. Rally embarrassing for a modern OS to get destroyed by
> > >> a 5 lines of C run as an ordinary user. Luckily screen was still alive,
> > >> oomk usually kills it also. See for yourself:
> > >>
> > >> dmesg: http://pastebin.com/f3f83738a
> > >> messages: http://pastebin.com/f2091110a
> > >>
> > >> (CCing to lklm again... I just want people to see the logs.)
> > >>
> > > Thank you for reporting and your patience. It seems something strange
> > > that your KDE programs are killed. I agree.
> > >
> > > I attached a scirpt for checking oom_score of all exisiting process.
> > > (oom_score is a value used for selecting "bad" processs.")
> > > please run if you have time.
> > >
> > > This is a result of my own desktop(on virtual machine.)
> > > In this environ (Total memory is 1.6GBytes), mmap(1G) program is running.
> > >
> > > %check_badness.pl | sort -n | tail
> > > --
> > > 89924 A  3938 A  A mixer_applet2
> > > 90210 A  3942 A  A tomboy
> > > 94753 A  3936 A  A clock-applet
> > > 101994 A 3919 A  A pulseaudio
> > > 113525 A 4028 A  A gnome-terminal
> > > 127340 A 1 A  A  A  init
> > > 128177 A 3871 A  A nautilus
> > > 151003 A 11515 A  bash
> > > 256944 A 11653 A  mmap
> > > 425561 A 3829 A  A gnome-session
> > > --
> > > Sigh, gnome-session has twice value of mmap(1G).
> > > Of course, gnome-session only uses 6M bytes of anon.
> > > I wonder this is because gnome-session has many children..but need to
> > > dig more. Does anyone has idea ?
> > > (CCed kosaki)
> > 
> > Following output address the issue.
> > The fact is, modern desktop application linked pretty many library. it
> > makes bloat VSS size and increase
> > OOM score.
> > 
> > Ideally, We shouldn't account evictable file-backed mappings for oom_score.
> > 
> Hmm. 
> I wonder why we consider VM size for OOM kiling. 
> How about RSS size?
> 

Maybe the current code assumes "Tons of swap have been generated, already" if
oom-kill is invoked. Then, just using mm->anon_rss will not be correct.

Hm, should we count # of swap entries reference from mm ?....

Regards,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
