Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA15997
	for <linux-mm@kvack.org>; Thu, 6 Mar 2003 02:21:42 -0800 (PST)
Date: Thu, 6 Mar 2003 02:21:40 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.64-mm1
Message-Id: <20030306022140.7c816f32.akpm@digeo.com>
In-Reply-To: <m365qw3jcx.fsf@lexa.home.net>
References: <20030305230712.5a0ec2d4.akpm@digeo.com>
	<m365qw3jcx.fsf@lexa.home.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alex Tomas <bzzz@tmi.comex.ru>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alex Tomas <bzzz@tmi.comex.ru> wrote:
>
> 
> As far as I understand this isn't error path. 
> 
> 	lock_kernel();
> 
> 	sb = inode->i_sb;
> 
> 	if (is_dx(inode)) {
> 		err = ext3_dx_readdir(filp, dirent, filldir);
> 		if (err != ERR_BAD_DX_DIR)
> 			return err;
> 		/*
> 		 * We don't set the inode dirty flag since it's not
> 		 * critical that it get flushed back to the disk.
> 		 */
> 		EXT3_I(filp->f_dentry->d_inode)->i_flags &= ~EXT3_INDEX_FL;
> 	}
> 
> So, if ext3_dx_readdir() returns 0 (OK path), then ext3_readdir() finish
> w/o unlock_kernel(). The remain part of ext3_readdir() gets used if
> ext3_dx_readdir() can't use HTree and returns ERR_BAD_DX_DIR.
> 

hm, yes, it does look that way.

It could be that any task which travels that path ends up running under
lock_kernel() for the rest of its existence, and nobody noticed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
