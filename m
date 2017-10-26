Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D17046B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 15:55:48 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g90so2166109wrd.14
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 12:55:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y34si3907400edb.54.2017.10.26.12.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 12:55:47 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9QJtGkm080083
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 15:55:46 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dukm47jrt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 15:55:46 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Oct 2017 20:55:44 +0100
Date: Thu, 26 Oct 2017 22:54:47 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] pids: introduce find_get_task_by_vpid helper
References: <1509023278-20604-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20171026135825.GA16528@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171026135825.GA16528@redhat.com>
Message-Id: <20171026195442.GA10558@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Thu, Oct 26, 2017 at 03:58:25PM +0200, Oleg Nesterov wrote:
> On 10/26, Mike Rapoport wrote:
> >
> > There are several functions that do find_task_by_vpid() followed by
> > get_task_struct(). We can use a helper function instead.
> 
> Yes, agreed, I was going to do this many times.
> 
> > --- a/kernel/futex.c
> > +++ b/kernel/futex.c
> > @@ -870,12 +870,7 @@ static struct task_struct *futex_find_get_task(pid_t pid)
> >  {
> >  	struct task_struct *p;
> >  
> > -	rcu_read_lock();
> > -	p = find_task_by_vpid(pid);
> > -	if (p)
> > -		get_task_struct(p);
> > -
> > -	rcu_read_unlock();
> > +	p = find_get_task_by_vpid(pid);
> >  
> >  	return p;
> 
> OK, but then I think you should remove futex_find_get_task() and convert
> it callers to use the new helper.

Agree. My cocci script was too simple :)
 
> > @@ -1103,11 +1103,7 @@ static struct task_struct *ptrace_get_task_struct(pid_t pid)
> >  {
> >  	struct task_struct *child;
> >  
> > -	rcu_read_lock();
> > -	child = find_task_by_vpid(pid);
> > -	if (child)
> > -		get_task_struct(child);
> > -	rcu_read_unlock();
> > +	child = find_get_task_by_vpid(pid);
> >  
> >  	if (!child)
> >  		return ERR_PTR(-ESRCH);
> 
> The same. ptrace_get_task_struct() should die imo.

Yeah, we could just return -ESRCH in ptrace_get_task_struct users instead
of all the ERR_PTR and PTR_ERR conversions...

> Oleg.
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
