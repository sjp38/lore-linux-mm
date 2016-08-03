Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CFB36B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 01:16:56 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so333423935pab.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 22:16:56 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id 19si6931713pft.165.2016.08.02.22.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 22:16:55 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id y134so13875020pfg.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 22:16:55 -0700 (PDT)
Message-ID: <1470201421.5034.1.camel@gmail.com>
Subject: Re: [memcg:auto-latest 238/243]
 include/linux/compiler-gcc.h:243:38: error: impossible constraint in 'asm'
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 03 Aug 2016 15:17:01 +1000
In-Reply-To: <CAOSf1CG1OB+tQx=u5C5RSEFydPy4Rsa04L=Cwm4PfENWJa658A@mail.gmail.com>
References: <201607300506.W5FnCSrY%fengguang.wu@intel.com>
	 <20160731121125.GA29775@dhcp22.suse.cz>
	 <20160801110859.GC13544@dhcp22.suse.cz>
	 <35a0878d-84bd-ad93-8810-23c861ed464e@suse.cz>
	 <CAOSf1CG1OB+tQx=u5C5RSEFydPy4Rsa04L=Cwm4PfENWJa658A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oliver <oohall@gmail.com>, Martin =?UTF-8?Q?Li=C5=A1ka?= <mliska@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>, kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, Jason Baron <jbaron@akamai.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2016-08-01 at 22:41 +1000, oliver wrote:
> On Mon, Aug 1, 2016 at 9:27 PM, Martin LiA!ka <mliska@suse.cz> wrote:
> >A 
> > On 08/01/2016 01:09 PM, Michal Hocko wrote:
> > >A 
> > > [CC our gcc guy - I guess he has some theory for this]
> > >A 
> > > On Sun 31-07-16 14:11:25, Michal Hocko wrote:
> > > >A 
> > > > It seems that this has been already reported and Jason has noticed [1] that
> > > > the problem is in the disabled optimizations:
> > > >A 
> > > > $ grep CRYPTO_DEV_UX500_DEBUG .config
> > > > CONFIG_CRYPTO_DEV_UX500_DEBUG=y
> > > >A 
> > > > if I disable this particular option the code compiles just fine. I have
> > > > no idea what is wrong about the code but it seems to depend on
> > > > optimizations enabled which sounds a bit scrary...
> > > >A 
> > > > [1] http://www.spinics.net/lists/linux-mm/msg109590.html
> > Hi.
> >A 
> > The difference is that w/o any optimization level, GCC doesn't make %c0 an
> > intermediate integer operand [1] (see description of "i" constraint).
> We recently hit a similar problem on ppc where the compiler couldn't
> satisfy an "i" when it was wrapped in an function and optimisations
> were disabled. The fix[1] was to change the function signature so that
> it's arguments were explicitly const. I don't know enough about gcc to
> tell if that behaviour is arch specific or not, but it's worth trying.
>A 
> Oliver
>A 
> [1] https://lists.ozlabs.org/pipermail/skiboot/2016-July/004061.html

Yes, the way I solved the issue was to look at the RTL and provide
hints to the compiler that the passed argument was a constant and it
needed to be passed as such to the instruction

I would suggest just looking at the RTL and figuring out why the constraints
break

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
