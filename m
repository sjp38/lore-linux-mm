Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5B76B0584
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 22:06:04 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id w10-v6so16369855plz.0
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 19:06:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c7-v6si2876728pfc.153.2018.11.07.19.06.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 19:06:02 -0800 (PST)
Date: Wed, 7 Nov 2018 19:05:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [LKP] d50d82faa0 [ 33.671845] WARNING: possible circular
 locking dependency detected
Message-Id: <20181107190558.812375161de4b5df413ea31b@linux-foundation.org>
In-Reply-To: <20181107154336.21e1f815226facdffd4a6c54@linux-foundation.org>
References: <20181023003004.GH24195@shao2-debian>
	<20181107154336.21e1f815226facdffd4a6c54@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <rong.a.chen@intel.com>, Mikulas Patocka <mpatocka@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>

On Wed, 7 Nov 2018 15:43:36 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 23 Oct 2018 08:30:04 +0800 kernel test robot <rong.a.chen@intel.com> wrote:
> 
> > Greetings,
> > 
> > 0day kernel testing robot got the below dmesg and the first bad commit is
> > 
> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > 
> > commit d50d82faa0c964e31f7a946ba8aba7c715ca7ab0
> > Author:     Mikulas Patocka <mpatocka@redhat.com>
> > AuthorDate: Wed Jun 27 23:26:09 2018 -0700
> > Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> > CommitDate: Thu Jun 28 11:16:44 2018 -0700
> > 
> >     slub: fix failure when we delete and create a slab cache
> 
> This is ugly.  Is there an alternative way of fixing the race which
> Mikulas attempted to address?  Possibly cancel the work and reuse the
> existing sysfs file, or is that too stupid to live?
> 
> 3b7b314053d021 ("slub: make sysfs file removal asynchronous") was
> pretty lame, really.  As mentioned,
> 
> : It'd be the cleanest to deal with the issue by removing sysfs files
> : without holding slab_mutex before the rest of shutdown; however, given
> : the current code structure, it is pretty difficult to do so.
> 
> Would be a preferable approach.
> 
> >     
> >     This uncovered a bug in the slub subsystem - if we delete a cache and
> >     immediatelly create another cache with the same attributes, it fails
> >     because of duplicate filename in /sys/kernel/slab/.  The slub subsystem
> >     offloads freeing the cache to a workqueue - and if we create the new
> >     cache before the workqueue runs, it complains because of duplicate
> >     filename in sysfs.

Alternatively, could we flush the workqueue before attempting to
(re)create the sysfs file?  Extra points for only doing this if the
first (re)creation attempt returned -EEXIST?
