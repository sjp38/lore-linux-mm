Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A00E6B78E8
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 09:05:47 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22-v6so5505033plq.21
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 06:05:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p20-v6si4541706pgk.393.2018.09.06.06.05.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Sep 2018 06:05:46 -0700 (PDT)
Date: Thu, 6 Sep 2018 06:05:36 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: linux-next test error
Message-ID: <20180906130536.GA29639@bombadil.infradead.org>
References: <0000000000004f6b5805751a8189@google.com>
 <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
 <20180905133459.GF23909@thunk.org>
 <CAFqt6za5OvHgONOgpmhxS+YsYZyiXUhzpmOgZYyHWPHEO34QwQ@mail.gmail.com>
 <20180906083800.GC19319@quack2.suse.cz>
 <CAFqt6zZ=uaArS0hrbgZGLe38HgSPhZBHzsGEJOZiQGm4Y2N0yw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zZ=uaArS0hrbgZGLe38HgSPhZBHzsGEJOZiQGm4Y2N0yw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org

On Thu, Sep 06, 2018 at 05:56:31PM +0530, Souptick Joarder wrote:
> On Thu, Sep 6, 2018 at 2:08 PM Jan Kara <jack@suse.cz> wrote:
> > Yes, I'd start with converting ext4_page_mkwrite() - that should be pretty
> > straightforward - and we can leave block_page_mkwrite() as is for now. I
> > don't think allocating other VM_FAULT_ codes is going to cut it as
> > generally the filesystem may need to communicate different error codes back
> > and you don't know in advance which are interesting.
> 
> Then I need to take care of ext4_page_mkwrite() and ext4_filemap_fault()
> to migrate to use vm_fault_t return type. Everything else can be removed
> from this patch and it will go as a separate patch.
> 
> As block_page_mkwrite() is getting called from 2 places in ext4 and nilfs and
> both places fault handler code convert errno to VM_FAULT_CODE using
> block_page_mkwrite_return(), is it required to migrate block_page_mkwrite()
> to use vm_fault_t return type and further complicate the API or better to
> leave this API in current state ??

Leave block_page_mkwrite() alone.  Somebody who understands it better
than you do can take care of converting it, if that's even the right
thing to do.  Let's get the typedef conversion _finished_ so we get the
benefit of typechecking for driver writers.
