Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5E3226B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 13:12:50 -0400 (EDT)
Received: by bwz24 with SMTP id 24so469645bwz.10
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 10:12:48 -0700 (PDT)
Message-ID: <4AE72A0D.9070804@gmail.com>
Date: Tue, 27 Oct 2009 18:12:45 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org>	<20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>	<hb2cfu$r08$2@ger.gmane.org>	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>	<4ADE3121.6090407@gmail.com>	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>	<4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, hugh.dickins@tiscali.co.uk, akpm@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

> On Mon, 26 Oct 2009 17:16:14 +0100
> Vedran FuraA? <vedran.furac@gmail.com> wrote:
>>>  - Could you show me /var/log/dmesg and /var/log/messages at OOM ?
>> It was catastrophe. :) X crashed (or killed) with all the programs, but
>> my little program was alive for 20 minutes (see timestamps). And for
>> that time computer was completely unusable. Couldn't even get the
>> console via ssh. Rally embarrassing for a modern OS to get destroyed by
>> a 5 lines of C run as an ordinary user. Luckily screen was still alive,
>> oomk usually kills it also. See for yourself:
>>
>> dmesg: http://pastebin.com/f3f83738a
>> messages: http://pastebin.com/f2091110a
>>
>> (CCing to lklm again... I just want people to see the logs.)
>>
> Thank you for reporting and your patience. It seems something strange
> that your KDE programs are killed. I agree.

No problem. I want this to be solved as much as you do. Actually, it is
not strange, just a buggy algorithm.

Run:

% ps -T -eo pid,ppid,tid,vsz,command

You'll see that ppid of a number of processes is kdeinit, gnome-session,
fvwm or something else depending on what one is using. All of this
processes are started automatically during startup or manually clicking
on a menu item or by some keyboard shortcut. OOM algorithm just sums
memory usage of all of them and adds that ot the parent. Just plain wrong.

Also, it seems it's looking at VIRT instead of RES.

> I attached a scirpt for checking oom_score of all exisiting process.
> (oom_score is a value used for selecting "bad" processs.")
> please run if you have time.

96890   21463   VirtualBox // OK
118615  11144   kded4 // WRONG
127455  11158   knotify4 // WRONG
132198  1       init // WRONG
133940  11151   ksmserver // WRONG
134109  11224   audacious2 // Audio player, maybe
145476  21503   VirtualBox // OK
174939  11322   icedove-bin // thunderbird, maybe
178015  11223   akregator // rss reader, maybe
201043  22672   krusader  // WRONG
212609  11187   krunner // WRONG
256911  24252   test // culprit, malloced 1GB
1750371 11318   run-mozilla.sh // tiny, parent of firefox threads
2044902 11141   kdeinit4 // tiny, parent of most KDE apps

> Sigh, gnome-session has twice value of mmap(1G).
> Of course, gnome-session only uses 6M bytes of anon.
> I wonder this is because gnome-session has many children..but need to

Yes it is.

Regards,

Vedran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
