Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id E87576B0062
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 00:21:03 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so5883444ied.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 21:21:03 -0700 (PDT)
Date: Mon, 22 Oct 2012 21:20:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Major performance regressions in 3.7rc1/2
In-Reply-To: <20121022170452.cc8cc629.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1210222059120.1136@eggly.anvils>
References: <CAGPN=9Qx1JAr6CGO-JfoR2ksTJG_CLLZY_oBA_TFMzA_OSfiFg@mail.gmail.com> <20121022173315.7b0da762@ilfaris> <20121022214502.0fde3adc@ilfaris> <20121022170452.cc8cc629.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Julian Wollrath <julian.wollrath@stud.uni-goettingen.de>, Julian Wollrath <jwollrath@web.de>, Patrik Kullman <patrik.kullman@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Mon, 22 Oct 2012, Andrew Morton wrote:
> On Mon, 22 Oct 2012 21:45:02 +0200
> Julian Wollrath <julian.wollrath@stud.uni-goettingen.de> wrote:
> 
> > Hello,
> > 
> > seems like I found the other bad commit. Everything, which means
> > v3.7-rc*, works fine again with commit e6c509f85 (mm: use
> > clear_page_mlock() in page_remove_rmap()) and commit 957f822a0 (mm,
> > numa: reclaim from all nodes within reclaim distance) revoked.
> 
> Thanks.  Let's add some cc's.  Can you please describe your workload
> and some estimate of the slowdown?

I'm currently assuming that my clear_page_mlock() commit is innocent
of this: it went in just two before David's numa reclaim commit, and
I don't see how mine could have any such marked effect: I'm thinking
it was just a bisection hiccup that implicated it.

Julian (or Patrik), what do you find if you revert the numa reclaim
commit but leave in the clear_page_mlock commit?  Or vice versa.

Whereas David's numa reclaim distance commit does look suspicious to
me: as I read it (perhaps wrongly), zone_reclaim_mode would previously
have stayed 0 if all nodes were close or equidistant (e.g. CONFIG_NUMA=y
on a non-NUMA machine), but now it would be 1 in this case, invoking
zone_reclaim() more frequently than before.

Hugh

> 
> Patrik has also seen this and his description is
> 
> : I'm using an Asus Zenbook UX31E and have been installing all RCs in
> : hope of improving the Wireless and Touchpad functionality.
> : However, when trying 3.7 (rc1 and now rc2) I have major performance issues.
> : 
> : Easiest way to reproduce is to launch and play a game like Nexuiz,
> : where the computer will lag, stutter and freeze until the machine is
> : unresponsive within a couple of minutes.
> : But an easy workload like browsing will also cause lags when switching
> : tabs or redrawing a web page after a tab switch.
> : Basically 3.7 is unusable for this machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
