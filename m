Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19AEF6B04FE
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 18:13:12 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id m39so1933017plg.19
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 15:13:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 69si2983817plc.769.2018.01.04.15.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Jan 2018 15:13:11 -0800 (PST)
Date: Thu, 4 Jan 2018 15:13:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
Message-ID: <20180104231307.GA794@bombadil.infradead.org>
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
 <20180102222341.GB20405@bombadil.infradead.org>
 <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
 <20180104013807.GA31392@tardis>
 <be1abd24-56c8-45bc-fecc-3f0c5b978678@oracle.com>
 <64ca3929-4044-9393-a6ca-70c0a2589a35@oracle.com>
 <20180104214658.GA20740@bombadil.infradead.org>
 <3e4ea0b9-686f-7e36-d80c-8577401517e2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3e4ea0b9-686f-7e36-d80c-8577401517e2@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: Boqun Feng <boqun.feng@gmail.com>, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org

On Thu, Jan 04, 2018 at 02:18:50PM -0800, Rao Shoaib wrote:
> > > > > +#define kfree_rcu(ptr, rcu_head_name) \
> > > > > +    do { \
> > > > > +        typeof(ptr) __ptr = ptr;    \
> > > > > +        unsigned long __off = offsetof(typeof(*(__ptr)), \
> > > > > +                              rcu_head_name); \
> > > > > +        struct rcu_head *__rptr = (void *)__ptr + __off; \
> > > > > +        __kfree_rcu(__rptr, __off); \
> > > > > +    } while (0)
> > > > why do you want to open code this?
> > But why are you changing this macro at all?  If it was to avoid the
> > double-mention of "ptr", then you haven't done that.
> I have -- I do not get the error because ptr is being assigned only one. If
> you have a better way than let me know and I will be happy to make the
> change.

But look at the original:

#define kfree_rcu(ptr, rcu_head)                                        \
        __kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
                       ^^^                                ^^^

versus your version:

+#define kfree_rcu(ptr, rcu_head_name) \
+    do { \
+        typeof(ptr) __ptr = ptr;    \
                ^^^          ^^^
+        unsigned long __off = offsetof(typeof(*(__ptr)), \
+                              rcu_head_name); \
+        struct rcu_head *__rptr = (void *)__ptr + __off; \
+        __kfree_rcu(__rptr, __off); \
+    } while (0)

I don't see the difference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
