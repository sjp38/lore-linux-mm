Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id E5F166B0036
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 05:47:34 -0400 (EDT)
Date: Fri, 12 Apr 2013 10:47:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130412094731.GI11656@suse.de>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130412025708.GB7445@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Thu, Apr 11, 2013 at 10:57:08PM -0400, Theodore Ts'o wrote:
> On Thu, Apr 11, 2013 at 11:33:35PM +0200, Jan Kara wrote:
> >   I think it might be more enlightening if Mel traced which process in
> > which funclion is holding the buffer lock. I suspect we'll find out that
> > the flusher thread has submitted the buffer for IO as an async write and
> > thus it takes a long time to complete in presence of reads which have
> > higher priority.
> 
> That's an interesting theory.  If the workload is one which is very
> heavy on reads and writes, that could explain the high latency.  That
> would explain why those of us who are using primarily SSD's are seeing
> the problems, because would be reads are nice and fast.
> 
> If that is the case, one possible solution that comes to mind would be
> to mark buffer_heads that contain metadata with a flag, so that the
> flusher thread can write them back at the same priority as reads.
> 
> The only problem I can see with this hypothesis is that if this is the
> explanation for what Mel and Jiri are seeing, it's something that
> would have been around for a long time, and would affect ext3 as well
> as ext4.  That isn't quite consistent, however, with Mel's observation
> that this is a probablem which has gotten worse in relatively
> recently.
> 

According to the tests I've run, multi-second stalls have been a problem for
a while but never really bothered me. I'm not sure why it felt particularly
bad around -rc2 or why it seems to be better now. Maybe I just had my
cranky pants on.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
