Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 46A0B6B00E8
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 06:01:44 -0400 (EDT)
Date: Fri, 10 Jun 2011 11:01:39 +0100
From: Tim Deegan <Tim.Deegan@citrix.com>
Subject: Re: [Xen-devel] Possible shadow bug
Message-ID: <20110610100139.GG5098@whitby.uk.xensource.com>
References: <4DE66BEB.7040502@redhat.com>
 <BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
 <4DE8D50F.1090406@redhat.com>
 <BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>
 <4DEE26E7.2060201@redhat.com>
 <20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com>
 <4DF0801F.9050908@redhat.com>
 <alpine.DEB.2.00.1106091311530.12963@kaball-desktop>
 <20110609150133.GF5098@whitby.uk.xensource.com>
 <4DF0F90D.4010900@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
In-Reply-To: <4DF0F90D.4010900@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: xen-devel@lists.xensource.com, Keir Fraser <keir@xen.org>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, "containers@lists.linux-foundation.org" <containers@lists.linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Keir Fraser <keir.xen@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>

Hi, 

At 18:47 +0200 on 09 Jun (1307645229), Igor Mammedov wrote:
> It's rhel5.6 xen. I've tried to test on SLES 11 that has 4.0.1 xen, however
> wasn't able to reproduce problem. (I'm not sure if hap was turned
> off in this case). More detailed info can be found at RHBZ#700565

The best way to be sure whether HAP is in use is to connect to the
serial line, hit ^A^A^A to switch input to Xen, and hit 'q' to dump
per-domain state.  The printout for the guest domain should either say 
"paging assistance: shadow refcounts translate external"
or 
"paging assistance: hap refcounts translate external".

(If you don't have serial you can get the same info by running 
"xm debug-keys q" and then "xm dmesg" to read the output.)

> >you're willing to try recompiling Xen with some small patches that
> >disable the "cleverer" parts of the shadow pagetable code that might
> >indicate something.  (Of course, it might just change the timing to
> >obscure a real linux bug too.)
> >
> Haven't got to this part yet. But looks like it's the only option left.

Actually, looking at the disassembly you posted, it looks more like it
might be an emulator bug in Xen; if Xen finds itself emulating the IMUL
instruction and either gets the logic wrong or does the memory access
wrong, it could cause that failure.  And one reason that Xen emulates
instructions is if the memory operand is on a pagetable that's shadowed
(which might be a page that was recently a pagetable). 

ISTR that even though the RHEL xen reports a 3.0.x version it has quite
a lot of backports in it.  Does it have this patch?
http://hg.uk.xensource.com/xen-3.1-testing.hg/rev/e8fca4c42d05

Cheers,

Tim.

-- 
Tim Deegan <Tim.Deegan@citrix.com>
Principal Software Engineer, Xen Platform Team
Citrix Systems UK Ltd.  (Company #02937203, SL9 0BG)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
