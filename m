Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DFA36B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 17:06:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so10764460wme.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 14:06:41 -0700 (PDT)
Received: from mail-lf0-x236.google.com (mail-lf0-x236.google.com. [2a00:1450:4010:c07::236])
        by mx.google.com with ESMTPS id m73si1302231lfe.142.2016.06.22.14.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 14:06:40 -0700 (PDT)
Received: by mail-lf0-x236.google.com with SMTP id l188so81650621lfe.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 14:06:39 -0700 (PDT)
Date: Thu, 23 Jun 2016 00:06:36 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: JITs and 52-bit VA
Message-ID: <20160622210636.GE2045@uranus.lan>
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org>
 <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
 <20160622191843.GA2045@uranus.lan>
 <CALCETrUH0uxfASkHkVVJhuFkEXvuVXhLc-Ed=Utn9E5vzx=Vzg@mail.gmail.com>
 <576AED88.6040805@intel.com>
 <20160622201754.GD2045@uranus.lan>
 <576AF804.3090901@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <576AF804.3090901@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Christopher Covington <cov@codeaurora.org>, Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>

On Wed, Jun 22, 2016 at 01:41:40PM -0700, Dave Hansen wrote:
> >>
> >> Yeah, cgroups don't make a lot of sense.
> >>
> >> On x86, the 48-bit virtual address is even hard-coded in the ABI[1].  So
> >> we can't change *any* program's layout without either breaking the ABI
> >> or having it opt in.
> >>
> >> But, we're also lucky to only have one VA layout since day one.
> >>
> >> 1. www.x86-64.org/documentation/abi.pdf - a??... Therefore, conforming
> >> processes may only use addresses from 0x00000000 00000000 to 0x00007fff
> >> ffffffff .a??
> > 
> > Yes, but noone forces you to write conforming programs ;)
> > After all while hw allows you to run VA with bits > than
> > 48 it's fine, all side effects of breaking abi is up to
> > program author (iirc on x86 there is up to 52 bits on
> > hw level allowed, don't have specs under my hands?)
> 
> My point was that you can't restrict the vaddr space without breaking
> the ABI because apps expect to be able to use 0x00007fffffffffff.  You
> also can't extend the vaddr space because apps can *also* expect that
> there are no valid vaddrs past 0x00007fffffffffff.
> 
> So, whatever happens here, at least on x86, we can't do anything to the
> vaddr space without it being an opt-in for *each* *app*.

The main problem is not abi on its own, because the abi stands for
"conforming" programs, if this feature will be controlled by some
flag in mm struct (or cgroup, of whatever) it won't affect regular
programs which follow the abi. But the problem is that if we allow
this wide addresses right now may not we clash with future abi extensions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
