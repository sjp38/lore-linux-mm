Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1436B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 20:27:22 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id i63-v6so2345119lji.23
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 17:27:22 -0700 (PDT)
Received: from nautica.notk.org (ipv6.notk.org. [2001:41d0:1:7a93::1])
        by mx.google.com with ESMTPS id n3-v6si185935lfn.279.2018.07.19.17.27.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 17:27:20 -0700 (PDT)
Date: Fri, 20 Jul 2018 02:27:05 +0200
From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [V9fs-developer] KASAN: use-after-free Read in
 generic_perform_write
Message-ID: <20180720002704.GA20844@nautica>
References: <00000000000047116205715df655@google.com>
 <20180719170718.8d4e7344fe79b2ad411dde98@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180719170718.8d4e7344fe79b2ad411dde98@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <syzbot+b173e77096a8ba815511@syzkaller.appspotmail.com>, jack@suse.cz, jlayton@redhat.com, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org, willy@infradead.org, linux-mm@kvack.org, v9fs-developer@lists.sourceforge.net, mgorman@techsingularity.net

Andrew Morton wrote on Thu, Jul 19, 2018:
> On Thu, 19 Jul 2018 11:01:01 -0700 syzbot <syzbot+b173e77096a8ba815511@syzkaller.appspotmail.com> wrote:
> > Hello,
> > 
> > syzbot found the following crash on:
> > 
> > HEAD commit:    1c34981993da Add linux-next specific files for 20180719
> > git tree:       linux-next
> > console output: https://syzkaller.appspot.com/x/log.txt?x=16e6ac44400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=7002497517b09aec
> > dashboard link: https://syzkaller.appspot.com/bug?extid=b173e77096a8ba815511
> > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > 
> > Unfortunately, I don't have any reproducer for this crash yet.
> 
> Thanks.  I cc'ed v9fs-developer, optimistically.  That list manager is
> weird :(

I agree that list is weird, does anyone know the reason v9fs-developer
is not a vger.k.o list? Or a reason not to change? It's still not too
late...

> I'm suspecting v9fs.  Does that fs attempt to write to the fs from a
> kmalloced buffer?

Difficult to say without any idea of what syzkaller tried doing, but it
looks like it hook'd up a fd opened to a local ext4 file into a trans_fd
mount; so sending a packet to the "server" would trigger a local write
instead.
The reason it's freed too early probably is that the reply came from a
read before the write happened; this is going to be tricky to fix as
that write is 100% asynchronous without any feedback right now (the
design assumes that the write has to have finished by the time reply
came), but if we want to protect ourselves from rogue servers we'll have
to think about something.

I'll write it down to not forget, thanks for the cc.

-- 
Dominique Martinet
