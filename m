Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C73D66B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 18:59:21 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so53660306pdb.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 15:59:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n10si4502101pby.224.2015.05.07.15.59.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 15:59:21 -0700 (PDT)
Date: Thu, 7 May 2015 15:59:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] devpts: If initialization failed, don't crash when
 opening /dev/ptmx
Message-Id: <20150507155919.16ab7177e4956d8f47803750@linux-foundation.org>
In-Reply-To: <20150507003547.GA6862@jtriplet-mobl1>
References: <20150507003547.GA6862@jtriplet-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Iulia Manda <iulia.manda21@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Fabian Frederick <fabf@skynet.be>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Wed, 6 May 2015 17:35:47 -0700 Josh Triplett <josh@joshtriplett.org> wrote:

> If devpts failed to initialize, it would store an ERR_PTR in the global
> devpts_mnt.  A subsequent open of /dev/ptmx would call devpts_new_index,
> which would dereference devpts_mnt and crash.
> 
> Avoid storing invalid values in devpts_mnt; leave it NULL instead.
> Make both devpts_new_index and devpts_pty_new fail gracefully with
> ENODEV in that case, which then becomes the return value to the
> userspace open call on /dev/ptmx.

It looks like the system is pretty crippled if init_devptr_fs() fails. 
Can the user actually get access to consoles and do useful things in
this situation?  Maybe it would be better to just give up and panic?

> @@ -676,12 +689,15 @@ static int __init init_devpts_fs(void)
>  	struct ctl_table_header *table;
>  
>  	if (!err) {
> +		static struct vfsmount *mnt;

static is weird.  I assume this was a braino?

>  		table = register_sysctl_table(pty_root_table);
> -		devpts_mnt = kern_mount(&devpts_fs_type);
> -		if (IS_ERR(devpts_mnt)) {
> -			err = PTR_ERR(devpts_mnt);
> +		mnt = kern_mount(&devpts_fs_type);
> +		if (IS_ERR(mnt)) {
> +			err = PTR_ERR(mnt);
>  			unregister_filesystem(&devpts_fs_type);
>  			unregister_sysctl_table(table);
> +		} else {
> +			devpts_mnt = mnt;
>  		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
