Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2D97382F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 15:05:52 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ho8so98883819pac.2
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 12:05:52 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id qz9si23115581pab.94.2016.02.22.12.05.50
        for <linux-mm@kvack.org>;
        Mon, 22 Feb 2016 12:05:51 -0800 (PST)
From: "Rudoff, Andy" <andy.rudoff@intel.com>
Subject: RE: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Date: Mon, 22 Feb 2016 20:05:44 +0000
Message-ID: <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
References: <56C9EDCF.8010007@plexistor.com>
 <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
 <56CA1CE7.6050309@plexistor.com>
 <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
 <20160222174426.GA30110@infradead.org>
In-Reply-To: <20160222174426.GA30110@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

>> This is surprising to me, and goes completely against the proposed=20
>> programming model.  In fact, this is a very basic tenet of the=20
>> operation of the nvml libraries on pmem.io.
>
>It's simply impossible to provide.  But then again pmem.io seems to be muc=
h more about hype than reality anyway.

Well that comment woke me up :-)

I think several things are getting mixed together in this discussion:

First, one primary reason DAX exists is so that applications can access per=
sistence directly.  Once mappings are set up, latency-sensitive apps get lo=
ad/store access and can flush stores themselves using instructions rather t=
han kernel calls.

Second, programming to load/store persistence is tricky, but the usual API =
for programming to memory-mapped files will "just work" and we built on tha=
t to avoid needlessly creating new permission & naming models.  If you want=
 to use msync() or fsync(), it will work, but may not perform as well as us=
ing the instructions.  The instructions give you very fine-grain flushing c=
ontrol, but the downside is that the app must track what it changes at that=
 fine granularity.  Both models work, but there's a trade-off.

So what can be done to make persistent memory easier to use?  I think this =
is where the debate really is.  Using memory-mapped files and the instructi=
ons directly is difficult.  The libraries available on pmem.io are meant to=
 make it easier (providing transactions, memory allocation, etc) but it is =
still difficult.  But what about just taking applications that use mmap() a=
nd giving them DAX without their knowledge?  Is that a way to leverage pmem=
 more easily, without forcing an application to change?  I think this is an=
alogous to forcing O_DIRECT on applications without their knowledge.  There=
 may be cases where it works, but there will always be better leverage of t=
he technology if the application is architected to use it.

There are applications already modified to use DAX for pmem and to flush st=
ores themselves (using NVDIMMs for testing, but planning for the higher-cap=
acity pmem to become available).  Some are using the libraries on pmem.io, =
some are not.  Those are pmem-aware applications and I haven't seen any inc=
orrect expectations on what happens with copy-on-write or page faults that =
fill in holes in a file.  Maybe there's a case to be made for applications =
getting DAX transparently, but I think that's not the only usage and the mo=
del we've been pushing where an application is pmem aware seems to be getti=
ng traction.

-andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
