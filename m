Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24A3B6B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 08:36:06 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id h70so21871224ioi.5
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 05:36:06 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f78sor4882595ita.133.2017.11.06.05.36.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 05:36:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171106133304.GS21978@ZenIV.linux.org.uk>
References: <94eb2c05f6a018dc21055d39c05b@google.com> <20171106032941.GR21978@ZenIV.linux.org.uk>
 <CACT4Y+abiKapoG9ms6RMqNkGBJtjX_Nf5WEQiYJcJ7=XCsyD2w@mail.gmail.com>
 <20171106131544.GB4359@quack2.suse.cz> <20171106133304.GS21978@ZenIV.linux.org.uk>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Nov 2017 14:35:44 +0100
Message-ID: <CACT4Y+YHPOaCVO81VPuC9hDLCSx=KJmwRf7pa3b96UAowLmA2A@mail.gmail.com>
Subject: Re: possible deadlock in generic_file_write_iter
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>, syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Mon, Nov 6, 2017 at 2:33 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Mon, Nov 06, 2017 at 02:15:44PM +0100, Jan Kara wrote:
>
>> > Should we annotate these inodes with different lock types? Or use
>> > nesting annotations?
>>
>> Well, you'd need to have a completely separate set of locking classes for
>> each filesystem to avoid false positives like these. And that would
>> increase number of classes lockdep has to handle significantly. So I'm not
>> sure it's really worth it...
>
> Especially when you consider that backing file might be on a filesystem
> that lives on another loop device.  *All* per-{device,fs} locks involved
> would need classes split that way...


This crashes our test machines left and right. We've seen 100000+ of
these crashes. We need to do at least something. Can we disable all
checking of these mutexes if they inherently have positives?

+Ingo, Peter, maybe you have some suggestions of how to fight this
lockdep false positives. Full thread is here:
https://groups.google.com/forum/#!msg/syzkaller-bugs/NJ_4llH84XI/c7M9jNLTAgAJ

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
