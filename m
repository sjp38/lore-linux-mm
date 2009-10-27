Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BED5D6B0044
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 23:24:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9R3Ordq025922
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Oct 2009 12:24:54 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C4F9145DE4E
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 12:24:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9801845DE4F
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 12:24:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CF771DB8038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 12:24:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3429B1DB803A
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 12:24:53 +0900 (JST)
Date: Tue, 27 Oct 2009 12:22:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4AE5CB4E.4090504@gmail.com>
References: <hav57c$rso$1@ger.gmane.org>
	<20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>
	<hb2cfu$r08$2@ger.gmane.org>
	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	<4ADE3121.6090407@gmail.com>
	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	<4AE5CB4E.4090504@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__27_Oct_2009_12_22_13_+0900_mF=J5nn4APaaG3/k"
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Tue__27_Oct_2009_12_22_13_+0900_mF=J5nn4APaaG3/k
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

On Mon, 26 Oct 2009 17:16:14 +0100
Vedran FuraA? <vedran.furac@gmail.com> wrote:
> >  - Could you show me /var/log/dmesg and /var/log/messages at OOM ?
> 
> It was catastrophe. :) X crashed (or killed) with all the programs, but
> my little program was alive for 20 minutes (see timestamps). And for
> that time computer was completely unusable. Couldn't even get the
> console via ssh. Rally embarrassing for a modern OS to get destroyed by
> a 5 lines of C run as an ordinary user. Luckily screen was still alive,
> oomk usually kills it also. See for yourself:
> 
> dmesg: http://pastebin.com/f3f83738a
> messages: http://pastebin.com/f2091110a
> 
> (CCing to lklm again... I just want people to see the logs.)
> 
Thank you for reporting and your patience. It seems something strange
that your KDE programs are killed. I agree.

I attached a scirpt for checking oom_score of all exisiting process.
(oom_score is a value used for selecting "bad" processs.")
please run if you have time.

This is a result of my own desktop(on virtual machine.)
In this environ (Total memory is 1.6GBytes), mmap(1G) program is running.

%check_badness.pl | sort -n | tail
--
89924	3938	mixer_applet2
90210	3942	tomboy
94753	3936	clock-applet
101994	3919	pulseaudio
113525	4028	gnome-terminal
127340	1	init
128177	3871	nautilus
151003	11515	bash
256944	11653	mmap
425561	3829	gnome-session
--
Sigh, gnome-session has twice value of mmap(1G).
Of course, gnome-session only uses 6M bytes of anon.
I wonder this is because gnome-session has many children..but need to
dig more. Does anyone has idea ?
(CCed kosaki)

Thanks,
-Kame





--Multipart=_Tue__27_Oct_2009_12_22_13_+0900_mF=J5nn4APaaG3/k
Content-Type: text/x-perl;
 name="check_badness.pl"
Content-Disposition: attachment;
 filename="check_badness.pl"
Content-Transfer-Encoding: 7bit

#!/usr/bin/perl

open(LINE, "ps -A -o pid,comm | grep -v PID|") || die "can't ps";

while (<LINE>) {
	/^\s*([0-9]+)\s+(.*)$/;
	$PID=$1;
	$COMM=$2;
	open(SCORE, "/proc/$PID/oom_score") || next;
	$oom_score = <SCORE>;
	chomp($oom_score);
	close(SCORE);
	print $oom_score."\t".$PID . "\t",$COMM."\n";
}
close(LINE);

--Multipart=_Tue__27_Oct_2009_12_22_13_+0900_mF=J5nn4APaaG3/k--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
