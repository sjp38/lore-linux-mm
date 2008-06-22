Date: Mon, 23 Jun 2008 08:50:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] ext2: Use page_mkwrite vma_operations to get mmap
	write notification.
Message-ID: <20080622225014.GC11558@disturbed>
References: <1212685513-32237-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20080605123045.445e380a.akpm@linux-foundation.org> <20080611150845.GA21910@skywalker> <20080611120749.d0c5a7de.akpm@linux-foundation.org> <20080612161706.GB12367@duck.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080612161706.GB12367@duck.suse.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, cmm@us.ibm.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 12, 2008 at 06:17:06PM +0200, Jan Kara wrote:
>   BTW: XFS, OCFS2 or GFS2 define page_mkwrite() in this manner so they do
> return SIGBUS when you run out of space when writing to mmapped hole. So
> it's not like this change is introducing completely new behavior... I can
> understand that we might not want to change the behavior for ext2 or ext3
> but ext4 is IMO definitely free to choose.

Yup, and it's the only sane behaviour, IMO. Letting the application
continue to oversubscribe filesystem space and then throwing away
the data that can't be written well after the fact (potentially
after the application has gone away) is a horrendously bad failure
mode.

This was one of the main publicised features of ->page_mkwrite() -
that it would allow up front detection of ENOSPC conditions during
mmap writes. I'm extremely surprised to see that this is being
considered undesirable after all this time....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
