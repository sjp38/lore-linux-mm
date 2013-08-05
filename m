Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id A6F4B6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 17:44:26 -0400 (EDT)
Date: Tue, 6 Aug 2013 01:41:35 +0400
From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [PATCH] memcg: don't initialize kmem-cache destroying work for
 root caches
Message-ID: <20130805214135.GA4958@paralelels.com>
References: <1375718980-22154-1-git-send-email-avagin@openvz.org>
 <20130805130530.fd38ec4866ba7f1d9a400218@linux-foundation.org>
 <20130805210128.GA2772@paralelels.com>
 <20130805141609.777a0d6dee55091f6981c39b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Content-Disposition: inline
In-Reply-To: <20130805141609.777a0d6dee55091f6981c39b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Vagin <avagin@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, stable@vger.kernel.org

On Mon, Aug 05, 2013 at 02:16:09PM -0700, Andrew Morton wrote:
> On Tue, 6 Aug 2013 01:01:28 +0400 Andrew Vagin <avagin@parallels.com> wrote:
> 
> > On Mon, Aug 05, 2013 at 01:05:30PM -0700, Andrew Morton wrote:
> > > On Mon,  5 Aug 2013 20:09:40 +0400 Andrey Vagin <avagin@openvz.org> wrote:
> > > 
> > > > struct memcg_cache_params has a union. Different parts of this union
> > > > are used for root and non-root caches. A part with destroying work is
> > > > used only for non-root caches.
> > > > 
> > > > I fixed the same problem in another place v3.9-rc1-16204-gf101a94, but
> > > > didn't notice this one.
> > > > 
> > > > Cc: <stable@vger.kernel.org>    [3.9.x]
> > > 
> > > hm, why the cc:stable?
> > 
> > Because this patch fixes the kernel panic:
> > 
> > [   46.848187] BUG: unable to handle kernel paging request at 000000fffffffeb8
> > [   46.849026] IP: [<ffffffff811a484c>] kmem_cache_destroy_memcg_children+0x6c/0xc0
> > [   46.849092] PGD 0
> > [   46.849092] Oops: 0000 [#1] SMP
> 
> OK, pretty soon we'll have a changelog!

Sorry, probably I had to write all these in the initial commit message. I
just thought that this patch is an additional part of v3.9-rc1-16204-gf101a94.

> 
> What does one do to trigger this oops?  The bug has been there since
> 3.9, so the means-of-triggering must be quite special?

I don't think that so many people use cgroups with limits of the kernel memory.

I use the vzctl utility to operate with containers. vzctl limits the
kernel memory of containers by default. A container should be started
and stoped a few times (five or four) to reproduce the bug.

And one more thing is that nf_conntrack should be loaded. It creates
a new kmem_cache for each network namespace.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
