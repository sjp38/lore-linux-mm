Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 359066B026A
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:26:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 142so310952wmt.1
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:26:51 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id d9-v6si15165822wrg.6.2018.05.04.09.26.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 09:26:50 -0700 (PDT)
Date: Fri, 4 May 2018 17:26:40 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Introduce atomic_dec_and_lock_irqsave()
Message-ID: <20180504162640.GH30522@ZenIV.linux.org.uk>
References: <20180504154533.8833-1-bigeasy@linutronix.de>
 <20180504155446.GP12217@hirez.programming.kicks-ass.net>
 <20180504160726.ikotgmd5fbix7b6b@linutronix.de>
 <20180504162102.GQ12217@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504162102.GQ12217@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

On Fri, May 04, 2018 at 06:21:02PM +0200, Peter Zijlstra wrote:
> On Fri, May 04, 2018 at 06:07:26PM +0200, Sebastian Andrzej Siewior wrote:
> 
> > do you intend to kill refcount_dec_and_lock() in the longterm?
> 
> You meant to say atomic_dec_and_lock() ? Dunno if we ever get there, but
> typically dec_and_lock is fairly refcounty, but I suppose it is possible
> to have !refcount users, in which case we're eternally stuck with it.

Yes, there are - consider e.g.

void iput(struct inode *inode)
{ 
        if (!inode)
                return;
        BUG_ON(inode->i_state & I_CLEAR);
retry:
        if (atomic_dec_and_lock(&inode->i_count, &inode->i_lock)) {

inode->i_count sure as hell isn't refcount_t fodder...
