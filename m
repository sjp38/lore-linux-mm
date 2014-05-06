Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7E16B0037
	for <linux-mm@kvack.org>; Tue,  6 May 2014 13:03:35 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id q8so4675500lbi.13
        for <linux-mm@kvack.org>; Tue, 06 May 2014 10:03:34 -0700 (PDT)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id bd6si2206240lbc.110.2014.05.06.10.03.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 10:03:33 -0700 (PDT)
Received: by mail-lb0-f180.google.com with SMTP id p9so2879600lbv.11
        for <linux-mm@kvack.org>; Tue, 06 May 2014 10:03:32 -0700 (PDT)
Date: Tue, 6 May 2014 21:03:31 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] mm: pgtable -- Require X86_64 for soft-dirty tracker
Message-ID: <20140506170331.GQ28248@moon>
References: <20140425081030.185969086@openvz.org>
 <20140425082042.848656782@openvz.org>
 <53690D97.50401@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53690D97.50401@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, mgorman@suse.de, mingo@kernel.org, steven@uplinklabs.net, riel@redhat.com, david.vrabel@citrix.com, akpm@linux-foundation.org, peterz@infradead.org, xemul@parallels.com

On Tue, May 06, 2014 at 09:28:07AM -0700, H. Peter Anvin wrote:
> On 04/25/2014 01:10 AM, Cyrill Gorcunov wrote:
> > Tracking dirty status on 2 level pages requires very ugly macros
> > and taking into account how old the machines who can operate
> > without PAE mode only are, lets drop soft dirty tracker from
> > them for code simplicity (note I can't drop all the macros
> > from 2 level pages by now since _PAGE_BIT_PROTNONE and
> > _PAGE_BIT_FILE are still used even without tracker).
> > 
> > Linus proposed to completely rip off softdirty support on
> > x86-32 (even with PAE) and since for CRIU we're not planning
> > to support native x86-32 mode, lets do that.
> > 
> > (Softdirty tracker is relatively new feature which mostly used
> >  by CRIU so I don't expect if such API change would cause problems
> >  on userspace).
> 
> I have to wonder which one is more likely to actually matter on whatever
> legacy 32-bit are going to remain.  This pretty much comes down to what
> kind of advanced features are going to matter in deep embedded
> applications in the future: checkpoint/restart or NUMA.  My guess is
> that it is actually checkpoint/restart...
> 
> How much does it actually simplify to leave this feature in for PAE?  I
> could care less about non-PAE... NX has pretty much killed that off cold.

At the current state -- not much I would say. Initially the idea was to
drop x86-32 and use page-soft-dirty-bit (ie 11) inside swap entries dropping
off page-swap-soft-dirty bit completely, this would simplify all the things
but eventually I realized that if I do so the number of maximum swap entries
will get more shrinked which is inacceptable I think.

Thus, currently (ie even with this patches) we can work on x86-32+PAE but
desided to drop x86-32 completely to simplify things in future.

Peter, deep embedded applications I guess would be working on systems
with really small amount of memory installed in a system I suppose and
I doubt if they would need c/r?

If we deside to leave x86-32+PAE then don't apply this patch, I will
need to update it, (The first patch is safe to apply anyway).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
