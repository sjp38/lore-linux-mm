Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0C3DF6B005C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 02:19:02 -0500 (EST)
Received: by yenq10 with SMTP id q10so1570183yen.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 23:19:02 -0800 (PST)
Date: Wed, 7 Dec 2011 23:18:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] vmalloc: purge_fragmented_blocks: Acquire spinlock
 before reading vmap_block
In-Reply-To: <CAFPAmTSJDXD1KNVBUz75yN_CeCT9f_+W9CaRNN467LSyCD+WXg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1112072314140.28419@chino.kir.corp.google.com>
References: <1323327732-30817-1-git-send-email-consul.kautuk@gmail.com> <alpine.DEB.2.00.1112072304010.28419@chino.kir.corp.google.com> <CAFPAmTSJDXD1KNVBUz75yN_CeCT9f_+W9CaRNN467LSyCD+WXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-1066931067-1323328473=:28419"
Content-ID: <alpine.DEB.2.00.1112072314460.28419@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Minchan Kim <minchan.kim@gmail.com>, David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-1066931067-1323328473=:28419
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1112072314461.28419@chino.kir.corp.google.com>

On Thu, 8 Dec 2011, Kautuk Consul wrote:

> > In the original code, if the if-clause fails, the lock is only then taken
> > and the exact same test occurs again while protected. A If the test now
> > fails, the lock is immediately dropped. A A branch here is faster than a
> > contented spinlock.
> 
> But, if there is some concurrent change happening to vb->free and
> vb->dirty, dont you think
> that it will continue and then go to the next vmap_block ?
> 
> If yes, then it will not be put into the purge list.
> 

That's intentional as an optimization, we don't care if 
vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS 
would speculatively be true after we grab vb->lock, we'll have to purge it 
next time instead.  We certainly don't want to grab vb->lock for blocks 
that aren't candidates, so this optimization is a singificant speedup.
--397155492-1066931067-1323328473=:28419--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
