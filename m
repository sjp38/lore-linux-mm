Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4186B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 16:09:30 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so81112440lfg.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 13:09:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si32978386wjr.197.2016.08.01.13.09.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 13:09:28 -0700 (PDT)
Date: Mon, 1 Aug 2016 22:09:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160801200926.GF31957@dhcp22.suse.cz>
References: <d8f3adcc-3607-1ef6-9ec5-82b2e125eef2@quantum.com>
 <20160801061625.GA11623@dhcp22.suse.cz>
 <b1a39756-a0b5-1900-6575-d6e1f502cb26@Quantum.com>
 <20160801182358.GB31957@dhcp22.suse.cz>
 <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
 <20160801192620.GD31957@dhcp22.suse.cz>
 <939def12-3fa8-e877-ce17-b59db9fa1876@Quantum.com>
 <20160801194323.GE31957@dhcp22.suse.cz>
 <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon 01-08-16 12:52:40, Ralf-Peter Rohbeck wrote:
> On 01.08.2016 12:43, Michal Hocko wrote:
> > On Mon 01-08-16 12:35:51, Ralf-Peter Rohbeck wrote:
> > > On 01.08.2016 12:26, Michal Hocko wrote:
> > [...]
> > > > the amount of dirty pages is much smaller as well as the anonymous
> > > > memory. The biggest portion seems to be in the page cache. The memory
> > > The page cache will always be full if I'm writing at full steam to multiple
> > > drives, no?
> > Yes, the memory full of page cache is not unusual. The large portion of
> > that memory being dirty/writeback can be a problem. That is why we have
> > a dirty memory throttling which slows down (throttles) writers to keep
> > the amount reasonable. What is your dirty throttling setup?
> > $ grep . /proc/sys/vm/dirty*
> > 
> > and what is your storage setup?
> 
> root@fs:~# grep . /proc/sys/vm/dirty*
> /proc/sys/vm/dirty_background_bytes:0
> /proc/sys/vm/dirty_background_ratio:10
> /proc/sys/vm/dirty_bytes:0
> /proc/sys/vm/dirty_expire_centisecs:3000
> /proc/sys/vm/dirty_ratio:20

With your 8G of RAM this can be quite a lot of dirty data at once. Is
your storage able to write that back in a reasonable time? I mean this
shouldn't cause the OOM killer but it can lead to some unexpected stalls
especially when there are a lot of writers AFAIU. dirty_bytes knob
should help to define a better cap.

> /proc/sys/vm/dirtytime_expire_seconds:43200
> /proc/sys/vm/dirty_writeback_centisecs:500
> 
> 
> Storage setup:
> 
> root@fs:~# lsscsi
> [0:2:0:0]    disk    LSI      MR9271-8iCC      3.29  /dev/sda
> [0:2:1:0]    disk    LSI      MR9271-8iCC      3.29  /dev/sdb
> [9:0:0:0]    disk    TOSHIBA  External USB 3.0 5438  /dev/sdf
> [10:0:0:0]   disk    Seagate  Backup+ Desk     050B  /dev/sdc
> [11:0:0:0]   disk    Seagate  Expansion Desk   9400  /dev/sdd
> [12:0:0:0]   disk    Seagate  Backup+ Desk     050B /dev/sde
> [13:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdg
> [14:0:0:0]   disk    TOSHIBA  External USB 3.0 5438 /dev/sdl
> [15:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdh
> [16:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdi
> [17:0:0:0]   disk    TOSHIBA  External USB 3.0 5438 /dev/sdm
> [18:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdj
> [19:0:0:0]   disk    Seagate  Expansion Desk   9400  /dev/sdk
> 
> sda is a 6x 1TB RAID5 and sdb is a single 480GB SSD, both on a MegaRAID
> controller.
> 
> The rest are 4TB USB drives that I'm experimenting with.

Which devices did you write when hitting the OOM killer?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
