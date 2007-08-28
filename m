Date: Tue, 28 Aug 2007 07:09:53 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 1/4] export __put_task_struct for XPMEM
Message-ID: <20070828120952.GC3648@lnx-holt.americas.sgi.com>
References: <20070827155622.GA25589@sgi.com> <20070827155933.GB25589@sgi.com> <20070827161327.GG21089@ftp.linux.org.uk> <20070827181056.GA30176@sgi.com> <20070827181544.GH21089@ftp.linux.org.uk> <20070827191906.GB30176@sgi.com> <20070827193510.GJ21089@ftp.linux.org.uk> <20070827202420.GE22922@lnx-holt.americas.sgi.com> <20070827204752.GK21089@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="/WwmFnJnmDyWGHa4"
Content-Disposition: inline
In-Reply-To: <20070827204752.GK21089@ftp.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ftp.linux.org.uk>
Cc: Robin Holt <holt@sgi.com>, Dean Nelson <dcn@sgi.com>, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

--/WwmFnJnmDyWGHa4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 27, 2007 at 09:47:52PM +0100, Al Viro wrote:
> On Mon, Aug 27, 2007 at 03:24:20PM -0500, Robin Holt wrote:
> > On Mon, Aug 27, 2007 at 08:35:10PM +0100, Al Viro wrote:
> > > On Mon, Aug 27, 2007 at 02:19:06PM -0500, Dean Nelson wrote:
> > > 
> > > > No operations can be done once it's closed, only while it's opened.
> > > 
> > > What the hell do you mean, can't be done?
> > > 
> > > 	fd = open(...);
> > > 	fp = popen("/bin/date", "r");
> > > 	/* read from fp */
> > > 	fclose(fp);
> > 
> > But this will operate on the dup'd fd.  We detect that in the flush
> > (ignore) and ioctl (return errors) operations.  All other operations
> > are not handled by xpmem.
> 
> How the hell do you detect dup'd fd?  It's identical to the original
> in every respect and it doesn't have to be held by a different task.

I attached that to the previous email.  We have a thread group structure
which is reference by tgid.  This comes from current->tgid.  For a fork'd
process, that tgid will be different.  Until that child process does
an open of /dev/xpmem, anything the child tries to do with xpmem will
not find the child's thread group structure and will return immediately.
We are not storing anything into or relating anything to the fd.  We are
dealing strictly with our own structures referenced by current->tgid.

> Seriously, what you are proposing makes no sense whatsoever...

I guess I am too close to this because it makes perfect sense to me.
The way I view it, we have a device special file which provides us a set
of ioctl()s which enable multiple processes to share the same physical
pages of memory including memory from other partitions of the same system.

Those pages need to be demand faulted.  That will require us to
call get_user_pages() which will require us to have a reference to
the task_struct and mm_struct for the process which made that memory
available.  The undoing of the reference will require us use put_task()
and mm_put().

We are certainly open to alternative methods of faulting in those pages.
We have been working on and with this code since 2001 and may be too
used to our current method of doing things.  If you have suggestions
for doing this differently, we would love to hear about them.

Thanks,
Robin

--/WwmFnJnmDyWGHa4
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Original-To: holt@estes.americas.sgi.com
Delivered-To: holt@estes.americas.sgi.com
Received: from relay.sgi.com (netops-testserver-3.corp.sgi.com [192.26.57.72])
	by estes.americas.sgi.com (Postfix) with ESMTP id 11A2470006E2
	for <holt@estes.americas.sgi.com>; Mon, 27 Aug 2007 15:24:30 -0500 (CDT)
Received: from cuda.sgi.com (cuda1.sgi.com [192.48.168.28])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id C15F9908C6
	for <holt@sgi.com>; Mon, 27 Aug 2007 13:24:29 -0700 (PDT)
X-ASG-Debug-ID: 1188246268-291100410000-ogsPki
X-Barracuda-URL: http://cuda.sgi.com:80/cgi-bin/mark.cgi
Received: from vger.kernel.org (localhost [127.0.0.1])
	by cuda.sgi.com (Spam Firewall) with ESMTP
	id 42648D6D405; Mon, 27 Aug 2007 13:24:29 -0700 (PDT)
Received: from vger.kernel.org (vger.kernel.org [209.132.176.167]) by cuda.sgi.com with ESMTP id TAKjLLjUyAZGwDeO; Mon, 27 Aug 2007 13:24:29 -0700 (PDT)
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Sender
X-ASG-Whitelist: Client
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
	id S1762562AbXH0UY1 (ORCPT <rfc822;glowell@sgi.com> + 28 others);
	Mon, 27 Aug 2007 16:24:27 -0400
Received: (majordomo@vger.kernel.org) by vger.kernel.org id S1762429AbXH0UY1
	(ORCPT <rfc822;linux-ia64-outgoing>);
	Mon, 27 Aug 2007 16:24:27 -0400
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:38228 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762567AbXH0UYY (ORCPT
	<rfc822;linux-ia64@vger.kernel.org>); Mon, 27 Aug 2007 16:24:24 -0400
Received: from estes.americas.sgi.com (estes.americas.sgi.com [128.162.236.10])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id 6CF93908A5;
	Mon, 27 Aug 2007 13:24:23 -0700 (PDT)
Received: from lnx-holt.americas.sgi.com (lnx-holt.americas.sgi.com [128.162.233.109])
	by estes.americas.sgi.com (Postfix) with ESMTP id 19CF070006E1;
	Mon, 27 Aug 2007 15:24:23 -0500 (CDT)
Received: from lnx-holt.americas.sgi.com (localhost.localdomain [127.0.0.1])
	by lnx-holt.americas.sgi.com (8.13.8/8.13.8) with ESMTP id l7RKOME9000302;
	Mon, 27 Aug 2007 15:24:22 -0500
Received: (from holt@localhost)
	by lnx-holt.americas.sgi.com (8.13.8/8.13.8/Submit) id l7RKOKQp000301;
	Mon, 27 Aug 2007 15:24:20 -0500
Date: Mon, 27 Aug 2007 15:24:20 -0500
From: Robin Holt <holt@sgi.com>
To: Al Viro <viro@ftp.linux.org.uk>
Cc: Dean Nelson <dcn@sgi.com>, akpm@linux-foundation.org,
	linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com
X-ASG-Orig-Subj: Re: [PATCH 1/4] export __put_task_struct for XPMEM
Subject: Re: [PATCH 1/4] export __put_task_struct for XPMEM
Message-ID: <20070827202420.GE22922@lnx-holt.americas.sgi.com>
References: <20070827155622.GA25589@sgi.com> <20070827155933.GB25589@sgi.com> <20070827161327.GG21089@ftp.linux.org.uk> <20070827181056.GA30176@sgi.com> <20070827181544.GH21089@ftp.linux.org.uk> <20070827191906.GB30176@sgi.com> <20070827193510.GJ21089@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070827193510.GJ21089@ftp.linux.org.uk>
User-Agent: Mutt/1.4.2.2i
Sender: linux-ia64-owner@vger.kernel.org
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
X-Barracuda-Connect: vger.kernel.org[209.132.176.167]
X-Barracuda-Start-Time: 1188246269
X-Barracuda-Virus-Scanned: by cuda.sgi.com at sgi.com

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
-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--/WwmFnJnmDyWGHa4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
