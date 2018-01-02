Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7344C6B02C9
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 17:23:48 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i2so9951435pgq.8
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 14:23:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e7si81327plt.807.2018.01.02.14.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Jan 2018 14:23:45 -0800 (PST)
Date: Tue, 2 Jan 2018 14:23:41 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
Message-ID: <20180102222341.GB20405@bombadil.infradead.org>
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rao.shoaib@oracle.com
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org

On Tue, Jan 02, 2018 at 12:11:37PM -0800, rao.shoaib@oracle.com wrote:
> -#define kfree_rcu(ptr, rcu_head)					\
> -	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))

> +#define kfree_rcu(ptr, rcu_head_name)	\
> +	do { \
> +		typeof(ptr) __ptr = ptr;	\
> +		unsigned long __off = offsetof(typeof(*(__ptr)), \
> +						      rcu_head_name); \
> +		struct rcu_head *__rptr = (void *)__ptr + __off; \
> +		__kfree_rcu(__rptr, __off); \
> +	} while (0)

I feel like you're trying to help people understand the code better,
but using longer names can really work against that.  Reverting to
calling the parameter 'rcu_head' lets you not split the line:

+#define kfree_rcu(ptr, rcu_head)	\
+	do { \
+		typeof(ptr) __ptr = ptr;	\
+		unsigned long __off = offsetof(typeof(*(__ptr)), rcu_head); \
+		struct rcu_head *__rptr = (void *)__ptr + __off; \
+		__kfree_rcu(__rptr, __off); \
+	} while (0)

Also, I don't understand why you're bothering to create __ptr here.
I understand the desire to not mention the same argument more than once,
but you have 'ptr' twice anyway.

And it's good practice to enclose macro arguments in parentheses in case
the user has done something really tricksy like pass in "p + 1".

In summary, I don't see anything fundamentally better in your rewrite
of kfree_rcu().  The previous version is more succinct, and to my
mind, easier to understand.

> +void call_rcu_lazy(struct rcu_head *head, rcu_callback_t func)
> +{
> +	__call_rcu(head, func, &rcu_sched_state, -1, 1);
> +}

> -void kfree_call_rcu(struct rcu_head *head,
> -		    rcu_callback_t func)
> -{
> -	__call_rcu(head, func, rcu_state_p, -1, 1);
> -}

You've silently changed this.  Why?  It might well be the right change,
but it at least merits mentioning in the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
