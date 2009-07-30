Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 506996B004D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 18:02:08 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n6UM23FL010925
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 23:02:04 +0100
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by spaceape11.eur.corp.google.com with ESMTP id n6UM1FcY025657
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 15:02:00 -0700
Received: by pzk35 with SMTP id 35so1276152pzk.24
        for <linux-mm@kvack.org>; Thu, 30 Jul 2009 15:02:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090730213956.GH12579@kernel.dk>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <20090730213956.GH12579@kernel.dk>
Date: Thu, 30 Jul 2009 15:01:59 -0700
Message-ID: <33307c790907301501v4c605ea8oe57762b21d414445@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 30, 2009 at 2:39 PM, Jens Axboe<jens.axboe@oracle.com> wrote:
> On Tue, Jul 28 2009, Chad Talbott wrote:
>> I run a simple workload on a 4GB machine which dirties a few largish
>> inodes like so:
>>
>> # seq 10 | xargs -P0 -n1 -i\{} dd if=3D/dev/zero of=3D/tmp/dump\{}
>> bs=3D1024k count=3D100
>>
>> While the dds are running data is written out at disk speed. =A0However,
>> once the dds have run to completion and exited there is ~500MB of
>> dirty memory left. =A0Background writeout then takes about 3 more
>> minutes to clean memory at only ~3.3MB/s. =A0When I explicitly sync, I
>> can see that the disk is capable of 40MB/s, which finishes off the
>> files in ~10s. [1]
>>
>> An interesting recent-ish change is "writeback: speed up writeback of
>> big dirty files." =A0When I revert the change to __sync_single_inode the
>> problem appears to go away and background writeout proceeds at disk
>> speed. =A0Interestingly, that code is in the git commit [2], but not in
>> the post to LKML. [3] =A0This is may not be the fix, but it makes this
>> test behave better.
>
> Can I talk you into trying the per-bdi writeback patchset? I just tried
> your test on a 16gb machine, and the dd's finish immediately since it
> wont trip the writeout at that percentage of dirty memory. The 1GB of
> dirty memory is flushed when it gets too old, 30 seconds later in two
> chunks of writeout running at disk speed.

How big did you make the dds? It has to be writing more data than
you have RAM, or it's not going to do anything much interesting ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
