Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7C66B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 08:33:16 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l18so5932375wrc.23
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 05:33:16 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id j17si6806019wmc.32.2017.11.06.05.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 05:33:14 -0800 (PST)
Date: Mon, 6 Nov 2017 13:33:04 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: possible deadlock in generic_file_write_iter
Message-ID: <20171106133304.GS21978@ZenIV.linux.org.uk>
References: <94eb2c05f6a018dc21055d39c05b@google.com>
 <20171106032941.GR21978@ZenIV.linux.org.uk>
 <CACT4Y+abiKapoG9ms6RMqNkGBJtjX_Nf5WEQiYJcJ7=XCsyD2w@mail.gmail.com>
 <20171106131544.GB4359@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171106131544.GB4359@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com

On Mon, Nov 06, 2017 at 02:15:44PM +0100, Jan Kara wrote:

> > Should we annotate these inodes with different lock types? Or use
> > nesting annotations?
> 
> Well, you'd need to have a completely separate set of locking classes for
> each filesystem to avoid false positives like these. And that would
> increase number of classes lockdep has to handle significantly. So I'm not
> sure it's really worth it...

Especially when you consider that backing file might be on a filesystem
that lives on another loop device.  *All* per-{device,fs} locks involved
would need classes split that way...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
