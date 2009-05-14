Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 242396B0096
	for <linux-mm@kvack.org>; Thu, 14 May 2009 14:15:08 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 4/6] PM/Hibernate: Rework shrinking of memory
Date: Thu, 14 May 2009 19:49:52 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905132356.39481.rjw@sisk.pl> <20090514094046.GF6417@elf.ucw.cz>
In-Reply-To: <20090514094046.GF6417@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905141949.53108.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-pm@lists.linux-foundation.org, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, nigel@tuxonice.net, rientjes@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 14 May 2009, Pavel Machek wrote:
> 
> > > > > The main point (I thought) was to remove shrink_all_memory().  Instead,
> > > > > we're retaining it and adding even more stuff?
> > > > 
> > > > The idea is that afterwards we can drop shrink_all_memory() once the
> > > > performance problem has been resolved.  Also, we now allocate memory for the
> > > > image using GFP_KERNEL instead of doing it with GFP_ATOMIC after freezing
> > > > devices.  I'd think that's an improvement?
> > > 
> > > Dunno.  GFP_KERNEL might attempt to do writeback/swapout/etc, which
> > > could be embarrassing if the devices are frozen.
> > 
> > They aren't, because the preallocation is done upfront, so once the OOM killer
> > has been taken care of, it's totally safe. :-)
> 
> As is GFP_ATOMIC. Except that GFP_KERNEL will cause catastrophic
> consequences when accounting goes wrong. (New kernel's idea of what is
> on disk will differ from what is _really_ on disk.)
> 
> If accounting is right, GFP_ATOMIC and GFP_KERNEL is equivalent.
> 
> If accounting is wrong, GFP_ATOMIC will fail with NULL, while
> GFP_KERNEL will do something bad.
> 
> I'd keep GFP_ATOMIC (or GFP_NOIO or similar). 

Repeating myself: with this and the next patch applied, we preallocate memory
for the image _before_ freezing devices and therefore it is safe to use
GFP_KERNEL, because the OOM killer has been taken care of by [3/6].

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
