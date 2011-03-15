Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 080BA8D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:22:40 -0400 (EDT)
Date: Tue, 15 Mar 2011 16:22:22 +0100
From: David Sterba <dave@jikos.cz>
Subject: Re: ext4 deep stack with mark_page_dirty reclaim
Message-ID: <20110315152222.GW17108@twin.jikos.cz>
Reply-To: dave@jikos.cz
References: <alpine.LSU.2.00.1103141156190.3220@sister.anvils>
 <20110314204627.GB8120@thunk.org>
 <FE7209AC-C66C-4482-945E-58CF5AF8FEE7@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <FE7209AC-C66C-4482-945E-58CF5AF8FEE7@dilger.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: adilger@dilger.ca

On Mon, Mar 14, 2011 at 07:25:10PM -0700, Andreas Dilger wrote:
> Is there a script which you used to generate this stack trace to
> function size mapping, or did you do it by hand?  I've always wanted
> such a script, but the tricky part is that there is so much garbage on
> the stack that any automated stack parsing is almost useless.
> Alternately, it would seem trivial to have the stack dumper print the
> relative address of each symbol, and the delta from the previous
> symbol...

> > 240 schedule+0x25a
> > 368 io_schedule+0x35
> >  32 get_request_wait+0xc6

from the callstack:

ffff88007a704338 schedule+0x25a
ffff88007a7044a8 io_schedule+0x35
ffff88007a7044c8 get_request_wait+0xc6

subtract the values and you get the ones Ted posted,

eg. for get_request_wait:

0xffff88007a7044c8 - 0xffff88007a7044a8 = 32

There'se a script scripts/checkstack.pl which tries to determine stack
usage from 'objdump -d' looking for the 'sub 0x123,%rsp' instruction and
reporting the 0x123 as stack consumption. It does not give same results,
for the get_request_wait:

ffffffff81216205:       48 83 ec 68             sub    $0x68,%rsp

reported as 104.


dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
