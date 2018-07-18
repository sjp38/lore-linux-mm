Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 44AEE6B0266
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 12:01:09 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l13-v6so3526713qth.8
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 09:01:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a18-v6si1391830qtm.396.2018.07.18.09.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 09:01:05 -0700 (PDT)
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
 <1530570880.3179.9.camel@HansenPartnership.com>
 <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
 <20180703091821.oiywpdxd6rhtxl4p@quack2.suse.cz>
 <20180714173516.uumlhs4wgfgrlc32@devuan>
 <CA+55aFw1vrsTjJyoq4Q3jBwv1nXaTkkmSbHO6vozWZuTc7_6Kg@mail.gmail.com>
 <20180714183445.GJ30522@ZenIV.linux.org.uk>
From: Waiman Long <longman@redhat.com>
Message-ID: <990ac8fd-69a6-7d6b-6608-cda012ac22a4@redhat.com>
Date: Wed, 18 Jul 2018 12:01:03 -0400
MIME-Version: 1.0
In-Reply-To: <20180714183445.GJ30522@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pavel Machek <pavel@ucw.cz>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On 07/14/2018 02:34 PM, Al Viro wrote:
> On Sat, Jul 14, 2018 at 11:00:32AM -0700, Linus Torvalds wrote:
>> On Sat, Jul 14, 2018 at 10:35 AM Pavel Machek <pavel@ucw.cz> wrote:
>>> Could we allocate -ve entries from separate slab?
>> No, because negative dentrires don't stay negative.
>>
>> Every single positive dentry starts out as a negative dentry that is
>> passed in to "lookup()" to maybe be made positive.
>>
>> And most of the time they <i>do</i> turn positive, because most of the=

>> time people actually open files that exist.
>>
>> But then occasionally you don't, because you're just blindly opening a=

>> filename whether it exists or not (to _check_ whether it's there).
> BTW, one point that might not be realized by everyone: negative dentrie=
s
> are *not* the hard case.
> mount -t tmpfs none /mnt
> touch /mnt/a
> for i in `seq 100000`; do ln /mnt/a /mnt/$i; done
>
> and you've got 100000 *unevictable* dentries, with the time per iterati=
on
> being not all that high (especially if you just call link(2) in a loop)=
=2E
> They are all positive and all pinned.  And you've got only one inode
> there and no persistently opened files, so rlimit and quota won't help
> any.

Normally you need to be root or have privileges to mount a filesystem.
Right?

I am aware there is effort going on to allow non-privilege user mount in
container. That can open a can of worms if it is not done properly.

With privileges, there is a lot of ways one can screw up the system. So
I am not less concern about this particular issue.

Cheers,
Longman
