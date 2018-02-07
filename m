Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDE0A6B0344
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 12:09:53 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a9so702720pff.0
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 09:09:53 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 28si1394377pfl.53.2018.02.07.09.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 09:09:52 -0800 (PST)
Date: Wed, 7 Feb 2018 12:09:49 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180207120949.62fa815f@gandalf.local.home>
In-Reply-To: <alpine.DEB.2.20.1802071040570.22131@nuc-kabylake>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
	<20180207021703.GC3617@linux.vnet.ibm.com>
	<20180207042334.GA16175@bombadil.infradead.org>
	<alpine.DEB.2.20.1802071040570.22131@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Wed, 7 Feb 2018 10:47:02 -0600 (CST)
Christopher Lameter <cl@linux.com> wrote:

> On Tue, 6 Feb 2018, Matthew Wilcox wrote:
> 
> > Personally, I would like us to rename kvfree() to just free(), and have
> > malloc(x) be an alias to kvmalloc(x, GFP_KERNEL), but I haven't won that
> > fight yet.  
> 
> Maybe lets implement malloc(), free() and realloc() in the kernel to be
> consistent with user space use as possible? Only use the others
> allocation variants for special cases.

They would need to drop the GFP part and default to GFP_KERNEL.

> 
> So malloc would check allocation sizes and if < 2* PAGE_SIZE use kmalloc()
> otherwise vmalloc().

Please no, I hate subtle internal decisions like this. It makes
debugging much more difficult, when allocating dynamic sized variables.
When something works at one size but not the other.

-- Steve

> 
> free() would free anything you give it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
