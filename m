Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D0ADD6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 08:36:27 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l65so104306568wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 05:36:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id db3si1826138wjb.228.2016.01.26.05.36.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 05:36:26 -0800 (PST)
Date: Tue, 26 Jan 2016 14:36:36 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: mm: WARNING in __delete_from_page_cache
Message-ID: <20160126133636.GE23820@quack.suse.cz>
References: <CACT4Y+aBnm8VLe5f=AwO2nUoQZaH-UVqUynGB+naAC-zauOQsQ@mail.gmail.com>
 <20160124230422.GA8439@node.shutemov.name>
 <20160125122206.GA24938@quack.suse.cz>
 <1453779754.32645.3.camel@intel.com>
 <20160126125456.GK2948@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160126125456.GK2948@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, "kirill@shutemov.name" <kirill@shutemov.name>, "jack@suse.cz" <jack@suse.cz>, "syzkaller@googlegroups.com" <syzkaller@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "kcc@google.com" <kcc@google.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "dvyukov@google.com" <dvyukov@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gthelen@google.com" <gthelen@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "jack@suse.com" <jack@suse.com>, "glider@google.com" <glider@google.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "j-nomura@ce.jp.nec.com" <j-nomura@ce.jp.nec.com>

On Tue 26-01-16 07:54:56, Matthew Wilcox wrote:
> On Tue, Jan 26, 2016 at 03:42:34AM +0000, Williams, Dan J wrote:
> > @@ -2907,7 +2912,12 @@ extern void replace_mount_options(struct super_block *sb, char *options);
> >  
> >  static inline bool io_is_direct(struct file *filp)
> >  {
> > -	return (filp->f_flags & O_DIRECT) || IS_DAX(file_inode(filp));
> 
> I think this should just be a one-liner:
> 
> -	return (filp->f_flags & O_DIRECT) || IS_DAX(file_inode(filp));
> +	return (filp->f_flags & O_DIRECT) || IS_DAX(filp->f_mapping->host);
> 
> This does the right thing for block device inodes and filesystem inodes.
> (see the opening stanzas of __dax_fault for an example).

Ah, right. This looks indeed better.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
