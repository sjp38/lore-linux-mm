Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1498A900002
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 23:44:33 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so2641438igb.4
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 20:44:32 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id bn6si26440612icb.24.2014.08.01.20.44.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 20:44:32 -0700 (PDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so6960403iec.31
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 20:44:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140802131946.207c597c@notabene.brown>
References: <53DA8443.407@candelatech.com>
	<20140801064217.01852788@notabene.brown>
	<53DAB307.2000206@candelatech.com>
	<20140801075053.2120cb33@notabene.brown>
	<20140801212120.1ae0eb02@tlielax.poochiereds.net>
	<CAABAsM7eh-Faaqmb9yf_xCVwi3cGpnTeOT8A4-e1jhwuEMPKWQ@mail.gmail.com>
	<20140802131946.207c597c@notabene.brown>
Date: Fri, 1 Aug 2014 23:44:32 -0400
Message-ID: <CAABAsM6dNYMus3GrrHiT82-kEb_hAftXnuhSx6SXeuq-E1+JLg@mail.gmail.com>
Subject: Re: Killing process in D state on mount to dead NFS server. (when
 process is in fsync)
From: Trond Myklebust <trondmy@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jlayton@poochiereds.net>, Ben Greear <greearb@candelatech.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, Aug 1, 2014 at 11:19 PM, NeilBrown <neilb@suse.de> wrote:
> On Fri, 1 Aug 2014 22:55:42 -0400 Trond Myklebust <trondmy@gmail.com> wrote:
>
>> > That still leaves some open questions though...
>> >
>> > Is that enough to fix it? You'd still have the dirty pages lingering
>> > around, right? Would a umount -f presumably work at that point?
>>
>> 'umount -f' will kill any outstanding RPC calls that are causing the
>> mount to hang, but doesn't do anything to change page states or NFS
>> file/lock states.
>
> Should it though?
>
>        MNT_FORCE (since Linux 2.1.116)
>               Force  unmount  even  if busy.  This can cause data loss.  (Only
>               for NFS mounts.)
>
> Given that data loss is explicitly permitted, I suspect it should.
>
> Can we make MNT_FORCE on NFS not only abort outstanding RPC calls, but
> fail all subsequent RPC calls?  That might make it really useful.   You
> wouldn't even need to "kill -9" then.

Yes, but if the umount fails due to other conditions (for example an
application happens to still have a file open on that volume) then
that could leave you with a persistent messy situation on your hands.

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
