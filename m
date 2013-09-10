Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id A41CF6B0031
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 01:43:25 -0400 (EDT)
Date: Tue, 10 Sep 2013 14:43:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [REPOST PATCH 3/4] slab: introduce byte sized index for the
 freelist of a slab
Message-ID: <20130910054342.GB24602@lge.com>
References: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1378447067-19832-4-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140f3fed229-f49b95d4-7087-476f-b2c9-37846749aad6-000000@email.amazonses.com>
 <20130909043217.GB22390@lge.com>
 <00000141032dea11-c5aa9c77-b2f2-4cab-b7a0-d37665a6cec8-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000141032dea11-c5aa9c77-b2f2-4cab-b7a0-d37665a6cec8-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 09, 2013 at 02:44:03PM +0000, Christoph Lameter wrote:
> On Mon, 9 Sep 2013, Joonsoo Kim wrote:
> 
> > 32 byte is not minimum object size, minimum *kmalloc* object size
> > in default configuration. There are some slabs that their object size is
> > less than 32 byte. If we have a 8 byte sized kmem_cache, it has 512 objects
> > in 4K page.
> 
> As far as I can recall only SLUB supports 8 byte objects. SLABs mininum
> has always been 32 bytes.

No.
There are many slabs that their object size are less than 32 byte.
And I can also create a 8 byte sized slab in my kernel with SLAB.

js1304@js1304-P5Q-DELUXE:~/Projects/remote_git/linux$ sudo cat /proc/slabinfo | awk '{if($4 < 32) print $0}'
slabinfo - version: 2.1
ecryptfs_file_cache      0      0     16  240    1 : tunables  120   60    8 : slabdata      0      0      0
jbd2_revoke_table_s      2    240     16  240    1 : tunables  120   60    8 : slabdata      1      1      0
journal_handle         0      0     24  163    1 : tunables  120   60    8 : slabdata      0      0      0
revoke_table           0      0     16  240    1 : tunables  120   60    8 : slabdata      0      0      0
scsi_data_buffer       0      0     24  163    1 : tunables  120   60    8 : slabdata      0      0      0
fsnotify_event_holder      0      0     24  163    1 : tunables  120   60    8 : slabdata      0      0      0
numa_policy            3    163     24  163    1 : tunables  120   60    8 : slabdata      1      1      0

> 
> > Moreover, we can configure slab_max_order in boot time so that we can't know
> > how many object are in a certain slab in compile time. Therefore we can't
> > decide the size of the index in compile time.
> 
> You can ignore the slab_max_order if necessary.
> 
> > I think that byte and short int sized index support would be enough, but
> > it should be determined at runtime.
> 
> On x86 f.e. it would add useless branching. The branches are never taken.
> You only need these if you do bad things to the system like requiring
> large contiguous allocs.

As I said before, since there is a possibility that some runtime loaded modules
use a 8 byte sized slab, we can't determine index size in compile time. Otherwise
we should always use short int sized index and I think that it is worse than
adding a branch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
