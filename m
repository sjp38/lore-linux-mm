Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 018206B0255
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:55:01 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id yy13so97243391pab.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:55:00 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ur4si62710pab.50.2016.01.26.04.55.00
        for <linux-mm@kvack.org>;
        Tue, 26 Jan 2016 04:55:00 -0800 (PST)
Date: Tue, 26 Jan 2016 07:54:56 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: mm: WARNING in __delete_from_page_cache
Message-ID: <20160126125456.GK2948@linux.intel.com>
References: <CACT4Y+aBnm8VLe5f=AwO2nUoQZaH-UVqUynGB+naAC-zauOQsQ@mail.gmail.com>
 <20160124230422.GA8439@node.shutemov.name>
 <20160125122206.GA24938@quack.suse.cz>
 <1453779754.32645.3.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1453779754.32645.3.camel@intel.com>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: "kirill@shutemov.name" <kirill@shutemov.name>, "jack@suse.cz" <jack@suse.cz>, "syzkaller@googlegroups.com" <syzkaller@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "kcc@google.com" <kcc@google.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "dvyukov@google.com" <dvyukov@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gthelen@google.com" <gthelen@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "jack@suse.com" <jack@suse.com>, "glider@google.com" <glider@google.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "j-nomura@ce.jp.nec.com" <j-nomura@ce.jp.nec.com>

On Tue, Jan 26, 2016 at 03:42:34AM +0000, Williams, Dan J wrote:
> @@ -2907,7 +2912,12 @@ extern void replace_mount_options(struct super_b=
lock *sb, char *options);
> =A0
> =A0static inline bool io_is_direct(struct file *filp)
> =A0{
> -	return (filp->f_flags & O_DIRECT) || IS_DAX(file_inode(filp));

I think this should just be a one-liner:

-	return (filp->f_flags & O_DIRECT) || IS_DAX(file_inode(filp));
+	return (filp->f_flags & O_DIRECT) || IS_DAX(filp->f_mapping->host);

This does the right thing for block device inodes and filesystem inodes.
(see the opening stanzas of __dax_fault for an example).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
