Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 97EC86B0374
	for <linux-mm@kvack.org>; Tue,  2 May 2017 05:47:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w50so13137064wrc.4
        for <linux-mm@kvack.org>; Tue, 02 May 2017 02:47:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d65si2035633wmd.105.2017.05.02.02.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 02:47:06 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v429iANN143104
	for <linux-mm@kvack.org>; Tue, 2 May 2017 05:47:04 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a6frwxv22-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 May 2017 05:47:04 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 2 May 2017 10:47:02 +0100
Date: Tue, 2 May 2017 12:46:55 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH man-pages 4/5] userfaultfd.2: add note about asynchronios
 events delivery
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493617399-20897-5-git-send-email-rppt@linux.vnet.ibm.com>
 <5fb9e169-5d92-2fe8-cc59-5c68cfb6be72@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5fb9e169-5d92-2fe8-cc59-5c68cfb6be72@gmail.com>
Message-Id: <20170502094654.GC5910@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On Mon, May 01, 2017 at 08:33:45PM +0200, Michael Kerrisk (man-pages) wrote:
> Hi Mike,
> 
> On 05/01/2017 07:43 AM, Mike Rapoport wrote:
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> Thanks. Applied. One question below.
> 
> > ---
> >  man2/userfaultfd.2 | 12 ++++++++++++
> >  1 file changed, 12 insertions(+)
> > 
> > diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> > index 8b89162..f177bba 100644
> > --- a/man2/userfaultfd.2
> > +++ b/man2/userfaultfd.2
> > @@ -112,6 +112,18 @@ created for the child process,
> >  which allows userfaultfd monitor to perform user-space paging
> >  for the child process.
> >  
> > +Unlike page faults which have to be synchronous and require
> > +explicit or implicit wakeup,
> > +all other events are delivered asynchronously and
> > +the non-cooperative process resumes execution as
> > +soon as manager executes
> > +.BR read(2).
> > +The userfaultfd manager should carefully synchronize calls
> > +to UFFDIO_COPY with the events processing.
> > +
> > +The current asynchronous model of the event delivery is optimal for
> > +single threaded non-cooperative userfaultfd manager implementations.
> 
> The preceding paragraph feels incomplete. It seems like you want to make
> a point with that last sentence, but the point is not explicit. What's
> missing?

I've copied both from Documentation/vm/userfaulftfd.txt, and there we also
talk about possibility of addition of synchronous events delivery and
that makes the paragraph above to seem crippled :)
The major point here is that current events delivery model could be
problematic for multi-threaded monitor. I even suspect that it would be
impossible to ensure synchronization between page faults and non-page
fault events in multi-threaded monitor.
 
> > +
> >  .\" FIXME elaborate about non-cooperating mode, describe its limitations
> >  .\" for kernels before 4.11, features added in 4.11
> >  .\" and limitations remaining in 4.11
> > 
> 
> Cheers,
> 
> Michael
> 
> 
> 
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
