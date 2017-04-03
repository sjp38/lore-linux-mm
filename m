Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3E996B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 11:10:34 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g2so140178163pge.7
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 08:10:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w17si14563837pge.138.2017.04.03.08.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 08:10:34 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v33F3jgM041242
	for <linux-mm@kvack.org>; Mon, 3 Apr 2017 11:10:33 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29kqbhdya5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:10:33 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 3 Apr 2017 16:10:31 +0100
Date: Mon, 3 Apr 2017 18:10:24 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH for 4.11] userfaultfd: report actual registered features
 in fdinfo
References: <1491140181-22121-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170403143523.GC5107@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403143523.GC5107@redhat.com>
Message-Id: <20170403151024.GA14802@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org

On Mon, Apr 03, 2017 at 04:35:23PM +0200, Andrea Arcangeli wrote:
> On Sun, Apr 02, 2017 at 04:36:21PM +0300, Mike Rapoport wrote:
> > fdinfo for userfault file descriptor reports UFFD_API_FEATURES. Up until
> > recently, the UFFD_API_FEATURES was defined as 0, therefore corresponding
> > field in fdinfo always contained zero. Now, with introduction of several
> > additional features, UFFD_API_FEATURES is not longer 0 and it seems better
> > to report actual features requested for the userfaultfd object described by
> > the fdinfo. First, the applications that were using userfault will still
> > see zero at the features field in fdinfo. Next, reporting actual features
> > rather than available features, gives clear indication of what userfault
> > features are used by an application.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> >  fs/userfaultfd.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > index 1d227b0..f7555fc 100644
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -1756,7 +1756,7 @@ static void userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
> >  	 *	protocols: aa:... bb:...
> >  	 */
> >  	seq_printf(m, "pending:\t%lu\ntotal:\t%lu\nAPI:\t%Lx:%x:%Lx\n",
> > -		   pending, total, UFFD_API, UFFD_API_FEATURES,
> > +		   pending, total, UFFD_API, ctx->features,
> >  		   UFFD_API_IOCTLS|UFFD_API_RANGE_IOCTLS);
> >  }
> >  #endif
> 
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> I wonder if we've been a bit overkill in showing these details in
> /proc as this innocent change is technically an ABI visible change
> now. It's intended only for informational/debug purposes, no software
> should attempt to decode it, so it'd be better in debugfs, but the
> per-thread fds aren't anywhere in debugfs so it's shown there where
> it's all already in place to provide it with a few liner function.
> 

Actually, I've found these details in /proc useful when I was experimenting
with checkpoint-restore of an application that uses userfaultfd. With
interface in /proc/<pid>/ we know exactly which process use userfaultfd and
can act appropriately.

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
