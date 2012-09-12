Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 307FF6B00AE
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 05:22:03 -0400 (EDT)
Date: Wed, 12 Sep 2012 11:22:12 +0200
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: iwl3945: order 5 allocation during ifconfig up; vm problem?
Message-ID: <20120912092211.GA3146@redhat.com>
References: <20120909213228.GA5538@elf.ucw.cz>
 <alpine.DEB.2.00.1209091539530.16930@chino.kir.corp.google.com>
 <20120910111113.GA25159@elf.ucw.cz>
 <20120911162536.bd5171a1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120911162536.bd5171a1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Machek <pavel@ucw.cz>, David Rientjes <rientjes@google.com>, linux-wireless@vger.kernel.org, johannes.berg@intel.com, wey-yi.w.guy@intel.com, ilw@linux.intel.com, Andrew Morton <akpm@osdl.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 11, 2012 at 04:25:36PM -0700, Andrew Morton wrote:
> On Mon, 10 Sep 2012 13:11:13 +0200
> Pavel Machek <pavel@ucw.cz> wrote:
> 
> > On Sun 2012-09-09 15:40:55, David Rientjes wrote:
> > > On Sun, 9 Sep 2012, Pavel Machek wrote:
> > > 
> > > > On 3.6.0-rc2+, I tried to turn on the wireless, but got
> > > > 
> > > > root@amd:~# ifconfig wlan0 10.0.0.6 up
> > > > SIOCSIFFLAGS: Cannot allocate memory
> > > > SIOCSIFFLAGS: Cannot allocate memory
> > > > root@amd:~# 
> > > > 
> > > > It looks like it uses "a bit too big" allocations to allocate
> > > > firmware...? Order five allocation....
> > > > 
> > > > Hmm... then I did "echo 3  > /proc/sys/vm/drop_caches" and now the
> > > > network works. Is it VM problem that it failed to allocate memory when
> > > > it was freeable?
> > > > 
> > > 
> > > Do you have CONFIG_COMPACTION enabled?
> > 
> > Yes:
> > 
> > pavel@amd:/data/l/linux-good$ zgrep CONFIG_COMPACTION /proc/config.gz 
> > CONFIG_COMPACTION=y
> 
> Asking for a 256k allocation is pretty crazy - this is an operating
> system kernel, not a userspace application.
> 
> I'm wondering if this is due to a recent change, but I'm having trouble
> working out where the allocation call site is.

iwlwifi/iwlegacy do such kind of allocation for ages, since iwlwifi driver
inclusion in 2.6.24 (however firmware was smaller then).

I can fix that in iwlegacy similar as Johannes did it in iwlwifi, but this
actually seems to be allocator regression. We use GFP_KERNEL allocation,
kernel can wait for free memory and/or swap out pages, I do not understand
why this fail.

Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
