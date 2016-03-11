Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 823FF6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:24:39 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l68so19676539wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:24:39 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id 4si2984799wmy.42.2016.03.11.06.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 06:24:38 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id l68so20911130wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:24:38 -0800 (PST)
Subject: Re: [PATCH v1 03/19] fs/anon_inodes: new interface to create new
 inode
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-4-git-send-email-minchan@kernel.org>
 <20160311080503.GR17997@ZenIV.linux.org.uk>
From: Gioh Kim <gi-oh.kim@profitbricks.com>
Message-ID: <56E2D524.8070708@profitbricks.com>
Date: Fri, 11 Mar 2016 15:24:36 +0100
MIME-Version: 1.0
In-Reply-To: <20160311080503.GR17997@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>



On 11.03.2016 09:05, Al Viro wrote:
> On Fri, Mar 11, 2016 at 04:30:07PM +0900, Minchan Kim wrote:
>> From: Gioh Kim <gurugio@hanmail.net>
>>
>> The anon_inodes has already complete interfaces to create manage
>> many anonymous inodes but don't have interface to get
>> new inode. Other sub-modules can create anonymous inode
>> without creating and mounting it's own pseudo filesystem.
> IMO that's a bad idea.  In case of aio "creating and mounting" takes this:
> static struct dentry *aio_mount(struct file_system_type *fs_type,
>                                  int flags, const char *dev_name, void *data)
> {
>          static const struct dentry_operations ops = {
>                  .d_dname        = simple_dname,
>          };
>          return mount_pseudo(fs_type, "aio:", NULL, &ops, AIO_RING_MAGIC);
> }
> and
>          static struct file_system_type aio_fs = {
>                  .name           = "aio",
>                  .mount          = aio_mount,
>                  .kill_sb        = kill_anon_super,
>          };
>          aio_mnt = kern_mount(&aio_fs);
>
> All of 12 lines.  Your export is not much shorter.  To quote old mail on
> the same topic:
I know what aio_setup() does. It can be a solution.
But I thought creating anon_inode_new() is simpler than several drivers 
create its own pseudo filesystem.
Creating a filesystem requires memory allocation and locking some lists 
even though it is pseudo.

Could you inform me if there is a reason we should avoid creating 
anonymous inode?

>
>> Note that anon_inodes.c reason to exist was "it's for situations where
>> all context lives on struct file and we don't need separate inode for
>> them".  Going from that to "it happens to contain a handy function for inode
>> allocation"...


-- 
Best regards,
Gioh Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
