Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB776B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 10:41:30 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id m98so27725408iod.2
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 07:41:30 -0800 (PST)
Received: from secvs01.rockwellcollins.com (secvs01.rockwellcollins.com. [205.175.225.240])
        by mx.google.com with ESMTPS id w2si6423176ita.87.2017.01.09.07.41.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 07:41:29 -0800 (PST)
Received: by mail-it0-f70.google.com with SMTP id p189so92827125itg.2
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 07:41:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170108095511.GB4203@infradead.org>
References: <1483653823-22018-1-git-send-email-david.graziano@rockwellcollins.com>
 <1483653823-22018-2-git-send-email-david.graziano@rockwellcollins.com> <20170108095511.GB4203@infradead.org>
From: David Graziano <david.graziano@rockwellcollins.com>
Date: Mon, 9 Jan 2017 09:41:03 -0600
Message-ID: <CA+RmS-9Pu0yK17Liwz0fqnDH-_1ejvLXRgD3y9WnZG56eoMGxA@mail.gmail.com>
Subject: Re: [PATCH v4 1/3] xattr: add simple initxattrs function
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-security-module@vger.kernel.org, Paul Moore <paul@paul-moore.com>, agruenba@redhat.com, linux-mm@kvack.org, Stephen Smalley <sds@tycho.nsa.gov>, linux-kernel@vger.kernel.org

On Sun, Jan 8, 2017 at 3:55 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> +/*
>> + * Callback for security_inode_init_security() for acquiring xattrs.
>> + */
>> +int simple_xattr_initxattrs(struct inode *inode,
>> +                         const struct xattr *xattr_array,
>> +                         void *fs_info)
>> +{
>> +     struct simple_xattrs *xattrs;
>> +     const struct xattr *xattr;
>> +     struct simple_xattr *new_xattr;
>> +     size_t len;
>> +
>> +     if (!fs_info)
>> +             return -ENOMEM;
>
> This probablt should be an EINVAL, and also a WARN_ON_ONCE.

I will change the return value to -EINVAL and add the WARN_ON_ONCE.
In the next version of the patchset.

>
>> +     xattrs = (struct simple_xattrs *) fs_info;
>
> No need for the cast.  In fact we should probably just declarate it
> as struct simple_xattrs *xattrs in the protoype and thus be type safe.

I don't think the prototype can be changed to "struct simple_xattrs" as the
security_inode_init_security() function in security/security.c which calls
this is asumming an initxattrs function with following prototype
int (*initxattrs)  (struct inode *inode, const struct xattr
*xattr_array, void *fs_data)

>
>> +
>> +     for (xattr = xattr_array; xattr->name != NULL; xattr++) {
>> +             new_xattr = simple_xattr_alloc(xattr->value, xattr->value_len);
>> +             if (!new_xattr)
>> +                     return -ENOMEM;
>
> We'll need to unwind the previous allocations here.

This patchset essentially relocates the shmem_initxattrs() function from
mm/shmem.c and uses the relocated function for both tmpfs and mqueuefs.
That inital function didn't attempt to unwind the previous allocations. If the
consensus is to unwind any allocations made by this function I can look
at adding it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
