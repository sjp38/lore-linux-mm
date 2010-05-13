Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 52D526B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 17:59:07 -0400 (EDT)
Subject: Re: [PATCH 0/9] mm: generic adaptive large memory allocation APIs
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <andreas.dilger@oracle.com>
In-Reply-To: <1273763055.4353.136.camel@mulgrave.site>
Date: Thu, 13 May 2010 15:56:43 -0600
Content-Transfer-Encoding: quoted-printable
Message-Id: <7280ADBE-F4BF-43B4-8BAC-5BF129C9DDB3@oracle.com>
References: <1273744147-7594-1-git-send-email-xiaosuo@gmail.com> <1273763055.4353.136.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@suse.de>
Cc: Changli Gao <xiaosuo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Hoang-Nam Nguyen <hnguyen@de.ibm.com>, Christoph Raisch <raisch@de.ibm.com>, Roland Dreier <rolandd@cisco.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Divy Le Ray <divy@chelsio.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-rdma@vger.kernel.org, "linux-kernel@vger.kernel.org Mailinglist" <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, "linux-ext4@vger.kernel.org development" <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 2010-05-13, at 09:04, James Bottomley wrote:
> This isn't necessarily true ... most drivers and filesystems have to
> know what type they're getting.  Often they have to do extra tricks to
> process vmalloc areas.  Conversely, large kmalloc areas are a very
> precious commodity: if a driver or filesystem can handle vmalloc for
> large allocations, it should: it's easier for us to expand the vmalloc
> area than to try to make page reclaim keep large contiguous areas ... =
I
> notice your proposed API does the exact opposite of this ... tries
> kmalloc first and then does vmalloc.
>=20
> Given this policy problem, isn't it easier simply to hand craft the
> vmalloc fall back to kmalloc (or vice versa) in the driver than add =
this
> whole massive raft of APIs for it?

I know we wouldn't mind using large vmalloc allocations for e.g. =
per-group arrays in ext4 (allocated once per mount), but I'd always =
understood that using vmalloc for general purpose uses can have a =
significant impact because the vmalloc() engine has (had?) serious =
performance problems.  That means it is better performance-wise to have =
a wrapper function like this to switch between kmalloc() and vmalloc() =
based on the allocation size, but it makes the code ugly.  Having the =
wrapper in the kernel would at least identify the different places that =
are using this kind of workaround.

If the performance of vmalloc() has been improved in the last few years, =
then I'd be happy to just use vmalloc() all the time.  That said, =
vmalloc still isn't suitable for sub-page allocations, so if you have a =
variable-sized allocation that may be very small or very large the small =
allocations will waste a whole page and a wrapper is still needed, or =
vmalloc should be changed to call kmalloc/kfree for the sub-page =
allocations.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
