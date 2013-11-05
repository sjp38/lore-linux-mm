Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 66D026B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 19:50:19 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id y10so7484249pdj.10
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 16:50:19 -0800 (PST)
Received: from psmtp.com ([74.125.245.182])
        by mx.google.com with SMTP id kn3si8143879pbc.94.2013.11.04.16.50.17
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 16:50:18 -0800 (PST)
Received: by mail-pb0-f46.google.com with SMTP id un15so2878471pbc.33
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 16:50:16 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1816\))
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <CA+55aFxj81TRhe1+FJWqER7VVH_z_Sk0+hwtHvniA0ATsF_eKw@mail.gmail.com>
Date: Mon, 4 Nov 2013 17:50:13 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <89AE8FE8-5B15-41DB-B9CE-DFF73531D821@dilger.ca>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07> <CA+55aFxj81TRhe1+FJWqER7VVH_z_Sk0+hwtHvniA0ATsF_eKw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>


On Oct 25, 2013, at 2:18 AM, Linus Torvalds =
<torvalds@linux-foundation.org> wrote:
> On Fri, Oct 25, 2013 at 8:25 AM, Artem S. Tashkinov =
<t.artem@lycos.com> wrote:
>>=20
>> On my x86-64 PC (Intel Core i5 2500, 16GB RAM), I have the same 3.11
>> kernel built for the i686 (with PAE) and x86-64 architectures. What=92s=

>> really troubling me is that the x86-64 kernel has the following =
problem:
>>=20
>> When I copy large files to any storage device, be it my HDD with ext4
>> partitions or flash drive with FAT32 partitions, the kernel first
>> caches them in memory entirely then flushes them some time later
>> (quite unpredictably though) or immediately upon invoking "sync".
>=20
> Yeah, I think we default to a 10% "dirty background memory" (and
> allows up to 20% dirty), so on your 16GB machine, we allow up to 1.6GB
> of dirty memory for writeout before we even start writing, and twice
> that before we start *waiting* for it.
>=20
> On 32-bit x86, we only count the memory in the low 1GB (really
> actually up to about 890MB), so "10% dirty" really means just about
> 90MB of buffering (and a "hard limit" of ~180MB of dirty).
>=20
> And that "up to 3.2GB of dirty memory" is just crazy. Our defaults
> come from the old days of less memory (and perhaps servers that don't
> much care), and the fact that x86-32 ends up having much lower limits
> even if you end up having more memory.

I think the =93delay writes for a long time=94 is a holdover from the
days when e.g. /tmp was on a disk and compilers had lousy IO
patterns, then they deleted the file.  Today, /tmp is always in
RAM, and IMHO the =93write and delete=94 workload tested by dbench
is not worthwhile optimizing for.

With Lustre, we=92ve long taken the approach that if there is enough
dirty data on a file to make a decent write (which is around 8MB
today even for very fast storage) then there isn=92t much point to
hold back for more data before starting the IO.

Any decent allocator will be able to grow allocated extents to
handle following data, or allocate a new extent.  At 4-8MB extents,
even very seek-impaired media could do 400-800MB/s (likely much
faster than the underlying storage anyway).

This also avoids wasting (tens of?) seconds of idle disk bandwidth.
If the disk is already busy, then the IO will be delayed anyway.
If it is not busy, then why aggregate GB of dirty data in memory
before flushing it?

Something simple like =93start writing at 16MB dirty on a single file=94
would probably avoid a lot of complexity at little real-world cost.
That shouldn=92t throttle dirtying memory above 16MB, but just start
writeout much earlier than it does today.

Cheers, Andreas





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
