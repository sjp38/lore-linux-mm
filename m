Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 226736B0003
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:44:39 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id g19-v6so307586yba.3
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:44:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v36-v6sor3535144ybi.140.2018.04.23.08.44.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 08:44:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxi9VBjN-xiGddepS3B_O=iteaV=dwew8_xdZ6R9seQqSA@mail.gmail.com>
References: <1510555438-28996-1-git-send-email-amir73il@gmail.com>
 <CAOQ4uxgnzRummiQm0DNP52QxGoJ8XN+EtEkYBWxyTD5YUWf+nQ@mail.gmail.com> <CAOQ4uxi9VBjN-xiGddepS3B_O=iteaV=dwew8_xdZ6R9seQqSA@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 23 Apr 2018 08:44:36 -0700
Message-ID: <CAOQ4uxgcyceCiFJTLj1jZSfcFPifKUn9S6tbP36q=xqHTFN6BQ@mail.gmail.com>
Subject: Re: [PATCH v2] tmpfs: allow decoding a file handle of an unlinked file
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Jeff Layton <jlayton@poochiereds.net>, "J . Bruce Fields" <bfields@fieldses.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, overlayfs <linux-unionfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Miklos Szeredi <miklos@szeredi.hu>, Linux MM <linux-mm@kvack.org>

On Sat, Jan 27, 2018 at 2:02 PM, Amir Goldstein <amir73il@gmail.com> wrote:
> On Fri, Jan 5, 2018 at 5:40 PM, Amir Goldstein <amir73il@gmail.com> wrote:
>> On Mon, Nov 13, 2017 at 8:43 AM, Amir Goldstein <amir73il@gmail.com> wrote:
>>> tmpfs uses the helper d_find_alias() to find a dentry from a decoded
>>> inode, but d_find_alias() skips unhashed dentries, so unlinked files
>>> cannot be decoded from a file handle.
>>>
>>> This can be reproduced using xfstests test program open_by_handle:
>>> $ open_by handle -c /tmp/testdir
>>> $ open_by_handle -dk /tmp/testdir
>>> open_by_handle(/tmp/testdir/file000000) returned 116 incorrectly on an
>>> unlinked open file!
>>>
>>> To fix this, if d_find_alias() can't find a hashed alias, call
>>> d_find_any_alias() to return an unhashed one.
>>>
>>> Cc: Hugh Dickins <hughd@google.com>
>>> Cc: Al Viro <viro@zeniv.linux.org.uk>
>>> Signed-off-by: Amir Goldstein <amir73il@gmail.com>
>>> ---
>>>
>>> Al, Miklos,
>>>
>>> Can either of you take this patch through your tree?
>>>
>>> Thanks,
>>> Amir.
>>>
>>> Changes since v1:
>>> - Prefer a hashed alias (James)
>>> - Use existing d_find_any_alias() helper
>>>
>>>  mm/shmem.c | 11 ++++++++++-
>>>  1 file changed, 10 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/shmem.c b/mm/shmem.c
>>> index 07a1d22807be..5d3fa4099f54 100644
>>> --- a/mm/shmem.c
>>> +++ b/mm/shmem.c
>>> @@ -3404,6 +3404,15 @@ static int shmem_match(struct inode *ino, void *vfh)
>>>         return ino->i_ino == inum && fh[0] == ino->i_generation;
>>>  }
>>>
>>> +/* Find any alias of inode, but prefer a hashed alias */
>>> +static struct dentry *shmem_find_alias(struct inode *inode)
>>> +{
>>> +       struct dentry *alias = d_find_alias(inode);
>>> +
>>> +       return alias ?: d_find_any_alias(inode);
>>> +}
>>> +
>>> +
>>>  static struct dentry *shmem_fh_to_dentry(struct super_block *sb,
>>>                 struct fid *fid, int fh_len, int fh_type)
>>>  {
>>> @@ -3420,7 +3429,7 @@ static struct dentry *shmem_fh_to_dentry(struct super_block *sb,
>>>         inode = ilookup5(sb, (unsigned long)(inum + fid->raw[0]),
>>>                         shmem_match, fid->raw);
>>>         if (inode) {
>>> -               dentry = d_find_alias(inode);
>>> +               dentry = shmem_find_alias(inode);
>>>                 iput(inode);
>>>         }
>>>
>>> --
>>
>> Hugh,
>>
>> Did you get a chance to look at this patch?
>>
>> The test for decoding a file handle of an unlinked file has already been
>> merged to xfstest generic/467 and the test is failing on tmpfs without this
>> change.
>>
>> Can you please take or ACK this patch?
>>
>
> Ping.
>

Ping^2
