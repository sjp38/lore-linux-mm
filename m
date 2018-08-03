Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8496B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 06:59:42 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 22-v6so871656ita.3
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 03:59:42 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30123.outbound.protection.outlook.com. [40.107.3.123])
        by mx.google.com with ESMTPS id 3-v6si3093856iov.79.2018.08.03.03.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Aug 2018 03:59:41 -0700 (PDT)
Subject: Re: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to
 do_shrink_slab()
References: <47c34fad-5d11-53b0-4386-61be890163c5@virtuozzo.com>
 <153320759911.18959.8842396230157677671.stgit@localhost.localdomain>
 <20180802134723.ecdd540c7c9338f98ee1a2c6@linux-foundation.org>
 <8347.1533292272@warthog.procyon.org.uk>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <5250d5c0-0d26-260e-dc39-227b8e355a1b@virtuozzo.com>
Date: Fri, 3 Aug 2018 13:59:32 +0300
MIME-Version: 1.0
In-Reply-To: <8347.1533292272@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, willy@infradead.org, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org

On 03.08.2018 13:31, David Howells wrote:
> The reproducer can be reduced to:
> 
> 	#define _GNU_SOURCE
> 	#include <endian.h>
> 	#include <stdint.h>
> 	#include <string.h>
> 	#include <stdio.h>
> 	#include <sys/syscall.h>
> 	#include <sys/stat.h>
> 	#include <sys/mount.h>
> 	#include <unistd.h>
> 	#include <fcntl.h>
> 
> 	const char path[] = "./file0";
> 
> 	int main()
> 	{
> 		mkdir(path, 0);
> 		mount(path, path, "cgroup2", 0, 0);
> 		chroot(path);
> 		umount2(path, 0);
> 		return 0;
> 	}
> 
> and I've found two bugs (see attached patch).  The issue is that
> do_remount_sb() is called with fc == NULL from umount(), but both
> cgroup_reconfigure() and do_remount_sb() dereference fc unconditionally.
>
> But!  I'm not sure why the reproducer works at all because the umount2() call
> is *after* the chroot, so should fail on ENOENT before it even gets that far.
> In fact, umount2() can be called multiple times, apparently successfully, and
> doesn't actually unmount anything.

Before I also try to check why it works; just reporting you that the patch
works the problem in my environment. Thanks, David.

> ---
> diff --git a/fs/super.c b/fs/super.c
> index 3fe5d12b7697..321fbc244570 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -978,7 +978,10 @@ int do_remount_sb(struct super_block *sb, int sb_flags, void *data,
>  	    sb->s_op->remount_fs) {
>  		if (sb->s_op->reconfigure) {
>  			retval = sb->s_op->reconfigure(sb, fc);
> -			sb_flags = fc->sb_flags;
> +			if (fc)
> +				sb_flags = fc->sb_flags;
> +			else
> +				sb_flags = sb->s_flags;
>  			if (retval == 0)
>  				security_sb_reconfigure(fc);
>  		} else {
> diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
> index f3238f38d152..48275fdce053 100644
> --- a/kernel/cgroup/cgroup.c
> +++ b/kernel/cgroup/cgroup.c
> @@ -1796,9 +1796,11 @@ static void apply_cgroup_root_flags(unsigned int root_flags)
>  
>  static int cgroup_reconfigure(struct kernfs_root *kf_root, struct fs_context *fc)
>  {
> -	struct cgroup_fs_context *ctx = cgroup_fc2context(fc);
> +	if (fc) {
> +		struct cgroup_fs_context *ctx = cgroup_fc2context(fc);
>  
> -	apply_cgroup_root_flags(ctx->flags);
> +		apply_cgroup_root_flags(ctx->flags);
> +	}
>  	return 0;
>  }
>  
> 
