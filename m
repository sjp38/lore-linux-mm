Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5C25B6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 20:37:53 -0400 (EDT)
Received: by qcbgu10 with SMTP id gu10so30075964qcb.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 17:37:53 -0700 (PDT)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [2001:4b98:c:538::196])
        by mx.google.com with ESMTPS id w19si3793850qha.85.2015.05.07.17.37.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 May 2015 17:37:52 -0700 (PDT)
Date: Thu, 7 May 2015 17:37:48 -0700
From: josh@joshtriplett.org
Subject: Re: [PATCH] devpts: If initialization failed, don't crash when
 opening /dev/ptmx
Message-ID: <20150508003748.GA1033@cloud>
References: <20150507003547.GA6862@jtriplet-mobl1>
 <20150507155919.16ab7177e4956d8f47803750@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150507155919.16ab7177e4956d8f47803750@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Iulia Manda <iulia.manda21@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Fabian Frederick <fabf@skynet.be>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, May 07, 2015 at 03:59:19PM -0700, Andrew Morton wrote:
> On Wed, 6 May 2015 17:35:47 -0700 Josh Triplett <josh@joshtriplett.org> wrote:
> 
> > If devpts failed to initialize, it would store an ERR_PTR in the global
> > devpts_mnt.  A subsequent open of /dev/ptmx would call devpts_new_index,
> > which would dereference devpts_mnt and crash.
> > 
> > Avoid storing invalid values in devpts_mnt; leave it NULL instead.
> > Make both devpts_new_index and devpts_pty_new fail gracefully with
> > ENODEV in that case, which then becomes the return value to the
> > userspace open call on /dev/ptmx.
> 
> It looks like the system is pretty crippled if init_devptr_fs() fails. 
> Can the user actually get access to consoles and do useful things in
> this situation?  Maybe it would be better to just give up and panic?

Mounting devpts doesn't work without it, but you don't *need* to do that
to run a viable system.  A full-featured terminal might be unhappy.
init=/bin/sh works, and a console login doesn't strictly require
/dev/pts.  A substantial initramfs or rescue system should work without
/dev/pts mounted.

I think this falls under Linus's comments elsewhere about BUG versus
WARN.  The system can continue and will function to some degree.
panic() is more suitable for "if I even return from this function,
horrible things will start happening".  With this patch, all the
functions provided by devpts gracefully fail if devpts did, so I don't
see a good reason to panic().

> > @@ -676,12 +689,15 @@ static int __init init_devpts_fs(void)
> >  	struct ctl_table_header *table;
> >  
> >  	if (!err) {
> > +		static struct vfsmount *mnt;
> 
> static is weird.  I assume this was a braino?

Copy/paste issue, yes.  Fixed in v2.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
