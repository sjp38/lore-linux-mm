Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 495DE6B650F
	for <linux-mm@kvack.org>; Sun,  2 Sep 2018 20:36:40 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l125-v6so930329pga.1
        for <linux-mm@kvack.org>; Sun, 02 Sep 2018 17:36:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u28-v6sor3804709pgn.114.2018.09.02.17.36.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Sep 2018 17:36:39 -0700 (PDT)
From: Rashmica <rashmica.g@gmail.com>
Subject: [PATCH RFCv2 3/6] mm/memory_hotplug: fix online/offline_pages called
 w.o. mem_hotplug_lock
References: <20180821104418.12710-1-david@redhat.com>
 <20180821104418.12710-4-david@redhat.com>
Message-ID: <70372ef5-e332-6c07-f08c-50f8808bde6d@gmail.com>
Date: Mon, 3 Sep 2018 10:36:24 +1000
MIME-Version: 1.0
In-Reply-To: <20180821104418.12710-4-david@redhat.com>
Content-Type: multipart/alternative;
 boundary="------------1093E43F969F497286F217F7"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Michael Neuling <mikey@neuling.org>, Balbir Singh <bsingharora@gmail.com>, Kate Stewart <kstewart@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>

This is a multi-part message in MIME format.
--------------1093E43F969F497286F217F7
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi David,


On 21/08/18 20:44, David Hildenbrand wrote:

> There seem to be some problems as result of 30467e0b3be ("mm, hotplug:
> fix concurrent memory hot-add deadlock"), which tried to fix a possible
> lock inversion reported and discussed in [1] due to the two locks
> 	a) device_lock()
> 	b) mem_hotplug_lock
>
> While add_memory() first takes b), followed by a) during
> bus_probe_device(), onlining of memory from user space first took b),
> followed by a), exposing a possible deadlock.

Do you mean "onlining of memory from user space first took a),
followed by b)"? 

> In [1], and it was decided to not make use of device_hotplug_lock, but
> rather to enforce a locking order.
>
> The problems I spotted related to this:
>
> 1. Memory block device attributes: While .state first calls
>    mem_hotplug_begin() and the calls device_online() - which takes
>    device_lock() - .online does no longer call mem_hotplug_begin(), so
>    effectively calls online_pages() without mem_hotplug_lock.
>
> 2. device_online() should be called under device_hotplug_lock, however
>    onlining memory during add_memory() does not take care of that.
>
> In addition, I think there is also something wrong about the locking in
>
> 3. arch/powerpc/platforms/powernv/memtrace.c calls offline_pages()
>    without locks. This was introduced after 30467e0b3be. And skimming over
>    the code, I assume it could need some more care in regards to locking
>    (e.g. device_online() called without device_hotplug_lock - but I'll
>    not touch that for now).

Can you mention that you fixed this in later patches?


The series looks good to me. Feel free to add my reviewed-by:

Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>


--------------1093E43F969F497286F217F7
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">
      <pre>Hi David,


On 21/08/18 20:44, David Hildenbrand wrote:</pre>
    </div>
    <blockquote type="cite"
      cite="mid:20180821104418.12710-4-david@redhat.com">
      <pre wrap="">There seem to be some problems as result of 30467e0b3be ("mm, hotplug:
fix concurrent memory hot-add deadlock"), which tried to fix a possible
lock inversion reported and discussed in [1] due to the two locks
	a) device_lock()
	b) mem_hotplug_lock

While add_memory() first takes b), followed by a) during
bus_probe_device(), onlining of memory from user space first took b),
followed by a), exposing a possible deadlock.</pre>
    </blockquote>
    <pre>Do you mean "onlining of memory from user space first took a),
followed by b)"? 

</pre>
    <blockquote type="cite"
      cite="mid:20180821104418.12710-4-david@redhat.com">
      <pre wrap="">
In [1], and it was decided to not make use of device_hotplug_lock, but
rather to enforce a locking order.

The problems I spotted related to this:

1. Memory block device attributes: While .state first calls
   mem_hotplug_begin() and the calls device_online() - which takes
   device_lock() - .online does no longer call mem_hotplug_begin(), so
   effectively calls online_pages() without mem_hotplug_lock.

2. device_online() should be called under device_hotplug_lock, however
   onlining memory during add_memory() does not take care of that.

In addition, I think there is also something wrong about the locking in

3. arch/powerpc/platforms/powernv/memtrace.c calls offline_pages()
   without locks. This was introduced after 30467e0b3be. And skimming over
   the code, I assume it could need some more care in regards to locking
   (e.g. device_online() called without device_hotplug_lock - but I'll
   not touch that for now).</pre>
    </blockquote>
    <pre>Can you mention that you fixed this in later patches?

</pre>
    <br>
    <pre>The series looks good to me. Feel free to add my reviewed-by:

Reviewed-by: Rashmica Gupta <a class="moz-txt-link-rfc2396E" href="mailto:rashmica.g@gmail.com">&lt;rashmica.g@gmail.com&gt;</a></pre>
  </body>
</html>

--------------1093E43F969F497286F217F7--
