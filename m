Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 93E566B00A5
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:38:20 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 19 Oct 2012 15:38:18 +0100
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9JEc91d50397434
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 14:38:10 GMT
Received: from d06av06.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9JEcGgi018122
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 08:38:16 -0600
Date: Fri, 19 Oct 2012 16:38:14 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
Message-ID: <20121019163814.55b3590e@mschwide>
In-Reply-To: <alpine.LSU.2.00.1210091600450.30446@eggly.anvils>
References: <1349108796-32161-1-git-send-email-jack@suse.cz>
	<alpine.LSU.2.00.1210082029190.2237@eggly.anvils>
	<20121009101822.79bdcb65@mschwide>
	<alpine.LSU.2.00.1210091600450.30446@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org

On Tue, 9 Oct 2012 16:21:24 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> > 
> > I am seriously tempted to switch to pure software dirty bits by using
> > page protection for writable but clean pages. The worry is the number of
> > additional protection faults we would get. But as we do software dirty
> > bit tracking for the most part anyway this might not be as bad as it
> > used to be.  
> 
> That's exactly the same reason why tmpfs opts out of dirty tracking, fear
> of unnecessary extra faults.  Anomalous as s390 is here, tmpfs is being
> anomalous too, and I'd be a hypocrite to push for you to make that change.

I tested the waters with the software dirty bit idea. Using kernel compile
as test case I got these numbers:

disk backing, swdirty: 10,023,870 minor-faults 18 major-faults
disk backing, hwdirty: 10,023,829 minor-faults 21 major-faults                          

tmpfs backing, swdirty: 10,019,552 minor-faults 49 major-faults
tmpfs backing, hwdirty: 10,032,909 minor-faults 81 major-faults

That does not look bad at all. One test I found that shows an effect is
lat_mmap from LMBench:

disk backing, hwdirty: 30,894 minor-faults 0 major-faults
disk backing, swdirty: 30,894 minor-faults 0 major-faults

tmpfs backing, hwdirty: 22,574 minor-faults 0 major-faults
tmpfs backing, swdirty: 36,652 minor-faults 0 major-faults 

The runtime between the hwdirty vs. the swdirty setup is very similar,
encouraging enough for me to ask our performance team to run a larger test.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
