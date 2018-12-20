Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 88DBD8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:04:10 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so2030552pfb.17
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:04:10 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c21si18322186plo.165.2018.12.20.08.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 08:04:09 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBKFwmTO083500
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:04:08 -0500
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pgdrx1e06-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:04:08 -0500
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 20 Dec 2018 16:04:06 -0000
Date: Thu, 20 Dec 2018 08:04:08 -0800
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
Subject: Re: Ipmi modules and linux-4.19.1
Reply-To: paulmck@linux.ibm.com
References: <CAJM9R-JWO1P_qJzw2JboMH2dgPX7K1tF49nO5ojvf=iwGddXRQ@mail.gmail.com>
 <20181220154217.GB2509588@devbig004.ftw2.facebook.com>
 <20181220160313.GB4170@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220160313.GB4170@linux.ibm.com>
Message-Id: <20181220160408.GA23426@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Angel Shtilianov <angel.shtilianov@siteground.com>, linux-mm@kvack.org, dennis@kernel.org, cl@linux.com, jeyu@kernel.org, cminyard@mvista.com

Also adding Corey.  ;-)

On Thu, Dec 20, 2018 at 08:03:13AM -0800, Paul E. McKenney wrote:
> On Thu, Dec 20, 2018 at 07:42:17AM -0800, Tejun Heo wrote:
> > Hello, Angel.
> > 
> > (cc'ing Paul for SRCU)
> > 
> > On Thu, Dec 20, 2018 at 09:55:10AM +0200, Angel Shtilianov wrote:
> > > Hi everybody.
> > > A couple of days I've decided to migrate several servers on
> > > linux-4.19. What I've observed is that I have no /dev/ipmi. After
> > > taking a look into the boot log I've found that ipmi modules are
> > > complaining about percpu memory allocation failures:
> > > https://pastebin.com/MCDssZzV
> > ...
> > > -#define PERCPU_DYNAMIC_RESERVE         (28 << 10)
> > > +#define PERCPU_DYNAMIC_RESERVE         (28 << 11)
> > 
> > So, you prolly just needed to bump this number.  The reserved percpu
> > area is used to accommodate static percpu variables used by modules.
> > They are special because code generation assumes static symbols aren't
> > too far from the program counter.  The usual dynamic percpu area is
> > way high up in vmalloc area, so if we put static percpu allocations
> > there, they go out of range for module symbol relocations.
> > 
> > The reserved area has some issues.
> > 
> > 1. The area is not dynamically mapped, meaning that however much we
> >    reserve is hard allocated on boot for future module uses, so we
> >    don't can't increase it willy-nilly.
> > 
> > 2. There is no mechanism to adjust the size dynamically.  28k is just
> >    a number I pulled out of my ass after looking at some common
> >    configs like a decade ago, so it being low now isn't too
> >    surprising.  Provided that we can't make it run-time dynamic (and I
> >    can't think of a way to do that), the right thing to do would be
> >    sizing it during build with some buffer and allow it to be
> >    overridden boot time.  This is definitely doable.
> > 
> > BTW, ipmi's extra usage, 8k, is coming from the use of static SRCU.
> > Paul, that's quite a bit of percpu memory to reserve statically.
> > Would it be possible to make srcu_struct init dynamic so that it can
> > use the normal percpu_alloc?  That way, this problem can be completely
> > side-stepped and it only occupies percpu memory which tends to be
> > pretty expensive unless ipmi is actually initialized.
> 
> Yes, it is possible.  Just do something like this:
> 
> 	struct srcu_struct my_srcu_struct;
> 
> And before the first use of my_srcu_struct, do this:
> 
> 	init_srcu_struct(&my_srcu_struct);
> 
> This will result in alloc_percpu() being invoked to allocate the
> needed per-CPU space.
> 
> If my_srcu_struct is used in a module or some such, then to avoid memory
> leaks, after the last use of my_srcu_struct, do this:
> 
> 	cleanup_srcu_struct(&my_srcu_struct);
> 
> There are several places in the kernel that take this approach.
> 
> 							Thanx, Paul
