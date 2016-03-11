Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 70DF36B025C
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:05:14 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l68so7164933wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 00:05:14 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id wl1si9590932wjc.217.2016.03.11.00.05.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 00:05:13 -0800 (PST)
Date: Fri, 11 Mar 2016 08:05:03 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v1 03/19] fs/anon_inodes: new interface to create new
 inode
Message-ID: <20160311080503.GR17997@ZenIV.linux.org.uk>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457681423-26664-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On Fri, Mar 11, 2016 at 04:30:07PM +0900, Minchan Kim wrote:
> From: Gioh Kim <gurugio@hanmail.net>
> 
> The anon_inodes has already complete interfaces to create manage
> many anonymous inodes but don't have interface to get
> new inode. Other sub-modules can create anonymous inode
> without creating and mounting it's own pseudo filesystem.

IMO that's a bad idea.  In case of aio "creating and mounting" takes this:
static struct dentry *aio_mount(struct file_system_type *fs_type,
                                int flags, const char *dev_name, void *data)  
{
        static const struct dentry_operations ops = {
                .d_dname        = simple_dname,
        };
        return mount_pseudo(fs_type, "aio:", NULL, &ops, AIO_RING_MAGIC);
}
and
        static struct file_system_type aio_fs = {
                .name           = "aio",
                .mount          = aio_mount,
                .kill_sb        = kill_anon_super,
        };
        aio_mnt = kern_mount(&aio_fs);

All of 12 lines.  Your export is not much shorter.  To quote old mail on
the same topic:

> Note that anon_inodes.c reason to exist was "it's for situations where
> all context lives on struct file and we don't need separate inode for
> them".  Going from that to "it happens to contain a handy function for inode
> allocation"...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
