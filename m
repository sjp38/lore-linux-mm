Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10C44280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 10:25:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c6so77299479pfj.5
        for <linux-mm@kvack.org>; Sat, 20 May 2017 07:25:55 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c188si11554954pfb.309.2017.05.20.07.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 May 2017 07:25:54 -0700 (PDT)
Date: Sat, 20 May 2017 10:25:50 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] slub/memcg: Cure the brainless abuse of sysfs
 attributes
Message-ID: <20170520102550.2f793194@gandalf.local.home>
In-Reply-To: <20170520131645.GA5058@infradead.org>
References: <alpine.DEB.2.20.1705201244540.2255@nanos>
	<20170520131645.GA5058@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>

On Sat, 20 May 2017 06:16:45 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sat, May 20, 2017 at 12:52:03PM +0200, Thomas Gleixner wrote:
> > This should be rewritten proper by adding a propagate() callback to those
> > slub_attributes which must be propagated and avoid that insane conversion
> > to and from ASCII
> 
> Exactly..
> 
> >, but that's too large for a hot fix.
> 
> What made this such a hot fix?  Looks like this crap has been in
> for quite a while.

It can cause a deadlock with get_online_cpus() that has been uncovered
by recent cpu hotplug and lockdep changes that Thomas and Peter have
been doing.

[  102.567308]  Possible unsafe locking scenario:
[  102.567308] 
[  102.574846]        CPU0                    CPU1
[  102.580148]        ----                    ----
[  102.585421]   lock(cpu_hotplug.lock);
[  102.589808]                                lock(slab_mutex);
[  102.596166]                                lock(cpu_hotplug.lock);
[  102.603028]   lock(slab_mutex);
[  102.606846] 
[  102.606846]  *** DEADLOCK ***

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
