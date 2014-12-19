Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0EDF46B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 14:53:37 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so2864982wiw.9
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 11:53:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j9si19270168wjf.10.2014.12.19.11.53.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Dec 2014 11:53:35 -0800 (PST)
Date: Fri, 19 Dec 2014 14:53:27 -0500
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: mempool.c: Replace io_schedule_timeout with io_schedule
Message-ID: <20141219195327.GC8697@redhat.com>
References: <1418863222-25096-1-git-send-email-nefelim4ag@gmail.com>
 <20141218153709.GC2293@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141218153709.GC2293@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Heinz Mauelshagen <heinzm@redhat.com>, dm-devel@redhat.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, Dec 18 2014 at 10:37am -0500,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Wed, Dec 17 2014 at  7:40pm -0500,
> Timofey Titovets <nefelim4ag@gmail.com> wrote:
> 
> > io_schedule_timeout(5*HZ);
> > Introduced for avoidance dm bug:
> > http://linux.derkeiler.com/Mailing-Lists/Kernel/2006-08/msg04869.html
> > According to description must be replaced with io_schedule()
> > 
> > Can you test it and answer: it produce any regression?
> > 
> > I replace it and recompile kernel, tested it by following script:
> > ---
> > dev=""
> > block_dev=zram #loop
> > if [ "$block_dev" == "loop" ]; then
> >         f1=$RANDOM
> >         f2=${f1}_2
> >         truncate -s 256G ./$f1
> >         truncate -s 256G ./$f2
> >         dev="$(losetup -f --show ./$f1) $(losetup -f --show ./$f2)"
> >         rm ./$f1 ./$f2
> > else
> >         modprobe zram num_devices=8
> >         # needed ~1g free ram for test
> >         echo 128G > /sys/block/zram7/disksize
> >         echo 128G > /sys/block/zram6/disksize
> >         dev="/dev/zram7 /dev/zram6"
> > fi
> > 
> > md=/dev/md$[$RANDOM%8]
> > echo "y\n" | mdadm --create $md --chunk=4 --level=1 --raid-devices=2 $(echo $dev)
> 
> You didn't test using DM, you used MD.
> 
> And in the context of 2.6.18 the old dm-raid1 target was all DM had
> (whereas now we also have a DM wrapper around MD raid with the dm-raid
> module).  Should we just kill dm-raid1 now that we have dm-raid?  But
> that is tangential to the question being posed here.

Heinz pointed out that dm-raid1 handles clustered raid1 capabilities.
So we cannot easily replace with dm-raid.
 
> So I'll have to read the thread you linked to to understand if DM raid1
> (or DM core) still suffers from the problem that this hack papered over.

Heinz also pointed out that the primary issue that forced the use of
io_schedule_timeout() was that dm-log-userspace (used by dm-raid1) makes
use of a single shared mempool for multiple devices.  Unfortunately,
dm-log-userspace still has this shared mempool (flush_entry_pool).  So
we'll need to fix that up to be per-device before mm/mempool.c code can
be switched to use io_schedule().

I'll add this to my TODO.  But it'll have to wait until after the new
year.

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
