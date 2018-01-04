Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA25B6B030E
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 16:47:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a9so228148pgf.12
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 13:47:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e4si2879972pln.445.2018.01.04.13.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Jan 2018 13:47:02 -0800 (PST)
Date: Thu, 4 Jan 2018 13:46:58 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
Message-ID: <20180104214658.GA20740@bombadil.infradead.org>
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
 <20180102222341.GB20405@bombadil.infradead.org>
 <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
 <20180104013807.GA31392@tardis>
 <be1abd24-56c8-45bc-fecc-3f0c5b978678@oracle.com>
 <64ca3929-4044-9393-a6ca-70c0a2589a35@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <64ca3929-4044-9393-a6ca-70c0a2589a35@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: Boqun Feng <boqun.feng@gmail.com>, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org

On Thu, Jan 04, 2018 at 01:27:49PM -0800, Rao Shoaib wrote:
> On 01/04/2018 12:35 PM, Rao Shoaib wrote:
> > As far as your previous comments are concerned, only the following one
> > has not been addressed. Can you please elaborate as I do not understand
> > the comment. The code was expanded because the new macro expansion check
> > fails. Based on Matthew Wilcox's comment I have reverted rcu_head_name
> > back to rcu_head.
> It turns out I did not remember the real reason for the change. With the
> macro rewritten, using rcu_head as a macro argument does not work because it
> conflicts with the name of the type 'struct rcu_head' used in the macro. I
> have renamed the macro argument to rcu_name.
> 
> Shoaib
> > 
> > > +#define kfree_rcu(ptr, rcu_head_name) \
> > > +    do { \
> > > +        typeof(ptr) __ptr = ptr;    \
> > > +        unsigned long __off = offsetof(typeof(*(__ptr)), \
> > > +                              rcu_head_name); \
> > > +        struct rcu_head *__rptr = (void *)__ptr + __off; \
> > > +        __kfree_rcu(__rptr, __off); \
> > > +    } while (0)
> > 
> > why do you want to open code this?

But why are you changing this macro at all?  If it was to avoid the
double-mention of "ptr", then you haven't done that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
