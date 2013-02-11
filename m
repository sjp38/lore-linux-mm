Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 442706B0005
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 17:13:38 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id hz1so3237218pad.38
        for <linux-mm@kvack.org>; Mon, 11 Feb 2013 14:13:37 -0800 (PST)
Date: Mon, 11 Feb 2013 14:13:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 11/11] ksm: stop hotremove lockdep warning
In-Reply-To: <20130208194510.65fadd37@thinkpad.boeblingen.de.com>
Message-ID: <alpine.LNX.2.00.1302111410290.1174@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251808120.29196@eggly.anvils> <20130208194510.65fadd37@thinkpad.boeblingen.de.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 8 Feb 2013, Gerald Schaefer wrote:
> On Fri, 25 Jan 2013 18:10:18 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > Complaints are rare, but lockdep still does not understand the way
> > ksm_memory_callback(MEM_GOING_OFFLINE) takes ksm_thread_mutex, and
> > holds it until the ksm_memory_callback(MEM_OFFLINE): that appears
> > to be a problem because notifier callbacks are made under down_read
> > of blocking_notifier_head->rwsem (so first the mutex is taken while
> > holding the rwsem, then later the rwsem is taken while still holding
> > the mutex); but is not in fact a problem because mem_hotplug_mutex
> > is held throughout the dance.
> > 
> > There was an attempt to fix this with mutex_lock_nested(); but if that
> > happened to fool lockdep two years ago, apparently it does so no
> > longer.
> > 
> > I had hoped to eradicate this issue in extending KSM page migration
> > not to need the ksm_thread_mutex.  But then realized that although
> > the page migration itself is safe, we do still need to lock out ksmd
> > and other users of get_ksm_page() while offlining memory - at some
> > point between MEM_GOING_OFFLINE and MEM_OFFLINE, the struct pages
> > themselves may vanish, and get_ksm_page()'s accesses to them become a
> > violation.
> > 
> > So, give up on holding ksm_thread_mutex itself from MEM_GOING_OFFLINE
> > to MEM_OFFLINE, and add a KSM_RUN_OFFLINE flag, and
> > wait_while_offlining() checks, to achieve the same lockout without
> > being caught by lockdep. This is less elegant for KSM, but it's more
> > important to keep lockdep useful to other users - and I apologize for
> > how long it took to fix.
> 
> Thanks a lot for the patch! I verified that it fixes the lockdep warning
> that we got on memory hotremove.
> 
> > 
> > Reported-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> > Signed-off-by: Hugh Dickins <hughd@google.com>

Thank you for reporting and testing and reporting back:
sorry again for taking so long to fix it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
