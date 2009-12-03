Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 05553600762
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 18:24:47 -0500 (EST)
Subject: Re: [RFC PATCH 4/6] networking: rework socket to fd mapping using
 alloc-file
From: Eric Paris <eparis@redhat.com>
In-Reply-To: <20091203.140045.67902314.davem@davemloft.net>
References: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com>
	 <20091203195917.8925.84203.stgit@paris.rdu.redhat.com>
	 <20091203.140045.67902314.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Dec 2009 18:24:30 -0500
Message-Id: <1259882670.2670.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-12-03 at 14:00 -0800, David Miller wrote:
> From: Eric Paris <eparis@redhat.com>
> Date: Thu, 03 Dec 2009 14:59:17 -0500
> 
> > Currently the networking code does interesting things allocating its struct
> > file and file descriptors.  This patch attempts to unify all of that and
> > simplify the error paths.  It is also a part of my patch series trying to get
> > rid of init-file and get-empty_filp and friends.
> > 
> > Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> I'm fine with this:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

It's actually busted, I forgot to actually pass back the new file in
sock_alloc_fd().  But I've got a fixed version and will resend the
series once I see other comments....

inc diff below in case anyone is trying to test this series.

diff --git a/net/socket.c b/net/socket.c
index 41ac0b1..6620421 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -390,6 +390,7 @@ static int sock_alloc_fd(struct file **filep, struct
socket *sock, int flags)
                goto out_err;
        }
 
+       *filep = file;
        sock->file = file;
        SOCK_INODE(sock)->i_fop = &socket_file_ops;
        file->f_flags = O_RDWR | (flags & O_NONBLOCK);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
