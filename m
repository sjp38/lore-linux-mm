Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 82F6B6B0035
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 08:24:41 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so6723350eaj.7
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 05:24:40 -0800 (PST)
Received: from moutng.kundenserver.de (moutng.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id m49si70847006eeg.136.2014.01.03.05.24.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 05:24:36 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: ARM: mm: Could I change module space size or place modules in vmalloc area?
Date: Fri, 3 Jan 2014 14:23:55 +0100
References: <002001cf07a1$fd4bdc10$f7e39430$@lge.com> <201401031310.09930.arnd@arndb.de> <20140103122206.GK7383@n2100.arm.linux.org.uk>
In-Reply-To: <20140103122206.GK7383@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201401031423.55336.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, HyoJun Im <hyojun.im@lge.com>, linux-mm@kvack.org, Gioh Kim <gioh.kim@lge.com>

On Friday 03 January 2014, Russell King - ARM Linux wrote:
> On Fri, Jan 03, 2014 at 01:10:09PM +0100, Arnd Bergmann wrote:
> > Aside from the good comments that Russell made, I would remark that the
> > fact that you need multiple megabytes worth of modules indicates that you
> > are doing something wrong. Can you point to a git tree containing those
> > modules?
> 
> From the comments which have been made, one point that seems to have
> been identified is that if this module is first stripped and then
> loaded, it can load, but if it's unstripped, it's too big.  This sounds
> suboptimal to me - the debug info shouldn't be loaded into the kernel.

Reading the layout_and_allocate() function, that is probably the
intention already, and if something goes wrong there on ARM, it could be
fixed up in an arch specific module_frob_arch_sections() function.

> However, I guess there's bad interactions with module signing if you
> don't do this and the module was signed with the debug info present,
> so I don't think there's a good solution for this.

My point was another anyway: I can't think of any good reason why
you would end up with this many modules on any sane system. The only
cases I've seen so far are

- modules written in C++, with libstdc++ linked into the module
- a closed-source platform port hidden in a loadable module that
  contains all the device drivers and subsystems while ignoring the
  infrastructure we have in the kernel, and the possible legal
  implications.
- a bug in the module using large arrays that should just be
  dynamically allocated.
- device firmware statically linked into the module rather than
  loaded using request_firmware.

In each of these cases, the real answer is to fix the code they are
trying to load to do things in a more common way, especially if the
intention is to eventually merge the code upstream. It is of course
possible that they are indeed trying something valid, that's why
I asked to see the source code.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
