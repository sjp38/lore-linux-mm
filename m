Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDC96B02AE
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 15:31:28 -0500 (EST)
Received: by mail-lf0-f53.google.com with SMTP id p203so154893664lfa.0
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 12:31:28 -0800 (PST)
Received: from n26.netmark.pl (n26.netmark.pl. [94.124.9.61])
        by mx.google.com with ESMTPS id o141si24556933lfe.74.2015.12.23.12.31.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Dec 2015 12:31:26 -0800 (PST)
Date: Wed, 23 Dec 2015 21:31:18 +0100
From: Marcin Szewczyk <Marcin.Szewczyk@wodny.org>
Subject: Re: Exhausting memory makes the system unresponsive but doesn't
 invoke OOM killer
Message-ID: <20151223203118.GB3309@orkisz>
References: <20151223143109.GC3519@orkisz>
 <20151223163221.GA7520@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20151223163221.GA7520@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org

On Wed, Dec 23, 2015 at 11:32:21AM -0500, Johannes Weiner wrote:
> Hi Marcin,

Hi,

> On Wed, Dec 23, 2015 at 03:31:09PM +0100, Marcin Szewczyk wrote:
> > In 2010 I noticed that viewing many GIFs in a row using gpicview renders 
> > my Linux unresponsive. The problem still exists. There is very little 
> > I can do in such a situation. Rarely after some minutes the OOM killer 
> > kicks in and saves the day. Nevertheless, usually I end up using 
> > Alt+SysRq+B.
> 
> Have you tried kicking the OOM killer manually with sysrq+f?

I completely forgot about that option. It works both at TTY and under
Xorg. Thank you very much.

> > The unresponsiveness goes with high CPU load and a lot of IO (read) 
> > operations on the root file system and its block device.
> 
> There is a semi-known issue of heavily thrashing page cache. Your
> crash program sucks up most memory and leaves very little for the
> executables and libraries to be cached, which results in multiple
> threads experiencing cache misses in their executable code, followed
> by fighting over the few remaining page cache slots, which are not
> enough to meet the demand at any given point in time. [...]

Thank you for the explanation.

> That being said, there is no real solution to thrashing page cache as
> of this day. We have most infrastructure in place to detect it, but it
> isn't hooked up to the OOM killer yet. The only answer until then is
> try to keep free+buffer+cache at at least 10-15% of overall memory.

OK. Is there a good source of information I could subscribe to so I
don't miss the moment when the integration code enters the kernel? Do
you think LWN would mention it or should I just follow "oom" messages on
linux-kernel and linux-mm?

> Since you can reproduce it easily, is there any chance you could grab
> backtraces (sysrq+t) of the tasks while the machine is in that state?
> That should confirm that most tasks are either waiting for IO or are
> inside page reclaim.

I've updated the repository. I will later add this thread to the README.

Dump is available here:
https://github.com/wodny/crasher/blob/master/logs/kern.log
I didn't want to post 200kB to everybody so I didn't attach it to this
email.

-- 
Marcin Szewczyk                       http://wodny.org
mailto:Marcin.Szewczyk@wodny.borg  <- remove b / usuA? b
xmpp:wodny@ubuntu.pl                  xmpp:wodny@jabster.pl

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
