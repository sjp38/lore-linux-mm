Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D12EF6B0288
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 09:29:25 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id w185so24476407qka.9
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 06:29:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q45si621256qte.344.2018.11.12.06.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 06:29:25 -0800 (PST)
Date: Mon, 12 Nov 2018 09:29:20 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [LKP] d50d82faa0 [ 33.671845] WARNING: possible circular locking
 dependency detected
In-Reply-To: <20181107190558.812375161de4b5df413ea31b@linux-foundation.org>
Message-ID: <alpine.LRH.2.02.1811120926240.3272@file01.intranet.prod.int.rdu2.redhat.com>
References: <20181023003004.GH24195@shao2-debian> <20181107154336.21e1f815226facdffd4a6c54@linux-foundation.org> <20181107190558.812375161de4b5df413ea31b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel test robot <rong.a.chen@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>



On Wed, 7 Nov 2018, Andrew Morton wrote:

> On Wed, 7 Nov 2018 15:43:36 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Tue, 23 Oct 2018 08:30:04 +0800 kernel test robot <rong.a.chen@intel.com> wrote:
> > 
> > > Greetings,
> > > 
> > > 0day kernel testing robot got the below dmesg and the first bad commit is
> > > 
> > > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > > 
> > > commit d50d82faa0c964e31f7a946ba8aba7c715ca7ab0
> > > Author:     Mikulas Patocka <mpatocka@redhat.com>
> > > AuthorDate: Wed Jun 27 23:26:09 2018 -0700
> > > Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> > > CommitDate: Thu Jun 28 11:16:44 2018 -0700
> > > 
> > >     slub: fix failure when we delete and create a slab cache
> > 
> > This is ugly.  Is there an alternative way of fixing the race which
> > Mikulas attempted to address?  Possibly cancel the work and reuse the
> > existing sysfs file, or is that too stupid to live?
> > 
> > 3b7b314053d021 ("slub: make sysfs file removal asynchronous") was
> > pretty lame, really.  As mentioned,
> > 
> > : It'd be the cleanest to deal with the issue by removing sysfs files
> > : without holding slab_mutex before the rest of shutdown; however, given
> > : the current code structure, it is pretty difficult to do so.
> > 
> > Would be a preferable approach.
> > 
> > >     
> > >     This uncovered a bug in the slub subsystem - if we delete a cache and
> > >     immediatelly create another cache with the same attributes, it fails
> > >     because of duplicate filename in /sys/kernel/slab/.  The slub subsystem
> > >     offloads freeing the cache to a workqueue - and if we create the new
> > >     cache before the workqueue runs, it complains because of duplicate
> > >     filename in sysfs.
> 
> Alternatively, could we flush the workqueue before attempting to
> (re)create the sysfs file?

What if someone creates the slab cache from the workqueue?

> Extra points for only doing this if the
> first (re)creation attempt returned -EEXIST?

If it returns -EEXIST, it has already written the warning to the log.

Mikulas
