Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3F146B0266
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:44:31 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id 23so124498523vkc.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:44:31 -0800 (PST)
Received: from mail-ua0-x230.google.com (mail-ua0-x230.google.com. [2607:f8b0:400c:c08::230])
        by mx.google.com with ESMTPS id y133si6741140vky.206.2017.01.25.13.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 13:44:30 -0800 (PST)
Received: by mail-ua0-x230.google.com with SMTP id 96so169260726uaq.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:44:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1485379919.2998.159.camel@decadent.org.uk>
References: <cover.1485377903.git.luto@kernel.org> <826ec4aab64ec304944098d15209f8c1ae65bb29.1485377903.git.luto@kernel.org>
 <1485379919.2998.159.camel@decadent.org.uk>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 25 Jan 2017 13:44:09 -0800
Message-ID: <CALCETrWY0JmC7T0x4Nz9TwMAZryx7=Eq04WZiL7ynX=V-utS=Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] fs: Harden against open(..., O_CREAT, 02777) in a
 setgid directory
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Andy Lutomirski <luto@kernel.org>, "security@kernel.org" <security@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

On Wed, Jan 25, 2017 at 1:31 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Wed, 2017-01-25 at 13:06 -0800, Andy Lutomirski wrote:
>> Currently, if you open("foo", O_WRONLY | O_CREAT | ..., 02777) in a
>> directory that is setgid and owned by a different gid than current's
>> fsgid, you end up with an SGID executable that is owned by the
>> directory's GID.  This is a Bad Thing (tm).  Exploiting this is
>> nontrivial because most ways of creating a new file create an empty
>> file and empty executables aren't particularly interesting, but this
>> is nevertheless quite dangerous.
>>
>> Harden against this type of attack by detecting this particular
>> corner case (unprivileged program creates SGID executable inode in
>> SGID directory owned by a different GID) and clearing the new
>> inode's SGID bit.
>>
>> > Signed-off-by: Andy Lutomirski <luto@kernel.org>
>> ---
>>  fs/inode.c | 21 +++++++++++++++++++--
>>  1 file changed, 19 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/inode.c b/fs/inode.c
>> index f7029c40cfbd..d7e4b80470dd 100644
>> --- a/fs/inode.c
>> +++ b/fs/inode.c
>> @@ -2007,11 +2007,28 @@ void inode_init_owner(struct inode *inode, const struct inode *dir,
>>  {
>>       inode->i_uid = current_fsuid();
>>       if (dir && dir->i_mode & S_ISGID) {
>> +             bool changing_gid = !gid_eq(inode->i_gid, dir->i_gid);
> [...]
>
> inode->i_gid hasn't been initialised yet.  This should compare with
> current_fsgid(), shouldn't it?

Whoops.  In v2, I'll fix it by inode->i_gid first -- that'll simplify
the control flow.

>
> Ben.
>
> --
> Ben Hutchings
> It is easier to write an incorrect program than to understand a correct
> one.
>



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
