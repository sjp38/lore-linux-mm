Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9E46B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 11:36:18 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id i1so5101731oib.2
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 08:36:18 -0700 (PDT)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id e197si3067137oig.18.2017.08.29.08.36.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 08:36:16 -0700 (PDT)
Received: by mail-io0-x230.google.com with SMTP id 81so21654295ioj.5
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 08:36:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4bcfaf44-a951-f730-638c-65e44bb2cec4@kernel.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-11-git-send-email-keescook@chromium.org> <4bcfaf44-a951-f730-638c-65e44bb2cec4@kernel.org>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 29 Aug 2017 08:36:15 -0700
Message-ID: <CAGXu5jKdO8igDTjazoD4GEqQgv9cSKczYLysXx5Ctiv7YDspfQ@mail.gmail.com>
Subject: Re: [PATCH v2 10/30] befs: Define usercopy region in befs_inode_cache
 slab cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luis de Bethencourt <luisbg@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, Salah Triki <salah.triki@gmail.com>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Aug 29, 2017 at 3:12 AM, Luis de Bethencourt <luisbg@kernel.org> wrote:
> Hello Kees,
>
> This is great. Thanks :)
>
> Will merge into my befs tree.

Hi! Actually, this depends on the rest of the series, which should be
merged together. If you can Ack this, I'll include it in my usercopy
tree.

Thanks!

-Kees

>
> Luis
>
>
> On 08/28/2017 10:34 PM, Kees Cook wrote:
>>
>> From: David Windsor <dave@nullcore.net>
>>
>> befs symlink pathnames, stored in struct befs_inode_info.i_data.symlink
>> and therefore contained in the befs_inode_cache slab cache, need to be
>> copied to/from userspace.
>>
>> cache object allocation:
>>      fs/befs/linuxvfs.c:
>>          befs_alloc_inode(...):
>>              ...
>>              bi = kmem_cache_alloc(befs_inode_cachep, GFP_KERNEL);
>>              ...
>>              return &bi->vfs_inode;
>>
>>          befs_iget(...):
>>              ...
>>              strlcpy(befs_ino->i_data.symlink, raw_inode->data.symlink,
>>                      BEFS_SYMLINK_LEN);
>>              ...
>>              inode->i_link = befs_ino->i_data.symlink;
>>
>> example usage trace:
>>      readlink_copy+0x43/0x70
>>      vfs_readlink+0x62/0x110
>>      SyS_readlinkat+0x100/0x130
>>
>>      fs/namei.c:
>>          readlink_copy(..., link):
>>              ...
>>              copy_to_user(..., link, len);
>>
>>          (inlined in vfs_readlink)
>>          generic_readlink(dentry, ...):
>>              struct inode *inode = d_inode(dentry);
>>              const char *link = inode->i_link;
>>              ...
>>              readlink_copy(..., link);
>>
>> In support of usercopy hardening, this patch defines a region in the
>> befs_inode_cache slab cache in which userspace copy operations are
>> allowed.
>>
>> This region is known as the slab cache's usercopy region. Slab caches can
>> now check that each copy operation involving cache-managed memory falls
>> entirely within the slab's usercopy region.
>>
>> This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
>> whitelisting code in the last public patch of grsecurity/PaX based on my
>> understanding of the code. Changes or omissions from the original code are
>> mine and don't reflect the original grsecurity/PaX code.
>>
>> Signed-off-by: David Windsor <dave@nullcore.net>
>> [kees: adjust commit log, provide usage trace]
>> Cc: Luis de Bethencourt <luisbg@kernel.org>
>> Cc: Salah Triki <salah.triki@gmail.com>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>>   fs/befs/linuxvfs.c | 14 +++++++++-----
>>   1 file changed, 9 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
>> index 4a4a5a366158..1c2dcbee79dd 100644
>> --- a/fs/befs/linuxvfs.c
>> +++ b/fs/befs/linuxvfs.c
>> @@ -444,11 +444,15 @@ static struct inode *befs_iget(struct super_block
>> *sb, unsigned long ino)
>>   static int __init
>>   befs_init_inodecache(void)
>>   {
>> -       befs_inode_cachep = kmem_cache_create("befs_inode_cache",
>> -                                             sizeof (struct
>> befs_inode_info),
>> -                                             0, (SLAB_RECLAIM_ACCOUNT|
>> -
>> SLAB_MEM_SPREAD|SLAB_ACCOUNT),
>> -                                             init_once);
>> +       befs_inode_cachep = kmem_cache_create_usercopy("befs_inode_cache",
>> +                               sizeof(struct befs_inode_info), 0,
>> +                               (SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
>> +                                       SLAB_ACCOUNT),
>> +                               offsetof(struct befs_inode_info,
>> +                                       i_data.symlink),
>> +                               sizeof_field(struct befs_inode_info,
>> +                                       i_data.symlink),
>> +                               init_once);
>>         if (befs_inode_cachep == NULL)
>>                 return -ENOMEM;
>>
>
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
