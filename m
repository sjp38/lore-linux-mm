Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 10BAA6B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 05:33:52 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t15so3764943wmh.3
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 02:33:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s14si5248927wrc.483.2017.12.15.02.33.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 02:33:50 -0800 (PST)
Date: Fri, 15 Dec 2017 11:33:48 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: save/restore current->journal_info in handle_mm_fault
Message-ID: <20171215103348.GB7419@quack2.suse.cz>
References: <20171214105527.5885-1-zyan@redhat.com>
 <20171214134338.GA1474@quack2.suse.cz>
 <CAAM7YA=ThWbBpOe1wgeYjGt3ogr9kT6uy3UpqSn94XqbhjOHJw@mail.gmail.com>
 <20171214165314.GB1930@quack2.suse.cz>
 <CAAM7YA=aKMgyi67nwamzNj82nhmsWoUPXWGuXxiMx2Ay1vZK3Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAM7YA=aKMgyi67nwamzNj82nhmsWoUPXWGuXxiMx2Ay1vZK3Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Yan, Zheng" <ukernel@gmail.com>
Cc: Jan Kara <jack@suse.cz>, "Yan, Zheng" <zyan@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, ceph-devel <ceph-devel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>, stable@vger.kernel.org

On Fri 15-12-17 09:17:42, Yan, Zheng wrote:
> On Fri, Dec 15, 2017 at 12:53 AM, Jan Kara <jack@suse.cz> wrote:
> >> >
> >> > In this particular case I'm not sure why does ceph pass 'filp' into
> >> > readpage() / readpages() handler when it already gets that pointer as part
> >> > of arguments...
> >>
> >> It actually a flag which tells ceph_readpages() if its caller is
> >> ceph_read_iter or readahead/fadvise/madvise. because when there are
> >> multiple clients read/write a file a the same time, page cache should
> >> be disabled.
> >
> > I'm not sure I understand the reasoning properly but from what you say
> > above it rather seems the 'hint' should be stored in the inode (or possibly
> > struct file)?
> >
> 
> The capability of using page cache is hold by the process who got it.
> ceph_read_iter() first gets the capability, calls
> generic_file_read_iter(), then release the capability. The capability
> can not be easily stored in inode or file because it can be revoked by
> server any time if caller does not hold it

OK, understood. But using storage in task_struct (such as journal_info) is
problematic as it has hard to fix recursion issues as the bug you're trying
to fix shows (it is difficult to track down all the paths that can recurse
into another filesystem which will clobber the stored info). So either you
have to come up with some scheme to safely use current->journal_info (by
somehow tracking owner as Andreas suggests) and convert all users to it or
you have to come up with some scheme propagating the information through
the inode / file->private_data and use it in Ceph.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
