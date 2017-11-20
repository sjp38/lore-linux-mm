Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6D996B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:13:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id c123so10075065pga.17
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 09:13:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k82si9612011pfg.374.2017.11.20.09.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 09:13:27 -0800 (PST)
Subject: Re: [mmotm:master 284/303] fs/cramfs/inode.c:959: undefined reference
 to `mount_mtd'
References: <201711201654.k3ucIYK5%fengguang.wu@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <7659cc74-6600-cef0-916b-6fc21649b4fe@infradead.org>
Date: Mon, 20 Nov 2017 09:13:22 -0800
MIME-Version: 1.0
In-Reply-To: <201711201654.k3ucIYK5%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Davidlohr Bueso <dave@stgolabs.net>, Johannes Weiner <hannes@cmpxchg.org>, Nicolas Pitre <nico@linaro.org>

On 11/20/2017 12:25 AM, kbuild test robot wrote:
> Hi Andrew,
> 
> It's probably a bug fix that unveils the link errors.
> 
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   21c4efa7694b072dddce68082e16156f24e1c1f0
> commit: 6f06b543d9c12d8dc7f90e7a8f548df330bc8e4b [284/303] linux-next-git-rejects
> config: i386-randconfig-x002-11201231 (attached as .config)
> compiler: gcc-6 (Debian 6.4.0-9) 6.4.0 20171026
> reproduce:
>         git checkout 6f06b543d9c12d8dc7f90e7a8f548df330bc8e4b
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    fs/cramfs/inode.o: In function `cramfs_mount':
>>> fs/cramfs/inode.c:959: undefined reference to `mount_mtd'
>    fs/cramfs/inode.o: In function `cramfs_mtd_fill_super':
>>> fs/cramfs/inode.c:641: undefined reference to `mtd_point'
>>> fs/cramfs/inode.c:658: undefined reference to `mtd_unpoint'
>    fs/cramfs/inode.c:659: undefined reference to `mtd_point'

Nicolas Pitre already has a patch for this.


> vim +959 fs/cramfs/inode.c
> 
> ^1da177e4 Linus Torvalds 2005-04-16  952  
> 934e54502 Andrew Morton  2017-11-11  953  static struct dentry *cramfs_mount(struct file_system_type *fs_type, int flags,
> 934e54502 Andrew Morton  2017-11-11  954  				   const char *dev_name, void *data)
> ^1da177e4 Linus Torvalds 2005-04-16  955  {
> 934e54502 Andrew Morton  2017-11-11  956  	struct dentry *ret = ERR_PTR(-ENOPROTOOPT);
> 934e54502 Andrew Morton  2017-11-11  957  
> 934e54502 Andrew Morton  2017-11-11  958  	if (IS_ENABLED(CONFIG_CRAMFS_MTD)) {
> 934e54502 Andrew Morton  2017-11-11 @959  		ret = mount_mtd(fs_type, flags, dev_name, data,
> 934e54502 Andrew Morton  2017-11-11  960  				cramfs_mtd_fill_super);
> 934e54502 Andrew Morton  2017-11-11  961  		if (!IS_ERR(ret))
> 934e54502 Andrew Morton  2017-11-11  962  			return ret;
> 934e54502 Andrew Morton  2017-11-11  963  	}
> 934e54502 Andrew Morton  2017-11-11  964  	if (IS_ENABLED(CONFIG_CRAMFS_BLOCKDEV)) {
> 934e54502 Andrew Morton  2017-11-11  965  		ret = mount_bdev(fs_type, flags, dev_name, data,
> 934e54502 Andrew Morton  2017-11-11  966  				 cramfs_blkdev_fill_super);
> 934e54502 Andrew Morton  2017-11-11  967  	}
> 934e54502 Andrew Morton  2017-11-11  968  	return ret;
> ^1da177e4 Linus Torvalds 2005-04-16  969  }
> ^1da177e4 Linus Torvalds 2005-04-16  970  
> 
> :::::: The code at line 959 was first introduced by commit
> :::::: 934e54502aed49ec17d662a6bb35dfe79044fa4b linux-next
> 
> :::::: TO: Andrew Morton <akpm@linux-foundation.org>
> :::::: CC: Johannes Weiner <hannes@cmpxchg.org>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
