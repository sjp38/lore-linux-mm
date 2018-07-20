Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E91DD6B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 21:25:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f91-v6so3694011plb.10
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 18:25:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n3-v6si590006pld.146.2018.07.19.18.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Jul 2018 18:25:42 -0700 (PDT)
Date: Thu, 19 Jul 2018 18:25:36 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [V9fs-developer] KASAN: use-after-free Read in
 generic_perform_write
Message-ID: <20180720012536.GA27335@bombadil.infradead.org>
References: <00000000000047116205715df655@google.com>
 <20180719170718.8d4e7344fe79b2ad411dde98@linux-foundation.org>
 <20180720002704.GA20844@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180720002704.GA20844@nautica>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, syzbot <syzbot+b173e77096a8ba815511@syzkaller.appspotmail.com>, jack@suse.cz, jlayton@redhat.com, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, v9fs-developer@lists.sourceforge.net, mgorman@techsingularity.net

On Fri, Jul 20, 2018 at 02:27:05AM +0200, Dominique Martinet wrote:
> Andrew Morton wrote on Thu, Jul 19, 2018:
> > On Thu, 19 Jul 2018 11:01:01 -0700 syzbot <syzbot+b173e77096a8ba815511@syzkaller.appspotmail.com> wrote:
> > > Hello,
> > > 
> > > syzbot found the following crash on:
> > > 
> > > HEAD commit:    1c34981993da Add linux-next specific files for 20180719
> > > git tree:       linux-next
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=16e6ac44400000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=7002497517b09aec
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=b173e77096a8ba815511
> > > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > > 
> > > Unfortunately, I don't have any reproducer for this crash yet.
> 
> > I'm suspecting v9fs.  Does that fs attempt to write to the fs from a
> > kmalloced buffer?
> 
> Difficult to say without any idea of what syzkaller tried doing, but it
> looks like it hook'd up a fd opened to a local ext4 file into a trans_fd
> mount; so sending a packet to the "server" would trigger a local write
> instead.
> The reason it's freed too early probably is that the reply came from a
> read before the write happened; this is going to be tricky to fix as
> that write is 100% asynchronous without any feedback right now (the
> design assumes that the write has to have finished by the time reply
> came), but if we want to protect ourselves from rogue servers we'll have
> to think about something.
> 
> I'll write it down to not forget, thanks for the cc.

I suspect this got unmasked by my changes; before it would allocate
buffers and just leave them around.  Now it'll free them, which means we
get to see this reuse (rather than having the buffer reused and getting
corrupt data written).

Not that I'm volunteering to fix this problem ;-)
