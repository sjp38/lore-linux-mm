Received: from fmsmsxvs041.fm.intel.com (fmsmsxvs041.fm.intel.com [132.233.42.126])
	by mail2.hd.intel.com (8.11.6/8.11.6/d: solo.mc,v 1.42 2002/05/23 22:21:11 root Exp $) with SMTP id g72JWCt00867
	for <linux-mm@kvack.org>; Fri, 2 Aug 2002 19:32:12 GMT
Message-ID: <25282B06EFB8D31198BF00508B66D4FA03EA56C0@fmsmsx114.fm.intel.com>
From: "Seth, Rohit" <rohit.seth@intel.com>
Subject: RE: large page patch 
Date: Fri, 2 Aug 2002 12:31:58 -0700 
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: gh@us.ibm.com, riel@conectiva.com.br, akpm@zip.com.au, "Seth, Rohit" <rohit.seth@intel.com>, "Saxena, Sunil" <sunil.saxena@intel.com>, "Mallick, Asit K" <asit.k.mallick@intel.com>, "David S. Miller" <davem@redhat.com>, "'davidm@hpl.hp.com'" <davidm@hpl.hp.com>
List-ID: <linux-mm.kvack.org>

We agree that there are few different ways to get this support implemented
in base kernel.  Also, the extent to which this support needs to go is also
debatable (like whether the large_pages could be made swapable etc.)  Just
to give little history, we also started with prototyping changes in kernel
that would get the large page support transparent to end user (as we wanted
to see the benefit of large apps like databases, spec benchmark and HPC
applications using different page sizes on IA-64).  And under some
conditions automagically user start using large pages for shm and private
anonymous pages.  But we would call this at best a kludge because there are
quite a number of conditions in these execution paths that one has to do
differently for large_pages.  For example,
make_pages_present/handle_mm_fault for anonymous or shmem type of pages need
to be modified to embed the knowledge of different page size in generic
kernel. Also, there are places where semantics of changes may not completely
match.  For example, doing a shm_lock/unlock on these segments were not
exactly doing the expected.  All those extra changes add cost in the normal
execution path (severity could differ from app to app). 

So, we needed to treat the large pages as a special case and want to make
sure that the application that will be using the large pages understand that
these pages are special (avoid transperent usage model until the large pages
are treated the same way as normal pages). This led to cleaner solution
(input for which also came from Linus himself).  The new APIs enable the
kernel to contain the changes to be architecture specific and limited to
very few kernel changes.  And above all it looks so much portable. Fact is,
the initial implementation was done for IA-64 and porting to x86 took couple
of hours. One of the other key advantage is that this design does not tie
the supported large_page size(s) to any specific size in the generic mm
code.  It supports all the underlying architecture supported page sizes
quite independent of generic code.  And architecture dependent code could
support multiple large_page sizes in the same kernel.

We presented our work to Oracle and they were acceptable to the new APIs
(not saying Oracle is the only DB in world that one has to worry about, but
it clearly indicates that the move from shm apis to this new APIs is easy.
Obviously the input from other big app vendors will be highly appreciated.).


Sceintific apps people who have the sources should also like this approach,
as there changes will be even more trivial (changes to malloc).  And above
all, for those people who really want to get this extra buck transparently,
the changes could be done to user land libraries to selectively map to these
new APIs.  LD_PRELOAD could be another way to do.  Ofcourse, there will be
changes that need to be done in user land.  But they are self contained
changes.  And one of the key point is that application knows what it is
demanding/getting form kernel.

Now to the point where the large_pages themselves could be made swapable. In
our opinion (and this may not be this API dependent), it is not a good idea
to look at these pages as swapable candidates.  Most of the big apps who are
going to use this feature will use them for the data that they really need
available all the time (prefereably in RAM if not on caches :-)).  And the
sysadm could easily configure the amount of large mem pool as per the needs
for a specific environment.

To the point where the whole kernel starts supporting (as David Mosberger
refered) superpages where support is built in kernel to basically treat
superpages as just another size the whole kernel supports will be great too.
But those need quite a lot of exhaustive changes in kernel layers as weill
as lot of tuning.....may be a little further away in future.

thanks,
asit & rohit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
