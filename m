Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E31566B0007
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 04:09:42 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id v21so9654269qka.6
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 01:09:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s72si945545qka.460.2018.03.03.01.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Mar 2018 01:09:41 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2399fXP129377
	for <linux-mm@kvack.org>; Sat, 3 Mar 2018 04:09:41 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gfqw6haqd-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 03 Mar 2018 04:09:40 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 3 Mar 2018 09:09:38 -0000
Date: Sat, 3 Mar 2018 11:09:28 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] userfaultfd: non-cooperative: syncronous events
References: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180302153849.d9d7b9a873755c6f5e883d0d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180302153849.d9d7b9a873755c6f5e883d0d@linux-foundation.org>
Message-Id: <20180303090926.GA14011@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, crml <criu@openvz.org>

On Fri, Mar 02, 2018 at 03:38:49PM -0800, Andrew Morton wrote:
> On Tue, 27 Feb 2018 10:19:49 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > Hi,
> > 
> > These patches add ability to generate userfaultfd events so that their
> > processing will be synchronized with the non-cooperative thread that caused
> > the event.
> > 
> > In the non-cooperative case userfaultfd resumes execution of the thread
> > that caused an event when the notification is read() by the uffd monitor.
> > In some cases, like, for example, madvise(MADV_REMOVE), it might be
> > desirable to keep the thread that caused the event suspended until the
> > uffd monitor had the event handled to avoid races between the thread that
> > caused the and userfaultfd ioctls.
> > 
> > Theses patches extend the userfaultfd API with an implementation of
> > UFFD_EVENT_REMOVE_SYNC that allows to keep the thread that triggered
> > UFFD_EVENT_REMOVE until the uffd monitor would not wake it explicitly.
> 
> "might be desirable" is a bit weak.  It might not be desirable, too ;)
> 
> _Is_ it desirable?  What are the use-cases and what is the end-user
> benefit?

It _is_ desirable :)
With asynchronous UFFD_EVENT_REMOVE, the faulting thread continues before
the uffd monitor had chance to process the event and the memory accesses or
layout modifications of faulting thread race with the monitor processing of
the UFFD_EVENT_REMOVE.  Moreover, for multithreaded uffd monitor there
could be also uffdio_{copy,zeropage} in flight that will also race with
those memory accesses.

I have elaborate description of the patch 3 in this series.

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
