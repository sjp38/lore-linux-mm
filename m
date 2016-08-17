Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCD2F6B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 04:34:59 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 93so218852238qtg.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 01:34:59 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id c195si24529056wmc.80.2016.08.17.01.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 01:34:57 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id o80so21608657wme.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 01:34:57 -0700 (PDT)
From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Subject: Re: [PATCH] mm, oom: report compaction/migration stats for higher order requests
Date: Wed, 17 Aug 2016 10:34:54 +0200
References: <201608120901.41463.a.miskiewicz@gmail.com> <201608161318.25412.a.miskiewicz@gmail.com> <20160816141007.GF17417@dhcp22.suse.cz>
In-Reply-To: <20160816141007.GF17417@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201608171034.54940.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Tuesday 16 of August 2016, Michal Hocko wrote:
> On Tue 16-08-16 13:18:25, Arkadiusz Miskiewicz wrote:
> > On Monday 15 of August 2016, Michal Hocko wrote:
> > > [Fixing up linux-mm]
> > >=20
> > > Ups I had a c&p error in the previous patch. Here is an updated patch.
> >=20
> > Going to apply this patch now and report again. I mean time what I have
> > is a
> >=20
> >  while (true); do echo "XX date"; date; echo "XX SLAB"; cat
> >  /proc/slabinfo ;
> >=20
> > echo "XX VMSTAT"; cat /proc/vmstat ; echo "XX free"; free; echo "XX
> > DMESG"; dmesg -T | tail -n 50; /bin/sleep 60;done 2>&1 | tee log
> >=20
> > loop gathering some data while few OOM conditions happened.
> >=20
> > I was doing "rm -rf copyX; cp -al original copyX" 10x in parallel.
> >=20
> > https://ixion.pld-linux.org/~arekm/p2/ext4/log-20160816.txt
>=20
> David was right when assuming it would be the ext4 inode cache which
> consumes the large portion of the memory. /proc/slabinfo shows
> ext4_inode_cache consuming between 2.5 to 4.6G of memory.
>=20
> 			first value	last-first
> pgmigrate_success       1861785 	2157917
> pgmigrate_fail  	335344  	1400384
> compact_isolated        4106390 	5777027
> compact_migrate_scanned 113962774       446290647
> compact_daemon_wake     17039   	43981
> compact_fail    	645     	1039
> compact_free_scanned    381701557       793430119
> compact_success 	217     	307
> compact_stall   	862     	1346
>=20
> which means that we have invoked compaction 1346 times and failed in
> 77% of cases. It is interesting to see that the migration wasn't all
> that unsuccessful. We managed to migrate 1.5x more pages than failed. It
> smells like the compaction just backs off.

With "[PATCH] mm, oom: report compaction/migration stats for higher order=20
requests" patch:
https://ixion.pld-linux.org/~arekm/p2/ext4/log-20160817.txt

Didn't count much - all counters are 0
compaction_stall:0 compaction_fail:0 compact_migrate_scanned:0=20
compact_free_scanned:0 compact_isolated:0 pgmigrate_success:0 pgmigrate_fai=
l:0

two processes were killed by OOM (rm and cp), the rest of rm/cp didn't fini=
sh=20
and I'm interrupting it to try that next patch:

> Could you try to test with
> patch from
> http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE please?
> Ideally on top of linux-next. You can add both the compaction counters
> patch in the oom report and high order atomic reserves patch on top.

Uhm, was going to use it on top of 4.7.[01] first.

> Thanks

=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
