Date: Mon, 27 Aug 2007 15:24:20 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 1/4] export __put_task_struct for XPMEM
Message-ID: <20070827202420.GE22922@lnx-holt.americas.sgi.com>
References: <20070827155622.GA25589@sgi.com> <20070827155933.GB25589@sgi.com> <20070827161327.GG21089@ftp.linux.org.uk> <20070827181056.GA30176@sgi.com> <20070827181544.GH21089@ftp.linux.org.uk> <20070827191906.GB30176@sgi.com> <20070827193510.GJ21089@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070827193510.GJ21089@ftp.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ftp.linux.org.uk>
Cc: Dean Nelson <dcn@sgi.com>, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 27, 2007 at 08:35:10PM +0100, Al Viro wrote:
> On Mon, Aug 27, 2007 at 02:19:06PM -0500, Dean Nelson wrote:
> 
> > No operations can be done once it's closed, only while it's opened.
> 
> What the hell do you mean, can't be done?
> 
> 	fd = open(...);
> 	fp = popen("/bin/date", "r");
> 	/* read from fp */
> 	fclose(fp);

But this will operate on the dup'd fd.  We detect that in the flush
(ignore) and ioctl (return errors) operations.  All other operations
are not handled by xpmem.

If you look at the fourth patch, at the beginning of the xpmem_flush
function, we have:

+       tg = xpmem_tg_ref_by_tgid(xpmem_my_part, current->tgid);
+       if (IS_ERR(tg))
+               return 0;  /* probably child process who inherited fd */

This will protect the xpmem structures of the parent from closes by
the child.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
