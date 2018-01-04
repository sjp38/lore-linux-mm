Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 028296B0500
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 18:47:03 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id s6so2148110qke.3
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 15:47:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s72si1954157qka.228.2018.01.04.15.47.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 15:47:01 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w04NjqKY032974
	for <linux-mm@kvack.org>; Thu, 4 Jan 2018 18:47:00 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f9vy8ahvd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Jan 2018 18:47:00 -0500
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 4 Jan 2018 18:46:59 -0500
Date: Thu, 4 Jan 2018 15:47:32 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
Reply-To: paulmck@linux.vnet.ibm.com
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
 <20180102222341.GB20405@bombadil.infradead.org>
 <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
 <20180104013807.GA31392@tardis>
 <be1abd24-56c8-45bc-fecc-3f0c5b978678@oracle.com>
 <64ca3929-4044-9393-a6ca-70c0a2589a35@oracle.com>
 <20180104214658.GA20740@bombadil.infradead.org>
 <3e4ea0b9-686f-7e36-d80c-8577401517e2@oracle.com>
 <20180104231307.GA794@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180104231307.GA794@bombadil.infradead.org>
Message-Id: <20180104234732.GM9671@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Rao Shoaib <rao.shoaib@oracle.com>, Boqun Feng <boqun.feng@gmail.com>, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org

On Thu, Jan 04, 2018 at 03:13:07PM -0800, Matthew Wilcox wrote:
> On Thu, Jan 04, 2018 at 02:18:50PM -0800, Rao Shoaib wrote:
> > > > > > +#define kfree_rcu(ptr, rcu_head_name) \
> > > > > > +    do { \
> > > > > > +        typeof(ptr) __ptr = ptr;    \
> > > > > > +        unsigned long __off = offsetof(typeof(*(__ptr)), \
> > > > > > +                              rcu_head_name); \
> > > > > > +        struct rcu_head *__rptr = (void *)__ptr + __off; \
> > > > > > +        __kfree_rcu(__rptr, __off); \
> > > > > > +    } while (0)
> > > > > why do you want to open code this?
> > > But why are you changing this macro at all?  If it was to avoid the
> > > double-mention of "ptr", then you haven't done that.
> > I have -- I do not get the error because ptr is being assigned only one. If
> > you have a better way than let me know and I will be happy to make the
> > change.
> 
> But look at the original:
> 
> #define kfree_rcu(ptr, rcu_head)                                        \
>         __kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
>                        ^^^                                ^^^
> 
> versus your version:
> 
> +#define kfree_rcu(ptr, rcu_head_name) \
> +    do { \
> +        typeof(ptr) __ptr = ptr;    \
>                 ^^^          ^^^
> +        unsigned long __off = offsetof(typeof(*(__ptr)), \
> +                              rcu_head_name); \
> +        struct rcu_head *__rptr = (void *)__ptr + __off; \
> +        __kfree_rcu(__rptr, __off); \
> +    } while (0)
> 
> I don't see the difference.

I was under the impression that typeof did not actually evaluate its
argument, but rather only returned its type.  And there are a few macros
with this pattern in mainline.

Or am I confused about what typeof does?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
