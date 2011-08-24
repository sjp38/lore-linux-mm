Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C63F86B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 03:19:00 -0400 (EDT)
Received: by gyg10 with SMTP id 10so788055gyg.14
        for <linux-mm@kvack.org>; Wed, 24 Aug 2011 00:18:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1107281215550.14640@nsl-11>
References: <alpine.DEB.2.00.1107281215550.14640@nsl-11>
From: Greg Freemyer <greg.freemyer@gmail.com>
Date: Wed, 24 Aug 2011 03:18:25 -0400
Message-ID: <CAGpXXZJwL1R9RFFu4kQfkVA1eu=2FoS0Mrvag0PSw=2_1zSipw@mail.gmail.com>
Subject: Re: What does drop_caches do?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prateek Sharma <prateeks@cse.iitb.ac.in>
Cc: linux-mm@kvack.org, kernelnewbies@kernelnewbies.org

On Thu, Jul 28, 2011 at 2:58 AM, Prateek Sharma <prateeks@cse.iitb.ac.in> w=
rote:
> Hello everyone,
> =A0 =A0 =A0 =A0I've been trying to understand the role of the pagecache, =
starting with
> drop_caches and observing what it does.
> =A0 =A0 =A0 =A0From my understanding of the code (fs/drop_caches.c) , it =
walks over all
> the open files/inodes, and invalidates all the mapped pages.

Stepping up a little, I think you're missing
drop_caches_sysctl_handler() in that same file.  It is the entry point
I believe that implements the userspace ABI defined in
Documentation/sysctl/vm.txt.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
 139
 140drop_caches
 141
 142Writing to this will cause the kernel to drop clean caches, dentries an=
d
 143inodes from memory, causing that memory to become free.
 144
 145To free pagecache:
 146        echo 1 > /proc/sys/vm/drop_caches
 147To free dentries and inodes:
 148        echo 2 > /proc/sys/vm/drop_caches
 149To free pagecache, dentries and inodes:
 150        echo 3 > /proc/sys/vm/drop_caches
 151
 152As this is a non-destructive operation and dirty objects are not
freeable, the
 153user should run `sync' first.
 154
 155=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Note the corresponding logic in /fs/drop_caches.c that implements the
above binary logic.


  61              if (sysctl_drop_caches & 1)
  62                        iterate_supers(drop_pagecache_sb, NULL);
  63                if (sysctl_drop_caches & 2)
  64                        drop_slab();

Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
